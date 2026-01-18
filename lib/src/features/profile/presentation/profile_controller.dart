import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/offline_service.dart';
import 'dart:io';

// State class
class ProfileState {
  final bool isLoading;
  final Map<String, dynamic>? data;
  final String? errorMessage;
  final bool isSuccess;

  const ProfileState({
    this.isLoading = false,
    this.data,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    Map<String, dynamic>? data,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      final offlineService = ref.watch(offlineServiceProvider);
      return ProfileController(offlineService);
    });

class ProfileController extends StateNotifier<ProfileState> {
  final OfflineService _offlineService;

  ProfileController(this._offlineService) : super(ProfileState());

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true, isSuccess: false);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User not logged in',
        );
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (profile['role'] == 'patient') {
        final patientData = await Supabase.instance.client
            .from('patients')
            .select()
            .eq('user_id', user.id)
            .maybeSingle(); // might be null if incomplete

        profile['patient_data'] = patientData;
      }

      state = state.copyWith(isLoading: false, data: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? specialization, // Doctor only
    // Patient params
    DateTime? hpht,
    DateTime? birthDate,
    String? address,
    String? medicalNote,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        isSuccess: false,
      );
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final currentData = state.data ?? {};
      final role = currentData['role'];

      // 1. Update Profile (Base)
      await Supabase.instance.client
          .from('profiles')
          .update({
            'full_name': fullName,
            if (role == 'doctor' && specialization != null)
              'specialization': specialization,
          })
          .eq('id', user.id);

      // 2. Update/Insert Patient Data
      if (role == 'patient') {
        final patientData = {
          'user_id': user.id,
          'name': fullName, // Sync name
          if (hpht != null) 'hpht': hpht.toIso8601String(),
          if (birthDate != null) 'birth_date': birthDate.toIso8601String(),
          if (address != null) 'address': address,
          if (medicalNote != null) 'medical_note': medicalNote,
        };

        final existing = currentData['patient_data'];
        if (existing != null) {
          await Supabase.instance.client
              .from('patients')
              .update(patientData)
              .eq('id', existing['id']);
        } else {
          await Supabase.instance.client.from('patients').insert(patientData);
        }
      }

      // Reload to get fresh state
      await loadProfile();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    try {
      // Check if online
      if (!_offlineService.isOnline) {
        throw Exception("You are offline. Cannot upload avatar.");
      }

      state = state.copyWith(isLoading: true, errorMessage: null);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      // Upload file to Supabase Storage
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            fileName,
            File(filePath),
            fileOptions: const FileOptions(upsert: true),
          );

      // Get Public URL
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update Profile
      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      // Reload
      await loadProfile();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

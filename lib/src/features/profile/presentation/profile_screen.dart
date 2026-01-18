import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _specController = TextEditingController(); // Doctor
  final _hphtController = TextEditingController(); // Patient
  final _addressController = TextEditingController(); // Patient
  final _notesController = TextEditingController(); // Patient

  DateTime? _hphtDate;
  // Birth Date not yet implemented in UI

  @override
  void initState() {
    super.initState();
    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  // Effect to populate controllers when data loads
  void _populateControllers(Map<String, dynamic> data) {
    if (_nameController.text.isEmpty)
      _nameController.text = data['full_name'] ?? '';

    if (data['role'] == 'doctor') {
      if (_specController.text.isEmpty && data['specialization'] != null) {
        _specController.text = data['specialization'];
      }
    } else if (data['role'] == 'patient') {
      final pData = data['patient_data'];
      if (pData != null) {
        if (_addressController.text.isEmpty)
          _addressController.text = pData['address'] ?? '';
        if (_notesController.text.isEmpty)
          _notesController.text = pData['medical_note'] ?? '';

        if (_hphtDate == null && pData['hpht'] != null) {
          _hphtDate = DateTime.parse(pData['hpht']);
          _hphtController.text = DateFormat('yyyy-MM-dd').format(_hphtDate!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    // Listen for success
    ref.listen(profileControllerProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully')),
        );
        // Invalidate dashboard provider so it refreshes too
        // ref.invalidate(userProfileProvider); // If imported
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (next.data != null &&
          (prev?.data == null || prev?.isLoading == true)) {
        _populateControllers(next.data!);
      }
    });

    if (state.isLoading && state.data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = state.data;
    if (data == null)
      return const Scaffold(
        body: Center(child: Text("Failed to load profile")),
      );

    final role = data['role'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.pink.shade100,
                      backgroundImage: data['avatar_url'] != null
                          ? NetworkImage(data['avatar_url'])
                          : null,
                      child: data['avatar_url'] == null
                          ? Text(
                              (data['full_name'] ?? 'U')[0]
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Read Only
              _buildReadOnlyField("Email", data['email']),
              const SizedBox(height: 16),
              _buildReadOnlyField("Role", role.toString().toUpperCase()),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 16),

              const Text(
                "Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              if (role == 'doctor') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specController,
                  decoration: const InputDecoration(
                    labelText: "Specialization",
                    border: OutlineInputBorder(),
                    hintText: "e.g. Obstetrician",
                  ),
                ),
              ],

              if (role == 'patient') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hphtController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "HPHT (Last Period)",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _hphtDate ?? DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _hphtDate = date;
                        _hphtController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: "Medical Notes",
                    border: OutlineInputBorder(),
                    hintText: "Allergies, history, etc.",
                  ),
                  maxLines: 3,
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _save,
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Save Changes"),
                ),
              ),

              // Sign Out Button (Redundant with dashboard but good to have)
              // const SizedBox(height: 16),
              // Center(child: TextButton(onPressed: (){}, child: Text("Sign Out", style: TextStyle(color: Colors.red))))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          fullName: _nameController.text,
          specialization: _specController.text,
          hpht: _hphtDate,
          address: _addressController.text,
          medicalNote: _notesController.text,
        );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      await ref
          .read(profileControllerProvider.notifier)
          .uploadAvatar(pickedFile.path);
    }
  }
}

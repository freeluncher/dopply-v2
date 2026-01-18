import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class BasicPatientProfileScreen extends ConsumerStatefulWidget {
  const BasicPatientProfileScreen({super.key});

  @override
  ConsumerState<BasicPatientProfileScreen> createState() =>
      _BasicPatientProfileScreenState();
}

class _BasicPatientProfileScreenState
    extends ConsumerState<BasicPatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hphtController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _hphtDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('To start monitoring, we need a few details.'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hphtController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'HPHT (Last Period Date)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser!;

      await Supabase.instance.client.from('patients').insert({
        'user_id': user.id,
        'name': _nameController.text,
        'hpht': _hphtDate!.toIso8601String(),
        // birth_date defaults null or add field
      });

      if (mounted) {
        ref.invalidate(
          userProfileProvider,
        ); // Force dashboard to reload profile data
        context.pop(); // Return to dashboard or whereever
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

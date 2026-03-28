import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regionController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _hasITKnowledge = false;
  bool _obscureText = true;
  bool _isLoading = false;

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    // Determine role based on IT Knowledge
    final role = _hasITKnowledge ? 'consultant' : 'farmer';

    final success = await authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      region: _regionController.text.trim(),
      role: role,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please check your data or try another email.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
    // If successful, AuthService state changes and GoRouter handles navigation automatically!
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tell us about yourself', style: Theme.of(context).textTheme.headlineSmall),
              AppSpacing.h8,
              const Text('Join AgriSmart to optimize your farming processes.', style: TextStyle(color: AppColors.textSecondary)),
              AppSpacing.h24,

              // Full Name
              Text('Full Name', style: Theme.of(context).textTheme.titleMedium),
              AppSpacing.h8,
              TextFormField(
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                decoration: const InputDecoration(hintText: 'Enter your full name'),
              ),
              AppSpacing.h16,

              // Email
              Text('Email', style: Theme.of(context).textTheme.titleMedium),
              AppSpacing.h8,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                decoration: const InputDecoration(hintText: 'Enter your email'),
              ),
              AppSpacing.h16,

              // Phone
              Text('Phone Number', style: Theme.of(context).textTheme.titleMedium),
              AppSpacing.h8,
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Enter your phone number (optional)'),
              ),
              AppSpacing.h16,

              // Region
              Text('Region / City', style: Theme.of(context).textTheme.titleMedium),
              AppSpacing.h8,
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(hintText: 'Where is your farm located? (optional)'),
              ),
              AppSpacing.h16,

              // Password
              Text('Password', style: Theme.of(context).textTheme.titleMedium),
              AppSpacing.h8,
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                validator: (val) => val != null && val.length < 6 ? 'Min 6 characters' : null,
                decoration: InputDecoration(
                  hintText: 'Create a password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              AppSpacing.h24,

              // Role Assessment Question
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.03)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role Assessment', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                    AppSpacing.h8,
                    const Text(
                      'Do you have advanced IT knowledge and want to analyze systems instead of manage a single farm?',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    AppSpacing.h8,
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_hasITKnowledge ? 'Yes, I am a Consultant' : 'No, I am a Farmer',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      activeThumbColor: AppColors.primary,
                      value: _hasITKnowledge,
                      onChanged: (bool value) {
                        setState(() {
                          _hasITKnowledge = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              AppSpacing.h32,

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleOtpSubmit(AuthViewModel viewModel) async {
    setState(() => _isLoading = true);
    try {
      final user = await viewModel.signInWithOTP(_otpController.text);
      if (user != null && mounted) {
        final res = await viewModel.registerorloginuser(context);
        if (res['documentId'] != null) {
          if (res['isFirstTimeUser']) {
            Navigator.pushReplacementNamed(context, '/register');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                _buildHeader(context),
                const SizedBox(height: 48),
                _buildAuthCard(context, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to\nMarkItDone',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Your personal task management assistant',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(BuildContext context, AuthViewModel viewModel) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              viewModel.isOTPSent ? 'Verify OTP' : 'Enter Phone Number',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.isOTPSent
                  ? 'Please enter the verification code sent to your phone'
                  : 'We\'ll send you a verification code',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (!viewModel.isOTPSent) ...[
              _buildPhoneInput(context, viewModel),
            ] else ...[
              _buildOtpInput(context, viewModel),
            ],
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!viewModel.isOTPSent) {
                      viewModel.setPhoneNumber(_phoneController.text);
                      await viewModel.verifyPhoneNumber();
                    } else {
                      await _handleOtpSubmit(viewModel);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      viewModel.isOTPSent ? 'Verify' : 'Send Code',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textLight,
                          ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context, AuthViewModel viewModel) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Enter your phone number',
        prefixIcon: Icon(
          Icons.phone_outlined,
          color: AppColors.textSecondary,
        ),
        prefixText: '+91 ',
        prefixStyle: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context, AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter 6-digit OTP',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
            ),
            counterText: '',
          ),
        ),
        TextButton(
          onPressed: () => viewModel.verifyPhoneNumber(),
          child: Text(
            'Resend Code',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

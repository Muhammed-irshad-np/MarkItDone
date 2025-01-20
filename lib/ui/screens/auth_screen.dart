import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/providers/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: AppColors.darkbackground,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildLogo(theme),
              const SizedBox(height: 32),
              _buildHeader(context, theme),
              const SizedBox(height: 48),
              _buildAuthForm(context, viewModel, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.check_circle_rounded,
        size: 56,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue managing your tasks',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
        ),
      ],
    );
  }

  Widget _buildAuthForm(
      BuildContext context, AuthViewModel viewModel, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.cardColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            viewModel.isOTPSent ? 'Verify OTP' : 'Phone Number',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.isOTPSent
                ? 'Enter the code we sent you'
                : 'We\'ll send you a verification code',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
          ),
          const SizedBox(height: 24),
          if (!viewModel.isOTPSent) _buildPhoneInput(context, viewModel, theme),
          if (viewModel.isOTPSent) _buildOTPInput(context, viewModel, theme),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      if (viewModel.isOTPSent) {
                        viewModel.handleOtpSubmit(context, _otpController.text);
                      } else {
                        if (_phoneController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your phone number'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        try {
                          viewModel.setPhoneNumber(_phoneController.text);
                          await viewModel.verifyPhoneNumber();

                          // Wait for animation to complete before updating loading state
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          viewModel.setIsOTPSent(true);
                          viewModel.isLoading = false;
                          viewModel.notifyListeners();
                          // if (mounted) {
                          //   setState(() => _isLoading = false);
                          // }
                        } catch (e) {
                          if (mounted) {
                            viewModel.isLoading = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        } finally {
                          // if (mounted) {
                          //   setState(() => _isLoading = false);
                          // }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.primaryColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  log('isLoading: ${viewModel.isLoading}');
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: viewModel.isLoading
                    ? Row(
                        // key: const ValueKey('loading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            viewModel.isOTPSent
                                ? 'Verifying...'
                                : 'Sending OTP...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        // key: const ValueKey('normal'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            viewModel.isOTPSent ? 'Verify' : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!viewModel.isOTPSent) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(
      BuildContext context, AuthViewModel viewModel, ThemeData theme) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Enter your phone number',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+91',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: theme.dividerColor,
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0),
      ),
    );
  }

  Widget _buildOTPInput(
      BuildContext context, AuthViewModel viewModel, ThemeData theme) {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '······',
        counterText: '',
        hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: theme.hintColor.withOpacity(0.5),
              letterSpacing: 8,
            ),
      ),
    );
  }
}

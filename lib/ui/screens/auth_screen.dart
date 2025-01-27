import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              _buildLogo(theme),
              SizedBox(height: 32.h),
              _buildHeader(context, theme),
              SizedBox(height: 48.h),
              _buildAuthForm(context, viewModel, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        width: 56.w,
        height: 56.w,
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
                fontSize: 28.sp,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in to continue managing your tasks',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
                fontSize: 16.sp,
              ),
        ),
      ],
    );
  }

  Widget _buildAuthForm(
      BuildContext context, AuthViewModel viewModel, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
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
                  fontSize: 20.sp,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            viewModel.isOTPSent
                ? 'Enter the code we sent you'
                : 'We\'ll send you a verification code',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontSize: 14.sp,
                ),
          ),
          SizedBox(height: 24.h),
          if (!viewModel.isOTPSent) _buildPhoneInput(context, viewModel, theme),
          if (viewModel.isOTPSent) _buildOTPInput(context, viewModel, theme),
          SizedBox(height: 24.h),
          SizedBox(
            height: 52.h,
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

                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          viewModel.setIsOTPSent(true);
                          viewModel.isLoading = false;
                          viewModel.notifyListeners();
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
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.primaryColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            viewModel.isOTPSent
                                ? 'Verifying...'
                                : 'Sending OTP...',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            viewModel.isOTPSent ? 'Verify' : 'Continue',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!viewModel.isOTPSent) ...[
                            SizedBox(width: 8.w),
                            Icon(Icons.arrow_forward, size: 18.w),
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
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
          ),
      decoration: InputDecoration(
        hintText: 'Enter your phone number',
        prefixIcon: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+91',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 1.w,
                height: 24.h,
                color: theme.dividerColor,
              ),
            ],
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0.w),
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
            letterSpacing: 8.w,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
          ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '······',
        counterText: '',
        hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: theme.hintColor.withOpacity(0.5),
              letterSpacing: 8.w,
              fontSize: 24.sp,
            ),
      ),
    );
  }
}

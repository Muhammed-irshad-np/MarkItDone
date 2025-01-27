import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markitdone/config/theme.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkbackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.darktextPrimary,
              size: 24.w,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Your Plan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darktextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Select the perfect plan for your needs',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darktextSecondary,
                      fontSize: 16.sp,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPlanCard(
                      context,
                      title: 'Free',
                      price: '0',
                      features: [
                        'Basic task management',
                        'Up to 5 team members',
                        'Simple scheduling',
                      ],
                      isPro: false,
                    ),
                    SizedBox(height: 16.h),
                    _buildPlanCard(
                      context,
                      title: 'Pro',
                      price: '9.99',
                      features: [
                        'Unlimited task management',
                        'Unlimited team members',
                        'Advanced scheduling',
                        'Priority support',
                        'Custom categories',
                        'Advanced analytics',
                      ],
                      isPro: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool isPro,
  }) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isPro
            ? AppColors.darkprimary.withOpacity(0.1)
            : AppColors.darksurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isPro ? AppColors.darkprimary : AppColors.cardBorder,
          width: 2.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isPro
                          ? AppColors.darkprimary
                          : AppColors.darktextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
              ),
              if (isPro) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkprimary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'RECOMMENDED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textLight,
                          fontSize: 10.sp,
                        ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$$price',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: isPro
                            ? AppColors.darkprimary
                            : AppColors.darktextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 32.sp,
                      ),
                ),
                if (price != '0')
                  TextSpan(
                    text: '/month',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.darktextSecondary,
                          fontSize: 16.sp,
                        ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          ...features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: isPro
                          ? AppColors.darkprimary
                          : AppColors.darktextSecondary,
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darktextPrimary,
                            fontSize: 14.sp,
                          ),
                    ),
                  ],
                ),
              )),
          if (isPro) ...[
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement purchase flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkprimary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'Upgrade to Pro',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

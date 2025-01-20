import 'package:flutter/material.dart';
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
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Your Plan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darktextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Select the perfect plan for your needs',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darktextSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
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
                    const SizedBox(height: 16),
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
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(color: AppColors.darktextSecondary),
                      ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPro
            ? AppColors.darkprimary.withOpacity(0.1)
            : AppColors.darksurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro ? AppColors.darkprimary : AppColors.cardBorder,
          width: 2,
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
                    ),
              ),
              if (isPro) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkprimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'RECOMMENDED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
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
                      ),
                ),
                if (price != '0')
                  TextSpan(
                    text: '/month',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.darktextSecondary,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: isPro
                          ? AppColors.darkprimary
                          : AppColors.darktextSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darktextPrimary,
                          ),
                    ),
                  ],
                ),
              )),
          if (isPro) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement purchase flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkprimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Upgrade to Pro',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

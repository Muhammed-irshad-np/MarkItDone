import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markitdone/config/theme.dart';
import 'package:markitdone/data/models/onboarding_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Smart Task Management',
      description:
          'Organize your tasks efficiently with our intuitive interface and smart categorization',
      imagePath: 'assets/images/smart.jpg',
    ),
    OnboardingItem(
      title: 'Team Collaboration',
      description:
          'Assign tasks to team members and track progress in real-time',
      imagePath: 'assets/images/team.jpg',
    ),
    OnboardingItem(
      title: 'Schedule & Reminders',
      description:
          'Never miss a deadline with smart scheduling and timely reminders',
      imagePath: 'assets/images/schedule.jpg',
    ),
    OnboardingItem(
      title: 'Premium Features',
      description:
          'Unlock advanced features with our Pro version for enhanced productivity',
      imagePath: 'assets/images/premium.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkbackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: EdgeInsets.all(24.0.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            item.imagePath,
            height: 0.4.sh,
          ),
          SizedBox(height: 40.h),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.darktextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.darktextSecondary,
                  fontSize: 16.sp,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(24.0.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => _buildDotIndicator(index),
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      color: AppColors.darktextSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_currentPage == _items.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkprimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                ),
                child: Text(
                  _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: _currentPage == index ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.darkprimary
            : AppColors.darktextSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/pricing');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/widgets/custom_button.dart';
import 'package:stockpulse/services/local_storage_service.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../controllers/onboardingController.dart';


class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
  Widget _buildDot({
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        color: Color(0xFF000000),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: isActive ? 20 : 10,
    );
  }

    SizeConfig().init(context);
    double width = SizeConfig.screenW!;
    double height = SizeConfig.screenH!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.onboardingDark
          : AppColors.onboardingLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: contents.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Expanded(
                          // Wrap the Image.asset with Expanded
                          child: Image.network(
                            contents[i].image,
                            // Remove fixed height here, let it be flexible
                          ),
                        ),
                        SizedBox(height: (height >= 840) ? 60 : 30),
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w600,
                            fontSize: (width <= 550) ? 30 : 35,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          contents[i].desc,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w300,
                            fontSize: (width <= 550) ? 17 : 25,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => _buildDot(isActive:
                      controller.currentPage.value == index,
                      ),
                    ),
                  ),
                  Obx(
                        () => controller.currentPage.value + 1 == contents.length
                        ? Padding(
                      padding: const EdgeInsets.all(30),
                      child: AppButton(
                        text: AppConstants.start,
                        onPressed: () {
                          Get.find<LocalStorageService>()
                              .setNotFirstTime();

                          Get.offAllNamed(Routes.login);
                        },
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.all(30),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.find<LocalStorageService>()
                                  .setNotFirstTime();

                              Get.offAllNamed(Routes.login);
                            },
                            child: Text(AppConstants.skip),
                          ),
                          AppButton(
                            text: AppConstants.next,
                            fullWidth: false,
                            onPressed: controller.nextPage,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: AppConstants.onboardingTitle1,
    image: AppConstants.onboardingImage1,
    desc: AppConstants.onboardingDesc1,
  ),
  OnboardingContents(
    title: AppConstants.onboardingTitle2,
    image: AppConstants.onboardingImage2,
    desc: AppConstants.onboardingDesc2,
  ),
  OnboardingContents(
    title: AppConstants.onboardingTitle3,
    image: AppConstants.onboardingImage3,
    desc: AppConstants.onboardingDesc3,
  ),
];

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenW;
  static double? screenH;
  static double? blockH;
  static double? blockV;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenW = _mediaQueryData!.size.width;
    screenH = _mediaQueryData!.size.height;
    blockH = screenW! / 100;
    blockV = screenH! / 100;
  }
}

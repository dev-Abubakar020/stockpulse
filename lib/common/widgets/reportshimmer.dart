import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stockpulse/utils/app_constants.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/app_colors.dart';
import '../theme/theme_helper.dart';


class SaleReportShimmer extends StatelessWidget {
  final AppThemeHelper theme;

  const SaleReportShimmer({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = theme.isDark? AppColors.darkSurface : AppColors.border;
    final highlightColor = theme.isDark ? AppColors.darkBorder : AppColors.darkTextPrimary;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppConstants.spaceMD,
              bottom: AppConstants.spaceXXL,
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter tabs
                  _box(
                    height: 44,
                    radius: AppConstants.radiusMD,
                  ),

                  const SizedBox(
                    height: AppConstants.spaceLG,
                  ),

                  // Period selector
                  _box(
                    height: 58,
                    radius: AppConstants.radiusMD,
                  ),

                  const SizedBox(
                    height: AppConstants.spaceLG,
                  ),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(),
                      ),
                      const SizedBox(
                        width: AppConstants.spaceMD,
                      ),
                      Expanded(
                        child: _summaryCard(),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppConstants.spaceMD,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(),
                      ),
                      const SizedBox(
                        width: AppConstants.spaceMD,
                      ),
                      Expanded(
                        child: _summaryCard(),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppConstants.spaceLG,
                  ),

                  // Chart
                  _chartSection(),

                  const SizedBox(
                    height: AppConstants.spaceLG,
                  ),

                  // Category section
                  _categorySection(),

                  const SizedBox(
                    height: AppConstants.spaceLG,
                  ),

                  // Recent sales
                  _recentSalesSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(
        AppConstants.spaceMD,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstants.radiusLG,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(
            width: AppConstants.reportIconBoxSize,
            height: AppConstants.reportIconBoxSize,
            radius: AppConstants.radiusMD,
          ),

          const SizedBox(
            height: AppConstants.spaceMD,
          ),

          _box(
            width: 75,
            height: 10,
          ),

          const SizedBox(
            height: AppConstants.spaceSM,
          ),

          _box(
            width: 105,
            height: 20,
          ),

          const SizedBox(
            height: AppConstants.spaceSM,
          ),

          _box(
            width: 55,
            height: 10,
          ),
        ],
      ),
    );
  }


  Widget _chartSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppConstants.spaceLG,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstants.radiusLG,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(
            width: 125,
            height: 16,
          ),

          const SizedBox(
            height: AppConstants.spaceSM,
          ),

          _box(
            width: 190,
            height: 10,
          ),

          const SizedBox(
            height: AppConstants.spaceXL,
          ),

          _box(
            width: double.infinity,
            height: AppConstants.reportChartHeight,
            radius: AppConstants.radiusMD,
          ),
        ],
      ),
    );
  }


  Widget _categorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppConstants.spaceLG,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstants.radiusLG,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(
            width: 145,
            height: 16,
          ),

          const SizedBox(
            height: AppConstants.spaceXL,
          ),

          ...List.generate(
            4,
                (index) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.spaceLG,
              ),
              child: _categoryRow(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow() {
    return Column(
      children: [
        Row(
          children: [
            _box(
              width: AppConstants.spaceSM,
              height: AppConstants.spaceSM,
              radius: AppConstants.radiusXL,
            ),

            const SizedBox(
              width: AppConstants.spaceSM,
            ),

            _box(
              width: 90,
              height: 11,
            ),

            const Spacer(),

            _box(
              width: 65,
              height: 11,
            ),

            const SizedBox(
              width: AppConstants.spaceSM,
            ),

            _box(
              width: 28,
              height: 11,
            ),
          ],
        ),

        const SizedBox(
          height: AppConstants.spaceSM,
        ),

        _box(
          width: double.infinity,
          height: AppConstants.reportProgressHeight,
          radius: AppConstants.radiusXL,
        ),
      ],
    );
  }

  Widget _recentSalesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppConstants.spaceLG,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstants.radiusLG,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(
                width: 110,
                height: 16,
              ),

              const Spacer(),

              _box(
                width: 50,
                height: 12,
              ),
            ],
          ),

          const SizedBox(
            height: AppConstants.spaceLG,
          ),

          ...List.generate(
            4,
                (index) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.spaceLG,
              ),
              child: _saleRow(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saleRow() {
    return Row(
      children: [
        _box(
          width: AppConstants.reportIconBoxSize,
          height: AppConstants.reportIconBoxSize,
          radius: AppConstants.radiusMD,
        ),

        const SizedBox(
          width: AppConstants.spaceMD,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(
                width: 90,
                height: 11,
              ),

              const SizedBox(
                height: AppConstants.spaceXS,
              ),

              _box(
                width: 125,
                height: 10,
              ),

              const SizedBox(
                height: AppConstants.spaceXS,
              ),

              _box(
                width: 80,
                height: 8,
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _box(
              width: 65,
              height: 12,
            ),

            const SizedBox(
              height: AppConstants.spaceXS,
            ),

            _box(
              width: 42,
              height: 8,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SHIMMER BOX
  // ============================================================

  Widget _box({
    double? width,
    required double height,
    double radius = AppConstants.radiusSM,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          radius,
        ),
      ),
    );
  }
}

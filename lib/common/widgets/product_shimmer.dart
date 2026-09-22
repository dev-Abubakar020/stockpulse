import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductListShimmer extends StatelessWidget {
  final int itemCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductListShimmer({
    super.key,
    this.itemCount = 6,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      // padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark
              ? const Color(0xFF131D2E)
              : const Color(0xFFE2E8F0),
          highlightColor: isDark
              ? const Color(0xFF1E2D44)
              : const Color(0xFFF8FAFC),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E2D44)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Product image
                _box(
                  width: 60,
                  height: 60,
                  radius: 12,
                ),

                const SizedBox(width: 14),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Article
                      _box(
                        width: 130,
                        height: 15,
                        radius: 5,
                      ),

                      const SizedBox(height: 7),

                      // Category
                      _box(
                        width: 90,
                        height: 12,
                        radius: 4,
                      ),

                      const SizedBox(height: 9),

                      // Price
                      _box(
                        width: 105,
                        height: 15,
                        radius: 5,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Stock section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _box(
                      width: 68,
                      height: 26,
                      radius: 8,
                    ),

                    const SizedBox(height: 8),

                    _box(
                      width: 50,
                      height: 11,
                      radius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
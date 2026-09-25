import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/route/app_routes.dart';
import 'package:stockpulse/common/theme/theme_helper.dart';
import 'package:stockpulse/utils/app_colors.dart';
import 'package:stockpulse/utils/app_constants.dart';

class PremiumSpeedDial extends StatefulWidget {
  final Future<void> Function()? onRefresh;

  const PremiumSpeedDial({
    super.key,
    this.onRefresh,
  });

  @override
  State<PremiumSpeedDial> createState() => _PremiumSpeedDialState();
}

class _PremiumSpeedDialState extends State<PremiumSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get isOpen => _controller.isCompleted;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  Future<void> _navigate(String route) async {
    await _controller.reverse();

    await Get.toNamed(route);

    await widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expense
        _SpeedDialAction(
          animation: _controller,
          interval: const Interval(0.15, 1),
          title: AppConstants.addExpenses,
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFFEF6C00),
          onTap: () => _navigate(Routes.addExpense),
        ),

        // Product
        _SpeedDialAction(
          animation: _controller,
          interval: const Interval(0.10, 0.90),
          title: AppConstants.addProducts,
          icon: Icons.add_box_outlined,
          color: const Color(0xFF1565C0),
          onTap: () => _navigate(Routes.addProductWizard),
        ),

        // Purchase
        _SpeedDialAction(
          animation: _controller,
          interval: const Interval(0.05, 0.80),
          title: AppConstants.addPurchase,
          icon: Icons.assignment_turned_in_outlined,
          color: const Color(0xFF00796B),
          onTap: () => _navigate(Routes.addPurchase),
        ),

        // Sale
        _SpeedDialAction(
          animation: _controller,
          interval: const Interval(0.0, 0.70),
          title: AppConstants.newSale,
          icon: Icons.add_shopping_cart_rounded,
          color: const Color(0xFF2E7D32),
          onTap: () => _navigate(Routes.addSale),
        ),

        const SizedBox(
          height: AppConstants.spaceSM,
        ),

        // Main FAB
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'home_speed_dial',
                elevation: 0,
                backgroundColor: theme.primary,
                onPressed: _toggle,
                child: Transform.rotate(
                  angle: _controller.value * 0.785,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SpeedDialAction extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialAction({
    required this.animation,
    required this.interval,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: interval,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        final value = curvedAnimation.value;

        if (value == 0) {
          return const SizedBox.shrink();
        }

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              15 * (1 - value),
            ),
            child: Transform.scale(
              scale: 0.85 + (0.15 * value),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConstants.spaceSM,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label
                    Material(
                      color: AppColors.lowStockCardBorderColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMD,
                      ),
                      elevation: 3,
                      shadowColor: theme.cardShadow,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMD,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceMD,
                            vertical: AppConstants.spaceSM,
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: AppConstants.spaceSM,
                    ),

                    // Action Button
                    Material(
                      color: color,
                      shape: const CircleBorder(),
                      elevation: 4,
                      shadowColor: color.withValues(alpha: 0.30),
                      child: InkWell(
                        onTap: onTap,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: AppConstants.iconMD,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
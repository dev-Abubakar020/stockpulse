import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockpulse/common/widgets/StandardScreen.dart';
import 'package:stockpulse/controllers/staff_controller.dart';
import 'package:stockpulse/utils/app_constants.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/custome_textbutton.dart';

class AddStaff extends StatelessWidget {
  const AddStaff({super.key});

  @override
  Widget build(BuildContext context) {
    final StaffController controller = Get.find<StaffController>();

    return CustomScreen(
      appBar: CustomAppBar(
        title: const Text(AppConstants.addStaff),
        showBackArrow: true,
        actions: [
          CustomTextButton(
            text: AppConstants.reset,
            onPressed: controller.clearForm,
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _buildCardGroup([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Label
                      RichText(
                        text: const TextSpan(
                          text: 'Staff Email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        AppConstants.staffEmailDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email Input
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: AppConstants.staffEmailLabelHint,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 19,
                              color: Color(0xFF3D7BFF),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppConstants.staffEmailHint,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 12),

          // Send Invitation
          Obx(
                () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.isSending.value
                    ? null
                    : () async {
                  final invitation =
                  await controller.sendInvitation();

                  if (invitation == null) return;

                  // Next:
                  // actual invitation email send karenge
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: controller.isSending.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  size: 20,
                ),
                label: Text(
                  controller.isSending.value
                      ? 'Sending...'
                      : 'Send Invitation',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
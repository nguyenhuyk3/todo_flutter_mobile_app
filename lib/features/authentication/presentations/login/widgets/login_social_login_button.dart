import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/others.dart';
import '../../../../../core/constants/sizes.dart';

class LoginSocialLoginButton extends StatelessWidget {
  const LoginSocialLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SocialButton(
          onPressed: () {},
          icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 28),
          label: 'Facebook',
        ),

        const SizedBox(width: X_MIN_WIDTH_SIZED_BOX * 4),

        _SocialButton(
          onPressed: () {},
          icon: SvgPicture.asset('assets/icons/google_logo.svg', height: 22),
          label: 'Google',
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: COLORS.INPUT_BG_COLOR,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: COLORS.FOCUSED_BORDER_IP_COLOR, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,

              const SizedBox(width: X_MIN_WIDTH_SIZED_BOX * 3),

              Text(
                label,
                style: TextStyle(
                  color: COLORS.PRIMARY_TEXT_COLOR,
                  fontWeight: FontWeight.w600,
                  fontSize: TextSizes.TITLE_X_SMALL,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

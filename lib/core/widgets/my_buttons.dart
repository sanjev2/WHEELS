import 'package:flutter/material.dart';
import 'package:wheels_flutter/app/theme/color.dart';

class MyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double height;
  final double? width;

  const MyButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.height = 54,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}) ??
        const TextStyle(inherit: true);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: isLoading ? 0 : 2,
          shadowColor: AppColors.primaryGreen.withOpacity(0.25),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loader'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  key: const ValueKey('text'),
                  style: baseStyle.copyWith(inherit: true),
                ),
        ),
      ),
    );
  }
}

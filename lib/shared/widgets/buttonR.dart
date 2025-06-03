// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names
import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:flutter/material.dart';

class ButtonR extends StatelessWidget {
  final bool? isResponsive;
  final double? width;
  final VoidCallback? onTap;
  final String? text;
  final bool showIcon;
  final IconData? icon;
  final Color? color; 

  // ignore: use_super_parameters
  const ButtonR({
    Key? key,
    this.width,
    this.isResponsive = false,
    this.onTap,
    this.text,
    this.showIcon = true,
    this.icon,
    this.color, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color ?? AppColors.azulOscuro,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon && icon != null)
              Icon(icon, color: AppColors.blanco),
            if (text != null) ...[
              if (showIcon && icon != null) const SizedBox(width: 10),
              Text(
                text!,
                style: const TextStyle(
                  color: AppColors.blanco,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

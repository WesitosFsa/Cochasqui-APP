// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonR extends StatelessWidget {
  bool? isResponsive;
  double? width;
  final VoidCallback? onTap;
  String? text;
  final bool showIcon; 

  // ignore: use_super_parameters
  ButtonR({
    Key? key,
    this.width,
    this.isResponsive = false,
    this.onTap,
    this.text,
    this.showIcon = true, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFFC9404),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) Image.asset("assets/images/icono.png"), 
            if (text != null) ...[
              if (showIcon) const SizedBox(width: 10),
              Text(
                text!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
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

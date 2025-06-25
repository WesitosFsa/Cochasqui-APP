import 'package:flutter/material.dart';

// ignore: must_be_immutable, camel_case_types
class text_simple extends StatelessWidget {
  double size;
  final String text;
  final Color color;

  // ignore: use_super_parameters
  text_simple({Key? key, 
  this.size=16,
  required this.text,
  this.color=const Color.fromARGB(73, 0, 0, 0)}) : super(key:key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
      ),
    );
  }
}
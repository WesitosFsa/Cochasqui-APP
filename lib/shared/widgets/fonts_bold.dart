import 'package:flutter/material.dart';

// ignore: must_be_immutable, camel_case_types
class text_bold extends StatelessWidget {
  //Tamaño del texto
  double size;
  final String text;
  final Color color;

  // ignore: use_super_parameters
  text_bold({Key? key, 
  this.size=30,
  required this.text,
  this.color=Colors.black}) : super(key:key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.bold
      ),
    );
  }
}
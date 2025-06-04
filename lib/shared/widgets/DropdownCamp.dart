import 'package:flutter/material.dart';
import 'package:cochasqui_park/shared/themes/colors.dart';

class DropdownCamp extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final bool readType;
  final bool readOnly;

  const DropdownCamp({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.readType = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReadType = readType;
    final bool isReadOnly = readOnly;

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.azulMedio),
        ),
        fillColor: isReadType || isReadOnly ? const Color.fromARGB(115, 160, 160, 160) : null,
        filled: isReadType || isReadOnly,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: isReadOnly ? null : onChanged,
      validator: validator,
    );
  }
}
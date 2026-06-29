import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool obscure;
  final String? Function(String?)? validator;
  final double? margin;
  final Widget? suffixIcon;
  final bool? readOnly;
  final void Function()? onTap;

  const CustomTextField({
    Key? key,
    required this.hint,
    required this.controller,
    this.inputType = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.margin,
    this.suffixIcon,
    this.readOnly,
    this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: margin ?? 8.0),
      child: TextFormField(
        // enableSuggestions: !obscure,
        cursorErrorColor: Colors.red,
        // cursorOpacityAnimates: true,
        style: AppTextStyles.regularGrey15,
        readOnly: readOnly ?? false,
        controller: controller,
        keyboardType: inputType,
        obscureText: obscure,
        textAlignVertical: TextAlignVertical.center,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTap: onTap,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: label,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          isCollapsed: false,
          alignLabelWithHint: false,
          labelStyle: AppTextStyles.regularGrey15,
          contentPadding:
          EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          suffixIcon: suffixIcon ?? const SizedBox.shrink(),
          suffixIconConstraints: suffixIcon != null
              ? BoxConstraints(minHeight: 16, minWidth: 16)
              : const BoxConstraints(),
          filled: true,
          fillColor: const Color(0xFFF7F8F9),
          hintText: hint,
          hintStyle: AppTextStyles.regularGrey15.copyWith(fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8ECF4), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        textDirection: TextDirection.rtl,
        validator: validator,
      ),
    );
  }
}

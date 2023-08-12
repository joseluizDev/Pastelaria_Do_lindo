import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  const TextFieldCustom({
    Key? key,
    required this.label,
    this.obscure = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: keyboardType,
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          labelText: label,
        ),
        obscureText: obscure,
      ),
    );
  }
}

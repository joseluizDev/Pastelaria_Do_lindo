import 'package:flutter/material.dart';

class DividerCustom extends StatelessWidget {
  final double thickness;
  const DividerCustom({super.key, this.thickness = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        20,
        (index) => const SizedBox(
          width: 10,
          child: Divider(
            thickness: 1,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

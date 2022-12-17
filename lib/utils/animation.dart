import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoadingLs extends StatelessWidget {
  const LoadingLs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: RiveAnimation.asset(
          'assets/animations/loading.riv',
          animations: ['Animation 1'],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final bool isCentered;

  const AppLoader({super.key, this.isCentered = true});

  @override
  Widget build(BuildContext context) {
    if (isCentered) {
      return const Center(child: CircularProgressIndicator());
    }
    return const CircularProgressIndicator();
  }
}

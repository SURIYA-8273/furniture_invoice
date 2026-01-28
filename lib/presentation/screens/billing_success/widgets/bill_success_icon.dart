import 'package:flutter/material.dart';

class BillSuccessIcon extends StatelessWidget {
  const BillSuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

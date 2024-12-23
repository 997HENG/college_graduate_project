import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeaveButton extends StatelessWidget {
  const LeaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Leave the class.',
      child: Container(
        width: 50.0, // Adjust size as needed
        height: 50.0, // Adjust size as needed
        decoration: BoxDecoration(
          color: Colors.red[300], // Background color of the circle
          shape: BoxShape.circle, // Makes the container circular
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.exit_to_app_rounded),
          color: Colors.black, // Icon color
        ),
      ),
    );
  }
}

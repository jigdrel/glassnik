import 'package:flutter/material.dart';

class IPhoneFrame extends StatelessWidget {
  const IPhoneFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  static const double phoneWidth = 393;
  static const double phoneHeight = 852;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          width: phoneWidth,
          height: phoneHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: const Size(
                  phoneWidth,
                  phoneHeight,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

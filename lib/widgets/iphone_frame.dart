import 'dart:math' as math;

import 'package:flutter/material.dart';

class IPhoneFrame extends StatelessWidget {
  const IPhoneFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  static const double phoneWidth =
      393;

  static const double phoneHeight =
      852;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,

      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final widthScale =
              constraints.maxWidth /
                  phoneWidth;

          final heightScale =
              constraints.maxHeight /
                  phoneHeight;

          // Never enlarge beyond actual iPhone size.
          // Shrink only when the browser is too small.
          final scale = math.min(
            1.0,
            math.min(
              widthScale,
              heightScale,
            ),
          );

          return Center(
            child: SizedBox(
              width:
                  phoneWidth * scale,

              height:
                  phoneHeight * scale,

              child:
                  Transform.scale(
                scale: scale,
                alignment:
                    Alignment.topLeft,

                child: SizedBox(
                  width:
                      phoneWidth,

                  height:
                      phoneHeight,

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      28,
                    ),

                    child:
                        MediaQuery(
                      data:
                          MediaQuery.of(
                        context,
                      ).copyWith(
                        size:
                            const Size(
                          phoneWidth,
                          phoneHeight,
                        ),
                      ),

                      child:
                          child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

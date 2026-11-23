import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderRadiusGeometry borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.elevation = 0,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(18),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,

      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),

      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
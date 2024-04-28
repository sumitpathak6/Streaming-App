import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget dekstopBody;
  const ResponsiveLayout({super.key, required this.mobileBody, required this.dekstopBody});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if(constraints.maxWidth < 600){
          return mobileBody;
        }
        else{
          return dekstopBody;
        }
      },
    );
  }
}
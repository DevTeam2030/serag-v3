import 'package:flutter/material.dart';

// This is where the magic happens.
// This functions are responsible to make UI responsive across all the mobile devices.

Size size = WidgetsBinding.instance.window.physicalSize /
    WidgetsBinding.instance.window.devicePixelRatio;

// Caution! If you think these are static values and are used to build a static UI,  you mustn’t.
// These are the Viewport values of your Figma Design.
// These are used in the code as a reference to create your UI Responsively.
const num FIGMA_DESIGN_WIDTH = 375;
const num FIGMA_DESIGN_HEIGHT = 812;
const num FIGMA_DESIGN_STATUS_BAR = 44;

///This method is used to get device viewport width.
get width {
  return size.width;
}

///This method is used to get device viewport height.
get height {
  num statusBar =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).viewPadding.top;
  num screenHeight = size.height - statusBar;
  return screenHeight;
}

///This method is used to set padding/margin (for the start and end side) & width of the screen or widget according to the Viewport width.
double getHorizontalSize(double px) {
  return ((px * width) / FIGMA_DESIGN_WIDTH).floorToDouble();
}

///This method is used to set padding/margin (for the top and bottom side) & height of the screen or widget according to the Viewport height.
double getVerticalSize(double px) {
  return ((px * height) / (FIGMA_DESIGN_HEIGHT - FIGMA_DESIGN_STATUS_BAR))
      .floorToDouble();
}

///This method is used to set smallest px in image height and width
double getSize(double px) {
  var height = getVerticalSize(px);
  var width = getHorizontalSize(px);
  if (height < width) {
    return height.toInt().toDouble();
  } else {
    return width.toInt().toDouble();
  }
}

///This method is used to set text font size according to Viewport
double getFontSize(double px) {
  return getSize(px);
}

///This method is used to set padding responsively
EdgeInsetsDirectional getPadding({
  double? all,
  double? start,
  double? top,
  double? end,
  double? bottom,

}) {
  return getMarginOrPadding(
    all:all!=null? getSize(all):null ,
    start:start!=null? start:null ,
    top:top!=null? top:null,
    end:end!=null?end:null,
    bottom:bottom!=null?bottom:null ,
  );
  return getMarginOrPadding(
    all:all!=null? getSize(all):null ,
    start:start!=null? getHorizontalSize(start):null ,
    top:top!=null? getVerticalSize(top):null,
    end:end!=null? getVerticalSize(end):null,
    bottom:bottom!=null?  getVerticalSize(bottom):null ,
  );
}

///This method is used to set margin responsively
EdgeInsetsGeometry getMargin({
  double? all,
  double? start,
  double? top,
  double? end,
  double? bottom,
}) {
  return getMarginOrPadding(
    all: all,
    start: start,
    top: top,
    end: end,
    bottom: bottom,
  );
}

///This method is used to get padding or margin responsively
EdgeInsetsDirectional getMarginOrPadding({
  double? all,
  double? start,
  double? top,
  double? end,
  double? bottom,
}) {
  if (all != null) {
    start = all;
    top = all;
    end = all;
    bottom = all;
  }
  return EdgeInsetsDirectional.only(
    start:
    start ?? 0,

    top:
    top ?? 0,

    end:
    end ?? 0,

    bottom:
    bottom ?? 0,

  );

  return EdgeInsetsDirectional.only(
    start: getHorizontalSize(
      start ?? 0,
    ),
    top: getVerticalSize(
      top ?? 0,
    ),
    end: getHorizontalSize(
      end ?? 0,
    ),
    bottom: getVerticalSize(
      bottom ?? 0,
    ),
  );
}

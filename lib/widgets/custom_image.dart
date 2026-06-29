import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../core/common/size_utilies.dart';

Widget cachedImage(
    String? url, {
      bool rotateWithDirectionality=false,
      double? height,
      double? width,
      BoxFit? fit,
      Color? color,
      AlignmentGeometry alignment=Alignment.center,
      bool usePlaceholderIfUrlEmpty = true,
    }) {
  if (url == null || url.isEmpty || url == 'null' || url == '') {
    return placeHolderWidget(
        useMyFit: true,
        height: height, width: width, fit: fit, alignment: alignment);
  }
  else if (url.startsWith('http')) {


    return CachedNetworkImage(
      imageUrl: url,

      height:height!=null? getVerticalSize(height):null ,
      width:width!=null? getHorizontalSize(width):null,
      fit: fit,
      alignment: alignment as Alignment ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(

            height:height!=null? getVerticalSize(height):null, width: width!=null? getHorizontalSize(width):null, fit: fit, alignment: alignment);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return const SizedBox();
        return placeHolderWidget(
            height: height!=null? getVerticalSize(height):null, width: width!=null? getHorizontalSize(width):null,  alignment: alignment);
      },
    );

  }
  else if (url.endsWith('svg')) {
    if(rotateWithDirectionality)
    {
      return RotatedBox(
        quarterTurns: 2,
        child: SvgPicture.asset(url,
            height:  height!=null? getVerticalSize(height):null,
            width:width!=null? getHorizontalSize(width):null,
            color: color,
            fit: fit??BoxFit.fill,
            alignment: alignment ?? Alignment.center),
      );
    }
    return  SvgPicture.asset(url,
        height:  height!=null? getVerticalSize(height):null,
        width: width!=null? getHorizontalSize(width):null,
        color: color,
        fit: fit??BoxFit.fill,
        alignment: alignment ?? Alignment.center);

  }


  else {
    if(rotateWithDirectionality)
    {
      return RotatedBox(
        quarterTurns: 2,
        child:Image.asset(url,
            height:  height!=null? getVerticalSize(height):null,
            width:width!=null? getHorizontalSize(width):null,
            color: color,
            fit: fit,
            alignment: alignment ?? Alignment.center),
      );
    }
    return Image.asset(url,
        height: height!=null? getVerticalSize(height):null,
        width:width!=null? getHorizontalSize(width):null,
        color: color,
        fit: fit,
        alignment: alignment ?? Alignment.center);
  }
}
Widget placeHolderWidget(
    {double? height,
      double? width,
      BoxFit? fit,
      bool useMyFit=false,
      AlignmentGeometry? alignment}) {
  return Image.asset(
    'assets/logo.png',
    height: height,
    width: width,
    fit:useMyFit? fit:BoxFit.contain,
    alignment: alignment ?? Alignment.center,
  );
}
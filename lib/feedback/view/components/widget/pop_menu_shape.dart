import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 自定义popMenu
class RacTangle extends ShapeBorder {
  ///todo popMenu调不了宽度，现阶段采用的是我强行用裁剪剪出理想形状，回头我重写一个
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    var path = Path();
    Rect newRect = Rect.fromLTWH(27.5.w, 0, 87.6.w, rect.height);
    path.addRRect(RRect.fromRectAndRadius(newRect, Radius.circular(5)));
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsetsGeometry.infinity;
}

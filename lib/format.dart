import 'package:flutter/foundation.dart';

enum ImageFormat {
  lottie,
  svg,
  others,
}

extension FormatExtension on ImageFormat{
  String get name => describeEnum(this);
}
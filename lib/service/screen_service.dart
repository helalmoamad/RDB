import 'package:flutter/material.dart';

enum WindowSize {
  compact,
  medium,
  expanded,
}

enum ScreenSize { small, medium, large, xlarge }

enum ScreenType { mobile, tablet, desktop }

extension SizeType on ScreenSize {
  String get text {
    switch (this) {
      case ScreenSize.small:
        return "SMALL";
      case ScreenSize.medium:
        return "MEDIUM";
      case ScreenSize.large:
        return "LARGE";
      case ScreenSize.xlarge:
        return "XLARGE";
    }
  }
}

class ScreenService {
  static ScreenSize get screenSize => _screenSize;

  static ScreenType get widthBasedScreenType => _widthBasedScreenType;
  static ScreenType get heightBasedScreenType => _heightBasedScreenType;
  static ScreenType get targetScreenType =>
      _orientation == Orientation.portrait ? widthBasedScreenType : heightBasedScreenType;

  static WindowSize get widthBasedWindowSize => _widthBasedWindowSize;
  static WindowSize get heightBasedWindowSize => _heightBasedWindowSize;
  static WindowSize get targetWindowSize =>
      _orientation == Orientation.portrait ? widthBasedWindowSize : heightBasedWindowSize;

  late double _screenWidth;
  late double _screenHeight;

  static late ScreenSize _screenSize;

  static late ScreenType _widthBasedScreenType;
  static late ScreenType _heightBasedScreenType;

  static late WindowSize _widthBasedWindowSize;
  static late WindowSize _heightBasedWindowSize;

  static late Orientation _orientation;
  final BuildContext _context;
  late MediaQueryData _mediaQueryData;

  ScreenService._singleton(this._context) {
    _mediaQueryData = MediaQuery.of(_context);
    _setDimensions();
    _computeScreenSize();
    _computeWindowSizeClasses();
    _computeScreenType();
  }

  factory ScreenService(BuildContext context) => ScreenService._singleton(context);

  _setDimensions() {
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _orientation = _mediaQueryData.orientation;
  }

  void _computeScreenSize() {
    if (_screenWidth >= 320 && _screenWidth < 375) {
      _screenSize = ScreenSize.small;
    } else if (_screenWidth >= 375 && _screenWidth < 414) {
      _screenSize = ScreenSize.medium;
    } else if (_screenWidth >= 414 && _screenWidth < 550) {
      _screenSize = ScreenSize.large;
    } else {
      _screenSize = ScreenSize.xlarge;
    }
  }

  void _computeWindowSizeClasses() {
    if (_screenWidth < 600) {
      _widthBasedWindowSize = WindowSize.compact;
    } else if (_screenWidth < 840) {
      _widthBasedWindowSize = WindowSize.medium;
    } else {
      _widthBasedWindowSize = WindowSize.expanded;
    }

    if (_screenHeight < 480) {
      _heightBasedWindowSize = WindowSize.compact;
    } else if (_screenHeight < 900) {
      _heightBasedWindowSize = WindowSize.medium;
    } else {
      _heightBasedWindowSize = WindowSize.expanded;
    }
  }

  _computeScreenType() {
    if (_screenWidth < 600) {
      _widthBasedScreenType = ScreenType.mobile;
    } else if (_screenWidth < 960) {
      _widthBasedScreenType = ScreenType.tablet;
    } else {
      _widthBasedScreenType = ScreenType.desktop;
    }

    if (_screenHeight < 960) {
      _heightBasedScreenType = ScreenType.mobile;
    } else if (_screenHeight < 1280) {
      _heightBasedScreenType = ScreenType.tablet;
    } else {
      _heightBasedScreenType = ScreenType.desktop;
    }
  }
}

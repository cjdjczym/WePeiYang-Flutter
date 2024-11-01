import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';

class WpyTheme extends InheritedWidget {
  final WpyThemeData themeData;

  WpyTheme({required super.child, required this.themeData});

  static WpyTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WpyTheme>();
  }

  static WpyTheme of(BuildContext context) {
    final WpyTheme? result = maybeOf(context);
    assert(result != null, 'No WpyTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant WpyTheme oldWidget) {
    return oldWidget.themeData.meta.themeId != themeData.meta.themeId;
  }

  static Future<bool> isDarkMode(BuildContext context) async {
    if (Platform.isIOS) {
      // 使用iOS原生代码检测是否启用了暗黑模式
      bool isDarkModeEnabled = await iOSThemeService.isDarkModeEnabled();
      return isDarkModeEnabled;
    } else {
      // 对于其他平台，使用Flutter的MediaQuery来检测
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  } // 事实上不需要单独通过iOS原生代码来获取iOS深色模式状态，MediaQuery就够用了...

  Color? get primary => themeData.data.primaryColor;

  String get name => themeData.meta.name;

  String get darkThemeId => themeData.meta.darkThemeId;

  Color get(WpyColorKey key) {
    return themeData.data.get(key);
  }

  List<Color> getColorSet(WpyColorSetKey key) {
    return themeData.data.getColorSet(key) as List<Color>;
  }

  Gradient getGradient(WpyColorSetKey key) {
    return themeData.data.getColorSet(key) as Gradient;
  }

  get isDarkTheme => themeData.meta.brightness == Brightness.dark;

  Brightness get brightness => themeData.meta.brightness;

  static void init() {
    final themeId = CommonPreferences.appThemeId.value;
    final darkThemeId = CommonPreferences.appDarkThemeId.value;
    final brightness = CommonPreferences.usingDarkTheme.value;
    final theme = WpyThemeData.themeList.firstWhere((element) {
      return element.meta.themeId == (brightness == 0 ? themeId : darkThemeId);
    }, orElse: () => WpyThemeData.themeList[0]);
    globalTheme.value = theme;
  }

  static Future<void> updateAutoDarkTheme(BuildContext context) async {
    if (!CommonPreferences.autoDarkTheme.value) return;

    // 检查要移动到什么主题
    WpyThemeData shiftTheme = WpyThemeData.themeList.firstWhere((element) {
      if (globalTheme.value.meta.brightness == Brightness.light) {
        return element.meta.themeId == CommonPreferences.appDarkThemeId.value;
      } else {
        return element.meta.themeId == CommonPreferences.appThemeId.value;
      }
    }, orElse: () => WpyThemeData.brightThemeList[0]);

    if (await isDarkMode(context)) {
      if (globalTheme.value.meta.brightness == Brightness.light) {
        globalTheme.value = shiftTheme;
        CommonPreferences.appDarkThemeId.value = shiftTheme.meta.darkThemeId;
        CommonPreferences.usingDarkTheme.value = 1;
      }
    } else {
      if (globalTheme.value.meta.brightness == Brightness.dark) {
        globalTheme.value = shiftTheme;
        CommonPreferences.appDarkThemeId.clear();
        CommonPreferences.usingDarkTheme.value = 0;
      }
    }
  }
}

extension BrightnessSystemUiOverlay on Brightness {
  get uiOverlay => this == Brightness.light
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;

  get reverseUiOverlay => this == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}

final globalTheme = ValueNotifier(WpyThemeData.themeList[0]);

class iOSThemeService {
  static const channel = MethodChannel('com.twt.service/theme');

  static Future<bool> isDarkModeEnabled() async {
    final bool isDarkMode = await channel.invokeMethod('isDarkMode');
    return isDarkMode;
  }
}

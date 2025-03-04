﻿import 'package:flutter/foundation.dart';

/// 动态打包配置
class EnvConfig {
  static void init() {
    QNHD = isDevelop
        // 测试服务器域名
        ? "http://172.18.149.225:7013/"
        // 正式服务器域名
        : "https://qnhd.twt.edu.cn/";
    QNHDPIC = isDevelop
        // 测试服务器域名
        ? "https://qnhdpic.twt.edu.cn/"
        // 正式服务器域名
        : "https://qnhdpic.twt.edu.cn/";
    CUSTOM_CLASS = isDevelop
        // 测试服务器域名
        ? "http://activity.twt.edu.cn/"
        // 正式服务器域名
        : "https://activity.twt.edu.cn/";
    LAF = isDevelop ? "http://121.36.230.111:80/" : "http://121.36.230.111:80/";
  }

  static bool get isDevelop => ENVIRONMENT == "DEVELOP";

  static bool get isTest =>
      ENVIRONMENT == "ONLINE_TEST" || isDevelop || kDebugMode;

  /// 测试版还是正式版 "RELEASE", "DEVELOP", "ONLINE_TEST"（默认）
  static const ENVIRONMENT =
      String.fromEnvironment("ENVIRONMENT", defaultValue: "RELEASE");

  /// 微北洋版本信息，请勿修改代码，这里的默认值由脚本生成
  static const VERSION = String.fromEnvironment(
    "VERSION",
    defaultValue: "Development",
  );

  /// 微北洋版本信息，请勿修改代码，这里的默认值由脚本生成
  static const VERSIONCODE = int.fromEnvironment(
    "VERSIONCODE",
    defaultValue: 0, // 设置非常小方便做更新测试
  );

  /// 青年湖底域名 "https://www.zrzz.site:7013/" (DEFAULT) 或 "https://qnhd.twt.edu.cn/"
  static late String QNHD;

  /// 青年湖底图片域名 "https://www.zrzz.site:7015/" (DEFAULT) 或 "https://qnhdpic.twt.edu.cn/"
  static late String QNHDPIC;

  /// 自定义课表域名 "https://activity.twt.edu.cn/" (DEFAULT) 或 "http://101.42.225.75:8081//"
  static late String CUSTOM_CLASS;

  /// 失物招领地址 "http://121.36.230.111:80/"
  static late String LAF;
}

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/webview/wby_webview.dart';

class FestivalArgs {
  final String url;
  final String name;

  FestivalArgs(this.url, this.name);
}

class FestivalPage extends WbyWebView {
  final FestivalArgs args;

  FestivalPage(this.args, {Key? key, required BuildContext context})
      : super(
            page: args.name,
            backgroundColor: WpyColorKey.primaryBackgroundColor,
            fullPage: false,
            key: key);

  @override
  _FestivalPageState createState() => _FestivalPageState(this.args);
}

class _FestivalPageState extends WbyWebViewState {
  FestivalArgs args;

  _FestivalPageState(this.args);

  @override
  Future<String> getInitialUrl(BuildContext context) async {
    return args.url
        .replaceAll('<token>', '${CommonPreferences.token.value}')
        .replaceAll(
            '<laketoken>', '${await LakeTokenManager().refreshToken()}');
  }
}

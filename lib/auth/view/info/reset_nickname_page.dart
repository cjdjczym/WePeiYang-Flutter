import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class ResetNicknamePage extends StatefulWidget {
  @override
  _ResetNicknamePageState createState() => _ResetNicknamePageState();
}

class _ResetNicknamePageState extends State<ResetNicknamePage> {
  String nickname = "";
  FocusNode node = FocusNode();

  _reset() async {
    if (nickname == "") {
      ToastProvider.error("用户名不能为空");
      return;
    }
    AuthService.changeNickname(nickname,
        onSuccess: () {
          ToastProvider.success("更改用户名成功");
          Navigator.pop(context);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text('更改用户名', style: TextUtil.base.bold.sp(17).blue52hz(context)),
          elevation: 0,
          centerTitle: true,
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                    size: 32),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: TextField(
            focusNode: node,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.oldListActionColor))),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.oldFurthActionColor),
                      width: 2)),
              suffixIcon: IconButton(
                onPressed: _reset,
                icon: Text(
                  '保存',
                  style: TextUtil.base.bold.sp(13).oldThirdAction(context),
                ),
              ),
            ),
            onChanged: (input) => setState(() => nickname = input)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/login/find_pw_dialog.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class FindPwWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.oldThirdActionColor),
                    size: 35),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Spacer(flex: 1),
          Center(
            child: Text('天外天账号密码找回',
                style: TextUtil.base.bold.sp(16).oldThirdAction(context)),
          ),
          SizedBox(height: 40),
          SizedBox(
            height: 50,
            width: 200,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AuthRouter.findPhone),
              child: Text('账号已绑定手机号',
                  style: TextUtil.base.regular.reverse(context).sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(3),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return WpyTheme.of(context)
                        .get(WpyColorKey.oldActionRippleColor);
                  return WpyTheme.of(context).get(WpyColorKey.oldActionColor);
                }),
                backgroundColor: MaterialStateProperty.all(
                    WpyTheme.of(context).get(WpyColorKey.oldActionColor)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
          SizedBox(height: 25),
          SizedBox(
            height: 50,
            width: 200,
            child: ElevatedButton(
              onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => FindPwDialog()),
              child: Text('账号未绑定手机号',
                  style: TextUtil.base.regular.reverse(context).sp(13)),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(3),
                overlayColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.pressed))
                    return WpyTheme.of(context)
                        .get(WpyColorKey.oldActionRippleColor);
                  return WpyTheme.of(context).get(WpyColorKey.oldActionColor);
                }),
                backgroundColor: MaterialStateProperty.all(
                    WpyTheme.of(context).get(WpyColorKey.oldActionColor)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class FindPwByPhoneWidget extends StatefulWidget {
  @override
  _FindPwByPhoneWidgetState createState() => _FindPwByPhoneWidgetState();
}

class _FindPwByPhoneWidgetState extends State<FindPwByPhoneWidget> {
  String phone = "";
  String code = "";
  bool isPress = false;

  _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnReset(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  _verifyCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    } else if (code == "") {
      ToastProvider.error("短信验证码不能为空");
      return;
    }
    AuthService.verifyOnReset(phone, code,
        onSuccess: () =>
            Navigator.pushNamed(context, AuthRouter.resetPw, arguments: phone),
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle _hintStyle =
        TextUtil.base.regular.sp(13).oldHintDarker(context);
    double width = WePeiYangApp.screenWidth - 80;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: WButton(
                child: Icon(Icons.arrow_back,
                    color: WpyTheme.of(context)
                        .get(WpyColorKey.oldThirdActionColor),
                    size: 35),
                onPressed: () => Navigator.pop(context)),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Center(
              child: Text('天外天账号密码找回',
                  style: TextUtil.base.bold.sp(16).oldThirdAction(context)),
            ),
            SizedBox(height: 40),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 55),
              child: TextField(
                decoration: InputDecoration(
                    hintText: '手机号',
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor:
                        WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => phone = input),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 55,
                    maxWidth: width / 2 + 20,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: '短信验证码',
                        hintStyle: _hintStyle,
                        filled: true,
                        fillColor: WpyTheme.of(context)
                            .get(WpyColorKey.oldSwitchBarColor),
                        isCollapsed: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 18, 0, 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none)),
                    onChanged: (input) => setState(() => code = input),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                    height: 55,
                    width: width / 2 - 20,
                    child: isPress
                        ? StreamBuilder<int>(
                            stream: Stream.periodic(
                                    Duration(seconds: 1), (time) => time + 1)
                                .take(60),
                            builder: (context, snap) {
                              var time = 60 - (snap.data ?? 0);
                              if (time == 0)
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => setState(() => isPress = false));
                              return ElevatedButton(
                                onPressed: () {},
                                child: Text('$time秒后重试',
                                    style: TextUtil.base.bold
                                        .sp(13)
                                        .oldThirdAction(context)),
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(5),
                                  overlayColor: MaterialStateProperty.all(
                                      WpyTheme.of(context)
                                          .get(WpyColorKey.oldHintColor)),
                                  backgroundColor: MaterialStateProperty.all(
                                      WpyTheme.of(context)
                                          .get(WpyColorKey.oldHintColor)),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                ),
                              );
                            })
                        : ElevatedButton(
                            onPressed: _fetchCaptcha,
                            child: Text('获取验证码',
                                style: TextUtil.base.regular
                                    .reverse(context)
                                    .sp(13)),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(5),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                if (states.contains(MaterialState.pressed))
                                  return WpyTheme.of(context)
                                      .get(WpyColorKey.oldActionRippleColor);
                                return WpyTheme.of(context)
                                    .get(WpyColorKey.oldActionColor);
                              }),
                              backgroundColor: MaterialStateProperty.all(
                                  WpyTheme.of(context)
                                      .get(WpyColorKey.oldActionColor)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                          )),
              ],
            ),
            Spacer(),
            Container(
              height: 50,
              alignment: Alignment.bottomRight,
              child: WButton(
                onPressed: _verifyCaptcha,
                child:
                    Image(image: AssetImage('assets/images/arrow_round.png')),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Stream<int> timerStream() async* {
    yield 1;
  }
}

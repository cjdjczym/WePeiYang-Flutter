import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/privacy_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/privacy/user_agreement_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/debug_dialog.dart';
import 'package:we_pei_yang_flutter/auth/view/user/logout_dialog.dart';
import 'package:we_pei_yang_flutter/commons/channel/local_setting/local_setting.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/test/test_router.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/util/dialog_provider.dart';
import '../../../commons/widgets/w_button.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String md = '';
  String iosLocalVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      rootBundle.loadString('privacy/privacy_content.md').then((str) {
        setState(() {
          md = str;
        });
      });

      iosLocalVersion = await LocalSetting.getBundleVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final arrow = Icon(Icons.arrow_forward_ios,
        color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
        size: 22);
    final mainTextStyle = TextUtil.base.bold.sp(14).oldThirdAction(context);
    final hintTextStyle = TextUtil.base.bold.sp(12).oldHintDarkest(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('设置',
            style: TextUtil.base.bold.sp(16).oldActionColor(context)),
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: WButton(
            child: Icon(Icons.arrow_back,
                color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: WButton(
              onPressed: () => Navigator.pushNamed(context, AuthRouter.userInfo)
                  .then((_) => this.setState(() {})),
              child: Row(
                children: [
                  Image.asset('assets/images/modify_info_icon.png',
                      color:
                          WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                      width: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text('个人信息更改', style: mainTextStyle),
                  ),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onLongPress: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => DebugDialog(),
                );
              },
              onTap: () =>
                  Navigator.pushNamed(context, AuthRouter.generalSetting)
                      .then((_) => this.setState(() {})),
              child: Row(
                children: [
                  Icon(Icons.widgets_outlined,
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor),
                      size: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(child: Text('应用设置', style: mainTextStyle)),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onLongPress: () {
                if (EnvConfig.isTest) {
                  Navigator.pushNamed(context, TestRouter.mainPage);
                }
                //show about dialog
                else {
                  showAboutDialog(
                    context: context,
                    applicationName: "微北洋",
                    applicationVersion:
                        "${EnvConfig.VERSION}+${EnvConfig.VERSIONCODE}",
                    applicationIcon: Image.asset(
                      'assets/images/logo.png',
                      width: 50.w,
                    ),
                  );
                }
              },
              onTap: () => Navigator.pushNamed(context, AuthRouter.aboutTwt),
              child: Row(
                children: [
                  Image.asset('assets/images/twt.png', width: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text('关于天外天', style: mainTextStyle),
                  ),
                  arrow,
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onLongPress: () {
                Navigator.pushNamed(context, AuthRouter.debugInfo);
              },
              onTap: () {
                print("tab");
                context.read<UpdateManager>().checkUpdate(
                      auto: false,
                    );
              },
              child: Row(
                children: [
                  Icon(Icons.update,
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor),
                      size: 20.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text('检查更新', style: mainTextStyle),
                  ),
                  Text(
                      "${'当前版本'}: " +
                          (Platform.isIOS
                              ? iosLocalVersion
                              : EnvConfig.VERSION),
                      style: hintTextStyle),
                  SizedBox(width: 15.w),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
            decoration: BoxDecoration(
              color:
                  WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: WButton(
              onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) => LogoutDialog()),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logout.png',
                    width: 20.w,
                    color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text('登出', style: mainTextStyle),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WButton(
                onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => UserAgreementDialog()),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(),
                  child: Text('《用户协议》', style: hintTextStyle),
                ),
              ),
              WButton(
                onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return PrivacyDialog(md);
                    }),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(),
                  child: Text('《隐私政策》', style: hintTextStyle),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          WButton(
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LakeDialogWidget(
                      title: '天外天工作室提示您',
                      titleTextStyle: TextUtil.base.normal
                          .infoText(context)
                          .NotoSansSC
                          .sp(22)
                          .w600,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ' 你即将离开微北洋，去往：',
                            style: TextStyle(
                                color: WpyTheme.of(context)
                                    .get(WpyColorKey.basicTextColor)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6, bottom: 6),
                            child: Text("https://beian.miit.gov.cn",
                                style: TextUtil.base.NotoSansSC
                                    .link(context)
                                    .w600
                                    .h(1.6)),
                          ),
                        ],
                      ),
                      cancelText: "取消",
                      confirmTextStyle: TextUtil.base.normal
                          .bright(context)
                          .NotoSansSC
                          .sp(16)
                          .w600,
                      confirmButtonColor: WpyTheme.of(context)
                          .get(WpyColorKey.primaryTextButtonColor),
                      cancelTextStyle: TextUtil.base.normal
                          .label(context)
                          .NotoSansSC
                          .sp(16)
                          .w400,
                      confirmText: "继续",
                      cancelFun: () {
                        Navigator.pop(context);
                      },
                      confirmFun: () async {
                        await launchUrl(Uri.parse("https://beian.miit.gov.cn"),
                            mode: LaunchMode.externalApplication);
                        Navigator.pop(context);
                      });
                }),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(),
              child: Text('津ICP备05004358号-18A', style: hintTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}

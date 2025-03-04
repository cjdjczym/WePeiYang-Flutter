import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

import '../../../commons/local/animation_provider.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';
import '../../../gpa/model/gpa_notifier.dart';

class GeneralSettingPage extends StatefulWidget {
  @override
  _GeneralSettingPageState createState() => _GeneralSettingPageState();
}

class _GeneralSettingPageState extends State<GeneralSettingPage> {
  @override
  Widget build(BuildContext context) {
    final titleTextStyle = TextUtil.base.bold.sp(14).oldListGroupTitle(context);
    final hintTextStyle = TextUtil.base.regular.sp(12).oldHint(context);
    final arrow = Icon(Icons.arrow_forward_ios,
        color: WpyTheme.of(context).get(WpyColorKey.oldListActionColor),
        size: 22);
    final mainTextStyle = TextUtil.base.bold.sp(14).oldThirdAction(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: WpyTheme.of(context).brightness.uiOverlay.copyWith(
          systemNavigationBarColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('应用设置',
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
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('通用', style: titleTextStyle),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 15.w, 20.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: WButton(
                  onPressed: () {
                    WbyFontLoader.initFonts(hint: true);
                  },
                  child: Row(
                    children: [
                      Expanded(child: Text('重新加载字体文件', style: mainTextStyle)),
                      arrow,
                      SizedBox(width: 15.w),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('主页显示校园地图和校历', style: mainTextStyle),
                          SizedBox(height: 3.h),
                          Text('默认关闭', style: hintTextStyle)
                        ],
                      ),
                    ),
                    Switch(
                      value: CommonPreferences.showMap.value,
                      onChanged: (value) {
                        setState(() => CommonPreferences.showMap.value = value);
                      },
                      activeColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor),
                      inactiveThumbColor:
                          WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                      activeTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                      inactiveTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('主页显示GPA', style: mainTextStyle),
                          SizedBox(height: 3.h),
                          Text('默认关闭', style: hintTextStyle)
                        ],
                      ),
                    ),
                    Switch(
                      value: !CommonPreferences.hideGPA.value,
                      onChanged: (value) {
                        setState(
                            () => CommonPreferences.hideGPA.value = !value);
                        context.read<GPANotifier>().hideGPA = !value;
                      },
                      activeColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor),
                      inactiveThumbColor:
                          WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                      activeTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                      inactiveTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 10.h),
              // Container(
              //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              //   decoration: BoxDecoration(
              //     color:
              //         WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              //     borderRadius: BorderRadius.circular(12.r),
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text('开启深色模式', style: mainTextStyle),
              //             SizedBox(height: 3.h),
              //             Text('Beta功能 Bug乱飞', style: hintTextStyle)
              //           ],
              //         ),
              //       ),
              //       Switch(
              //         value: CommonPreferences.useDarkMode.value,
              //         onChanged: (value) {
              //           setState(() => CommonPreferences.useDarkMode.value = value);
              //           globalTheme.value =
              //               value ? WpyThemeData.dark() : WpyThemeData.light();
              //         },
              //         activeColor: WpyTheme.of(context)
              //             .get(WpyColorKey.oldSecondaryActionColor),
              //         inactiveThumbColor:
              //             WpyTheme.of(context).get(WpyColorKey.oldHintColor),
              //         activeTrackColor:
              //             WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
              //         inactiveTrackColor:
              //             WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: WButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRouter.themeSetting),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('主题设置', style: mainTextStyle),
                            SizedBox(height: 3.h),
                            Text(WpyTheme.of(context).name,
                                style: hintTextStyle)
                          ],
                        ),
                      ),
                      arrow,
                      SizedBox(width: 15.w),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: WButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AuthRouter.toolbarManage);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('高级编辑导航栏', style: mainTextStyle),
                            SizedBox(height: 3.h),
                            Text("自定义&增删改 或重置", style: hintTextStyle)
                          ],
                        ),
                      ),
                      Icon(Icons.edit,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.oldListActionColor),
                          size: 22),
                      SizedBox(width: 15.w),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 10.h),
              // Container(
              //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12.r),
              //   ),
              //   child: WButton(
              //     onPressed: () => Navigator.pushNamed(context, AuthRouter.themeSetting)
              //         .then((_) {
              //       /// 使用pop返回此页面时进行rebuild
              //       this.setState(() {});
              //     }),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text('主题', style: mainTextStyle),
              //               SizedBox(height: 3.h),
              //               Text('联网获取全部已获得主题', style: hintTextStyle)
              //             ],
              //           ),
              //         ),
              //         arrow,
              //         SizedBox(width: 15.w),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(height: 10.h),
              // Container(
              //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12.r),
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //           child: Text(S.current.setting_gpa, style: mainTextStyle)),
              //       Switch(
              //         value: CommonPreferences.hideGPA.value,
              //         onChanged: (value) {
              //           setState(() => CommonPreferences.hideGPA.value = value);
              //           Provider.of<GPANotifier>(context, listen: false).hideGPA =
              //               value;
              //         },
              //         activeColor: Color.fromRGBO(105, 109, 127, 1),
              //         inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
              //         activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
              //         inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 10.h),
              // Container(
              //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12.r),
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //           child: Text(S.current.setting_exam, style: mainTextStyle)),
              //       Switch(
              //         value: CommonPreferences.hideExam.value,
              //         onChanged: (value) {
              //           setState(() => CommonPreferences.hideExam.value = value);
              //           Provider.of<ExamProvider>(context, listen: false).hideExam =
              //               value;
              //         },
              //         activeColor: Color.fromRGBO(105, 109, 127, 1),
              //         inactiveThumbColor: Color.fromRGBO(205, 206, 212, 1),
              //         activeTrackColor: Color.fromRGBO(240, 241, 242, 1),
              //         inactiveTrackColor: Color.fromRGBO(240, 241, 242, 1),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('课程表', style: titleTextStyle),
              ),
              // SizedBox(height: 10.h),
              // // Container(
              // //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
              // //   decoration: BoxDecoration(
              // //     color:
              // //         WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
              // //     borderRadius: BorderRadius.circular(12.r),
              // //   ),
              // //   child: Row(
              // //     children: [
              // //       Expanded(
              // //         child: Column(
              // //           mainAxisAlignment: MainAxisAlignment.center,
              // //           crossAxisAlignment: CrossAxisAlignment.start,
              // //           children: [
              // //             Text('智能云端服务（BETA）', style: mainTextStyle),
              // //             SizedBox(height: 3.h),
              // //             Text('获取课表、GPA、考表无需输入图形验证码', style: hintTextStyle)
              // //           ],
              // //         ),
              // //       ),
              // //       Switch(
              // //         value: CommonPreferences.useClassesBackend.value,
              // //         onChanged: (value) {
              // //           setState(() =>
              // //               CommonPreferences.useClassesBackend.value = value);
              // //         },
              // //         activeColor: WpyTheme.of(context)
              // //             .get(WpyColorKey.oldSecondaryActionColor),
              // //         inactiveThumbColor:
              // //             WpyTheme.of(context).get(WpyColorKey.oldHintColor),
              // //         activeTrackColor:
              // //             WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
              // //         inactiveTrackColor:
              // //             WpyTheme.of(context).get(WpyColorKey.oldSwitchBarColor),
              // //       ),
              // //     ],
              // //   ),
              // // ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('开启夜猫子模式', style: mainTextStyle),
                          SizedBox(height: 3.h),
                          Text('晚上9:00以后首页课表将展示第二天课程安排', style: hintTextStyle)
                        ],
                      ),
                    ),
                    Switch(
                      value: CommonPreferences.nightMode.value,
                      onChanged: (value) {
                        setState(
                            () => CommonPreferences.nightMode.value = value);
                        Provider.of<CourseDisplayProvider>(context,
                                listen: false)
                            .nightMode = value;
                      },
                      activeColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor),
                      inactiveThumbColor:
                          WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                      activeTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                      inactiveTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('实验课显示详细内容', style: mainTextStyle),
                          SizedBox(height: 3.h),
                          Text('若开启时遇到课表显示问题，可在此处关闭', style: hintTextStyle)
                        ],
                      ),
                    ),
                    Switch(
                      value: CommonPreferences.isShowExperiment.value,
                      onChanged: (value) {
                        setState(() =>
                            CommonPreferences.isShowExperiment.value = value);
                        Provider.of<CourseDisplayProvider>(context,
                                listen: false)
                            .showExperiment = value;
                      },
                      activeColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor),
                      inactiveThumbColor:
                          WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                      activeTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                      inactiveTrackColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: WButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRouter.scheduleSetting)
                          .then((_) => this.setState(() {})),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('每周显示天数', style: mainTextStyle),
                            SizedBox(height: 5.h),
                            Text('${CommonPreferences.dayNumber.value}',
                                style: hintTextStyle)
                          ],
                        ),
                      ),
                      arrow,
                      SizedBox(width: 15.w),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('消息通知', style: titleTextStyle),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('求是论坛和信箱消息通知', style: mainTextStyle),
                          SizedBox(height: 3.h),
                          Text('应用消息通知', style: hintTextStyle)
                        ],
                      ),
                    ),
                    Builder(builder: (context) {
                      return Switch(
                        value: context
                            .select((PushManager manger) => manger.openPush),
                        onChanged: (value) {
                          if (value) {
                            context.read<PushManager>().turnOnPushService(() {
                              ToastProvider.success("开启推送成功");
                            }, () {
                              ToastProvider.success("开启推送需要通知权限");
                            }, () {
                              ToastProvider.error("打开失败");
                            });
                          } else {
                            context.read<PushManager>().turnOffPushService(() {
                              ToastProvider.success("关闭推送成功");
                            }, () {
                              ToastProvider.error("关闭失败");
                            });
                          }
                        },
                        activeColor: WpyTheme.of(context)
                            .get(WpyColorKey.oldSecondaryActionColor),
                        inactiveThumbColor:
                            WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                        activeTrackColor: WpyTheme.of(context)
                            .get(WpyColorKey.oldSwitchBarColor),
                        inactiveTrackColor: WpyTheme.of(context)
                            .get(WpyColorKey.oldSwitchBarColor),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('动画设置', style: titleTextStyle),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 15.w, 10.h),
                decoration: BoxDecoration(
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('动画速度', style: mainTextStyle),
                          SizedBox(height: 3.h),
                          Text(
                              '速度: ${[
                                "极快",
                                "较快",
                                "正常",
                                "较慢",
                                "极慢"
                              ][context.watch<AnimationProvider>().speedIndex]}',
                              style: hintTextStyle)
                        ],
                      ),
                    ),
                    Slider(
                      activeColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSecondaryActionColor),
                      inactiveColor:
                          WpyTheme.of(context).get(WpyColorKey.oldHintColor),
                      thumbColor: WpyTheme.of(context)
                          .get(WpyColorKey.oldSwitchBarColor),
                      value: context
                          .watch<AnimationProvider>()
                          .speedIndex
                          .toDouble(),
                      onChanged: (e) {
                        final v = e.toInt();
                        const speed = <double>[0.1, 0.5, 1, 1.5, 2];
                        context.read<AnimationProvider>().speed = speed[v];
                        context.read<AnimationProvider>().speedIndex = v;
                        timeDilation = speed[v];
                      },
                      min: 0,
                      max: 4,
                      divisions: 4,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/auth/view/login/find_pw_dialog.dart';
import 'package:we_pei_yang_flutter/commons/channel/push/push_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/statistics/umeng_statistics.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/home_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/view/profile_page.dart';
import 'package:we_pei_yang_flutter/home/view/wpy_page.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_provider.dart';
import 'package:we_pei_yang_flutter/urgent_report/report_server.dart';

import '../../auth/view/user/account_upgrade_dialog.dart';
import '../../commons/themes/wpy_theme.dart';
import '../../commons/update/dialog/update_failure_dialog.dart';
import '../../commons/update/dialog/widgets/today_check.dart';
import '../../schedule/extension/ui_extension.dart';

class HomePage extends StatefulWidget {
  final int? page;

  HomePage(this.page);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// bottomNavigationBar对应的分页
  List<Widget> pages = [];
  int _currentIndex = 0;
  DateTime? _lastPressedAt;
  late final TabController _tabController;
  final feedbackKey = GlobalKey<FeedbackHomePageState>();

  @override
  void initState() {
    super.initState();
    pages
      ..add(WPYPage())
      ..add(FeedbackHomePage(key: feedbackKey))
      ..add(ProfilePage());
    _tabController = TabController(
      length: pages.length,
      vsync: this,
      initialIndex: 0,
    )..addListener(() {
        if (_tabController.index != _tabController.previousIndex) {
          setState(() {
            _currentIndex = _tabController.index;
          });
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<PushManager>().initGeTuiSdk();

      final manager = context.read<PushManager>();
      final cid = (await manager.getCid()) ?? '';
      final now = DateTime.now();
      DateTime lastTime;
      try {
        lastTime = DateTime.tryParse(CommonPreferences.pushTime.value)!;
      } catch (_) {
        lastTime = now.subtract(Duration(days: 3));
      }
      if (cid != CommonPreferences.pushCid.value ||
          CommonPreferences.userNumber.value !=
              CommonPreferences.pushUser.value ||
          now.difference(lastTime).inDays >= 3) {
        AuthService.updateCid(cid, onResult: (_) {
          debugPrint('cid $cid 更新成功');
          CommonPreferences.pushCid.value = cid;
          CommonPreferences.pushUser.value = CommonPreferences.userNumber.value;
          CommonPreferences.pushTime.value =
              DateFormat('yyyy-MM-dd').format(now);
        }, onFailure: (_) {
          debugPrint('cid $cid 更新失败');
        });
      }

      var hasReport = await ReportService.getTodayHasReported();
      if (hasReport) {
        CommonPreferences.reportTime.value = DateTime.now().toString();
      } else {
        CommonPreferences.reportTime.value = '';
      }
      // 检查当前是否有未处理的事件
      context.findAncestorStateOfType<WePeiYangAppState>()?.checkEventList();
      // 友盟统计账号信息
      UmengCommonSdk.onProfileSignIn(CommonPreferences.account.value);
      // 刷新自习室数据
      context.read<CampusProvider>().init();
    });
    if (widget.page != null) {
      _tabController.animateTo(widget.page!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CommonPreferences.accountUpgrade.value.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AccountUpgradeDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = WePeiYangApp.screenWidth / 3;

    var homePage = SizedBox(
      height: 70.h,
      width: width,
      child: IconButton(
        splashRadius: 1,
        icon: _currentIndex == 0
            ? SvgPicture.asset(
                'assets/svg_pics/home.svg',
              )
            : SvgPicture.asset(
                'assets/svg_pics/home.svg',
                color: ColorUtil.grey144,
              ),
        color: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        onPressed: () => _tabController.animateTo(0),
      ),
    );

    var feedbackPage = SizedBox(
      height: 70.h,
      width: width,
      child: IconButton(
        splashRadius: 1,
        icon: _currentIndex == 1
            ? SvgPicture.asset(
                'assets/svg_pics/lake.svg',
              )
            : SvgPicture.asset(
                'assets/svg_pics/lake_grey.svg',
              ),
        color: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        onPressed: () {
          if (_currentIndex == 1) {
            feedbackKey.currentState?.listToTop();
            // 获取剪切板微口令
            context.read<LakeModel>().getClipboardWeKoContents(context);
          } else
            _tabController.animateTo(1);
        },
      ),
    );

    var selfPage = SizedBox(
      height: 70.h,
      width: width,
      child: IconButton(
        splashRadius: 1,
        icon: _currentIndex == 2
            ? SvgPicture.asset(
                'assets/svg_pics/my.svg',
              )
            : SvgPicture.asset(
                'assets/svg_pics/my.svg',
                color: ColorUtil.grey144,
              ),
        color: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        onPressed: () => _tabController.animateTo(2),
      ),
    );

    var bottomNavigationBar = Container(
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor),
        boxShadow: [
          BoxShadow(
              color: WpyTheme.of(context).get(WpyThemeKeys.dislikeSecondary),
              spreadRadius: -1,
              blurRadius: 2)
        ],
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
      ),

      /// 适配iOS底部安全区
      child: SafeArea(
        child: Row(children: <Widget>[homePage, feedbackPage, selfPage]),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _tabController.index == 2
          ? SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarColor:
                  WpyTheme.of(context).get(WpyThemeKeys.primaryBackgroundColor))
          : SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarColor: WpyTheme.of(context)
                  .get(WpyThemeKeys.primaryBackgroundColor)),
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: bottomNavigationBar,
        body: WillPopScope(
          onWillPop: () async {
            if (_tabController.index == 0) {
              if (_lastPressedAt == null ||
                  DateTime.now().difference(_lastPressedAt!) >
                      Duration(seconds: 1)) {
                //两次点击间隔超过1秒则重新计时
                _lastPressedAt = DateTime.now();
                ToastProvider.running('再按一次退出程序');
                return false;
              }
            } else if (context.read<LakeModel>().currentTab != 0) {
              context.read<LakeModel>().tabController.animateTo(0);
              return false;
            } else {
              _tabController.animateTo(0);
              return false;
            }
            return true;
          },
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: pages,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/post_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/activity_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/hot_rank_card.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/home_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';
import 'package:we_pei_yang_flutter/main.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';
import '../../../commons/themes/wpy_theme.dart';
import '../../../commons/widgets/w_button.dart';

class NSubPage extends StatefulWidget {
  final int index;

  const NSubPage({Key? key, required this.index}) : super(key: key);

  @override
  NSubPageState createState() => NSubPageState(this.index);
}

class NSubPageState extends State<NSubPage> with AutomaticKeepAliveClientMixin {
  int index;
  double _previousOffset = 0;

  bool get needHorizontalView => 1.sw > 1.sh;

  NSubPageState(this.index);

  List<String> topText = [
    "正在刷新喵",
  ];

  void getRecTag() {
    context.read<FbHotTagsProvider>().initRecTag(failure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    final lakeModel = context.read<LakeModel>();
    final lakeArea = lakeModel.lakeAreas[index]!;
    final refreshController = lakeArea.refreshController;
    final pixels = scrollInfo.metrics.pixels;
    final maxScrollExtent = scrollInfo.metrics.maxScrollExtent;
    final threshold = 12.h + FeedbackHomePageState().searchBarHeight;

    // Check for refresh idle state and feedback conditions
    if (refreshController.isRefresh && pixels >= 2) {
      refreshController.refreshToIdle();
    }
    // if (pixels < threshold) {
    //   lakeModel.onFeedbackOpen();
    // }
    //
    // // Toggle feedback based on scroll direction
    // if (_shouldToggleFeedback(scrollInfo, pixels, maxScrollExtent)) {
    //   pixels <= _previousOffset
    //       ? lakeModel.onFeedbackOpen()
    //       : lakeModel.onFeedbackClose();
    //   _previousOffset = pixels;
    // }

    return true;
  }

  bool _shouldToggleFeedback(
      ScrollNotification scrollInfo, double pixels, double maxScrollExtent) {
    return scrollInfo.metrics.axisDirection == AxisDirection.down &&
        (pixels - _previousOffset).abs() >= 20 &&
        pixels >= 10 &&
        pixels <= maxScrollExtent - 10;
  }

  Future<void> onRefresh({bool retry = true}) async {
    try {
      _setLoadingStatus();
      _initializeHotTagsIfNeeded();
      getRecTag();

      await _refreshPostList();
      _initializeAdditionalProviders();
    } catch (e) {
      await _handleRefreshError();
    }
  }

  void _setLoadingStatus() =>
      context.read<LakeModel>().lakeAreas[index]?.status =
          LakePageStatus.loading;

  void _initializeHotTagsIfNeeded() {
    if (index == 0) {
      context.read<FbHotTagsProvider>().initHotTags();
    }
  }

  Future<void> _refreshPostList() async {
    final lakeModel = context.read<LakeModel>();
    lakeModel.initPostList(
      index,
      success: () =>
          lakeModel.lakeAreas[index]?.refreshController.refreshCompleted(),
      failure: (e) => _handlePostListFailure(e),
    );
  }

  void _handlePostListFailure(DioException e) {
    final refreshController =
        context.read<LakeModel>().lakeAreas[index]?.refreshController;
    if ([
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout
    ].contains(e.type)) {
      refreshController?.refreshToIdle();
    }
    refreshController?.refreshFailed();
  }

  Future<void> _handleRefreshError() async {
    await LakeTokenManager().refreshToken();
    onRefresh(retry: true);
    ToastProvider.error("发生未知错误");
    context
        .read<LakeModel>()
        .lakeAreas[index]
        ?.refreshController
        .refreshFailed();
  }

  void _initializeAdditionalProviders() {
    context.read<FestivalProvider>().initFestivalList();
    context.read<NoticeProvider>().initNotices();
  }

  _onLoading() {
    final lakeModel = context.read<LakeModel>();
    lakeModel.getNextPage(index,
        success: () =>
            lakeModel.lakeAreas[index]?.refreshController.loadComplete(),
        failure: (e) =>
            lakeModel.lakeAreas[index]?.refreshController.loadFailed());
  }

  void listToTop() {
    final controller = context.read<LakeModel>().lakeAreas[index]!.controller;

    if (controller.offset > 1500) {
      controller.jumpTo(1500);
    }

    controller.animateTo(
      -85,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCirc,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeProvidersIfNeeded();
    _initializeLakeArea();
  }

  void _initializeProvidersIfNeeded() {
    if (index == 0) {
      _initializeAdditionalProviders();
      context.read<FbHotTagsProvider>().initHotTags();
    }
  }

  void _initializeLakeArea() {
    context.read<LakeModel>().fillLakeAreaAndInitPostList(
          index,
          RefreshController(),
          ScrollController(),
        );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var status =
        context.select((LakeModel model) => model.lakeAreas[index]!.status);

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Builder(
          key: ValueKey(status),
          builder: (BuildContext context) {
            if (status == LakePageStatus.idle)
              return NotificationListener<ScrollNotification>(
                child: SmartRefresher(
                  physics: BouncingScrollPhysics(),
                  controller: context
                      .read<LakeModel>()
                      .lakeAreas[index]!
                      .refreshController,
                  header: ClassicHeader(
                    height: 5.h,
                    completeDuration: Duration(milliseconds: 300),
                    idleText: '下拉以刷新 (乀*･ω･)乀',
                    releaseText: '下拉以刷新',
                    refreshingText: topText[Random().nextInt(topText.length)],
                    completeText: '刷新完成 (ﾉ*･ω･)ﾉ',
                    failedText: '刷新失败（；´д｀）ゞ',
                  ),
                  cacheExtent: 11,
                  enablePullDown: true,
                  onRefresh: onRefresh,
                  footer: ClassicFooter(
                    idleText: '下拉以刷新',
                    noDataText: '无数据',
                    loadingText: '加载中，请稍等  ;P',
                    failedText: '加载失败（；´д｀）ゞ',
                  ),
                  enablePullUp: true,
                  onLoading: _onLoading,
                  child: ListView.builder(
                    controller:
                        context.read<LakeModel>().lakeAreas[index]!.controller,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: context.select((LakeModel model) => index == 0
                        ? model.lakeAreas[index]!.dataList.values
                                .toList()
                                .length +
                            3
                        : model.lakeAreas[index]!.dataList.values
                                .toList()
                                .length +
                            2),
                    itemBuilder: (context, ind) {
                      if (ind == 0) return AnnouncementBannerWidget();
                      ind--;
                      if (ind == 0)
                        return index == 0 ? HotCard() : SizedBox(height: 10.h);
                      ind--;
                      if (ind == 0) return AdCardWidget();
                      ind--;
                      if (ind == 0)
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              WButton(
                                onPressed: () {
                                  setState(() {
                                    context.read<LakeModel>().sortSeq = 1;
                                    listToTop();
                                  });
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(20.w, 14.h, 5.w, 6.h),
                                  child: Text('默认排序',
                                      style:
                                          context.read<LakeModel>().sortSeq != 0
                                              ? TextUtil.base
                                                  .primaryAction(context)
                                                  .w600
                                                  .sp(14)
                                              : TextUtil.base
                                                  .label(context)
                                                  .w400
                                                  .sp(14)),
                                ),
                              ),
                              WButton(
                                onPressed: () {
                                  setState(() {
                                    context.read<LakeModel>().sortSeq = 0;
                                    listToTop();
                                  });
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(5.w, 14.h, 10.w, 6.h),
                                  child: Text('最新发帖',
                                      style:
                                          context.read<LakeModel>().sortSeq != 0
                                              ? TextUtil.base
                                                  .label(context)
                                                  .w400
                                                  .sp(14)
                                              : TextUtil.base
                                                  .primaryAction(context)
                                                  .w600
                                                  .sp(14)),
                                ),
                              ),
                            ]);
                      ind--;
                      final post = context
                          .read<LakeModel>()
                          .lakeAreas[index]!
                          .dataList
                          .values
                          .toList()[ind];
                      return PostCardNormal(post);
                    },
                  ),
                ),
                onNotification: (ScrollNotification scrollInfo) =>
                    _onScrollNotification(scrollInfo),
              );
            else if (status == LakePageStatus.unload)
              return SizedBox();
            else if (status == LakePageStatus.error)
              return HomeErrorContainer(onRefresh, true, index);
            else
              return LoadingPageWidget(index, onRefresh);
          }),
    );
  }
}

class AdCardWidget extends StatelessWidget {
  const AdCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _len = context.watch<FestivalProvider>().nonePopupListLength;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _len > 0
            ? ActivityCard(1.sw - 40.w)
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                  color: WpyTheme.of(context)
                      .get(WpyColorKey.primaryBackgroundColor),
                ),
                width: 1.sw - 40.w,
                height: (1.sw - 40.w) * 0.32,
              ),
      ),
    );
  }
}

class LoadingPageWidget extends StatefulWidget {
  final int index;
  final void Function() onPressed;

  LoadingPageWidget(this.index, this.onPressed);

  @override
  _LoadingPageWidgetState createState() => _LoadingPageWidgetState();
}

class _LoadingPageWidgetState extends State<LoadingPageWidget>
    with SingleTickerProviderStateMixin {
  bool isOpa = false;
  bool showBtn = false;
  late final Timer _timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
    isOpa = true;
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      count++;
      if (isOpa)
        isOpa = false;
      else
        isOpa = true;
      if (count > 50) {
        setState(() {
          showBtn = true;
        });
        _timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showBtn
        ? HomeErrorContainer(widget.onPressed, true, widget.index)
        : Stack(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 8,
                itemBuilder: (context, ind) {
                  return Builder(builder: (context) {
                    if (ind == 0)
                      return Container(
                        height: 35.h,
                        margin:
                            EdgeInsets.only(top: 14.h, left: 14.w, right: 14.w),
                        padding: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.primaryActionColor)
                                .withAlpha(12)),
                      );
                    ind--;
                    if (widget.index == 0 && ind == 0)
                      return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.dislikeSecondary),
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          height: 160.h);
                    if (widget.index != 0 && ind == 0)
                      return SizedBox(height: 10.h);
                    ind--;
                    if (ind == 0 &&
                        context.read<FestivalProvider>().nonePopupList.length >
                            0)
                      return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: WpyTheme.of(context)
                                .get(WpyColorKey.dislikeSecondary),
                          ),
                          margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          height: 0.32 * WePeiYangApp.screenWidth);
                    ind--;
                    if (ind == 0) return SizedBox(height: 20.h);
                    ind--;
                    return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.dislikeSecondary),
                        ),
                        margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                        height: 160.h);
                  });
                },
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 1.sw,
                height: 1.sh,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      if (isOpa)
                        WpyTheme.of(context)
                            .get(WpyColorKey.skeletonStartAColor)
                      else
                        WpyTheme.of(context)
                            .get(WpyColorKey.skeletonStartBColor),
                      if (!isOpa)
                        WpyTheme.of(context).get(WpyColorKey.skeletonEndAColor)
                      else
                        WpyTheme.of(context).get(WpyColorKey.skeletonEndBColor),
                    ],
                  ),
                ),
                // child: Center(child: Loading())
              )
            ],
          );
  }
}

class HomeErrorContainer extends StatefulWidget {
  final void Function() onPressed;
  final bool networkFailPageUsage;
  final int index;

  HomeErrorContainer(this.onPressed, this.networkFailPageUsage, this.index);

  @override
  _HomeErrorContainerState createState() => _HomeErrorContainerState();
}

class _HomeErrorContainerState extends State<HomeErrorContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  late final LakeModel _listProvider;
  late final FbDepartmentsProvider _tagsProvider;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurveTween(curve: Curves.easeInOutCubic).animate(controller);
    _listProvider = Provider.of<LakeModel>(context, listen: false);
    _tagsProvider = Provider.of<FbDepartmentsProvider>(context, listen: false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var errorImg = WpyPic('assets/images/lake_butt_icons/monkie.png',
        height: 160, width: 160);

    var errorText = Text(
        widget.networkFailPageUsage ? '错误！请重试' : '啊哦，没有找到相关消息... \n 要不然换一个试试？',
        style: TextUtil.base.label(context).NotoSansSC.w600.sp(16));

    var retryButton = FloatingActionButton(
      child: RotationTransition(
        alignment: Alignment.center,
        turns: animation,
        child: Icon(Icons.refresh),
      ),
      elevation: 4,
      heroTag: 'error_btn',
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      foregroundColor: WpyTheme.of(context).get(WpyColorKey.defaultActionColor),
      onPressed: () async {
        try {
          await LakeTokenManager().refreshToken();
          _tagsProvider.initDepartments();
          _listProvider.initPostList(widget.index, success: () {
            widget.onPressed;
          }, failure: (_) {
            controller.reset();
            ToastProvider.error('刷新失败');
          });
        } catch (e) {
          controller.reset();
          ToastProvider.error('刷新失败');
        } finally {
          if (!controller.isAnimating) {
            controller.repeat();
            widget.onPressed.call();
          }
        }
      },
      mini: true,
    );

    var paddingBox = SizedBox(height: WePeiYangApp.screenHeight / 8);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 120.h),
          errorImg,
          SizedBox(height: 20.h),
          errorText,
          paddingBox,
          widget.networkFailPageUsage ? retryButton : SizedBox(),
        ],
      ),
    );
  }
}

class AnnouncementBannerWidget extends StatelessWidget {
  const AnnouncementBannerWidget({super.key});

  String get _getGreetText {
    int hour = DateTime.now().hour;
    if (hour < 5)
      return '晚上好';
    else if (hour >= 5 && hour < 12)
      return '早上好';
    else if (hour >= 12 && hour < 14)
      return '中午好';
    else if (hour >= 12 && hour < 17)
      return '下午好';
    else if (hour >= 17 && hour < 19)
      return '傍晚好';
    else
      return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      margin: EdgeInsets.only(
          top: 12.h + FeedbackHomePageState().searchBarHeight,
          left: 14.w,
          right: 14.w),
      padding: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          color: WpyTheme.of(context)
              .get(WpyColorKey.primaryActionColor)
              .withAlpha(12)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 12),
            context.read<NoticeProvider>().noticeList.length > 0
                ? WButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svg_pics/lake_butt_icons/la_ba.svg",
                          width: 20,
                          colorFilter: ColorFilter.mode(
                              WpyTheme.of(context)
                                  .get(WpyColorKey.primaryActionColor),
                              BlendMode.srcIn),
                        ),
                        SizedBox(width: 6),
                        SizedBox(
                            width: WePeiYangApp.screenWidth - 83,
                            child: context
                                        .read<NoticeProvider>()
                                        .noticeList
                                        .length >
                                    1
                                ? TextScroller(
                                    stepOffset: 500,
                                    duration: Duration(seconds: 20),
                                    paddingLeft: 0.0,
                                    children: List.generate(
                                      context
                                          .read<NoticeProvider>()
                                          .noticeList
                                          .length,
                                      (index) => Text(
                                          '· ${context.read<NoticeProvider>().noticeList[index].title.length > 21 ? context.read<NoticeProvider>().noticeList[index].title.replaceAll('\n', ' ').substring(0, 20) + '...' : context.read<NoticeProvider>().noticeList[index].title.replaceAll('\n', ' ')}           ',
                                          style: TextUtil.base
                                              .primaryAction(context)
                                              .w400
                                              .NotoSansSC
                                              .sp(15)),
                                    ),
                                  )
                                : Text(
                                    '${context.read<NoticeProvider>().noticeList[0].title.length > 21 ? context.read<NoticeProvider>().noticeList[0].title.replaceAll('\n', ' ').substring(0, 20) + '...' : context.read<NoticeProvider>().noticeList[0].title.replaceAll('\n', ' ')}',
                                    style: TextUtil.base
                                        .primaryAction(context)
                                        .w400
                                        .NotoSansSC
                                        .sp(15))),
                      ],
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, HomeRouter.notice),
                  )
                : WButton(
                    child: SizedBox(
                      width: WePeiYangApp.screenWidth - 83,
                      child: Text(
                        '${_getGreetText}, ${CommonPreferences.lakeNickname.value == '无昵称' ? '微友' : CommonPreferences.lakeNickname.value.toString()}',
                        style: TextUtil.base
                            .primaryAction(context)
                            .w600
                            .NotoSansSC
                            .sp(16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, HomeRouter.notice),
                  ),
            Spacer()
          ]),
    );
  }
}

//https://www.cnblogs.com/qqcc1388/p/12405548.html
/// 跑马灯哗哗哗
class TextScroller extends StatefulWidget {
  final Duration duration; // 轮播时间
  final double stepOffset; // 偏移量
  final double paddingLeft; // 内容之间的间距
  final List<Widget> children; //内容

  TextScroller(
      {required this.paddingLeft,
      required this.duration,
      required this.stepOffset,
      required this.children});

  _TextScrollerState createState() => _TextScrollerState();
}

class _TextScrollerState extends State<TextScroller> {
  late ScrollController _controller; // 执行动画的controller
  late Timer _timer; // 定时器timer
  double _offset = 0.0; // 执行动画的偏移量

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: _offset);
    _timer = Timer.periodic(widget.duration, (timer) {
      double newOffset = _controller.offset + widget.stepOffset;
      if (newOffset != _offset) {
        _offset = newOffset;
        _controller.animateTo(_offset,
            duration: widget.duration, curve: Curves.linear); // 线性曲线动画
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _child() {
    return new Row(children: _children());
  }

  // 子视图
  List<Widget> _children() {
    List<Widget> items = [];
    List list = widget.children;
    for (var i = 0; i < list.length; i++) {
      Container item = new Container(
        margin: new EdgeInsets.only(right: widget.paddingLeft),
        child: list[i],
      );
      items.add(item);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal, // 横向滚动
      controller: _controller, // 滚动的controller
      itemBuilder: (context, index) {
        return _child();
      },
    );
  }
}

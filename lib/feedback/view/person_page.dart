import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/level_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/w_button.dart';
import '../feedback_router.dart';
import 'components/post_card.dart';
import 'components/widget/refresh_header.dart';
import 'image_view/image_view_page.dart';

class PersonPage extends StatefulWidget {
  final PersonPageArgs args;

  const PersonPage(this.args);

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class PersonPageArgs {
  final int postOrCommentId;
  final bool fromPostCard;
  final int type;
  final int uid;
  final String avatar;
  final String nickName;
  final String level;
  final String heroTag;

  PersonPageArgs(this.postOrCommentId, this.fromPostCard, this.type, this.uid,
      this.avatar, this.nickName, this.level, this.heroTag);
}

class _PersonPageState extends State<PersonPage> {
  List<Post> _postList = [];
  var _refreshController = RefreshController(initialRefresh: true);
  bool tap = false;
  int currentPage = 1;

  int? uid;
  String? avatar;
  String? nickName;
  String? level;

  _getAnyonePosts(
      {required Function(List<Post>) onSuccess, required Function onFail}) {
    FeedbackService.getAnyonePosts(
        uid: uid,
        page: currentPage,
        page_size: 10,
        onResult: (list) {
          setState(() {
            onSuccess.call(list);
          });
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          onFail.call();
        });
  }

  //刷新
  _onRefresh() {
    if (widget.args.fromPostCard)
      FeedbackService.getPostById(
          id: widget.args.postOrCommentId,
          onResult: (post) {
            uid = post.uid;
            avatar = post.avatar;
            nickName = post.nickname;
            level = post.level.toString();
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
    else
      FeedbackService.getFloorById(
          id: widget.args.postOrCommentId,
          onResult: (floor) {
            uid = floor.uid;
            avatar = floor.avatar;
            nickName = floor.nickname;
            level = floor.level.toString();
          },
          onFailure: (e) {
            ToastProvider.error(e.error.toString());
          });
    _postList.clear();
    currentPage = 1;
    _refreshController.resetNoData();
    _getAnyonePosts(onSuccess: (list) {
      _postList.addAll(list);
      _refreshController.refreshCompleted();
    }, onFail: () {
      _refreshController.refreshFailed();
    });
    setState(() {});
  }

//下拉加载
  _onLoading() {
    currentPage++;
    _getAnyonePosts(onSuccess: (list) {
      if (list.length == 0) {
        _refreshController.loadNoData();
        currentPage--;
      } else {
        _postList.addAll(list);
        _refreshController.loadComplete();
      }
    }, onFail: () {
      currentPage--;
      _refreshController.loadFailed();
    });
  }

  @override
  void initState() {
    uid = widget.args.uid;
    avatar = widget.args.avatar;
    nickName = widget.args.nickName;
    level = widget.args.level;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var postLists = (List.generate(
      _postList.length,
      (index) {
        Widget post = PostCardNormal(
          _postList[index],
          avatarClickable: false,
        );
        return post;
      },
    ));
    var postListShow;
    if (_postList.isEmpty) {
      postListShow = Container(
          height: 430,
          alignment: Alignment.center,
          child: Text("暂无冒泡", style: TextUtil.base.oldThirdAction(context)));
    } else {
      postListShow = Column(
        children: postLists,
      );
    }

//静态header，头像和资料以及appbar
    Widget appBar = Padding(
        padding: EdgeInsets.only(top: 10.h, left: 20.w, bottom: 10.h),
        child: Row(children: [
          WButton(
            onPressed: () {
              if (avatar != null && avatar != '')
                Navigator.pushNamed(
                  context,
                  FeedbackRouter.imageView,
                  arguments: ImageViewPageArgs([avatar!], 1, 0, false),
                );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: avatar == ""
                  ? Container(
                      decoration: BoxDecoration(
                        color: WpyTheme.of(context)
                            .get(WpyColorKey.secondaryBackgroundColor),
                      ),
                      width: 100.w,
                      height: 100.h,
                      child: Center(
                        child: Text(
                          nickName!.substring(0, 1),
                          style: TextUtil.base.w600.NotoSansSC.sp(40),
                        ),
                      ),
                    )
                  : WpyPic(
                      'https://qnhdpic.twt.edu.cn/download/origin/${avatar}',
                      width: 100.w,
                      height: 100.w,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 1.sw - 140.w,
                child: Text('${nickName}',
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextUtil.base.ProductSans
                        .infoText(context)
                        .w400
                        .sp(20)),
              ),
              Text('uid: ${uid}',
                  textAlign: TextAlign.start,
                  style:
                      TextUtil.base.ProductSans.infoText(context).w400.sp(14)),
              LevelUtil(
                level: level ?? '',
                style: TextUtil.base.bright(context).bold.sp(9),
              ),
            ],
          )
        ]));

    Widget manage = Padding(
        padding: EdgeInsets.only(top: 10.h, left: 20.w, bottom: 10.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (CommonPreferences.isSuper.value ||
              CommonPreferences.isStuAdmin.value)
            WButton(
              onPressed: () =>
                  _showResetConfirmDialog(context, '昵称').then((value) {
                if (value ?? false)
                  FeedbackService.adminResetName(
                      id: uid,
                      onSuccess: () {
                        ToastProvider.success('重置成功');
                      },
                      onFailure: (e) {
                        ToastProvider.error(e.message ?? '重置失败');
                      });
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  Text(
                    '重置昵称',
                    style: TextUtil.base.w600.NotoSansSC.sp(12).label(context),
                  ),
                ],
              ),
            ),
          SizedBox(height: 6),
          if (CommonPreferences.isSuper.value ||
              CommonPreferences.isStuAdmin.value)
            WButton(
              onPressed: () =>
                  _showResetConfirmDialog(context, '头像').then((value) {
                if (value ?? false)
                  FeedbackService.adminResetAva(
                      id: uid,
                      onSuccess: () {
                        ToastProvider.success('重置成功');
                      },
                      onFailure: (e) {
                        ToastProvider.error(e.message ?? '重置失败');
                      });
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  Text(
                    '重置头像',
                    style: TextUtil.base.w600.NotoSansSC.sp(12).label(context),
                  ),
                ],
              ),
            ),
          if (CommonPreferences.isSuper.value)
            WButton(
              onPressed: () => Navigator.pushNamed(
                  context, FeedbackRouter.openBox,
                  arguments: uid),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_search_rounded),
                  Text(
                    '开盒',
                    style: TextUtil.base.w600.NotoSansSC.sp(12).label(context),
                  ),
                ],
              ),
            ),
        ]));

    Widget body = ListView(
      children: [
        appBar,
        manage,
        if (CommonPreferences.isSuper.value ||
            CommonPreferences.isStuAdmin.value)
          postListShow,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('个人主页'),
        centerTitle: true,
        titleTextStyle: TextUtil.base.w600.NotoSansSC.sp(16).primary(context),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: WpyTheme.of(context).get(WpyColorKey.oldActionColor),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        child: SafeArea(
          child: (CommonPreferences.isSuper.value ||
                  CommonPreferences.isStuAdmin.value)
              ? SmartRefresher(
                  physics: BouncingScrollPhysics(),
                  controller: _refreshController,
                  header: RefreshHeader(context),
                  footer: ClassicFooter(
                    idleText: '没有更多数据了:>',
                    idleIcon: Icon(Icons.check),
                  ),
                  enablePullDown: true,
                  onRefresh: _onRefresh,
                  enablePullUp: true,
                  onLoading: _onLoading,
                  child: body,
                )
              : Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: WpyPic(
                        avatar == ""
                            ? '${EnvConfig.QNHD}avatar/beam/20/${uid}.svg'
                            : 'https://qnhdpic.twt.edu.cn/download/origin/${avatar}',
                        width: 1.sw,
                        height: 1.sw,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 1.sw,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                WpyTheme.of(context)
                                    .get(WpyColorKey.primaryBackgroundColor),
                                WpyTheme.of(context)
                                    .get(WpyColorKey.backgroundMaskColor),
                                WpyTheme.of(context).get(
                                    WpyColorKey.backgroundGradientEndColor),
                                WpyTheme.of(context)
                                    .get(WpyColorKey.liteBackgroundMaskColor)
                              ],
                              stops: [0, 0.4, 0.7, 1],
                              begin: Alignment(0, -1),
                              end: Alignment(0, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(child: appBar),
                  ],
                ),
        ),
      ),
    );
  }

  Future<bool?> _showResetConfirmDialog(BuildContext context, String quote) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return LakeDialogWidget(
              title: '重置$quote',
              content: Text('您确定要重置该用户$quote吗？'),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.label(context).NotoSansSC.sp(16).w400,
              cancelTextStyle:
                  TextUtil.base.normal.label(context).NotoSansSC.sp(16).w600,
              confirmText: '确认',
              cancelFun: () {
                Navigator.of(context).pop();
              },
              confirmFun: () {
                _refreshController.requestRefresh();
                Navigator.of(context).pop(true);
              });
        });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/icon_widget.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef LikeCallback = void Function(bool, int);

class NCommentCard extends StatefulWidget {
  final Floor comment;
  final int commentFloor;
  final LikeCallback likeSuccessCallback;
  final bool isSubFloor;

  @override
  _NCommentCardState createState() => _NCommentCardState();

  NCommentCard(
      {this.comment,
      this.commentFloor,
      this.likeSuccessCallback,
      this.isSubFloor});
}

class _NCommentCardState extends State<NCommentCard> {
  final String baseUrl = 'https://www.zrzz.site:7013/';

  Future<bool> _showDeleteConfirmDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('您确定要删除这条评论吗?'),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  //关闭对话框并返回true
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var box = SizedBox(height: 8);

    var topWidget = Row(
      children: [
        Icon(Icons.account_circle_rounded,
            size: 34, color: Color.fromRGBO(98, 103, 124, 1.0)),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.comment.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextUtil.base.black2A.w400.NotoSansSC.sp(14),
                  ),
                  if (widget.comment.nickname == 'Owner')
                    CommentIdentificationContainer('楼主', true),
                  widget.comment.replyToName == ''
                      ? Container()
                      : Row(
                        children: [
                          SizedBox(width: 3),
                          Icon(Icons.play_arrow, size: 8),
                          SizedBox(width: 3),
                          Text(
                              widget.comment.replyToName,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextUtil.base.grey97.w400.NotoSansSC.sp(14),
                            ),
                        ],
                      ),
                  if (widget.comment.replyToName == 'Owner')
                    CommentIdentificationContainer('楼主', false),
                  if (widget.comment.isOwner) Text('我的回复'),
                ],
              ),
              Text(
                DateTime.now()
                    .difference(widget.comment.createAt)
                    .dayHourMinuteSecondFormatted(),
                style: TextUtil.base.ProductSans.grey97.regular.sp(10),
              ),
            ],
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
              'assets/svg_pics/lake_butt_icons/more_horizontal.svg'),
          iconSize: 16,
          onPressed: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(1000, kToolbarHeight, 0, 0),
              //TODO:需要处理
              items: <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: '分享',
                  child: new Text(
                    '分享',
                    style: TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                  ),
                ),
                widget.comment.isOwner
                    ? PopupMenuItem<String>(
                        value: '删除',
                        child: new Text(
                          '删除',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      )
                    : PopupMenuItem<String>(
                        value: '举报',
                        child: new Text(
                          '举报',
                          style:
                              TextUtil.base.black2A.regular.NotoSansSC.sp(12),
                        ),
                      ),
              ],
            ).then((value) async {
              if (value == '举报') {
                //TODO:举报
                Navigator.pushNamed(context, FeedbackRouter.report,
                    arguments: ReportPageArgs(widget.comment.id, false));
              } else if (value == '删除') {
                bool confirm = await _showDeleteConfirmDialog();
                if (confirm) {
                  FeedbackService.deleteFloor(
                    id: widget.comment.id,
                    onSuccess: () {
                      ToastProvider.success(S.current.feedback_delete_success);
                      setState(() {});
                    },
                    onFailure: (e) {
                      ToastProvider.error(e.error.toString());
                    },
                  );
                }
              }
            });
          },
          constraints: BoxConstraints(),
          padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
        )
      ],
    );

    var commentContent = Text(
      widget.comment.content,
      style: TextUtil.base.w400.NotoSansSC.normal.black2A.sp(14),
    );

    var commentImage = Image.network(baseUrl + widget.comment.imageUrl);

    var replyButton = IconButton(
      icon: SvgPicture.asset('assets/svg_pics/lake_butt_icons/reply.svg'),
      iconSize: 16,
      constraints: BoxConstraints(),
      onPressed: () {
        context.read<NewFloorProvider>().replyTo = widget.comment.id;
        context.read<NewFloorProvider>().focusNode.requestFocus();
      },
      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
      color: ColorUtil.boldLakeTextColor,
    );

    var subFloor;
    if (widget.comment.subFloors != null && !widget.isSubFloor) {
      subFloor = ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.comment.subFloorCnt,
        itemBuilder: (context, index) {
          return NCommentCard(
            comment: widget.comment.subFloors[index],
            commentFloor: index + 1,
            isSubFloor: true,
            // likeSuccessCallback: (isLiked, count) {
            //   data.isLiked = isLiked;
            //   data.likeCount = count;
            // },
          );
        },
      );
    }

    // var reportWidget = IconButton(
    //     iconSize: 20,
    //     padding: const EdgeInsets.all(2),
    //     constraints: BoxConstraints(),
    //     icon: Icon(
    //       Icons.warning_amber_rounded,
    //       color: ColorUtil.lightTextColor,
    //     ),
    //     onPressed: () {
    //       Navigator.pushNamed(context, FeedbackRouter.report,
    //           arguments: ReportPageArgs(widget.comment.id, false));
    //     });

    var likeWidget = IconWidget(IconType.like, count: widget.comment.likeCount,
        onLikePressed: (isLiked, count, success, failure) async {
      await FeedbackService.commentHitLike(
        id: widget.comment.id,
        isLike: widget.comment.isLike,
        onSuccess: () {
          widget.likeSuccessCallback?.call(!isLiked, count);
          success.call();
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          failure.call();
        },
      );
    }, isLike: widget.comment.isLike);

    var bottomWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        likeWidget,
        replyButton,
      ],
    );

    var mainBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box,
        topWidget,
        box,
        box,
        commentContent,
        if (widget.comment.imageUrl != null) box,
        if (widget.comment.imageUrl != null) commentImage,
        bottomWidget,
      ],
    );

    return Column(
      children: [
        ClipCopy(
          copy: widget.comment.content,
          toast: '复制评论成功',
          // 这个padding其实起到的是margin的效果，因为Ink没有margin属性
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            // 这个Ink是为了确保body -> bottomWidget -> reportWidget的波纹效果正常显示
            child: Ink(
              padding: EdgeInsets.fromLTRB(16.w, 8, 16.w, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5,
                      color: Color.fromARGB(64, 236, 237, 239),
                      offset: Offset(0, 0),
                      spreadRadius: 3),
                ],
              ),
              child: mainBody,
            ),
          ),
        ),
        if (!widget.isSubFloor && subFloor != null)
          Padding(padding: EdgeInsets.fromLTRB(32.w, 0, 0, 0), child: subFloor),
      ],
    );
  }
}

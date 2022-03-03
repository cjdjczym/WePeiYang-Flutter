import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/dialog_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/clip_copy.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/round_taggings.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';


enum Official { detail, reply }

typedef LikeCallback = void Function(bool, int);
typedef ContentPressedCallback = void Function(void Function(Floor));



class OfficialReplyCard extends StatefulWidget {
  final String tag;
  final Floor comment;
  final String title;
  final Official type;
  final int ancestorId;
  final ContentPressedCallback onContentPressed;
  final LikeCallback onLikePressed;
  final int placeAppeared;
  int ratings;

  OfficialReplyCard.detail({
    this.tag,
    this.comment,
    this.title,
    this.ancestorId,
    this.onLikePressed,
    this.placeAppeared,
  })  : type = Official.detail,
        onContentPressed = null;

  OfficialReplyCard.reply({
    this.tag,
    this.comment,
    this.title,
    this.ancestorId,
    this.onContentPressed,
    this.onLikePressed,
    this.placeAppeared,
  }) : type = Official.reply;

  @override
  _OfficialReplyCardState createState() => _OfficialReplyCardState();
}

class _OfficialReplyCardState extends State<OfficialReplyCard> {
  double _rating;
  double _initialRating = 0;

  @override
  void initState() {
    _rating = _initialRating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> column = [];
    var OfficialLogo = Row(
      children: [
        Image.asset(
          widget.tag == '天外天' ? 'assets/images/twt.png' : 'assets/images/school.png',
          height: widget.tag == '天外天' ? 18 : 24,
          width: 30,
          fit: BoxFit.contain,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(widget.tag ?? '官方',
                  style: TextUtil.base.NotoSansSC.black2A.normal.w500.sp(14)),
              CommentIdentificationContainer('官方', true),
            ]),
            Text(
              DateTime.now().difference(widget.comment.createAt).inHours >= 11
                  ? widget.comment.createAt
                      .toLocal()
                      .toIso8601String()
                      .replaceRange(10, 11, ' ')
                      .substring(0, 19)
                  : DateTime.now()
                      .difference(widget.comment.createAt)
                      .dayHourMinuteSecondFormatted(),
              style: TextUtil.base.ProductSans.grey97.regular.sp(10),
            ),
          ],
        )
      ],
    );
    var box = SizedBox(height: 6);
    var createTime = Row(
      children: [
        OfficialLogo,
        Spacer(),
      ],
    );
    Widget starWidget;
    if (CommonPreferences().feedbackUid.value == widget.ancestorId) {
      starWidget = GestureDetector(
        onTap: ()async{
          ratingCard();
        },
        child: Row(children: [
          Text(
            S.current.feedback_rating,
            style: TextUtil.base.NotoSansSC.black2A.normal.w500.sp(14),
          ),
          RatingBar.builder(
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            allowHalfRating: true,
            glow: false,
            initialRating: _rating,
            itemCount: 5,
            itemSize: 16.w,
            ignoreGestures: true,
            unratedColor: ColorUtil.lightTextColor,
            onRatingUpdate: (_) {},
          ),
        ]),
      );
    } else {
      starWidget = Row(children: [
        Text(
          S.current.feedback_rating,
          style: TextUtil.base.NotoSansSC.black2A.normal.w500.sp(14),
        ),
        RatingBar.builder(
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: Colors.yellow,
          ),
          allowHalfRating: true,
          glow: false,
          initialRating: _initialRating,
          itemCount: 5,
          itemSize: 16.w,
          ignoreGestures: true,
          unratedColor: ColorUtil.lightTextColor,
          onRatingUpdate: (_) {},
        ),
      ]);
    }

    var bottomWidget = Row(
      children: [starWidget, Spacer()],
    );

    switch (widget.type) {
      case Official.detail:
        var title = Text(
          widget.title,
          style: FontManager.YaHeiRegular.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ColorUtil.boldTextColor,
          ),
        );
        var divider = Divider(
          height: 0.6,
          color: Color(0xffacaeba),
        );

        column.addAll([
          box,
          title,
          box,
          divider,
          box,
          createTime,
          box,
          box,
          bottomWidget
        ]);

        break;
      case Official.reply:
        var comment = RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          text: HTML.toTextSpan(
            context,
            widget.comment.content,
            defaultTextStyle:
                TextUtil.base.w400.normal.black2A.NotoSansSC.sp(16),
          ),
        );

        column.addAll([
          box,
          createTime,
          box,
          comment,
          box,
          bottomWidget,
          box
        ]);

        break;
    }

    Widget list = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: column),
    );

    return InkWell(
      onTap: () {
        widget.onContentPressed?.call((comment) {
          setState(() {
            widget.comment.isLike = comment.isLike;
            widget.comment.likeCount = comment.likeCount;
            widget.comment.rating = comment.rating;
          });
        });
      },
      child: ClipCopy(
        copy: widget.comment.content,
        toast: '复制评论成功',
        child: Container(
          padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          child: list,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  color: Color.fromARGB(64, 236, 237, 239),
                  offset: Offset(0, 0),
                  spreadRadius: 3),
            ],
          ),
        ),
      ),
    );
  }

  ratingCard()  {
    final checkedNotifier = ValueNotifier(_rating);
    final List<String> comments= ['请对官方回复态度进行评分','很差','较差','一般','较好','非常满意'];
    Widget ratingBars =  RatingBar.builder(
      initialRating: _initialRating,
      minRating: 0,
      allowHalfRating: true,
      unratedColor: Colors.grey,
      itemCount: 5,
      itemSize: 47.w,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
          checkedNotifier.value =rating;
        });
      },
      updateOnDrag: true,
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogWidget(
              title: "",
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<double>(
                      valueListenable: checkedNotifier,
                      builder: (context, type, _) {
                      return Text('「'+(checkedNotifier.value<1?comments[0]:comments[checkedNotifier.value.toInt()])+'」',
                          style:
                              TextUtil.base.normal.black00.NotoSansSC.sp(16).w400);
                    }
                  ),
                  ratingBars,
                ],
              ),
              cancelText: "取消",
              confirmTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(14).w400,
              cancelTextStyle:
                  TextUtil.base.normal.black2A.NotoSansSC.sp(14).w400,
              confirmText: "提交",
              cancelFun: () {
                Navigator.pop(context);
              },
              confirmFun: () {
               FeedbackService.rate(
                   id:widget.comment.postId,
                   rating: _rating,
                   onSuccess: (){
                     ToastProvider.success("评分成功！");
                     setState(() {
                       Navigator.pop(context);
                     });
                   },
                   onFailure:(e) {
                     ToastProvider.error("204 no content");
                     Navigator.pop(context);
                   });
              });
        });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:like_button/like_button.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

typedef WithCountNotifierCallback = Future<void> Function(
    bool, int, Function onSuccess, Function onFailure);

enum IconType { like, bottomLike, fav, bottomFav }

extension IconTypeExt on IconType {
  Image get iconFilled => [
        Image.asset('assets/images/lake_butt_icons/like_filled.png'),
        Image.asset('assets/images/lake_butt_icons/like_filled.png'),
        Image.asset('assets/images/lake_butt_icons/favorite_filled.png'),
        Image.asset('assets/images/lake_butt_icons/favorite_filled.png')
      ][index];

  Image iconOutlined(context) {
    final iconColor = WpyTheme.of(context).get(WpyColorKey.infoTextColor);
    return [
      Image.asset('assets/images/lake_butt_icons/like_outlined.png',
          color: iconColor),
      Image.asset('assets/images/lake_butt_icons/like_outlined.png',
          color: iconColor),
      Image.asset('assets/images/lake_butt_icons/favorite_outlined.png',
          color: iconColor),
      Image.asset('assets/images/lake_butt_icons/favorite_outlined.png',
          color: iconColor)
    ][index];
  }

  double get size => [15.w, 22.w, 15.w, 22.w][index];

  CircleColor circleColor(context) => [
        CircleColor(
            start:
                WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
            end: WpyTheme.of(context).get(WpyColorKey.likeColor)),
        CircleColor(
            start:
                WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
            end: WpyTheme.of(context).get(WpyColorKey.likeColor)),
        CircleColor(
            start:
                WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
            end: WpyTheme.of(context).get(WpyColorKey.FavorColor)),
        CircleColor(
            start:
                WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
            end: WpyTheme.of(context).get(WpyColorKey.FavorColor)),
      ][index];

  BubblesColor bubblesColor(context) => [
        BubblesColor(
          dotPrimaryColor: WpyTheme.of(context).get(WpyColorKey.likeColor),
          dotSecondaryColor:
              WpyTheme.of(context).get(WpyColorKey.likeBubbleColor),
        ),
        BubblesColor(
          dotPrimaryColor: WpyTheme.of(context).get(WpyColorKey.likeColor),
          dotSecondaryColor:
              WpyTheme.of(context).get(WpyColorKey.likeBubbleColor),
        ),
        BubblesColor(
          dotPrimaryColor:
              WpyTheme.of(context).get(WpyColorKey.FavorBubbleStartColor),
          dotSecondaryColor:
              WpyTheme.of(context).get(WpyColorKey.FavorBubbleColor),
        ),
        BubblesColor(
          dotPrimaryColor:
              WpyTheme.of(context).get(WpyColorKey.FavorBubbleStartColor),
          dotSecondaryColor:
              WpyTheme.of(context).get(WpyColorKey.FavorBubbleColor),
        ),
      ][index];

  double get textSize => [12.0, 14.0, 12.0, 14.0][index];
}

class IconWidget extends StatefulWidget {
  final int count;
  final double size;
  final bool isLike;
  final WithCountNotifierCallback onLikePressed;
  final IconType iconType;

  final ValueNotifier<int> countNotifier;
  final ValueNotifier<bool> isLikedNotifier;

  IconWidget(this.iconType,
      {required this.count,
      required this.isLike,
      required this.onLikePressed,
      required this.size})
      : countNotifier = ValueNotifier(count),
        isLikedNotifier = ValueNotifier(isLike);

  @override
  _IconWidgetState createState() => _IconWidgetState();
}

class _IconWidgetState extends State<IconWidget> {
  @override
  Widget build(BuildContext context) {
    var likeButton = ValueListenableBuilder(
      valueListenable: widget.isLikedNotifier,
      builder: (_, bool value, __) {
        return LikeButton(
          size: widget.size,
          likeCountPadding: EdgeInsets.only(right: 5.17.r),
          likeBuilder: (bool isLiked) {
            if (isLiked) {
              return widget.iconType.iconFilled;
            } else {
              return widget.iconType.iconOutlined(context);
            }
          },
          onTap: (value) async {
            if (value) {
              widget.countNotifier.value--;
            } else {
              widget.countNotifier.value++;
            }
            widget.onLikePressed(value, widget.countNotifier.value, () {
              widget.isLikedNotifier.value = !value;
            }, () {
              if (value) {
                widget.countNotifier.value++;
              } else {
                widget.countNotifier.value--;
              }
              setState(() {});
            });
            return !value;
          },
          isLiked: value,
          circleColor: widget.iconType.circleColor(context),
          bubblesColor: widget.iconType.bubblesColor(context),
          animationDuration: Duration(milliseconds: 600),
        );
      },
    );

    var likeCount = ValueListenableBuilder(
        valueListenable: widget.countNotifier,
        builder: (_, int value, __) {
          return Text(
            value.toString() + (value < 100 ? '   ' : ' '),
            style: TextUtil.base
                .label(context)
                .bold
                .ProductSans
                .sp(widget.iconType.textSize),
          );
        });

    var likeWidget = Row(
      children: [likeButton, likeCount],
    );
    return likeWidget;
  }
}

typedef DislikeNotifierCallback = void Function(bool);

class DislikeWidget extends StatelessWidget {
  final bool isDislike;
  final DislikeNotifierCallback onDislikePressed;

  final ValueNotifier<bool> isDislikedNotifier;
  final double size;

  DislikeWidget(
      {required this.onDislikePressed,
      required this.isDislike,
      required this.size})
      : isDislikedNotifier = ValueNotifier(isDislike);

  @override
  Widget build(BuildContext context) {
    var dislikeButton = ValueListenableBuilder(
      valueListenable: isDislikedNotifier,
      builder: (_, bool value, __) {
        return LikeButton(
          size: size,
          likeBuilder: (bool isDisliked) {
            if (isDisliked) {
              return Image.asset(
                  'assets/images/lake_butt_icons/dislike_filled.png');
            } else {
              return Image.asset(
                  'assets/images/lake_butt_icons/dislike_outlined.png',
                  color: WpyTheme.of(context).get(WpyColorKey.infoTextColor));
            }
          },
          onTap: (value) async {
            onDislikePressed.call(isDislikedNotifier.value);
            return !value;
          },
          isLiked: value,
          // end的值是Colors.blue[200]
          circleColor: CircleColor(
              start:
                  WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
              end: WpyTheme.of(context).get(WpyColorKey.dislikePrimary)),
          bubblesColor: BubblesColor(
            dotPrimaryColor:
                WpyTheme.of(context).get(WpyColorKey.dislikePrimary),
            dotSecondaryColor:
                WpyTheme.of(context).get(WpyColorKey.dislikeSecondary),
          ),
          animationDuration: Duration(milliseconds: 600),
        );
      },
    );

    return dislikeButton;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/image_view_page.dart';
import '../../../../../commons/environment/config.dart';
import '../../../../../commons/themes/template/wpy_theme_data.dart';
import '../../../../../commons/themes/wpy_theme.dart';
import '../../../../../commons/widgets/wpy_pic.dart';

final String picBaseUrl = '${EnvConfig.QNHDPIC}download/';
final radius = 4.r;

//外侧的单张图片
class OuterSinglePostPic extends StatelessWidget {
  final String imgUrl;

  OuterSinglePostPic({required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, layout) {
      return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          child: Container(
            width: layout.maxWidth,
            height: 150,
            color:
                WpyTheme.of(context).get(WpyColorKey.iconAnimationStartColor),
            //追踪首页帖子单图
            child: WpyPic(
              picBaseUrl + 'origin/' + imgUrl,
              fit: BoxFit.cover,
              withHolder: true,
              withCache: true,
              width: layout.maxWidth,
              alignment: Alignment.topCenter,
            ),
          ));
    });
  }
}

//外侧的多张图片(区别在于能否点击预览)
class OuterMultiPostPic extends StatelessWidget {
  final List<String> imgUrls;
  final bool isOuter;

  const OuterMultiPostPic(
      {Key? key, required this.imgUrls, this.isOuter = true})
      : super(key: key);

  bool isMaskedImage(String url) {
    if (url.contains("#") && url.split("#").last.contains("masked"))
      return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, layout) {
      double padding = 4.w;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          imgUrls.length,
          (index) => Padding(
            padding: EdgeInsets.all(padding),
            child: IgnorePointer(
              ignoring: isOuter && !isMaskedImage(imgUrls[index]),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      FeedbackRouter.imageView,
                      arguments: ImageViewPageArgs(
                          imgUrls, imgUrls.length, index, false),
                    );
                  },
                  child: SizedBox(
                    width: layout.maxWidth / imgUrls.length - padding * 2,
                    height: layout.maxWidth / imgUrls.length - padding * 2,
                    child: WpyPic(
                      picBaseUrl + 'thumb/' + imgUrls[index],
                      width: layout.maxWidth / imgUrls.length - padding * 2,
                      fit: BoxFit.cover,
                      withHolder: true,
                      withCache: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

///该组件用于表达论坛帖子的预览图片,详见设计图
///参数为需要展示的url(仅此而已)
class PostPreviewPic extends StatelessWidget {
  final List<String> imgUrls;

  const PostPreviewPic({Key? key, required this.imgUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imgUrls.length == 0) {
      return SizedBox.shrink();
    } else if (imgUrls.length == 1) {
      return OuterSinglePostPic(imgUrl: imgUrls[0]);
    } else {
      return OuterMultiPostPic(imgUrls: imgUrls);
    }
  }
}

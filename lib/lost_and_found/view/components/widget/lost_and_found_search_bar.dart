import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/lake_home_page/lake_notifier.dart';

import '../../../../commons/themes/wpy_theme.dart';

List<SearchTag> tagUtil = [];

typedef SubmitCallback = void Function(String);
typedef ChangeCallback = void Function(String);

class LostAndFoundSearchBar extends StatefulWidget {
  final SubmitCallback onSubmitted;

  const LostAndFoundSearchBar({Key? key, required this.onSubmitted})
      : super(key: key);

  @override
  _LostAndFoundSearchBarState createState() => _LostAndFoundSearchBarState();
}

class _LostAndFoundSearchBarState extends State<LostAndFoundSearchBar>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  FocusNode _fNode = FocusNode();
  List<Widget> tagList = [SizedBox(height: 4)];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget searchInputField = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 30,
      ),
      child: Padding(
        padding: EdgeInsets.only(top:5.h),
        child: Row(
              children: [
                Expanded(
                  child: Consumer<FbHotTagsProvider>(
                    builder: (_, data, __) => TextField(
                      controller: _controller,
                      focusNode: _fNode,
                      style: TextStyle().label(context).NotoSansSC.w400.sp(15),
                      decoration: InputDecoration(
                        hintStyle:
                            TextStyle().infoText(context).NotoSansSC.w400.sp(15),
                        hintText: data.recTag == null ? '天大不能没有微北洋' : '暂无相关内容',
                        contentPadding: EdgeInsets.only(right: 6.w),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(1080.w),
                        ),
                        fillColor: WpyTheme.of(context)
                            .get(WpyColorKey.secondaryBackgroundColor),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.search,
                          size: 19.w,
                          color: WpyTheme.of(context)
                              .get(WpyColorKey.infoTextColor),
                        ),
                      ),
                      enabled: true,
                      onSubmitted: (content) {
                        if (content.isNotEmpty) {
                          widget.onSubmitted.call(content);
                        } else {}
                      },
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );

    return Column(
      children: [
        Container(
            color:
                WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            child: searchInputField,
            padding: EdgeInsets.symmetric(vertical: 6.h)),
        SizedBox(height: 8.w),
      ],
    );
  }
}

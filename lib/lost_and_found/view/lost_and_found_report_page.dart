import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

import '../../commons/themes/wpy_theme.dart';

class LostAndFoundReportPage extends StatelessWidget {
  LostAndFoundReportPage();

  @override
  Widget build(BuildContext context) {
    ///进入页面的时候会有非空断言报错
    try {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            // 取消阴影
            backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
            leading: IconButton(
              icon: Image.asset(
                'assets/images/back.png',
                width: 30.w,
                height: 30.h,
              ),
              onPressed: () => Navigator.pop(context),
            ),

            title: Text(
                '举报', style: TextUtil.base.w500.primary(context).sp(18)),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(20.r), // 使用 EdgeInsets.all 设置 padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 360.w,
                  height: 50.h,
                  child: TextFormField(
                    style: TextUtil.base.sp(19),
                    decoration: InputDecoration(
                      hintText: "你正在举报“MP000001",
                    ),
                  ),
                ),
                SizedBox(height: 33.h),
                Text(
                  '请填写举报理由，如“色情暴力”“政治敏感”等',
                  style: TextUtil.base.sp(17).customColor(Colors.grey[700]!),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.only(left: 290.w, top: 270.h),
                    width: 80.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: WpyTheme.of(context)
                          .get(WpyColorKey.primaryActionColor),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: Text(
                        '发送',
                        style: TextUtil.base.reverse(context).sp(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    } catch (e,stacktrace) {
      print(e);
      print(stacktrace);
      return Container();
    }
  }
}

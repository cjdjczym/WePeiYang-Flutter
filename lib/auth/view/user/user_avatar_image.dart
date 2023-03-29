import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../commons/widgets/wpy_pic.dart';

class UserAvatarImage extends StatelessWidget {
  final double size;
  final Color iconColor;
  final String tempUrl;
  final bool useTemp;

  UserAvatarImage({
    @required this.size,
    this.iconColor = const Color.fromRGBO(98, 103, 124, 1),
    this.tempUrl = "",
    this.useTemp = false,
  });

  @override
  Widget build(BuildContext context) {
    var avatar = CommonPreferences.avatar.value;

    var avatarBox =
        useTemp == true ? tempUrl : CommonPreferences.avatarBoxMyUrl.value;

    return avatar == ''
        //? Icon(Icons.account_box_rounded, size: size, color: iconColor)
        ? ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(500.r)),
            child: WpyPic(
              'assets/images/default_image.png',
              withHolder: true,
            ))
        : ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(500.r)),
            child: WpyPic(
              'https://qnhdpic.twt.edu.cn/download/origin/' + avatar,
              withHolder: true,
              width: size,
              height: size,
            ),
          );
  }
}

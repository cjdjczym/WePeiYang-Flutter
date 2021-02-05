import 'package:flutter/material.dart' show Widget;
import 'package:wei_pei_yang_demo/auth/view/login/add_info_page.dart';
import 'package:wei_pei_yang_demo/auth/view/login/find_pw_page.dart';
import 'package:wei_pei_yang_demo/auth/view/login/login_page.dart';
import 'package:wei_pei_yang_demo/auth/view/login/login_pw_page.dart';
import 'package:wei_pei_yang_demo/auth/view/login/register_page.dart';
import 'package:wei_pei_yang_demo/auth/view/login/reset_done_page.dart';
import 'package:wei_pei_yang_demo/auth/view/login/reset_pw_page.dart';
import 'package:wei_pei_yang_demo/auth/view/tju_bind_page.dart';
import 'package:wei_pei_yang_demo/auth/view/user_page.dart';

class AuthRouter {
  static String login = '/login';
  static String loginPw = '/login_pw';
  static String register1 = '/register1';
  static String register2 = '/register2';
  static String addInfo = '/add_info';
  static String findHome = '/find_home';
  static String findPhone = '/find_phone';
  static String reset = '/reset';
  static String resetDone = '/reset_done';
  static String bind = '/bind';
  static String user = '/user';

  static final Map<String, Widget Function(Object arguments)> routers = {
    login: (_) => LoginHomeWidget(),
    loginPw: (_) => LoginPwWidget(),
    register1: (_) => RegisterPageOne(),
    register2: (_) => RegisterPageTwo(),
    addInfo: (_) => AddInfoWidget(),
    findHome: (_) => FindPwWidget(),
    findPhone: (_) => FindPwByPhoneWidget(),
    reset: (_) => ResetPwWidget(),
    resetDone: (_) => ResetDoneWidget(),
    bind: (_) => TjuBindWidget(),
    user: (_) => UserPage()
  };
}

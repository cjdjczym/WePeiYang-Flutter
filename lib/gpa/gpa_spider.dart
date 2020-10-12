import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/network/spider_service.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/gpa/gpa_model.dart';

/// 发送请求，获取html中的gpa数据
Future<void> getGPABean(
    {@required void Function(GPABean) onSuccess,
    void Function(DioError) onFailure}) async {
  var pref = CommonPreferences.create();
  var jSessionId = "J" + pref.gSessionId.substring(1);
  var cookieList = [pref.gSessionId, jSessionId, pref.garbled, pref.semesterId];
  await fetch(
      "http://classes.tju.edu.cn/eams/teach/grade/course/person!historyCourseGrade.action?projectType=MAJOR",
      cookieList: cookieList,
      onSuccess: (response) =>
          onSuccess(_data2GPABean(response.data.toString())),
      onFailure: onFailure);
}

const double _DELAYED = 999.0;
const double _IGNORED = 999.0;

/// 用请求到的html数据生成gpaBean对象
GPABean _data2GPABean(String data) {
  /// 匹配总加权/绩点/学分
  var totalData = getRegExpStr(r'(?<=总计\<\/th\>)[\s\S]*?(?=\<\/tr)', data);
  List<double> thList = [];
  getRegExpList(r'(?<=\<th\>)[0-9\.]*', totalData)
      .forEach((e) => thList.add(double.parse(e)));
  // 下标321是因为html数据的顺序和数据类的顺序不一样
  var total = Total(thList[3], thList[2], thList[1]);

  /// 匹配所有科目信息
  var filterStr = getRegExpStr(r'(?<=\>绩点\<)[\s\S]*', data); // 先去掉总数据部分的tr结点
  var courseDataList =
      getRegExpList(r'(?<=\<tr)[\s\S]*?(?=\<\/tr)', filterStr); // 所有的课程数据（糙数据）
  var currentTermStr = "";
  List<GPAStat> stats = [];
  List<GPACourse> courses = [];
  for (int i = 0; i < courseDataList.length; i++) {
    var courseData = getRegExpList(r'(?<=\<td[ style="]*?\>)[\s\S]*?(?=\<)',
        courseDataList[i]); // 这里的数据含有转义符
    var term = courseData[0];
    if (currentTermStr == "") currentTermStr = term;
    if (currentTermStr != term) {
      stats.add(_calculateStat(courses));
      courses.clear();
      currentTermStr = term;
    }
    var gpaCourse = _data2GPACourse(courseData);
    if (gpaCourse != null) courses.add(gpaCourse);
    if (i == courseDataList.length - 1) stats.add(_calculateStat(courses));
  }
  return GPABean(total, stats);
}

/// 对课程数据进行整理后生成gpaCourse对象
GPACourse _data2GPACourse(List<String> data) {
  List<String> list = [];
  data.forEach((s) => list.add(s.replaceAll(RegExp(r'\s'), ''))); // 去掉数据中的转义符
  double score = 0.0;
  switch (list[6]) {
    case 'P':
      score = 100.0;
      break;
    case '--':
      score = _DELAYED;
      break;
    case 'F':
      score = 0.0;
      break;
    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
      score = _IGNORED;
      break;
    default:
      // Invalid double 文化素质教育必修
      score = double.parse(list[6]);
  }
  double credit = 0.0;
  if (score >= 60) credit = double.parse(list[5]);
  double gpa = double.parse(list[8]);
  if (score != _DELAYED && score != _IGNORED)
    return GPACourse(list[2], list[4], score, credit, gpa);
  else
    return null;
}

/// 计算每学期的总加权/绩点/学分
GPAStat _calculateStat(List<GPACourse> courses) {
  /// 不能直接把courses传进gpaStat对象中，stats数组会持续持有courses的引用导致每学期课程相同，所以这里搞个新数组copy一下
  List<GPACourse> deepCopyCourses = [];
  var currentTermScore = 0.0;
  var currentTermGpa = 0.0;
  var currentTermTotalCredits = 0.0;
  courses.forEach((course) => currentTermTotalCredits += course.credit);
  courses.forEach((course) {
    double ratio = course.credit / currentTermTotalCredits;
    currentTermGpa += course.gpa * ratio;
    currentTermScore += course.score * ratio;
    deepCopyCourses.add(course);
  });
  double score = double.parse(currentTermScore.toStringAsFixed(2));
  double gpa = double.parse(currentTermGpa.toStringAsFixed(2));
  return GPAStat(score, gpa, currentTermTotalCredits, deepCopyCourses);
}

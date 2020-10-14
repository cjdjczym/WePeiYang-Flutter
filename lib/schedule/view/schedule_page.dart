import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/common_model.dart';
import 'package:wei_pei_yang_demo/schedule/service/common_service.dart';
import 'package:wei_pei_yang_demo/schedule/service/schedule_spider.dart';
import 'class_table_widget.dart';
import 'week_select_widget.dart';

/// schedule页面两边的白边
const double schedulePadding = 15;

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 60,
      color: Color.fromRGBO(105, 109, 126, 1),
      // TODO onRefresh和下面的onTap函数也许能复用
      onRefresh: () async {
        Fluttertoast.showToast(
            msg:"刷新数据中……",
            textColor: Colors.white,
            backgroundColor: Colors.blue,
            timeInSecForIosWeb: 1,
            fontSize: 16);
        await getClassTable(onSuccess: (schedule) {
          var provider = Provider.of<ScheduleNotifier>(context);
          provider.termStart = schedule.termStart;
          provider.coursesWithNotify = schedule.courses;
          Fluttertoast.showToast(
              msg: "刷新课程表数据成功",
              textColor: Colors.white,
              backgroundColor: Colors.green,
              timeInSecForIosWeb: 1,
              fontSize: 16);
        }, onFailure: (e) {
          // TODO 记得改成 “失败” 文字
          Fluttertoast.showToast(
              msg: e.error.toString(),
              textColor: Colors.white,
              backgroundColor: Colors.red,
              timeInSecForIosWeb: 1,
              fontSize: 16);
        });
      },
      child: Scaffold(
        appBar: ScheduleAppBar(),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: schedulePadding),
          child: ListView(
            children: [
              TitleWidget(),
              WeekSelectWidget(),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClassTableWidget(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
          child: Icon(Icons.arrow_back,
              color: Color.fromRGBO(105, 109, 126, 1), size: 28),
          onTap: () =>
              // Navigator.pop(context)
        test(context)
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
              child: Icon(Icons.autorenew,
                  color: Color.fromRGBO(105, 109, 126, 1), size: 25),
              onTap: () async {
                Fluttertoast.showToast(
                    msg:"刷新数据中……",
                    textColor: Colors.white,
                    backgroundColor: Colors.blue,
                    timeInSecForIosWeb: 1,
                    fontSize: 16);
                await getSchedule(onSuccess: (schedule){});
                // getClassTable(onSuccess: (schedule) {
                //   var provider = Provider.of<ScheduleNotifier>(context);
                //   provider.termStart = schedule.termStart;
                //   provider.coursesWithNotify = schedule.courses;
                //   Fluttertoast.showToast(
                //       msg: "刷新课程表数据成功",
                //       textColor: Colors.white,
                //       backgroundColor: Colors.green,
                //       timeInSecForIosWeb: 1,
                //       fontSize: 16);
                // }, onFailure: (e) {
                //   // TODO 记得改成 “失败” 文字
                //   Fluttertoast.showToast(
                //       msg: e.error.toString(),
                //       textColor: Colors.white,
                //       backgroundColor: Colors.red,
                //       timeInSecForIosWeb: 1,
                //       fontSize: 16);
                // });
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: GestureDetector(
              child: Icon(Icons.add,
                  color: Color.fromRGBO(105, 109, 126, 1), size: 30),
              onTap: () {
                // TODO 更多功能
                Provider.of<ScheduleNotifier>(context).changeWeekMode();
              }),
        ),
      ],
    );
  }

  void test(BuildContext context){
      List<Course> courses = [];
      courses.add(Course("123","321","大学物理2B","4.0","冯星辉(讲师)","北洋园",Week("4","19"),Arrange("单周","33楼221","1","2","1")));
      courses.add(Course("123","321","大学物理2B","4.0","冯星辉(讲师)","北洋园",Week("4","19"),Arrange("单双周","33楼221","3","4","3")));
      courses.add(Course("123","321","算法设计与分析","3.0","刘春凤(副教授),宫秀军(副教授)","北洋园",Week("4","17"),Arrange("单双周","55楼A区308","3","4","1")));
      courses.add(Course("123","321","算法设计与分析","3.0","刘春凤(副教授),宫秀军(副教授)","北洋园",Week("4","17"),Arrange("单双周","55楼A区308","7","8","3")));
      courses.add(Course("123","321","马克思主义基本原理","3.0","刘金增(讲师)","北洋园",Week("4","19"),Arrange("单双周","46楼A区303","7","8","1")));
      courses.add(Course("123","321","马克思主义基本原理","3.0","刘金增(讲师)","北洋园",Week("4","19"),Arrange("单周","46楼A区303","1","2","3")));
      courses.add(Course("123","321","人类文明史漫谈（翻转）","2.0","张凯峰(讲师)","北洋园",Week("4","19"),Arrange("单双周","46楼A区303","9","10","1")));
      courses.add(Course("123","321","操作系统原理","3.0","李罡(讲师)","北洋园",Week("4","17"),Arrange("单双周","55楼B区316","5","6","4")));
      courses.add(Course("123","321","操作系统原理","3.0","李罡(讲师)","北洋园",Week("4","17"),Arrange("单双周","55楼B区316","1","2","2")));
      courses.add(Course("123","321","概率论与数理统计1","3.0","吴华明(副研究员)","北洋园",Week("4","15"),Arrange("单双周","46楼A309","1","2","5")));
      courses.add(Course("123","321","概率论与数理统计1","3.0","吴华明(副研究员)","北洋园",Week("4","15"),Arrange("单双周","46楼A309","3","4","2")));
      courses.add(Course("123","321","体育C（体育舞蹈）","1.0","郭营(讲师)","北洋园",Week("4","19"),Arrange("单双周","","5","6","2")));
      courses.add(Course("123","321","计算机产业前沿与创新创业","1.0","王文俊(教授)","北洋园",Week("12","19"),Arrange("单双周","46楼A208","7","8","2")));
      courses.add(Course("123","321","大学英语3","2.0","张宇(讲师)","北洋园",Week("4","19"),Arrange("单双周","46楼A114","5","6","3")));
      courses.add(Course("123","321","物理实验A","1.0","刘云朋(副教授)","北洋园",Week("4","19"),Arrange("单周","","1","4","4")));
      Provider.of<ScheduleNotifier>(context).coursesWithNotify = courses;
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(
        builder: (context, notifier, _) => Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Text('Schedule',
                      style: TextStyle(
                          color: Color.fromRGBO(105, 109, 126, 1),
                          fontSize: 35,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 12),
                    child: Text('WEEK ${notifier.selectedWeek}',
                        style: TextStyle(
                            color: Color.fromRGBO(220, 220, 220, 1),
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/colored_icon.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam.dart';
import 'package:we_pei_yang_flutter/schedule/model/exam_provider.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/scroll_synchronizer.dart';

class WpyExamWidget extends StatelessWidget {
  final ScrollController _sc2 = ScrollController();

  void handleDetail(ScrollSynchronizer synchronizer, details) {
    final dy = details.primaryDelta!;
    if (!synchronizer.firstAtBottom ||
        (synchronizer.secondAtTop(_sc2) && dy > 0)) {
      synchronizer.controller1.jumpTo(
        (synchronizer.controller1.position.pixels - dy)
            .clamp(0.0, synchronizer.controller1.position.maxScrollExtent),
      );
    } else {
      _sc2.jumpTo(
        (_sc2.position.pixels - dy).clamp(0, _sc2.position.maxScrollExtent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, child) {
        if (provider.hideExam) return SizedBox.shrink();
        return _detail(provider, context);
      },
    );
  }

  Widget _detail(ExamProvider provider, BuildContext context) {
    final ScrollSynchronizer synchronizer = Provider.of<ScrollSynchronizer>(
      context,
      listen: false,
    );
    if (provider.unscheduled.length == 0) {
      var msg = provider.unfinished.length == 0 ? '目前没有考试哦' : '没有已安排时间的考试哦';
      return WButton(
        onPressed: () => Navigator.pushNamed(context, ScheduleRouter.exam),
        child: provider.unfinished.length == 0
            ? Align(
                alignment: Alignment.topCenter,
                child: ColoredIcon(
                  "assets/images/schedule_empty.png",
                  color: WpyTheme.of(context).primary,
                ))
            : Container(
                height: 430.h,
                alignment: Alignment.center,
                child: Text(msg),
              ),
      );
    }
    return SizedBox(
        height: 430.h,
        child: GestureDetector(
          onVerticalDragUpdate: (details) =>
              handleDetail(synchronizer, details),
          child: ListView.builder(
            controller: _sc2,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(top: 35.r),
            itemCount: provider.unscheduled.length,
            itemBuilder: (context, i) {
              var exam = provider.unscheduled[i];
              var seat = exam.seat;
              if (seat != '地点未安排') seat = '座位' + seat;
              return _BuildingItem(exam: exam, seat: seat);
            },
          ),
        ));
  }
}

class _BuildingItem extends StatelessWidget {
  const _BuildingItem({
    required this.exam,
    required this.seat,
  });

  final Exam exam;
  final String seat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: 330.w,
      margin: EdgeInsets.symmetric(vertical: 7.5.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 20,
            color: WpyTheme.of(context)
                .get(WpyColorKey.basicTextColor)
                .withOpacity(0.05),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, ScheduleRouter.exam),
          borderRadius: BorderRadius.circular(15.r),
          splashFactory: InkRipple.splashFactory,
          splashColor:
              WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (exam.name.length > 10)
                          ? exam.name.substring(0, 12) + "..."
                          : exam.name,
                      style:
                          TextUtil.base.PingFangSC.label(context).bold.sp(14),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Image.asset('assets/images/schedule/location.png',
                            width: 13.r, height: 13.r),
                        SizedBox(width: 8.w),
                        Text(
                          '${exam.location}-$seat',
                          style: TextUtil.base.PingFangSC.normal
                              .label(context)
                              .sp(12),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      exam.arrange,
                      style: TextUtil.base.PingFangSC.normal
                          .sp(12)
                          .primaryAction(context),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      exam.date,
                      style: TextUtil.base.PingFangSC.normal
                          .sp(12)
                          .primaryAction(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/dialog/dialog_button.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/edit_provider.dart';
import 'package:we_pei_yang_flutter/schedule/view/edit_widgets.dart';

import '../../commons/themes/wpy_theme.dart';
import '../../commons/widgets/colored_icon.dart';
import '../../commons/widgets/w_button.dart';

class EditDetailPageArgs {
  final int index;
  final String name;
  final String credit;

  EditDetailPageArgs(this.index, this.name, this.credit);
}

class EditDetailPage extends StatefulWidget {
  final int index;
  final String name;
  final String credit;

  EditDetailPage(EditDetailPageArgs args)
      : index = args.index,
        name = args.name,
        credit = args.credit;

  @override
  _EditDetailPageState createState() => _EditDetailPageState();
}

class _EditDetailPageState extends State<EditDetailPage> {
  final _scrollController = ScrollController();

  var name = '';
  var credit = '';

  @override
  void initState() {
    super.initState();
    name = widget.name;
    credit = widget.credit;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _check(BuildContext context) {
    if (name.isEmpty) {
      ToastProvider.error('请填写课程名称');
      return false;
    }
    var pvd = context.read<EditProvider>();
    int frameCheck = pvd.check();
    if (frameCheck != -1) {
      ToastProvider.error('时段 ${frameCheck + 1} 信息不完整');
      return false;
    }
    return true;
  }

  void _saveAndQuit(BuildContext context) {
    if (!_check(context)) return;

    int start = 100;
    int end = 0;
    var teacherSet = Set<String>();

    var pvd = context.read<EditProvider>();
    pvd.arrangeList.forEach((arrange) {
      if (arrange.weekList.first <= start) start = arrange.weekList.first;
      if (arrange.weekList.last >= end) end = arrange.weekList.last;
      if (arrange.teacherList.isNotEmpty) {
        teacherSet.add(arrange.teacherList.first);
      }
    });

    context.read<CourseProvider>().modifyCustomCourse(
        Course.custom(
            name, credit, '$start-$end', teacherSet.toList(), pvd.arrangeList),
        widget.index);
    ToastProvider.success('保存成功');
    Navigator.pop(context);
  }

  void _deleteAndQuit(BuildContext context) {
    context.read<CourseProvider>().deleteCustomCourse(widget.index);
    Navigator.pop(context);
  }

  Future<bool?> _showDialog(String text) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 30.w,
                  height: 30.h,
                  child: ColoredIcon(
                    'assets/images/schedule/notify.png',
                    color: WpyTheme.of(context).primary,
                  ),
                ),
              ),
              SizedBox(height: 25.h),
              Text(
                text,
                style: TextUtil.base.PingFangSC.primary(context).medium.sp(15),
              ),
              SizedBox(height: 30.h),
            ],
          ),
          actions: <Widget>[
            WbyDialogStandardTwoButton(
              first: () {
                Navigator.of(context).pop(false); // 返回false表示取消
              },
              second: () {
                Navigator.of(context).pop(true); // 返回true表示确认
              },
              firstText: '取消',
              secondText: '确定',
              secondType: ButtonType.blue,
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var mainColor = WpyTheme.of(context).get(WpyColorKey.primaryActionColor);

    var timeFrameBuilder = Builder(
      builder: (BuildContext context) {
        var provider = context.watch<EditProvider>();
        return Column(
          children: List.generate(
            provider.arrangeList.length,
            (index) => TimeFrameWidget(
              index,
              !(provider.arrangeList.length == 1 && index == 0),
              _scrollController,
              key: ValueKey(provider.initIndex(index)),
            ),
          ),
        );
      },
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        bool? confirm =await _showDialog('是否保存修改内容?');
        if(confirm==true){
          var check = _check(context);
          if (check) _saveAndQuit(context);
        }else{
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
              WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
          leading: Center(
            child: WButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(),
                padding: EdgeInsets.fromLTRB(10.w, 9.h, 8.w, 8.h),
                child: ColoredIcon(
                  'assets/images/schedule/back.png',
                  color: WpyTheme.of(context).primary,
                ),
              ),
            ),
          ),
          titleSpacing: 0,
          leadingWidth: 40.w,
          title: Text('课程详情',
              style: TextUtil.base.PingFangSC.bold.label(context).sp(18)),
          actions: [
            Center(
              child: Container(
                child: ElevatedButton(
                  onPressed: () => _saveAndQuit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('保存',
                      style:
                          TextUtil.base.PingFangSC.bold.bright(context).sp(12)),
                ),
              ),
            ),
            SizedBox(width: 15.w),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                    secondaryHeaderColor: WpyTheme.of(context)
                        .get(WpyColorKey.primaryBackgroundColor)),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  controller: _scrollController,
                  children: [
                    SizedBox(height: 5.h),
                    CardWidget(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InputWidget(
                            onChanged: (text) => name = text,
                            title: '课程名称',
                            hintText: '请输入课程名称（必填）',
                            initText: name,
                            inputFormatter: [
                              LengthLimitingTextInputFormatter(20)
                            ],
                          ),
                          InputWidget(
                            onChanged: (text) => credit = text,
                            title: '课程学分',
                            hintText: '请输入课程学分（选填）',
                            initText: credit,
                            keyboardType: TextInputType.number,
                            inputFormatter: [
                              LengthLimitingTextInputFormatter(10)
                            ],
                          ),
                        ],
                      ),
                    ),
                    timeFrameBuilder,
                    CardWidget(
                      onTap: () {
                        context.read<EditProvider>().add();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear,
                          );
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle, color: mainColor),
                          SizedBox(width: 5.w),
                          Text('新增时段',
                              style: TextUtil.base.PingFangSC.medium
                                  .customColor(mainColor)
                                  .sp(12)),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Material(
              color: WpyTheme.of(context).get(WpyColorKey.errorActionColor),
              child: InkWell(
                onTap: () async {
                  bool? confirm=await _showDialog("您确定要删除该课程吗?");
                  if(confirm == true)_deleteAndQuit(context);
                },
                splashFactory: InkRipple.splashFactory,
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/schedule/dust_bin.png',
                          height: 18.r, width: 18.r),
                      SizedBox(width: 5.w),
                      Text('删除',
                          style: TextUtil.base.PingFangSC.medium
                              .bright(context)
                              .sp(14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/model/feedback_notifier.dart';
import 'package:we_pei_yang_flutter/feedback/util/color_util.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/tab_grid_view.dart';

import '../feedback_router.dart';
import 'components/widget/tag_search_card.dart';

class NewPostPage extends StatefulWidget {
  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  // 0 -> 不区分; 1 -> 卫津路; 2 -> 北洋园
  final campusNotifier = ValueNotifier(0);

  // 0 -> 青年湖底; 1 -> 校务专区
  final postTypeNotifier = ValueNotifier(PostType.feedback);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: true,
      title: Text(
        S.current.feedback_new_post,
        style: FontManager.YaHeiRegular.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorUtil.boldTextColor,
        ),
      ),
      brightness: Brightness.light,
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: Color(0XFF62677B),
          size: 36,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: TitleInputField(),
      ),
      backgroundColor: Colors.transparent,
    );

    return Scaffold(
        backgroundColor: ColorUtil.backgroundColor,
        appBar: appBar,
        body: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              LakeSelector(),
              SizedBox(height: 10),
              TagView(postTypeNotifier),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    shape: BoxShape.rectangle,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContentInputField(),
                        SizedBox(height: 10),
                        ImagesGridView(),
                        SizedBox(height: 20),
                        CampusSelector(campusNotifier),
                        SizedBox(height: 10),
                        SubmitButton(campusNotifier, postTypeNotifier),
                      ]))
            ]));
  }
}

enum PostType{
  lake,
  feedback
}

extension PostTypeExt on PostType{
  int get value => [0, 1][index];

  String get title => ["青年湖底", "校务专区"][index];
}


class LakeSelector extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => LakeSelectorState();
}

class LakeSelectorState extends State<LakeSelector> {

  @override
  Widget build(BuildContext context) {
    final notifier = context.findAncestorStateOfType<_NewPostPageState>().postTypeNotifier;
    return ValueListenableBuilder<PostType>(
      valueListenable: notifier,
      builder: (context, type, _) {
        return SizedBox(
          height: 60,
          child: ListView.builder(
            itemCount: 2,
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SizedBox(
                height: 58,
                width: (WePeiYangApp.screenWidth - 40) / 2,
                child: ElevatedButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        PostType.values[index].title,
                        style: FontManager.YaHeiRegular.copyWith(
                          color: type.value == index
                              ? ColorUtil.boldTextColor
                              : ColorUtil.lightTextColor,
                          fontWeight: type.value == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: type.value == index
                                ? ColorUtil.mainColor
                                : Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                        width: 30,
                        height: 4,
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: _judgeBorder(index)),
                    primary: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () {
                    notifier.value = PostType.values[index];
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  BorderRadius _judgeBorder(int index) {
    if (index == 0)
      return BorderRadius.horizontal(left: Radius.circular(16));
    else
      return BorderRadius.horizontal(right: Radius.circular(16));
  }
}

class SubmitButton extends StatelessWidget {
  final ValueNotifier campusNotifier, postTypeNotifier;

  const SubmitButton(this.campusNotifier, this.postTypeNotifier, {Key key}) : super(key: key);

  void submit(BuildContext context) {
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    if (dataModel.check) {
      postTypeNotifier.value == PostType.feedback
          ?
          FeedbackService.sendPost(
              type: PostType.feedback.value,
              title: dataModel.title,
              content: dataModel.content,
              departmentId: dataModel.department.id,
              images: dataModel.images,
              campus: campusNotifier.value,
              onSuccess: () {
                ToastProvider.success(S.current.feedback_post_success);
                Navigator.pop(context);
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
              },
            )
          : FeedbackService.sendPost(
              type: PostType.lake.value,
              title: dataModel.title,
              content: dataModel.content,
              tagId: dataModel.tag.id,
              images: dataModel.images,
              campus: campusNotifier.value,
              onSuccess: () {
                ToastProvider.success(S.current.feedback_post_success);
                Navigator.pop(context);
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
              },
            );
      dataModel.clear();
    } else {
      ToastProvider.error(S.current.feedback_empty_content_error);
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.5;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        Hero(
          tag: "addNewPost",
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(1),
              backgroundColor: MaterialStateProperty.all(ColorUtil.mainColor),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            onPressed: () => submit(context),
            child: Text(
              S.current.feedback_submit,
              style: FontManager.YaHeiRegular.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorUtil.backgroundColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TagView extends StatefulWidget {
  final ValueNotifier postTypeNotifier;

  const TagView(this.postTypeNotifier, {Key key}) : super(key: key);

  @override
  _TagViewState createState() => _TagViewState();
}

class _TagViewState extends State<TagView> {
  ValueNotifier<Department> department;
  ValueNotifier<Tag> tag;

  @override
  void initState() {
    super.initState();
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    department = ValueNotifier(dataModel.department)
      ..addListener(() {
        dataModel.department = department.value;
      });
    tag = ValueNotifier(dataModel.tag)
      ..addListener(() {
        dataModel.tag = tag.value;
      });
  }

  _showTags(BuildContext context) async {
    var result = await showModalBottomSheet<Department>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) => TabGridView(
        department: department.value,
      ),
    );
    if (result != null) department.value = result;
  }

  @override
  Widget build(BuildContext context) {
    var text = ValueListenableBuilder(
      valueListenable: department,
      builder: (_, Department tag, __) {
        return Text(
          tag == null
              ? S.current.feedback_add_tag_hint
              : '#${tag.name} ${S.current.feedback_change_tag_hint}',
          style: FontManager.YaHeiRegular.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ColorUtil.boldTextColor,
          ),
        );
      },
    );
    final notifier = context.findAncestorStateOfType<_NewPostPageState>().postTypeNotifier;
    return ValueListenableBuilder<PostType>(
        valueListenable: notifier,
        builder: (context, type, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            shape: BoxShape.rectangle,
          ),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
          child: notifier.value==PostType.feedback?InkResponse(
            radius: 16,
            onTap: () => _showTags(context),
            child: Row(
              children: [text, Spacer(), Icon(Icons.tag)],
            ),
          ) : SearchTagCard(),
        );
      }
    );
  }
}

class CampusSelector extends StatefulWidget {
  final ValueNotifier campusNotifier;

  CampusSelector(this.campusNotifier);

  @override
  _CampusSelectorState createState() => _CampusSelectorState();
}

class _CampusSelectorState extends State<CampusSelector> {
  static const texts = ["双校区", "卫津路", "北洋园"];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.campusNotifier,
      builder: (context, value, _) {
        return SizedBox(
          height: 32,
          child: ListView.builder(
            itemCount: 3,
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SizedBox(
                height: 32,
                width: (WePeiYangApp.screenWidth - 100) / 3,
                child: ElevatedButton(
                  child: Text(
                    texts[index],
                    style: FontManager.YaHeiRegular.copyWith(
                      color:
                          value == index ? Colors.white : ColorUtil.mainColor,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: _judgeBorder(index)),
                      primary:
                          value == index ? ColorUtil.mainColor : Colors.white),
                  onPressed: () {
                    widget.campusNotifier.value = index;
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  BorderRadius _judgeBorder(int index) {
    if (index == 0)
      return BorderRadius.horizontal(left: Radius.circular(12));
    else if (index == 2)
      return BorderRadius.horizontal(right: Radius.circular(12));
    else
      return BorderRadius.zero;
  }
}

class ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ConfirmButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all(Size(0, 0)),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      onPressed: onPressed,
      child: Text(
        S.current.feedback_ok,
        style: FontManager.YaHeiRegular.copyWith(
          color: Color(0xff303c66),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class TitleInputField extends StatefulWidget {
  @override
  _TitleInputFieldState createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<TitleInputField> {
  ValueNotifier<String> titleCounter;
  TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    _titleController = TextEditingController(text: dataModel.title);
    titleCounter = ValueNotifier('${dataModel.title.characters.length}/30')
      ..addListener(() {
        dataModel.title = _titleController.text;
      });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = Expanded(
      child: TextField(
        buildCounter: null,
        controller: _titleController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        style: FontManager.YaHeiRegular.copyWith(
          color: ColorUtil.boldTextColor,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
        minLines: 1,
        maxLines: 10,
        decoration: InputDecoration.collapsed(
          hintStyle: FontManager.YaHeiRegular.copyWith(
            color: ColorUtil.searchBarIconColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          hintText: S.current.feedback_enter_title,
        ),
        onChanged: (text) {
          titleCounter.value = '${text.characters.length} / 30';
        },
        inputFormatters: [
          CustomizedLengthTextInputFormatter(30),
        ],
        cursorColor: ColorUtil.boldTextColor,
        cursorHeight: 20,
      ),
    );

    Widget rightTextCounter = ValueListenableBuilder(
      valueListenable: titleCounter,
      builder: (_, String value, __) {
        return Text(
          value,
          style: FontManager.YaHeiRegular.copyWith(
            color: Color(0xffd0d1d6),
            fontSize: 12,
          ),
        );
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        shape: BoxShape.rectangle,
      ),
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 15),
      padding: const EdgeInsets.fromLTRB(22, 15, 22, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [inputField, SizedBox(width: 3), rightTextCounter],
      ),
    );
  }
}

class ContentInputField extends StatefulWidget {
  @override
  _ContentInputFieldState createState() => _ContentInputFieldState();
}

class _ContentInputFieldState extends State<ContentInputField> {
  ValueNotifier<String> contentCounter;
  TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    var dataModel = Provider.of<NewPostProvider>(context, listen: false);
    _contentController = TextEditingController(text: dataModel.content);
    contentCounter = ValueNotifier('${dataModel.content.characters.length}/200')
      ..addListener(() {
        dataModel.content = _contentController.text;
      });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = TextField(
      controller: _contentController,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.done,
      minLines: 1,
      maxLines: 22,
      style: FontManager.YaHeiRegular.copyWith(
          color: ColorUtil.boldTextColor,
          letterSpacing: 0.9,
          fontWeight: FontWeight.w700,
          height: 1.6,
          fontSize: 15),
      decoration: InputDecoration.collapsed(
        hintStyle: FontManager.YaHeiRegular.copyWith(
          color: Color(0xffd0d1d6),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
        hintText: '${S.current.feedback_detail}...',
      ),
      onChanged: (text) {
        contentCounter.value = '${text.characters.length}/200';
      },
      inputFormatters: [
        CustomizedLengthTextInputFormatter(200),
      ],
      cursorColor: ColorUtil.profileBackgroundColor,
    );

    Widget bottomTextCounter = ValueListenableBuilder(
      valueListenable: contentCounter,
      builder: (_, String value, __) {
        return Text(
          value,
          style: FontManager.YaHeiRegular.copyWith(
            color: Color(0xffd0d1d6),
            fontSize: 12,
          ),
        );
      },
    );

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [inputField, SizedBox(height: 100), bottomTextCounter],
    );
  }
}

class ImagesGridView extends StatefulWidget {
  @override
  _ImagesGridViewState createState() => _ImagesGridViewState();
}

class _ImagesGridViewState extends State<ImagesGridView> {
  static const maxImage = 3;

  loadAssets() async {
    XFile xFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 30);
    Provider.of<NewPostProvider>(context, listen: false)
        .images
        .add(File(xFile.path));
    if (!mounted) return;
    setState(() {});
  }

  Future<String> _showDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        titleTextStyle: FontManager.YaHeiRegular.copyWith(
            color: Color.fromRGBO(79, 88, 107, 1.0),
            fontSize: 16,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none),
        title: Text(S.current.feedback_delete_image_content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
              child: Text(S.current.feedback_cancel)),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop('ok');
              },
              child: Text(S.current.feedback_ok)),
        ],
      ),
    );
  }

  Widget imgBuilder(index, List<File> data, length, {onTap}) {
    return Stack(fit: StackFit.expand, children: [
      InkWell(
        onTap: () => Navigator.pushNamed(context, FeedbackRouter.localImageView,
            arguments: {
              "uriList": data,
              "uriListLength": length,
              "indexNow": index
            }),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(width: 1, color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: ClipRRect(
            child: Image.file(
              data[index],
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            child: Icon(
              Icons.close,
              size: MediaQuery.of(context).size.width / 32,
              color: ColorUtil.searchBarBackgroundColor,
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4, //方便右边宽度留白哈哈
      childAspectRatio: 1,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
    );

    return Consumer<NewPostProvider>(
      builder: (_, data, __) => GridView.builder(
        shrinkWrap: true,
        gridDelegate: gridDelegate,
        itemCount: maxImage == data.images.length
            ? data.images.length
            : data.images.length + 1,
        itemBuilder: (_, index) {
          if (index <= 2 && index == data.images.length) {
            return _ImagePickerWidget(onTap: loadAssets);
          } else {
            return imgBuilder(
              index,
              data.images,
              data.images.length,
              onTap: () async {
                var result = await _showDialog();
                if (result == 'ok') {
                  data.images.removeAt(index);
                  setState(() {});
                }
              },
            );
          }
        },
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}

class _ImagePickerWidget extends StatelessWidget {
  const _ImagePickerWidget({
    Key key,
    this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.crop_original),
      onPressed: onTap,
    );
  }
}

/// 自定义兼容中文拼音输入法长度限制输入框
/// https://www.jianshu.com/p/d2c50b9271d3
class CustomizedLengthTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  CustomizedLengthTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.isComposingRangeValid) return newValue;
    return LengthLimitingTextInputFormatter(maxLength)
        .formatEditUpdate(oldValue, newValue);
  }
}

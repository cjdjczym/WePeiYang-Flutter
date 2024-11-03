import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/token/lake_token_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/feedback_router.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';
import 'package:we_pei_yang_flutter/feedback/view/components/widget/we_ko_dialog.dart';

class FbDepartmentsProvider {
  List<Department> departmentList = [];

  Future<void> initDepartments() async {
    await FeedbackService.getDepartments(
      await LakeTokenManager().token,
      onResult: (list) {
        departmentList.clear();
        departmentList.addAll(list);
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
    );
  }
}

///用于在断网情况下过四秒显示重连按钮
class ChangeHintTextProvider extends ChangeNotifier {
  bool timeEnded = false;

  void resetTimer() {
    timeEnded = false;
    notifyListeners();
    calculateTime();
  }

  void calculateTime() {
    if (!timeEnded) {
      Future.delayed(Duration(seconds: 6), () {
        timeEnded = true;
        notifyListeners();
      });
    }
  }
}

class FbHotTagsProvider extends ChangeNotifier {
  List<Tag> hotTagsList = [];

  /// 0：未加载 1：加载中 2：加载完成 3：加载失败 4：加载成功但无数据
  int hotTagCardState = 0;
  Tag? recTag;

  Future<void> initHotTags({OnSuccess? success, OnFailure? failure}) async {
    hotTagCardState = 1;
    await FeedbackService.getHotTags(onSuccess: (list) {
      hotTagsList.clear();
      if (list.length == 0) {
        hotTagCardState = 4;
      } else {
        hotTagCardState = 2;
        hotTagsList.addAll(list);
      }
      notifyListeners();
    }, onFailure: (e) {
      hotTagCardState = 3;
      failure?.call(e);
      ToastProvider.error(e.error.toString());
    });
  }

  Future<void> initRecTag({required OnFailure failure}) async {
    await FeedbackService.getRecTag(onSuccess: (tag) {
      recTag = tag;
      notifyListeners();
    }, onFailure: (e) {
      failure.call(e);
      ToastProvider.error(e.error.toString());
    });
  }
}

enum LakePageStatus {
  unload,
  loading,
  idle,
  error,
}

class LakeArea {
  final WPYTab tab;
  Map<int, Post> dataList;
  RefreshController refreshController;
  ScrollController controller;
  LakePageStatus status;
  int currentPage = 1;
  Post horizontalViewingPost = Post.empty();

  LakeArea.empty()
      : this.tab = WPYTab(),
        this.dataList = {},
        this.refreshController = RefreshController(),
        this.controller = ScrollController(),
        this.status = LakePageStatus.unload;

  clear() {
    this.dataList = {};
    this.refreshController = RefreshController();
    this.controller = ScrollController();
    this.status = LakePageStatus.unload;
    this.horizontalViewingPost = Post.empty();
  }
}

class ChangeablePost {
  Post post = Post.empty();
  int changeId = 0;

  ChangeablePost(Post p, int cId)
      : post = p,
        changeId = cId;
}

class LakeModel extends ChangeNotifier {
  LakePageStatus mainStatus = LakePageStatus.unload;
  Map<int, LakeArea> lakeAreas = {};
  List<WPYTab> tabList = [];
  List<WPYTab> backupList = [WPYTab()];
  int currentTab = 0;
  bool openFeedbackList = false, tabControllerLoaded = false, scroll = false;
  bool barExtended = true;
  double opacity = 0;
  TabController? tabController;
  int sortSeq = 1;
  ChangeablePost horizontalViewingPost = ChangeablePost(Post.empty(), 0);

  clearAll() {
    mainStatus = LakePageStatus.unload;
    lakeAreas.clear();
    tabList.clear();
    backupList = [WPYTab()];
    currentTab = 0;
    openFeedbackList = false;
    tabControllerLoaded = false;
    scroll = false;
    barExtended = true;
    opacity = 0;
    tabController?.dispose();
    sortSeq = 1;
    horizontalViewingPost = ChangeablePost(Post.empty(), 0);
  }

  int get currentTabId => tabList[currentTab].id;

  Future<void> initTabList() async {
    _setLoadingStatus();

    try {
      _initializeTabList();
      await _fetchAndAddTabs();
      _setIdleStatus();
    } catch (e) {
      _handleError(e);
    }
  }

  void _setLoadingStatus() {
    if (mainStatus == LakePageStatus.error ||
        mainStatus == LakePageStatus.unload) {
      mainStatus = LakePageStatus.loading;
    }
    notifyListeners();
  }

  void _initializeTabList() {
    WPYTab oTab = WPYTab(id: 0, shortname: '精华', name: '精华');
    tabList.clear();
    tabList.add(oTab);
    lakeAreas[0] = LakeArea.empty(); // Initialize the first area
  }

  Future<void> _fetchAndAddTabs() async {
    final list = await FeedbackService.getTabList();
    tabList.addAll(list);
    for (var element in list) {
      lakeAreas[element.id] = LakeArea.empty();
    }
  }

  void _setIdleStatus() {
    mainStatus = LakePageStatus.idle;
    notifyListeners();
  }

  void _handleError(dynamic e) {
    mainStatus = LakePageStatus.error;
    ToastProvider.error(e.toString());
    notifyListeners();
  }

  void onFeedbackOpen() {
    barExtended = true;
    notifyListeners();
  }

  void onFeedbackClose() {
    barExtended = false;
    notifyListeners();
  }

  void initLakeArea(int index, WPYTab tab, RefreshController rController,
      ScrollController sController) {
    // LakeArea lakeArea = new LakeArea._(
    //     WPYTab(), {}, rController, sController, LakePageStatus.unload);
    // lakeAreas[index] = lakeArea;
  }

  void fillLakeAreaAndInitPostList(
      int index, RefreshController rController, ScrollController sController) {
    lakeAreas[index]?.clear();
    initPostList(index, success: () {}, failure: (e) {
      ToastProvider.error(e.error.toString());
    });
  }

  void quietUpdateItem(Post post, WPYTab tab) {
    lakeAreas[tab]?.dataList.update(
      post.id,
      (value) {
        value.isLike = post.isLike;
        value.isFav = post.isFav;
        value.likeCount = post.likeCount;
        value.favCount = post.favCount;
        return value;
      },
      ifAbsent: () => post,
    );
  }

  // 列表去重
  void _addOrUpdateItems(List<Post> data, int index) {
    data.forEach((element) {
      lakeAreas[index]
          ?.dataList
          .update(element.id, (value) => element, ifAbsent: () => element);
    });
  }

  Future<void> getNextPage(int index,
      {required OnSuccess success, required OnFailure failure}) async {
    await FeedbackService.getPosts(
      type: '${index}',
      searchMode: sortSeq,
      etag: index == 0 ? 'recommend' : '',
      page: lakeAreas[index]!.currentPage + 1,
      onSuccess: (postList, page) {
        _addOrUpdateItems(postList, index);
        lakeAreas[index]!.currentPage += 1;
        success.call();
        notifyListeners();
      },
      onFailure: (e) {
        LakeTokenManager().refreshToken();
        failure.call(e);
      },
    );
  }

  getTabList(FbDepartmentsProvider provider, {OnSuccess? success}) async {
    try {
      provider.initDepartments();
      initTabList();
      success?.call();
    } catch (e) {
      ToastProvider.error('获取分区失败');
      notifyListeners();
    }
  }

  Future<void> initPostList(int index,
      {OnSuccess? success, OnFailure? failure, bool reset = false}) async {
    if (reset) {
      lakeAreas[index]?.status = LakePageStatus.loading;
      notifyListeners();
    }
    await FeedbackService.getPosts(
      type: '$index',
      searchMode: sortSeq,
      page: '1',
      etag: index == 0 ? 'recommend' : '',
      onSuccess: (postList, totalPage) {
        tabControllerLoaded = true;
        lakeAreas[index]?.dataList.clear();
        _addOrUpdateItems(postList, index);
        lakeAreas[index]!.currentPage = 1;
        lakeAreas[index]!.status = LakePageStatus.idle;
        notifyListeners();
        success?.call();
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
        initPostList(index);
        lakeAreas[index]!.status = LakePageStatus.error;
        notifyListeners();
        failure?.call(e);
      },
    );
  }

  Future<void> getClipboardWeKoContents(BuildContext context) async {
    final clipboardData = await _getValidClipboardData();
    if (clipboardData == null) return;

    final id = _extractIdFromText(clipboardData);
    if (id.isEmpty || !_shouldFetchPost(id)) return;

    _fetchPostById(context, id);
  }

  Future<String?> _getValidClipboardData() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text?.trim().isNotEmpty ?? false) {
      return clipboardData!.text!.trim();
    }
    return null;
  }

  String _extractIdFromText(String text) {
    return text.find(r"wpy://school_project/(\d*)");
  }

  bool _shouldFetchPost(String id) {
    return CommonPreferences.feedbackLastWeCo.value != id &&
        CommonPreferences.lakeToken.value.isNotEmpty;
  }

  void _fetchPostById(BuildContext context, String id) {
    FeedbackService.getPostById(
      id: int.parse(id),
      onResult: (post) => _showWeKoDialog(context, post, id),
      onFailure: (e) {
        // Handle error if necessary
      },
    );
  }

  void _showWeKoDialog(BuildContext context, Post post, String id) {
    showDialog<bool>(
      context: context,
      builder: (context) => WeKoDialog(
        post: post,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, true),
      ),
    ).then((confirm) {
      if (confirm == true) {
        Navigator.pushNamed(context, FeedbackRouter.detail, arguments: post);
      }
      CommonPreferences.feedbackLastWeCo.value = id;
    });
  }

  void clearAndSetSplitPost(Post post) {
    int changeId = horizontalViewingPost.changeId;
    if (horizontalViewingPost.post.id != post.id) {
      changeId = changeId + 1;
      FeedbackService.visitPost(id: post.id, onFailure: (_) {});
    }
    horizontalViewingPost = ChangeablePost(post, changeId);
    notifyListeners();
  }
}

class FestivalProvider extends ChangeNotifier {
  List<Festival> festivalList = [];
  List<Festival> nonePopupList = [];
  bool _notInit = true;

  int get nonePopupListLength {
    _initializeIfNeeded();
    return nonePopupList.length;
  }

  Future<void> initFestivalList() async {
    _notInit = false;
    await FeedbackService.getFestCards(
      onSuccess: (list) {
        _updateFestivalLists(list);
      },
      onFailure: (e) {
        notifyListeners();
      },
    );
  }

  void _initializeIfNeeded() {
    if (_notInit) {
      initFestivalList();
    }
  }

  void _updateFestivalLists(List<Festival> list) {
    festivalList = list;
    nonePopupList = list.where((f) => f.name != 'popup').toList();
    notifyListeners();
  }

  int popUpIndex() {
    return festivalList.indexWhere((f) => f.name == 'popup');
  }
}

class NoticeProvider extends ChangeNotifier {
  List<Notice> noticeList = [];

  Future<void> initNotices() async {
    await FeedbackService.getNotices(
      onResult: (notices) {
        noticeList.clear();
        noticeList.addAll(notices);
        notifyListeners();
      },
      onFailure: (e) {
        notifyListeners();
      },
    );
  }
}

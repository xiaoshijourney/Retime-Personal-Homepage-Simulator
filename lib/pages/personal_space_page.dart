import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_item.dart';
import '../widgets/content_card.dart';
import 'settings_page.dart';

class PersonalSpacePage extends StatefulWidget {
  const PersonalSpacePage({super.key});

  @override
  State<PersonalSpacePage> createState() => _PersonalSpacePageState();
}

class _PersonalSpacePageState extends State<PersonalSpacePage> {
  final ScrollController _scrollController = ScrollController();
  double _barOpacity = 0.0;

  static const double _coverExpandedHeight = 250;
  static const double _avatarTopOffset = 50;

  // 编辑模式（开关控制）
  bool _editMode = false;

  // 标签库
  final List<String> _predefinedTags = ['学习打卡', '劳动打卡'];
  List<String> _customTags = [];
  int _displayCount = 999;
  bool _initialized = false;

  // 可变数据
  String _nickname = '小矢';
  String _avatarPath = 'lib/my_res/avatar.png';
  String _coverPath = 'lib/my_res/avatar.png';
  String _infoText = 'XX大学 | XX学院 | XXX';
  late List<ContentItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _buildInitialItems();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? '小矢';
      _avatarPath = prefs.getString('avatarPath') ?? 'lib/my_res/avatar.png';
      _coverPath = prefs.getString('coverPath') ?? 'lib/my_res/avatar.png';
      _infoText = prefs.getString('infoText') ?? 'XX大学 | XX学院 | XXX';
      _customTags = prefs.getStringList('customTags') ?? [];
      _displayCount = prefs.getInt('displayCount') ?? 999;
      final itemsJson = prefs.getString('items');
      if (itemsJson != null) {
        final list = jsonDecode(itemsJson) as List;
        _items = list.map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      _initialized = true;
    });
  }

  Future<void> _saveData() async {
    if (!_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('nickname', _nickname);
    prefs.setString('avatarPath', _avatarPath);
    prefs.setString('coverPath', _coverPath);
    prefs.setString('infoText', _infoText);
    prefs.setStringList('customTags', _customTags);
    prefs.setInt('displayCount', _displayCount);
    prefs.setString('items', jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _saveData();
  }

  List<ContentItem> _buildInitialItems() {
    final list = <ContentItem>[];
    final tags = ['学习打卡', '劳动打卡'];
    for (int i = 0; i < 14; i++) {
      final day = 30 - i;
      final hour = 8 + (i % 14);
      final minute = (i * 7) % 60;
      list.add(ContentItem(
        title: 'ENJOY JOURNEY!',
        userInfo: '小矢 XX大学 XX学院',
        tag: tags[i % 2],
        time: '06-${day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
        imageUrl: 'lib/my_res/default_pic.png',
      ));
    }
    return list;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final opacity = (offset / 120).clamp(0.0, 1.0);
    if ((opacity - _barOpacity).abs() > 0.01) {
      setState(() => _barOpacity = opacity);
    }
  }

  // ── 打开设置页 ──
  void _openSettings() async {
    final parts = _infoText.split('|').map((s) => s.trim()).toList();
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => SettingsPage(
        isLocked: _editMode,
        name: _nickname,
        school: parts.isNotEmpty ? parts[0] : '',
        college: parts.length > 1 ? parts[1] : '',
        customTags: _customTags,
        predefinedTags: _predefinedTags,
        displayCount: _displayCount,
      )),
    );
    if (result != null) {
      // 恢复出厂设置（需要异步清 SharedPreferences，放在 setState 外面）
      if (result['resetAll'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        setState(() {
          _items = _buildInitialItems();
          _customTags = [];
          _displayCount = 999;
          _nickname = '小矢';
          _avatarPath = 'lib/my_res/avatar.png';
          _coverPath = 'lib/my_res/avatar.png';
          _infoText = 'XX大学 | XX学院 | XXX';
          _editMode = false;
        });
        return;
      }
      setState(() {
        _editMode = result['locked'] ?? _editMode;
        _nickname = result['name'] ?? _nickname;
        final s = result['school'] ?? parts[0];
        final c = result['college'] ?? (parts.length > 1 ? parts[1] : '');
        final rest = parts.length > 2 ? parts.sublist(2).join(' | ') : '';
        _infoText = rest.isNotEmpty ? '$s | $c | $rest' : '$s | $c';
        if (result['customTags'] != null) _customTags = List<String>.from(result['customTags']);
        if (result['displayCount'] != null) _displayCount = result['displayCount'];
        if (result['deleteAllCards'] == true) {
          _items.clear();
          return;
        }
        if (result['resetInfo'] == true) {
          _nickname = '小矢';
          _infoText = 'XX大学 | XX学院 | XXX';
          return;
        }
        if (result['addCards'] != null) {
          _addCards(result['addCards'] as int);
          return;
        }
        if (result['generateDorm'] != null) {
          final g = result['generateDorm'] as Map;
          _generateDormCheckins(g['year'], g['month']);
          return; // generateDormCheckins already calls setState
        }
        // 更新卡片数据
        for (int i = 0; i < _items.length; i++) {
          final old = _items[i];
          _items[i] = ContentItem(
            title: old.title,
            userInfo: '$_nickname $s $c',
            tag: old.tag,
            time: old.time,
            imageUrl: old.imageUrl,
          );
        }
      });
    }
  }

  // ── 编辑文字弹窗 ──
  void _editText(String title, String current, ValueChanged<String> onSave) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // ── 系统相册选图 ──
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ValueChanged<String> onSave) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      onSave(file.path);
      setState(() {});
    }
  }

  // ── 图片 Provider（支持 asset 路径和本地文件路径）──
  ImageProvider _imageProvider(String path) {
    if (path.startsWith('lib/')) return AssetImage(path);
    return FileImage(File(path));
  }

  // ── 排序后的列表 ──
  List<ContentItem> get _sortedItems {
    final sorted = List<ContentItem>.from(_items);
    sorted.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sorted;
  }

  // ── 删除卡片 ──
  void _deleteItem(ContentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除卡片'),
        content: Text('确定要删除「${item.title}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              setState(() => _items.removeWhere((e) => e.title == item.title && e.tag == item.tag && e.time == item.time));
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── 删除自定义标签 ──
  void _deleteCustomTag(String tag) {
    setState(() => _customTags.remove(tag));
  }

  // ── 标签选择弹窗 ──
  void _pickTag(int displayIndex) {
    final displayed = _sortedItems.take(_displayCount).toList();
    final item = displayed[displayIndex];
    final allTags = [..._predefinedTags, ..._customTags];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择标签'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allTags.length + 1,
            itemBuilder: (ctx, i) {
              if (i < allTags.length) {
                final tag = allTags[i];
                final isSelected = tag == item.tag;
                final isCustom = !_predefinedTags.contains(tag);
                return ListTile(
                  title: Text(tag),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) const Icon(Icons.check, color: Colors.blue, size: 20),
                      if (isCustom)
                        GestureDetector(
                          onTap: () {
                            _deleteCustomTag(tag);
                            Navigator.pop(ctx);
                          },
                          child: const Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      final idx = _items.indexWhere((e) => e.title == item.title && e.tag == item.tag && e.time == item.time);
                      if (idx != -1) {
                        _items[idx] = ContentItem(
                          title: _items[idx].title,
                          userInfo: _items[idx].userInfo,
                          tag: tag,
                          time: _items[idx].time,
                          imageUrl: _items[idx].imageUrl,
                        );
                      }
                    });
                    Navigator.pop(ctx);
                  },
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.add, color: Colors.blue),
                  title: const Text('添加自定义标签', style: TextStyle(color: Colors.blue)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _addCustomTagDialog(displayIndex);
                  },
                );
              }
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ],
      ),
    );
  }

  // ── 更新列表项 ──
  void _updateItem(int index, ContentItem updated) {
    if (index >= 0 && index < _items.length) {
      setState(() => _items[index] = updated);
    }
  }

  void _addCustomTagDialog(int displayIndex) {
    final displayed = _sortedItems.take(_displayCount).toList();
    final item = displayed[displayIndex];
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加自定义标签'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: '输入新标签名')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty && !_predefinedTags.contains(tag) && !_customTags.contains(tag)) {
                setState(() {
                  _customTags.add(tag);
                  final idx = _items.indexWhere((e) => e.title == item.title && e.tag == item.tag && e.time == item.time);
                  if (idx != -1) {
                    _items[idx] = ContentItem(
                      title: _items[idx].title,
                      userInfo: _items[idx].userInfo,
                      tag: tag,
                      time: _items[idx].time,
                      imageUrl: _items[idx].imageUrl,
                    );
                  }
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // ── 新增卡片 ──
  void _addCards(int count) {
    final parts = _infoText.split('|').map((s) => s.trim()).toList();
    final userInfo = '$_nickname ${parts.isNotEmpty ? parts[0] : ''} ${parts.length > 1 ? parts[1] : ''}';
    final now = DateTime.now();
    for (int i = 0; i < count; i++) {
      final dt = now.subtract(Duration(minutes: i * 3));
      _items.add(ContentItem(
        title: 'ENJOY JOURNEY!',
        userInfo: userInfo,
        tag: i % 2 == 0 ? '学习打卡' : '劳动打卡',
        time: '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
        imageUrl: 'lib/my_res/default_pic.png',
        dateTime: dt,
      ));
    }
    setState(() {});
  }

  // ── 一键宿舍打卡 ──
  void _generateDormCheckins(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final days = List.generate(lastDay, (i) => i + 1)..shuffle();
    final picked = days.take(7).toList()..sort();

    int studyNum = 1;
    int laborNum = 1;
    final parts = _infoText.split('|').map((s) => s.trim()).toList();
    final userInfo = '$_nickname ${parts.isNotEmpty ? parts[0] : ''} ${parts.length > 1 ? parts[1] : ''}';

    for (final day in picked) {
      final baseH = 8 + ((day * 3 + month * 7) % 14);
      final baseM = (day * 17 + month * 11) % 60;
      final baseDt = DateTime(year, month, day, baseH, baseM);

      // 学习打卡
      _items.add(ContentItem(
        title: '${month}月寝室第$studyNum次学习打卡',
        userInfo: userInfo,
        tag: '学习打卡',
        time: '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} ${baseH.toString().padLeft(2, '0')}:${baseM.toString().padLeft(2, '0')}',
        imageUrl: 'lib/my_res/cover.jpg',
        dateTime: baseDt,
      ));
      studyNum++;

      // 劳动打卡（时间偏移 ±30 分钟内）
      final offset = ((day * 13 + month * 5) % 61) - 30;
      final laborDt = baseDt.add(Duration(minutes: offset));
      final lDay = laborDt.day;
      _items.add(ContentItem(
        title: '${month}月寝室第$laborNum次劳动打卡',
        userInfo: userInfo,
        tag: '劳动打卡',
        time: '${laborDt.month.toString().padLeft(2, '0')}-${lDay.toString().padLeft(2, '0')} ${laborDt.hour.toString().padLeft(2, '0')}:${laborDt.minute.toString().padLeft(2, '0')}',
        imageUrl: 'lib/my_res/cover.jpg',
        dateTime: laborDt,
      ));
      laborNum++;
    }
    setState(() {});
  }

  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: statusBarHeight + _coverExpandedHeight,
                child: _buildCover(statusBarHeight),
              ),
              Container(
                color: const Color.fromARGB(245,247,247, 249),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: () {
                      final displayed = _sortedItems.take(_displayCount).toList();
                      final widgets = <Widget>[];
                      for (int i = 0; i < displayed.length; i++) {
                        final item = displayed[i];
                        final itemIndex = _items.indexWhere((e) => e.title == item.title && e.tag == item.tag && e.time == item.time);
                        widgets.add(ContentCard(
                          item: item,
                          editable: _editMode,
                          onLongPress: _editMode ? () => _deleteItem(item) : null,
                          onTitleTap: () => _editText(
                            '编辑标题', item.title,
                            (v) => _updateItem(itemIndex, ContentItem(title: v, userInfo: item.userInfo, tag: item.tag, time: item.time, imageUrl: item.imageUrl)),
                          ),
                          onUserInfoTap: () => _editText(
                            '编辑署名', item.userInfo,
                            (v) => _updateItem(itemIndex, ContentItem(title: item.title, userInfo: v, tag: item.tag, time: item.time, imageUrl: item.imageUrl)),
                          ),
                          onTagTap: () => _pickTag(i),
                          onTimeTap: () => _editText(
                            '编辑时间', item.time,
                            (v) => _updateItem(itemIndex, ContentItem(title: item.title, userInfo: item.userInfo, tag: item.tag, time: v, imageUrl: item.imageUrl)),
                          ),
                          onImageTap: () => _pickImage(
                            (v) => _updateItem(itemIndex, ContentItem(title: item.title, userInfo: item.userInfo, tag: item.tag, time: item.time, imageUrl: v)),
                          ),
                        ));
                      }
                      return widgets;
                    }(),
                  ),
                ),
              ),
            ],
          ),

          // ── 顶部栏 ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: _barOpacity > 0.05
                    ? const Color(0xFF73B4F5).withAlpha((_barOpacity * 255).round().clamp(0, 255))
                    : Colors.transparent,
              ),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 3),
                        child: IconButton(
                          icon: Image.asset('lib/my_res/back.png', width: 60, height: 60, color: Colors.white),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const Spacer(),
                      Opacity(
                        opacity: _barOpacity,
                        child: Text(_nickname, style: const TextStyle(fontFamily: 'Microsoft YaHei', fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const Spacer(),
                      Transform.translate(
                        offset: const Offset(0, 3),
                        child: IconButton(
                          icon: Image.asset('lib/my_res/setting_00000.png', width: 60, height: 60, color: Colors.white),
                          onPressed: _openSettings,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  Widget _buildCover(double statusBarHeight) {
    final isDefaultCover = _coverPath == 'lib/my_res/avatar.png';
    Widget coverImage = Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: _imageProvider(_coverPath), fit: BoxFit.cover),
      ),
    );
    if (isDefaultCover) {
      coverImage = Stack(
        children: [
          coverImage,
          Container(color: Colors.black.withAlpha(80)),
        ],
      );
    }
    if (_editMode) {
      coverImage = GestureDetector(
        onTap: () => _pickImage((v) => _coverPath = v),
        child: coverImage,
      );
    }

    Widget avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color.fromARGB(134, 255, 255, 255), width: 3),
      ),
      child: CircleAvatar(radius: 41, backgroundImage: _imageProvider(_avatarPath)),
    );
    if (_editMode) {
      avatar = GestureDetector(
        onTap: () => _pickImage((v) => _avatarPath = v),
        child: avatar,
      );
    }

    Widget nickname = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_nickname, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Transform.translate(
          offset: const Offset(6, 3),
          child: Image.asset('lib/my_res/vip1.png', width: 24, height: 25),
        ),
        Transform.translate(
          offset: const Offset(3, 3),
          child: Image.asset('lib/my_res/vip2.png', width: 55, height: 23),
        ),
      ],
    );
    if (_editMode) {
      nickname = GestureDetector(
        onTap: () => _editText('编辑昵称', _nickname, (v) => _nickname = v),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(border: Border.all(color: Colors.white.withAlpha(120), width: 1), borderRadius: BorderRadius.circular(4)),
          child: nickname,
        ),
      );
    }

    final infoParts = _infoText.split('|').map((s) => s.trim()).toList();
    Widget infoRow = Row(
      children: () {
        final children = <Widget>[];
        for (int i = 0; i < infoParts.length; i++) {
          children.add(Expanded(
            child: Text(infoParts[i], textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Microsoft YaHei', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
          ));
          if (i < infoParts.length - 1) {
            children.add(const Text('|', style: TextStyle(fontFamily: 'Microsoft YaHei', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10)));
          }
        }
        return children;
      }(),
    );
    if (_editMode) {
      infoRow = GestureDetector(
        onTap: () => _editText('编辑信息', _infoText, (v) => _infoText = v),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(border: Border.all(color: Colors.white.withAlpha(120), width: 1), borderRadius: BorderRadius.circular(4)),
          child: infoRow,
        ),
      );
    }

    return Stack(
      children: [
        coverImage,
        Positioned(top: statusBarHeight + _avatarTopOffset + 5, left: 35, child: avatar),
        Positioned(top: statusBarHeight + _avatarTopOffset + 10, left: 130, child: nickname),
        Positioned(top: statusBarHeight + _avatarTopOffset + 115, left: 20, right: 20, child: infoRow),
        Positioned(
          top: statusBarHeight + 65,
          right: 16,
          child: Image.asset('lib/my_res/qr.png', width: 20, height: 20),
        ),
      ],
    );
  }
}

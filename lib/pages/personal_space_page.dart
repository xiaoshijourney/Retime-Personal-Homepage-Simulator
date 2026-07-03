import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // 可变数据
  String _nickname = '谢毅捷';
  String _avatarPath = 'lib/my_res/avatar.png';
  String _coverPath = 'lib/my_res/cover.jpg';
  String _infoText = '东北电力大学 | 自动化工程学院 | 机器人231';
  late List<ContentItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _buildInitialItems();
    _scrollController.addListener(_onScroll);
  }

  List<ContentItem> _buildInitialItems() => [
        ContentItem(title: '六月寝室第一次学习打卡', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '学习打卡', time: '06-24 00:11', imageUrl: 'lib/my_res/cover.jpg'),
        ContentItem(title: '劳动最光荣，今天也是努力的一天', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '劳动打卡', time: '06-23 18:30', imageUrl: 'lib/my_res/cover.jpg'),
        ContentItem(title: '期末复习笔记分享', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '学习打卡', time: '06-22 22:15', imageUrl: 'lib/my_res/cover.jpg'),
        ContentItem(title: '早起晨跑第三周', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '劳动打卡', time: '06-21 07:05', imageUrl: 'lib/my_res/cover.jpg'),
        ContentItem(title: '图书馆自习打卡', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '学习打卡', time: '06-20 19:20', imageUrl: 'lib/my_res/cover.jpg'),
        ContentItem(title: '周末志愿服务记录', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '劳动打卡', time: '06-19 10:00', imageUrl: 'lib/my_res/cover.jpg'),
        ContentItem(title: 'Python课程笔记整理', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '学习打卡', time: '06-18 22:45', imageUrl: 'lib/my_res/cover.jpg'),
        ContentItem(title: '操场晨跑第五周达成', userInfo: '小矢 东北电力大学 自动化工程学院', tag: '劳动打卡', time: '06-17 06:50', imageUrl: 'lib/my_res/cover.jpg'),
      ];

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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SettingsPage(isLocked: _editMode)),
    );
    if (result != null) setState(() => _editMode = result);
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

  // ── 更新列表项 ──
  void _updateItem(int index, ContentItem updated) {
    setState(() => _items[index] = updated);
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
                child: Column(
                  children: [
                    for (int i = 0; i < _items.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ContentCard(
                          item: _items[i],
                          editable: _editMode,
                          onTitleTap: () => _editText(
                            '编辑标题', _items[i].title,
                            (v) => _updateItem(i, ContentItem(title: v, userInfo: _items[i].userInfo, tag: _items[i].tag, time: _items[i].time, imageUrl: _items[i].imageUrl)),
                          ),
                          onUserInfoTap: () => _editText(
                            '编辑署名', _items[i].userInfo,
                            (v) => _updateItem(i, ContentItem(title: _items[i].title, userInfo: v, tag: _items[i].tag, time: _items[i].time, imageUrl: _items[i].imageUrl)),
                          ),
                          onTagTap: () => _editText(
                            '编辑标签', _items[i].tag,
                            (v) => _updateItem(i, ContentItem(title: _items[i].title, userInfo: _items[i].userInfo, tag: v, time: _items[i].time, imageUrl: _items[i].imageUrl)),
                          ),
                          onTimeTap: () => _editText(
                            '编辑时间', _items[i].time,
                            (v) => _updateItem(i, ContentItem(title: _items[i].title, userInfo: _items[i].userInfo, tag: _items[i].tag, time: v, imageUrl: _items[i].imageUrl)),
                          ),
                          onImageTap: () => _pickImage(
                            (v) => _updateItem(i, ContentItem(title: _items[i].title, userInfo: _items[i].userInfo, tag: _items[i].tag, time: _items[i].time, imageUrl: v)),
                          ),
                        ),
                      ),
                  ],
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
    Widget coverImage = Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: _imageProvider(_coverPath), fit: BoxFit.cover),
      ),
    );
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
          offset: const Offset(0, 3),
          child: Image.asset('lib/my_res/vip1.png', width: 20, height: 20),
        ),
        Transform.translate(
          offset: const Offset(-6, 3),
          child: Image.asset('lib/my_res/vip2.png', width: 50, height: 20),
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
        Positioned(top: statusBarHeight + _avatarTopOffset + 110, left: 20, right: 20, child: infoRow),
      ],
    );
  }
}

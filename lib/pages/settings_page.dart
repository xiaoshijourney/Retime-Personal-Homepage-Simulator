import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isLocked;
  final String name;
  final String school;
  final String college;
  final List<String> customTags;
  final List<String> predefinedTags;
  final int displayCount;

  const SettingsPage({
    super.key,
    required this.isLocked,
    required this.name,
    required this.school,
    required this.college,
    required this.customTags,
    required this.predefinedTags,
    required this.displayCount,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _locked;
  late TextEditingController _nameCtrl;
  late TextEditingController _schoolCtrl;
  late TextEditingController _collegeCtrl;
  late TextEditingController _cardCountCtrl;
  late List<String> _customTags;
  Map<String, int>? _generateDorm;
  int? _addCards;
  bool _resetInfo = false;
  bool _deleteAllCards = false;
  bool _resetAll = false;

  @override
  void initState() {
    super.initState();
    _locked = widget.isLocked;
    _nameCtrl = TextEditingController(text: widget.name);
    _schoolCtrl = TextEditingController(text: widget.school);
    _collegeCtrl = TextEditingController(text: widget.college);
    _cardCountCtrl = TextEditingController(text: widget.displayCount >= 999 ? '' : widget.displayCount.toString());
    _customTags = List.from(widget.customTags);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _collegeCtrl.dispose();
    _cardCountCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final countText = _cardCountCtrl.text.trim();
    final count = countText.isEmpty ? 999 : int.tryParse(countText) ?? 999;
    Navigator.pop(context, {
      'locked': _locked,
      'name': _nameCtrl.text,
      'school': _schoolCtrl.text,
      'college': _collegeCtrl.text,
      'customTags': _customTags,
      'displayCount': count,
      'generateDorm': _generateDorm,
      'addCards': _addCards,
      'resetInfo': _resetInfo,
      'deleteAllCards': _deleteAllCards,
      'resetAll': _resetAll,
    });
  }

  void _addTag() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: '输入标签名')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final tag = ctrl.text.trim();
              if (tag.isNotEmpty && !widget.predefinedTags.contains(tag) && !_customTags.contains(tag)) {
                setState(() => _customTags.add(tag));
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _generateDormDialog() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('一键宿舍打卡'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('年份: '),
                  DropdownButton<int>(
                    value: year,
                    items: List.generate(5, (i) => now.year - 1 + i).map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (v) => setDlgState(() => year = v!),
                  ),
                  const SizedBox(width: 20),
                  const Text('月份: '),
                  DropdownButton<int>(
                    value: month,
                    items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text('$m'))).toList(),
                    onChanged: (v) => setDlgState(() => month = v!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('将随机生成 7 天 × 2 次 = 14 张卡片', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            ElevatedButton(
              onPressed: () {
                _generateDorm = {'year': year, 'month': month};
                Navigator.pop(ctx);
                _apply();
              },
              child: const Text('生成'),
            ),
          ],
        ),
      ),
    );
  }

  void _addCardsDialog() {
    final ctrl = TextEditingController(text: '5');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新增卡片'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '输入要新增的卡片数量'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final count = int.tryParse(ctrl.text.trim()) ?? 0;
              if (count > 0) {
                _addCards = count;
                Navigator.pop(ctx);
                _apply();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmResetInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复个人信息'),
        content: const Text('确定要恢复个人信息到默认值吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              _resetInfo = true;
              Navigator.pop(ctx);
              _apply();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmResetAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复出厂设置'),
        content: const Text('将清除所有数据并恢复到默认状态，此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              _resetAll = true;
              Navigator.pop(ctx);
              _apply();
            },
            child: const Text('确定重置', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除所有卡片'),
        content: const Text('确定要删除所有卡片吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              _deleteAllCards = true;
              Navigator.pop(ctx);
              _apply();
            },
            child: const Text('确定删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _apply();
      },
      child: Scaffold(
        appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _apply,
        ),
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('编辑模式'),
            subtitle: Text(_locked ? '点击元素即可编辑' : '编辑已锁定'),
            value: _locked,
            onChanged: (val) => setState(() => _locked = val),
          ),
          const SizedBox(height: 6),

          // ═══════ 个人信息 ═══════
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('个人信息', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _buildField('名字', _nameCtrl),
          _buildField('学校', _schoolCtrl),
          _buildField('学院', _collegeCtrl),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _apply,
              child: const Text('一键应用个人信息'),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _confirmResetInfo,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              child: const Text('恢复个人信息到默认'),
            ),
          ),

          // ═══════ 卡片管理 ═══════
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('卡片管理', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _buildField('显示数量（留空=全部）', _cardCountCtrl),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _addCardsDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('新增卡片'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _confirmDeleteAll,
              icon: const Icon(Icons.delete_forever),
              label: const Text('一键删除所有卡片'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _generateDormDialog,
              icon: const Icon(Icons.night_shelter),
              label: const Text('一键宿舍打卡'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF73B4F5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),

          // ═══════ 标签管理 ═══════
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('标签管理', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.add, color: Colors.blue), onPressed: _addTag, iconSize: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: () {
                final widgets = <Widget>[];
                for (final tag in widget.predefinedTags) {
                  widgets.add(Chip(label: Text(tag), backgroundColor: const Color(0xFFEEEEEE)));
                }
                for (final tag in _customTags) {
                  widgets.add(Chip(
                    label: Text(tag),
                    backgroundColor: const Color(0xFFDDE4FF),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _customTags.remove(tag)),
                  ));
                }
                return widgets;
              }(),
            ),
          ),

          // ═══════ 恢复出厂设置 ═══════
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _confirmResetAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('恢复出厂设置'),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

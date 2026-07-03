import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isLocked;
  final String name;
  final String school;
  final String college;

  const SettingsPage({
    super.key,
    required this.isLocked,
    required this.name,
    required this.school,
    required this.college,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _locked;
  late TextEditingController _nameCtrl;
  late TextEditingController _schoolCtrl;
  late TextEditingController _collegeCtrl;

  @override
  void initState() {
    super.initState();
    _locked = widget.isLocked;
    _nameCtrl = TextEditingController(text: widget.name);
    _schoolCtrl = TextEditingController(text: widget.school);
    _collegeCtrl = TextEditingController(text: widget.college);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _collegeCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    Navigator.pop(context, {
      'locked': _locked,
      'name': _nameCtrl.text,
      'school': _schoolCtrl.text,
      'college': _collegeCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            subtitle: Text(_locked ? '点击元素即可编辑，下方可批量修改' : '编辑已锁定'),
            value: _locked,
            onChanged: (val) => setState(() => _locked = val),
          ),
          const SizedBox(height: 12),
          _buildField('名字', _nameCtrl),
          _buildField('学校', _schoolCtrl),
          _buildField('学院', _collegeCtrl),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _apply,
              child: const Text('一键应用'),
            ),
          ),
        ],
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

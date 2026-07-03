import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isLocked;

  const SettingsPage({super.key, required this.isLocked});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _locked;

  @override
  void initState() {
    super.initState();
    _locked = widget.isLocked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context, _locked),
        ),
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('编辑模式'),
            subtitle: Text(_locked ? '编辑模式已开启，点击即可编辑' : '编辑模式已关闭'),
            value: _locked,
            onChanged: (val) => setState(() => _locked = val),
          ),
        ],
      ),
    );
  }
}

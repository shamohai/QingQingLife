import 'package:flutter/material.dart';

import '../../../../core/storage/secure_storage.dart';

/// 临时联调页面：手动编辑请求使用的认证 token 和设备 ID。
class TokenDebugPage extends StatefulWidget {
  const TokenDebugPage({super.key});

  @override
  State<TokenDebugPage> createState() => _TokenDebugPageState();
}

class _TokenDebugPageState extends State<TokenDebugPage> {
  static const _defaultAuthToken = '1575474';
  static const _defaultDeviceId = '17835616055244338';

  final _authTokenController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _storage = SecureStorage();
  String _storedAuthToken = '';
  String _storedDeviceId = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final authToken = await _storage.readAuthToken();
    final deviceId = await _storage.readDeviceId();
    if (!mounted) return;
    _storedAuthToken = authToken ?? '';
    _storedDeviceId = deviceId ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _saveValues() async {
    setState(() => _isSaving = true);
    final authToken = _authTokenController.text.trim();
    final deviceId = _deviceIdController.text.trim();
    await _storage.writeAuthToken(authToken);
    await _storage.writeDeviceId(deviceId);
    if (!mounted) return;
    setState(() {
      _storedAuthToken = authToken;
      _storedDeviceId = deviceId;
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存到本地存储')));
  }

  @override
  void dispose() {
    _authTokenController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Token 临时设置')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _authTokenController,
                  decoration: const InputDecoration(labelText: 'auth_token', hintText: '请输入 authtoken', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _deviceIdController,
                  decoration: const InputDecoration(labelText: 'auth_device_id', hintText: '请输入设备 ID', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton(onPressed: _isSaving ? null : _saveValues, child: _isSaving ? const CircularProgressIndicator() : const Text('保存')),
                ),
                const SizedBox(height: 12),
                Text(
                  '当前 localStorage 值\n'
                  'auth_token：${_storedAuthToken.isEmpty ? '（空）' : _storedAuthToken}\n'
                  'auth_device_id：${_storedDeviceId.isEmpty ? '（空）' : _storedDeviceId}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _authTokenController.text = _defaultAuthToken;
                      _deviceIdController.text = _defaultDeviceId;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('联调默认值：1575474, 17835616055244338（点击回填）', style: TextStyle(color: Colors.blue, fontSize: 13)),
                  ),
                ),
              ],
            ),
    );
  }
}

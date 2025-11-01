import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final ApiService api = ApiService();

  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    try {
      final resp = await api.post('/client/auth/login', data: {
        'username': username,
        'password': password,
      });

      // Expecting JSON like: { token: '...', redirectUrl: '/...' }
      final data = resp.data is Map ? resp.data as Map<String, dynamic> : <String, dynamic>{};

      final token = data['token'] as String?;
      final redirectUrl = data['redirectUrl'] as String?;

      if (token != null && token.isNotEmpty) {
        // Save token to SharedPreferences
        final sp = await SharedPreferences.getInstance();
        await sp.setString('authToken', token);

        setState(() {
          _successMessage = 'Đăng nhập thành công! Đang chuyển hướng...';
        });

        // Small delay to show success message
        await Future.delayed(const Duration(milliseconds: 800));

        // If redirectUrl is an internal route (starts with '/'), navigate there.
        if (redirectUrl != null && redirectUrl.startsWith('/')) {
          if (mounted) Navigator.pushReplacementNamed(context, redirectUrl);
        } else {
          if (mounted) Navigator.pushReplacementNamed(context, '/'); // home
        }
        return;
      } else {
        setState(() {
          _errorMessage = 'Không nhận được token từ server.';
        });
      }
    } on DioError catch (e) {
      String msg = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      if (e.response != null) {
        final respData = e.response?.data;
        if (respData is Map && respData['error'] != null) {
          msg = respData['error'].toString();
        } else if (e.response?.statusCode == 401) {
          msg = 'Sai tài khoản hoặc mật khẩu!';
        } else if (respData is String) {
          msg = respData;
        }
      } else {
        msg = e.message ?? msg;
      }
      setState(() => _errorMessage = msg);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (logo + link)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  // Logo (replace asset or network)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://your-cdn.com/images/logo.jpg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant_menu),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                    icon: const Icon(Icons.home, color: Color(0xFF667EEA)),
                    label: Text('Trang chủ', style: TextStyle(color: Colors.grey[800])),
                  ),
                ],
              ),
            ),

            // Form area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFF3690C), Color(0xFFDF3333)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.person, size: 56, color: Colors.white),
                                SizedBox(height: 8),
                                Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Text('Chào mừng bạn quay trở lại', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),

                          // Body
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border(left: BorderSide(color: Colors.red.shade700, width: 4)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (_successMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border(left: BorderSide(color: Colors.green.shade700, width: 4)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_successMessage!, style: const TextStyle(color: Colors.green))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // Username
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _usernameCtrl,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.person),
                                          hintText: 'Nhập tài khoản của bạn',
                                          filled: true,
                                          fillColor: const Color(0xFFF9FAFB),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        ),
                                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tài khoản' : null,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.username],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Password
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordCtrl,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.lock),
                                          hintText: 'Nhập mật khẩu của bạn',
                                          filled: true,
                                          fillColor: const Color(0xFFF9FAFB),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        ),
                                        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [AutofillHints.password],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Login button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDF3333),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: _loading
                                          ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                          SizedBox(width: 12),
                                          Text('Đang đăng nhập...', style: TextStyle(fontWeight: FontWeight.w700)),
                                        ],
                                      )
                                          : const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: Colors.white,
              child: const Text('© 2024 TeamFOOD. Tất cả quyền được bảo lưu.', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

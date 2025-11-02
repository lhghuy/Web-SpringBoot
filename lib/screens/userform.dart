import 'package:flutter/material.dart';

class User {
  int? userID;
  String username;
  String passwordHash;
  String fullName;
  String avatar;
  String role;

  User({
    this.userID,
    required this.username,
    this.passwordHash = '',
    required this.fullName,
    required this.avatar,
    this.role = 'NhanVien',
  });
}

class UserFormScreen extends StatefulWidget {
  final User? user; // Nếu null => thêm mới, không null => chỉnh sửa

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;
  late TextEditingController _avatarController;
  String _role = 'NhanVien';

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _avatarController = TextEditingController(text: user?.avatar ?? '');
    _role = user?.role ?? 'NhanVien';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Lấy dữ liệu từ form
    final newUser = User(
      userID: widget.user?.userID,
      username: _usernameController.text.trim(),
      passwordHash: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
      avatar: _avatarController.text.trim(),
      role: _role,
    );

    // TODO: Gọi API thêm hoặc cập nhật
    if (widget.user == null) {
      print("Thêm mới: ${newUser.username}");
    } else {
      print("Cập nhật: ${newUser.username}");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lưu thông tin thành công!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa thông tin Nhân viên' : 'Thêm Nhân viên mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                ),
                obscureText: true,
                validator: (value) {
                  if (!isEditing && (value == null || value.isEmpty)) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              if (isEditing)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Để trống nếu không muốn thay đổi mật khẩu',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập họ và tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(
                  labelText: 'Avatar',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập avatar' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                items: const [
                  DropdownMenuItem(value: 'NhanVien', child: Text('Nhân Viên')),
                  DropdownMenuItem(value: 'QuanLy', child: Text('Quản Lý')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _role = val);
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(isEditing ? 'Cập nhật' : 'Thêm Nhân viên'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

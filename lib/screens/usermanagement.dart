import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model User
class User {
  final int userID;
  String username;
  String fullName;
  String role;
  String? avatar;

  User({
    required this.userID,
    required this.username,
    required this.fullName,
    required this.role,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userID: json['userID'],
    username: json['username'],
    fullName: json['fullName'],
    role: json['role'],
    avatar: json['avatar'],
  );
}

// User management screen
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];
  List<String> roles = [];
  bool loading = true;
  bool submitting = false;
  String searchQuery = '';
  String selectedRole = '';
  String alertMessage = '';
  bool alertSuccess = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadRoles();
  }

  Future<void> loadUsers() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse('https://yourapi.com/api/admin/users'));
      final data = json.decode(response.body);
      if (data['success']) {
        users = (data['data'] as List).map((e) => User.fromJson(e)).toList();
        filteredUsers = [...users];
      } else {
        showAlert(data['message'] ?? "Không thể tải dữ liệu", false);
      }
    } catch (e) {
      showAlert("Lỗi kết nối", false);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadRoles() async {
    try {
      final response = await http.get(Uri.parse('https://yourapi.com/api/admin/users/roles'));
      final data = json.decode(response.body);
      if (data['success']) {
        roles = List<String>.from(data['data']);
      }
    } catch (e) {
      // ignore
    }
  }

  void filterUsers() {
    List<User> temp = [...users];
    if (searchQuery.isNotEmpty) {
      temp = temp.where((u) => u.username.toLowerCase().contains(searchQuery.toLowerCase()) || u.fullName.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    if (selectedRole.isNotEmpty) {
      temp = temp.where((u) => u.role == selectedRole).toList();
    }
    setState(() {
      filteredUsers = temp;
    });
  }

  void showAlert(String message, bool success) {
    setState(() {
      alertMessage = message;
      alertSuccess = success;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        alertMessage = '';
      });
    });
  }

  Future<void> deleteUser(int userId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa nhân viên này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );
    if (!confirm) return;

    try {
      final response = await http.delete(Uri.parse('https://yourapi.com/api/admin/users/$userId'));
      final data = json.decode(response.body);
      if (data['success']) {
        users.removeWhere((u) => u.userID == userId);
        filterUsers();
        showAlert("Xóa nhân viên thành công", true);
      } else {
        showAlert(data['message'] ?? "Không thể xóa", false);
      }
    } catch (e) {
      showAlert("Lỗi kết nối", false);
    }
  }

  Future<void> openUserForm({User? user}) async {
    final result = await showDialog<User>(
      context: context,
      builder: (_) => UserFormDialog(user: user, roles: roles),
    );
    if (result != null) {
      await loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý nhân viên"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.logout)), // TODO logout
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (alertMessage.isNotEmpty)
              Container(
                width: double.infinity,
                color: alertSuccess ? Colors.green : Colors.red,
                padding: const EdgeInsets.all(8),
                child: Text(alertMessage, style: const TextStyle(color: Colors.white)),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Tìm kiếm..."),
                    onChanged: (val) {
                      searchQuery = val;
                      filterUsers();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  hint: const Text("Chọn vai trò"),
                  value: selectedRole.isEmpty ? null : selectedRole,
                  items: roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                  onChanged: (val) {
                    selectedRole = val ?? '';
                    filterUsers();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                  ? const Center(child: Text("Không tìm thấy nhân viên"))
                  : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (_, index) {
                  final user = filteredUsers[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar ?? 'https://via.placeholder.com/150'),
                      ),
                      title: Text(user.username),
                      subtitle: Text(user.fullName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(user.role),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => openUserForm(user: user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteUser(user.userID),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openUserForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// User form dialog
class UserFormDialog extends StatefulWidget {
  final User? user;
  final List<String> roles;
  const UserFormDialog({super.key, this.user, required this.roles});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController fullNameController;
  late TextEditingController avatarController;
  String? selectedRole;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    usernameController = TextEditingController(text: u?.username ?? '');
    passwordController = TextEditingController();
    fullNameController = TextEditingController(text: u?.fullName ?? '');
    avatarController = TextEditingController(text: u?.avatar ?? '');
    selectedRole = u?.role ?? (widget.roles.isNotEmpty ? widget.roles.first : null);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => submitting = true);
    try {
      final body = {
        'username': usernameController.text,
        'fullName': fullNameController.text,
        'role': selectedRole,
        'avatar': avatarController.text.isEmpty ? null : avatarController.text,
      };
      if (passwordController.text.isNotEmpty) body['passwordHash'] = passwordController.text;

      http.Response response;
      if (widget.user == null) {
        response = await http.post(Uri.parse('https://yourapi.com/api/admin/users'),
            headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      } else {
        response = await http.put(Uri.parse('https://yourapi.com/api/admin/users/${widget.user!.userID}'),
            headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      }
      final data = jsonDecode(response.body);
      if (data['success']) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Lỗi')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Thêm nhân viên' : 'Sửa thông tin nhân viên'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (val) => val == null || val.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                    labelText: widget.user == null ? 'Mật khẩu' : 'Mật khẩu mới (để trống nếu không đổi)'),
                obscureText: true,
                validator: (val) {
                  if (widget.user == null && (val == null || val.isEmpty)) return 'Không được để trống';
                  return null;
                },
              ),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (val) => val == null || val.isEmpty ? 'Không được để trống' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: widget.roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                onChanged: (val) => selectedRole = val,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                validator: (val) => val == null || val.isEmpty ? 'Chọn vai trò' : null,
              ),
              TextFormField(
                controller: avatarController,
                decoration: const InputDecoration(labelText: 'URL Avatar'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(onPressed: submitting ? null : submit, child: Text(widget.user == null ? 'Thêm' : 'Cập nhật')),
      ],
    );
  }
}

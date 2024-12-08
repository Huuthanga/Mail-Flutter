import 'package:flutter/material.dart';

class UploadProfileScreenWeb extends StatefulWidget {
  final String user; // Bạn có thể thay đổi loại dữ liệu nếu muốn

  UploadProfileScreenWeb({required this.user});

  @override
  _UploadProfileScreenWebState createState() => _UploadProfileScreenWebState();
}

class _UploadProfileScreenWebState extends State<UploadProfileScreenWeb> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _profileInfo = ''; // Biến lưu thông tin profile đã lưu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Profile'),
            ),
            SizedBox(height: 20),
            // Hiển thị thông tin đã lưu
            Text(
              'Saved Profile Info:\n$_profileInfo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    setState(() {
      _profileInfo = 'Name: ${_nameController.text}\n'
          'Email: ${_emailController.text}\n'
          'Phone: ${_phoneController.text}';
    });
  }
}

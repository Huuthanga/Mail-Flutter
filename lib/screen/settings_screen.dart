import 'package:flutter/material.dart';
import 'package:code/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:code/screen/setting/theme_provider.dart';
import 'package:code/screen/password_change_screen.dart';

import 'package:code/screen/two_step_verification_screen.dart';

class SettingsScreen extends StatelessWidget {
  final User user;

  SettingsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () => _changePassword(context),
          ),
          
          ListTile(
            leading: Icon(Icons.notifications_off),
            title: Text('Turn Off Notifications'),
            trailing: Switch(
              value: Provider.of<ThemeProvider>(context, listen: true).notificationsEnabled,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleNotifications(value);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Toggle Dark/Light Theme'),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          ListTile(
            leading: Icon(Icons.auto_fix_high),
            title: Text('Turn On/Off Auto Answer Mode'),
            trailing: Switch(
              value: Provider.of<ThemeProvider>(context, listen: true).autoAnswerMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleAutoAnswerMode(value);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.font_download),
            title: Text('Change Font Settings'),
            onTap: () => _changeFontSettings(context),
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Two-Step Verification'),
            onTap: () => _navigateToTwoStepVerification(context),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordChangeScreen(user: user),
      ),
    );
  }

  void _navigateToTwoStepVerification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TwoStepVerificationScreen(user: user)),
    );
  }
  void _changeFontSettings(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Font Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Font Size Slider
            ListTile(
              title: Text('Font Size'),
              subtitle: Slider(
                min: 10,
                max: 30,
                value: Provider.of<ThemeProvider>(context, listen: false).fontSize,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false).setFontSize(value);
                },
              ),
            ),
            // Font Family Dropdown
            ListTile(
              title: Text('Font Family'),
              subtitle: DropdownButton<String>(
                value: Provider.of<ThemeProvider>(context, listen: false).fontFamily,
                onChanged: (String? newValue) {
                  Provider.of<ThemeProvider>(context, listen: false).setFontFamily(newValue!);
                },
                items: <String>['Arial', 'Roboto', 'Courier New', 'Times New Roman']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}


  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
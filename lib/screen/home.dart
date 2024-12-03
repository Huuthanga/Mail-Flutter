import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'password_change_screen.dart';
import 'two_step_verification_screen.dart';

class HomePage extends StatelessWidget {
  final User user;

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Welcome, ${user.email ?? user.phoneNumber ?? 'User'}!',
              style: TextStyle(fontSize: 20),
              
            ),
            TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasswordChangeScreen(),
                        ),
                      );
                    },
                    child: Text('Change Password'),
            ),
            TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TwoStepVerificationScreen(),
                        ),
                      );
                    },
                    child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

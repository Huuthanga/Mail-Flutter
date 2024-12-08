import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  final User user;

  TwoStepVerificationScreen({required this.user});
  
  @override
  _TwoStepVerificationScreenState createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  bool _isTwoStepEnabled = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _toggleTwoStepVerification() async {
    setState(() {
      _isTwoStepEnabled = !_isTwoStepEnabled;
    });

    if (_isTwoStepEnabled) {
      // Enable 2FA (e.g., by setting up SMS or email-based authentication)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Two-step verification enabled')),
      );
    } else {
      // Disable 2FA
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Two-step verification disabled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Two-Step Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Enable Two-Step Verification'),
              value: _isTwoStepEnabled,
              onChanged: (value) => _toggleTwoStepVerification(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComposeEmailScreen extends StatefulWidget {
  @override
  _ComposeEmailScreenState createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState  extends State<ComposeEmailScreen> {
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  
  @override
  void dispose() {
    super.dispose();
    // Lưu bản nháp khi người dùng rời khỏi màn hình nếu chưa gửi thư
    _saveDraft();
  }

  void _saveDraft() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final recipientEmail = recipientController.text.trim().toLowerCase();
    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();

    if (recipientEmail.isEmpty || subject.isEmpty || body.isEmpty) {
      return;
    }

    try {
      // Tạo bản nháp email
      final emailData = {
        'senderId': user.uid,
        'receiverEmail': recipientEmail,
        'senderEmail': user.email,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'folder': 'Draft',
      };

      // Lưu vào thư mục Draft
      await FirebaseFirestore.instance.collection('emails').add(emailData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save draft: $e')),
      );
    }
  }
  
  void sendEmail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to send emails')),
      );
      return;
    }

    final recipientEmail = recipientController.text.trim().toLowerCase();
    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();

    if (recipientEmail.isEmpty || subject.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Look up recipient by email
      final recipientSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: recipientEmail)
          .limit(1)
          .get();

      if (recipientSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipient not found')),
        );
        return;
      }

      final recipientId = recipientSnapshot.docs.first.id;

      // Email data structure
      final emailData = {
        'senderId': user.uid,
        'receiverId': recipientId,
        'senderEmail': user.email,
        'receiverEmail': recipientEmail,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save email to sender's "Sent" folder
      await FirebaseFirestore.instance
          .collection('emails')
          .add({...emailData, 'folder': 'Sent'});

      // Save email to recipient's "Inbox" folder
      await FirebaseFirestore.instance
          .collection('emails')
          .add({...emailData, 'folder': 'Inbox'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sent successfully')),
      );

      // Navigate back after success
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compose Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: recipientController,
              decoration: InputDecoration(labelText: 'Recipient (Email)'),
            ),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(labelText: 'Body'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sendEmail(context),
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:code/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'compose_email_screen.dart';
import 'package:intl/intl.dart'; // For timestamp formatting

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentFolder = 'Inbox'; // Default folder
  late Stream<QuerySnapshot> emailStream; // Track the email stream

  final List<String> folders = ['Inbox', 'Starred', 'Sent', 'Draft', 'Trash'];

  @override
  void initState() {
    super.initState();
    emailStream = _getEmailsStream();
    print('Fetching emails for folder: $currentFolder'); // Initialize the stream
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - $currentFolder'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: Text(
                  'Folders',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ...folders.map((folder) {
              return ListTile(
                title: Text(folder),
                onTap: () {
                  setState(() {
                    currentFolder = folder; // Update the current folder
                    emailStream = _getEmailsStream(); // Update the stream
                  });
                  Navigator.pop(context); // Close the drawer after selecting folder
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ${widget.user.email ?? widget.user.phoneNumber ?? 'User'}!',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: emailStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  String errorMessage = 'Error loading emails.';
                  if (snapshot.error.toString().contains('index is currently building')) {
                    errorMessage = 'The required index is currently being built. Please try again in a few minutes.';
                  }
                  print('Error loading emails: ${snapshot.error}');
                  return Center(child: Text(errorMessage));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No emails in $currentFolder.'));
                }

                final emails = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: emails.length,
                  itemBuilder: (context, index) {
                    final email = emails[index].data() as Map<String, dynamic>;
                    return _buildCompactEmailListTile(email, emails[index].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToComposeEmail,
        child: Icon(Icons.edit),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Navigate to Compose Email Screen
  void _navigateToComposeEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComposeEmailScreen(),
      ),
    );
  }

  // Logout function
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the Login screen, removing all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your Login screen widget
      (Route<dynamic> route) => false,
    );
  }

  // Build compact email list tile with onTap to show email in a dialog
  Widget _buildCompactEmailListTile(Map<String, dynamic> email, String emailId) {
    String bodyPreview = email['body'] ?? 'No Content';
    // Ensure the preview does not exceed the available length
    if (bodyPreview.length > 30) {
      bodyPreview = bodyPreview.substring(0, 30) + '...'; // Add ellipsis if the content is longer than 30 characters
    }

    // Default to false if starred is null
    bool isStarred = email['starred'] == null ? false : email['starred'];

    return ListTile(
      title: Text(email['subject'] ?? 'No Subject'),
      subtitle: Text(bodyPreview),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isStarred ? Icons.star : Icons.star_border,
              color: isStarred ? Colors.yellow : null,
            ),
            onPressed: () {
              _toggleStarredStatus(emailId, isStarred);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _moveToTrash(emailId);
            },
          ),
          Text(
            _formatTimestamp(email['timestamp']),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: () {
        // Show email details in a dialog
        _showEmailDialog(email);
      },
    );
  }

  // Format the timestamp to a readable format
  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  // Show email details in a pop-up dialog
  void _showEmailDialog(Map<String, dynamic> email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(email['subject'] ?? 'No Subject'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: ${email['senderEmail'] ?? 'Unknown'}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'To: ${email['receiverEmail'] ?? 'Unknown'}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  email['body'] ?? 'No Content',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Move email to Trash folder
  Future<void> _moveToTrash(String emailId) async {
    final emailRef = FirebaseFirestore.instance.collection('emails').doc(emailId);

    // Update the folder field to 'Trash'
    await emailRef.update({
      'folder': 'Trash',
    });

    // Optionally, show a snackbar or other UI feedback for success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email moved to Trash')),
    );
  }

  // Toggle starred status for email
  Future<void> _toggleStarredStatus(String emailId, bool isStarred) async {
    final emailRef = FirebaseFirestore.instance.collection('emails').doc(emailId);
    
    // Update the starred field to the opposite value (true to false, or false to true)
    await emailRef.update({
      'starred': !isStarred,
    });
  }

  // Get email stream based on the selected folder
  Stream<QuerySnapshot> _getEmailsStream() {
    try {
      print('Fetching emails for folder: $currentFolder');
      final collection = FirebaseFirestore.instance.collection('emails');

      switch (currentFolder) {
        case 'Inbox':
          return collection
              .where('folder', isEqualTo: 'Inbox')
              .where('receiverId', isEqualTo: widget.user.uid)
              .orderBy('timestamp', descending: true)
              .snapshots();
        case 'Starred':
          return collection
              .where('folder', isEqualTo: 'Inbox')  // Starred emails are still in the Inbox folder
              .where('receiverId', isEqualTo: widget.user.uid)
              .where('starred', isEqualTo: true)   // Only fetch starred emails
              .orderBy('timestamp', descending: true)
              .snapshots();
        case 'Sent':
          return collection
              .where('folder', isEqualTo: 'Sent')
              .where('senderId', isEqualTo: widget.user.uid)
              .orderBy('timestamp', descending: true)
              .snapshots();
        case 'Draft':
          return collection
              .where('folder', isEqualTo: 'Draft')  // Fetch emails in the Draft folder
              .where('senderId', isEqualTo: widget.user.uid)
              .where('body', isEqualTo: '')  // Assuming that unfinished emails have an empty body
              .orderBy('timestamp', descending: true)
              .snapshots();
        case 'Trash':
          return collection
              .where('folder', isEqualTo: 'Trash')  // Fetch emails in the Trash folder
              .where('receiverId', isEqualTo: widget.user.uid)
              .orderBy('timestamp', descending: true)
              .snapshots();
        default:
          print('Unrecognized folder: $currentFolder');
          return Stream.empty();
      }
    } catch (e) {
      print('Error in Firestore query: $e');
      return Stream.empty();
    }
  }
}
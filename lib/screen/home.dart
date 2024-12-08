import 'package:code/screen/login_screen.dart';
import 'settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'compose_email_screen.dart';
import 'package:intl/intl.dart'; 
import 'package:code/screen/setting/theme_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentFolder = 'Inbox'; // Default folder
  late Stream<QuerySnapshot> emailStream;
  String searchQuery = '';

  final List<String> folders = ['Inbox', 'Starred', 'Sent', 'Draft', 'Trash'];

  @override
  void initState() {
    super.initState();
    emailStream = _getEmailsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - $currentFolder'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.email),
            tooltip: 'View All Emails',
            onPressed: _navigateToViewAllEmails,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EmailSearchDelegate(currentFolder: currentFolder, user: widget.user),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: SingleChildScrollView(
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),

            ...folders.map((folder) {
              return ListTile(
                title: Text(folder),
                onTap: () {
                  setState(() {
                    currentFolder = folder;
                    emailStream = _getEmailsStream();
                  });
                  Navigator.pop(context);
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
              style: Provider.of<ThemeProvider>(context).getTextStyle(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: emailStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading emails.'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No emails in $currentFolder.'));
                }

                final emails = snapshot.data!.docs;
                final filteredEmails = emails.where((email) {
                  final emailData = email.data() as Map<String, dynamic>;
                  final subject = emailData['subject'] ?? '';
                  final body = emailData['body'] ?? '';
                  return subject.toLowerCase().contains(searchQuery.toLowerCase()) || 
                         body.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredEmails.length,
                  itemBuilder: (context, index) {
                    final email = filteredEmails[index].data() as Map<String, dynamic>;
                    return _buildCompactEmailListTile(email, filteredEmails[index].id);
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
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(user: widget.user),
      ),
    );
  }

  void _navigateToViewAllEmails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAllEmailsScreen(folder: currentFolder, user: widget.user),
      ),
    );
  }
  void _navigateToComposeEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComposeEmailScreen(),
      ),
    );
  }
  
  Widget _buildCompactEmailListTile(Map<String, dynamic> email, String emailId) {
    String bodyPreview = email['body'] ?? 'No Content';
    if (bodyPreview.length > 30) {
      bodyPreview = bodyPreview.substring(0, 30) + '...';
    }

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewEmailScreen(email: email),
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  Future<void> _moveToTrash(String emailId) async {
    final emailRef = FirebaseFirestore.instance.collection('emails').doc(emailId);
    await emailRef.update({'folder': 'Trash'});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email moved to Trash')));
  }

  Future<void> _toggleStarredStatus(String emailId, bool isStarred) async {
    final emailRef = FirebaseFirestore.instance.collection('emails').doc(emailId);
    await emailRef.update({'starred': !isStarred});
  }

  Stream<QuerySnapshot> _getEmailsStream() {
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
            .where('folder', isEqualTo: 'Inbox')
            .where('receiverId', isEqualTo: widget.user.uid)
            .where('starred', isEqualTo: true)
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
            .where('folder', isEqualTo: 'Draft')
            .where('senderId', isEqualTo: widget.user.uid)
            .where('body', isEqualTo: '')
            .orderBy('timestamp', descending: true)
            .snapshots();
      case 'Trash':
        return collection
            .where('folder', isEqualTo: 'Trash')
            .where('receiverId', isEqualTo: widget.user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots();
      default:
        return Stream.empty();
    }
  }
}

class ViewAllEmailsScreen extends StatelessWidget {
  final String folder;
  final User user;

  ViewAllEmailsScreen({required this.folder, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Emails - $folder'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emails')
            .where('folder', isEqualTo: folder)
            .where('receiverId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading emails.'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No emails in $folder.'));
          }

          final emails = snapshot.data!.docs;

          return ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(email['subject'] ?? 'No Subject'),
                
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewEmailScreen(email: email),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ViewEmailScreen extends StatelessWidget {
  final Map<String, dynamic> email;

  ViewEmailScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(email['subject'] ?? 'No Subject'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender Info
              Container(
                padding: EdgeInsets.all(12.0),
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From: ${email['senderEmail'] ?? 'Unknown'}',                    
                      style: Provider.of<ThemeProvider>(context).getTextStyle(),          
                    ),
                    SizedBox(height: 8),
                    Text(
                      'To: ${email['receiverEmail'] ?? 'Unknown'}',
                      style: Provider.of<ThemeProvider>(context).getTextStyle(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              // Body of the email in a container
              Container(
                padding: EdgeInsets.all(16.0),
                
                child: Text(
                  email['body'] ?? 'No Content',
                  style: Provider.of<ThemeProvider>(context).getTextStyle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class EmailSearchDelegate extends SearchDelegate {
  final String currentFolder;
  final User user;

  EmailSearchDelegate({required this.currentFolder, required this.user});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emails')
          .where('folder', isEqualTo: currentFolder)
          .where('receiverId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No emails found.'));
        }

        final filteredEmails = snapshot.data!.docs.where((email) {
          final emailData = email.data() as Map<String, dynamic>;
          final subject = emailData['subject'] ?? '';
          final body = emailData['body'] ?? '';
          return subject.toLowerCase().contains(query.toLowerCase()) ||
                 body.toLowerCase().contains(query.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredEmails.length,
          itemBuilder: (context, index) {
            final email = filteredEmails[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(email['subject'] ?? 'No Subject'),
              subtitle: Text(email['body'] ?? 'No Content'),
            );
          },
        );
      },
    );
  }
}

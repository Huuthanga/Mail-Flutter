import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registration App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isPhoneRegistration = true;
  String _selectedCountryCode = '+1';

  Future<void> _registerWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showMessage('Registration successful!');
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e);
      _showMessage(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$_selectedCountryCode${_phoneController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) {
          _showMessage('Phone number automatically verified.');
        },
        verificationFailed: (FirebaseAuthException e) {
          _showMessage(e.message ?? 'Verification failed.');
        },
        codeSent: (String verificationId, int? resendToken) {
          _showMessage('OTP sent! Verification ID: $verificationId');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    if (e.code == 'weak-password') return 'The password is too weak.';
    if (e.code == 'email-already-in-use') return 'This email is already in use.';
    if (e.code == 'invalid-email') return 'The email address is not valid.';
    return e.message ?? 'An unknown error occurred.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPhoneRegistration = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPhoneRegistration
                        ? Colors.green
                        : Colors.grey[300],
                    foregroundColor: _isPhoneRegistration
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: Text('Phone Registration'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPhoneRegistration = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isPhoneRegistration
                        ? Colors.green
                        : Colors.grey[300],
                    foregroundColor: !_isPhoneRegistration
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: Text('Email Registration'),
                ),
              ],
            ),
            SizedBox(height: 20),
            _isPhoneRegistration
                ? Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() {
                                    _selectedCountryCode =
                                        '+${country.phoneCode}';
                                  });
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Text(_selectedCountryCode,
                                    style: TextStyle(fontSize: 16)),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _sendOTP,
                              child: Text('Send OTP'),
                            ),
                    ],
                  )
                : Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _registerWithEmail,
                              child: Text('Register with Email'),
                            ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'package:country_picker/country_picker.dart';
import 'forget_password.dart';
import 'phone_registration_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isPhoneLogin = false;
  String _selectedCountryCode = '+1';

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$_selectedCountryCode${_phoneController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: FirebaseAuth.instance.currentUser!),
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                verificationId: verificationId,
                onVerificationSuccess: (User user) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(user: user),
                    ),
                  );
                },
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: userCredential.user!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQI3xpQMedA9WwJG1Xcdlx0WdGj4VB8_jHEZpdsPnuNSNMwpGLKvTNwDmuBmcs-Q-qszLs&usqp=CAU',
                        width: 100, // Adjust size as needed
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isPhoneLogin = false;
                            });
                          },
                          child: Text(
                            'Email Login',
                            style: TextStyle(
                              color: !_isPhoneLogin ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text('|'),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isPhoneLogin = true;
                            });
                          },
                          child: Text(
                            'Phone Login',
                            style: TextStyle(
                              color: _isPhoneLogin ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_isPhoneLogin)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() {
                                    _selectedCountryCode = '+${country.phoneCode}';
                                  });
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedCountryCode,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Enter Phone Number',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Enter Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Enter Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed:
                                _isPhoneLogin ? _sendOTP : _loginWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _isPhoneLogin ? 'Send OTP' : 'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },
                    child: Text('Register'),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgetPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

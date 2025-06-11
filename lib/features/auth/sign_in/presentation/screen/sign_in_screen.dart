import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project11/features/customer/home/presentation/screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project11/core/api/api_constants.dart';
import 'package:graduation_project11/core/themes/app__theme.dart';
import 'package:graduation_project11/core/utils/shared_keys.dart';
import 'package:graduation_project11/core/providers/auth_provider.dart';
import 'package:graduation_project11/features/auth/forget_password/presentation/screens/forget_password_step1_screen.dart';
import 'package:graduation_project11/features/auth/sign_up/presentation/screen/sign_up_screen1.dart';
import 'package:graduation_project11/features/delivery%20boy/home/presentation/screen/DeliveryHomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await http.post(
          Uri.parse(ApiConstants.login),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final userType = responseData['user_type'];
          final user = responseData['user'];
          final inputEmail = _emailController.text.trim();

          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(SharedKeys.isLoggedIn, true);
          await prefs.setString(SharedKeys.userEmail, inputEmail);
          await prefs.setString(SharedKeys.userType, userType);

          if (userType == 'customer') {
            await authProvider.setAuthState(inputEmail, 'customer');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (userType == 'delivery_boy') {
            await authProvider.setAuthState(inputEmail, 'delivery_boy');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DeliveryHomeScreen(email: inputEmail),
              ),
            );
          }
        } else {
          final errorData = json.decode(response.body);
          String errorMessage = errorData['error'];
          if (errorMessage == 'No account found with this email') {
            errorMessage = 'No account found with this email.';
          } else if (errorMessage == 'Incorrect password') {
            errorMessage = 'Incorrect password. Please try again.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        print('Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.light.colorScheme.primary,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.asset(
                            'assets/icons/recycle.png',
                            width: 350,
                          ),
                        ),
                        const Spacer(),
                        AnimatedSlide(
                          offset: _isVisible ? Offset.zero : const Offset(0, 1),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.light.colorScheme.secondary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "SIGN IN",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.light.colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Email Address',
                                      style: TextStyle(
                                        color:
                                            AppTheme.light.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  TextFormField(
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'This Field is required';
                                      }
                                      String emailPattern =
                                          r'^[a-z0-9]+@(gmail|yahoo|icloud)\.[a-z]{3}$';
                                      RegExp emailRegExp = RegExp(emailPattern);
                                      if (!emailRegExp.hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: _inputDecoration(
                                      'Enter Email Address',
                                      size,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.025),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Password',
                                      style: TextStyle(
                                        color:
                                            AppTheme.light.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  TextFormField(
                                    controller: _passwordController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'This Field is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    obscureText: _obscureText,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: _inputDecoration(
                                      'Enter Password',
                                      size,
                                      isPassword: true,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const ForgetPasswordStep1Screen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Forget Password?",
                                        style: TextStyle(
                                          color:
                                              AppTheme
                                                  .light
                                                  .colorScheme
                                                  .primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.015),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppTheme.light.colorScheme.primary,
                                      minimumSize: Size(
                                        size.width * 0.8,
                                        size.height * 0.065,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: _login,
                                    child:
                                        _isLoading
                                            ? const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            )
                                            : Text(
                                              "Log In",
                                              style: TextStyle(
                                                color:
                                                    AppTheme
                                                        .light
                                                        .colorScheme
                                                        .secondary,
                                                fontSize: size.width * 0.045,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                  SizedBox(height: size.height * 0.025),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account?",
                                        style: TextStyle(
                                          color:
                                              AppTheme
                                                  .light
                                                  .colorScheme
                                                  .primary,
                                          fontSize: size.width * 0.035,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const SignUpScreen1(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          " Sign Up",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: size.width * 0.038,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    Size size, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.04,
      ),
      suffixIcon:
          isPassword
              ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
              : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppTheme.light.colorScheme.primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: AppTheme.light.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

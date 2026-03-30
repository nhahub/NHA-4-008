import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import '../Theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late String email;
  late String password;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  var formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.blue,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Login",
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                              "Welcome Back!",
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Image.asset(
                          "images/logo.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const SizedBox(height: 20),

                      // Email Field:
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email Address can't be empty";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          email = value;
                        },
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: AppColors.danger,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(Icons.mail, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password Field:
                      TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password can't be empty";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          password = value;
                        },
                        obscureText: _obscureText,
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: AppColors.danger,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.remove_red_eye_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   PageTransition(
                            //     type: PageTransitionType.bottomToTop,
                            //     alignment: Alignment.center,
                            //     duration: const Duration(milliseconds: 400),
                            //     child: const ForgotPasswordScreen(),
                            //   ),
                            // );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Login Button:
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: MaterialButton(
                          onPressed: () async {
                            // try {
                            //   showDialog(
                            //     context: context,
                            //     builder: (context) {
                            //       return const Center(
                            //           child: CircularProgressIndicator());
                            //     },
                            //   );
                            //   var user = await auth.signInWithEmailAndPassword(
                            //     email: email,
                            //     password: password,
                            //   );
                            //   if (user != null) {
                            //     Navigator.of(context).pop(); // close loader
                            //     await _setLoggedInAndNavigate();
                            //   }
                            // } catch (e) {
                            //   Navigator.of(context).pop(); // close loader
                            //   showDialog(
                            //     context: context,
                            //     builder: (context) {
                            //       return AlertDialog(
                            //         title: const Text("Error"),
                            //         content: Text(e.toString()),
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () {
                            //               Navigator.pop(context);
                            //             },
                            //             child: const Text("OK"),
                            //           ),
                            //         ],
                            //       );
                            //     },
                            //   );
                            // }
                          },
                          color:  AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Social Sign In Buttons:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // Facebook sign in button:
                          IconButton(
                            onPressed: (){},
                            icon: Icon(FontAwesome.facebook_brand,
                              color: AppColors.blue,
                            ),
                          ),


                          const SizedBox(width: 10),


                          // Google sign in button:
                          IconButton(
                              onPressed: (){},
                              icon: Icon(FontAwesome.google_brand,
                                color: AppColors.blue,
                          ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Sign Up Link:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: AppColors.dark,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   PageTransition(
                              //     type: PageTransitionType.bottomToTop,
                              //     alignment: Alignment.center,
                              //     duration: const Duration(milliseconds: 400),
                              //     child: const SignupScreen(),
                              //   ),
                              // );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset(
                          'images/lottie/verification2.json',
                          fit: BoxFit.cover,
                          repeat: false,
                          animate: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

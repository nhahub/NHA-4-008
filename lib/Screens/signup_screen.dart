import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import '../Theme/theme.dart';
import 'onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String email;
  late String password;
  String? selectedGender;
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phonenumberController = TextEditingController();
  final countryController = TextEditingController();
  final birthdateController = TextEditingController();
  bool _obscureText = true;
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            "Register Now",
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 100,
                        width: 100,
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
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [

                          //First Name Field
                          Expanded(
                            child: TextFormField(
                              controller: firstnameController,
                              keyboardType: TextInputType.name,
                              style: const TextStyle(color: Colors.grey),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "First Name can't be empty";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "First Name",
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
                                prefixIcon:
                                    Icon(Icons.person, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          //Last Name Field
                          Expanded(
                            child: TextFormField(
                              controller: lastnameController,
                              keyboardType: TextInputType.name,
                              style: const TextStyle(color: Colors.grey),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Last Name can't be empty";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Last Name",
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
                                prefixIcon: Icon(Icons.person_outline,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      //Email Field
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.dark),
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
                      //Password Field
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
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.grey),
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
                      const SizedBox(height: 20),
                      //Phone Number Field
                      TextFormField(
                        controller: phonenumberController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Phone Number can't be empty";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
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
                          prefixIcon: Icon(Icons.phone, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Country/Address Field
                      TextFormField(
                        controller: countryController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Country/Address can't be empty";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Country/Address",
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
                          prefixIcon:
                              Icon(Icons.location_on, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //Gender Field
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(
                          labelText: "Gender",
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
                          prefixIcon: Icon(Icons.people, color: Colors.grey),
                        ),
                        dropdownColor: AppColors.background,
                        style: const TextStyle(color: Colors.grey),
                        items: ["Male", "Female"].map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Gender can't be empty";
                          }
                          return null;
                        },
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      //Birth Date Field
                      TextFormField(
                        controller: birthdateController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Birth Date can't be empty";
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              birthdateController.text =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: "Birth Date",
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
                          prefixIcon:
                              Icon(Icons.date_range, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Signup Button:
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: MaterialButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OnboardingScreen(),
                                ),
                              );
                            }
                          },
                          color: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Sign Up",
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
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              FontAwesome.facebook_brand,
                              color: AppColors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              FontAwesome.google_brand,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Login Link:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: AppColors.dark,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Login',
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
                          fit: BoxFit.contain,
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
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phonenumberController.dispose();
    countryController.dispose();
    birthdateController.dispose();
    super.dispose();
  }

}

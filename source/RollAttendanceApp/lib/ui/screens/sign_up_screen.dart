import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
// import 'package:itproject/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itproject/services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.controller});
  final PageController controller;
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();
  // final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  final UserService _userService = UserService();

  Future<void> _register() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_passController.text.isEmpty ||
          _repassController.text.isEmpty ||
          _emailController.text.isEmpty) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Warning',
            desc: 'Missing information!',
            btnCancelOnPress: () {},
          ).show();
        }

        return;
      }

      if (_passController.text != _repassController.text) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Warning',
            desc: 'Incorrected password!',
            btnCancelOnPress: () {},
          ).show();
        }

        return;
      }

      // FIREBASE SERVICE
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      if (userCredential.user != null) {
        final userProfile = await _userService.createProfile(
            _emailController.text, userCredential.user?.uid);

        if (userProfile == "Create profile successfully") {
          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'Success',
              desc: 'Register successful!',
              btnOkOnPress: () {
                widget.controller.animateToPage(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              },
            ).show();
          }
        } else {
          // Xóa user vừa tạo trong Firebase nếu tạo profile thất bại
          await userCredential.user?.delete();

          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Error',
              desc: 'Failed to create profile. $userProfile',
              btnCancelOnPress: () {},
            ).show();
          }
        }
      } else {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Error',
            desc: 'Registration failed. Please try again.',
            btnCancelOnPress: () {},
          ).show();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Register failed. $e';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'This email is already in use.';
              break;
            case 'weak-password':
              errorMessage = 'The password is too weak.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            default:
              errorMessage = 'An error occurred: ${e.message}';
              break;
          }
        }
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: errorMessage,
          btnCancelOnPress: () {},
        ).show();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Image.asset(
                  "assets/images/vector-2.png",
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 27,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      height: 56,
                      child: TextField(
                        controller: _emailController,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF837E93),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF9F7BFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 17,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0), // Thêm khoảng cách giữa hai ô
                            child: TextField(
                              controller: _passController,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                              obscureText: _isPasswordHidden,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Create Password',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF837E93),
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                                labelStyle: const TextStyle(
                                  color: Color(0xFF755DC1),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xFF837E93),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xFF9F7BFF),
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF755DC1),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordHidden =
                                          !_isPasswordHidden; // Toggle visibility
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0), // Thêm khoảng cách giữa hai ô
                            child: TextField(
                              controller: _repassController,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                              obscureText: _isConfirmPasswordHidden,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                hintText: 'Confirm Password',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF837E93),
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                                labelStyle: const TextStyle(
                                  color: Color(0xFF755DC1),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xFF837E93),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color(0xFF9F7BFF),
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF755DC1),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordHidden =
                                          !_isConfirmPasswordHidden; // Toggle visibility
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: double.infinity,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9F7BFF),
                          ),
                          child: const Text(
                            'Create account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF837E93),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          width: 2.5,
                        ),
                        InkWell(
                          onTap: () {
                            widget.controller.animateToPage(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          child: const Text(
                            'Log In ',
                            style: TextStyle(
                              color: Color(0xFF755DC1),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
// import 'package:itproject/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itproject/services/user_service.dart';
import 'package:itproject/ui/screens/login_screen.dart';

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
        backgroundColor: Color.fromRGBO(197, 240, 200, 1),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: MediaQuery.of(context).size.width * 0.7,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Email TextBox
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Baloo',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Color(0xFFDBDBDB),
                              fontSize: 15,
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF48B02C),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF48B02C),
                              ),
                            ),
                            contentPadding: EdgeInsets.only(left: 60),
                          ),
                        ),
                        Positioned(
                          left: -25,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 70,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF48B02C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.email,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TextField(
                          controller: _passController,
                          obscureText: _isPasswordHidden,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Baloo',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: Color(0xFFDBDBDB),
                              fontSize: 15,
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF48B02C),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF48B02C),
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(left: 60),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF48B02C),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          left: -25,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 70,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF48B02C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TextField(
                          controller: _repassController,
                          obscureText: _isPasswordHidden,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Baloo',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: const TextStyle(
                              color: Color(0xFFDBDBDB),
                              fontSize: 15,
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF48B02C),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF48B02C),
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(left: 60),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF48B02C),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          left: -25,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 70,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF48B02C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8925),
                            ),
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: 'Baloo',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          widget.controller.animateToPage(0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease);
                        },
                        child: const Text(
                          'Already have an account? Log in now',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 16,
                            fontFamily: 'Baloo',
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
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

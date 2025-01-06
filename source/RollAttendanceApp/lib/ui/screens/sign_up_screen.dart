import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
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
  final screenWidth = MediaQuery.of(context).size.width;

  return BlurryModalProgressHUD(
    inAsyncCall: _isLoading,
    opacity: 0.3,
    blurEffectIntensity: 5,
    child: Scaffold(
      backgroundColor: const Color.fromRGBO(197, 240, 200, 1),
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
                  // Logo responsive
                  width: screenWidth > 1024
                      ? screenWidth * 0.4
                      : screenWidth * 0.6,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Email TextBox
                  _buildResponsiveTextBox(
                      context, _emailController, Icons.email, 'Email'),
                  const SizedBox(height: 30),
                  // Password TextBox
                  _buildResponsiveTextBox(
                      context, _passController, Icons.lock, 'Password',
                      isObscure: true, toggleObscure: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  }),
                  const SizedBox(height: 30),
                  // Confirm Password TextBox
                  _buildResponsiveTextBox(
                      context, _repassController, Icons.lock, 'Confirm Password',
                      isObscure: true, toggleObscure: () {
                    setState(() {
                      _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                    });
                  }),
                  const SizedBox(height: 60),
                  // SIGN UP Button
                  Center(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: screenWidth > 480
                            ? screenWidth * 0.5
                            : screenWidth * 0.7,
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
                              fontSize: 18,
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Already have an account
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
                          fontSize: 14,
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

// Helper method for building responsive TextBox
Widget _buildResponsiveTextBox(
  BuildContext context,
  TextEditingController controller,
  IconData icon,
  String hintText, {
  bool isObscure = false,
  VoidCallback? toggleObscure,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  return Stack(
    clipBehavior: Clip.none,
    children: [
      TextField(
        controller: controller,
        obscureText: isObscure && (toggleObscure != null),
        style: const TextStyle(
          fontSize: 15,
          fontFamily: 'Baloo',
          color: Color(0xFF000000),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFDBDBDB),
            fontSize: 15,
            fontFamily: 'Baloo',
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF48B02C),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF48B02C),
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 60),
          suffixIcon: isObscure && toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF48B02C),
                  ),
                  onPressed: toggleObscure,
                )
              : null,
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
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    ],
  );
}

}

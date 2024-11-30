import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.controller});
  final PageController controller;
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
    });

    if (_emailController.text.isEmpty) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Warning',
          desc: 'Please enter your email!',
          btnCancelOnPress: () {},
        ).show();
      }

      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Show success dialog
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Success',
          desc: 'Login successful!',
          btnOkOnPress: () {
            widget.controller.animateToPage(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          },
        ).show();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to send reset email.';
        if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address.';
        } else if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email address.';
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
                padding:
                    const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
                child: Column(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        color: Color(0xFF755DC1),
                        fontSize: 27,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
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
                    const SizedBox(
                      height: 25,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: double.infinity,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _sendPasswordResetEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9F7BFF),
                          ),
                          child: const Text(
                            'Submit',
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
                          'Remember your password?',
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
                            'Sign In',
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

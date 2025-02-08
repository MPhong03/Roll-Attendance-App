import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:itproject/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itproject/services/google_sign_in_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});
  final PageController controller;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isPasswordHidden = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignInService.getInstance();
  final UserService _userService = UserService();

  Future<void> _login() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_passController.text.isEmpty || _emailController.text.isEmpty) {
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

      // FIREBASE SERVICE
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      if (userCredential.user != null) {
        print(
            'TOKEN: ${await FirebaseAuth.instance.currentUser?.getIdToken()}');
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Success',
            desc: 'Login successful!',
            btnOkOnPress: () {
              GoRouter.of(context).go('/home');
            },
          ).show();
        }
      } else {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Error',
            desc: 'Login failed. Please try again.',
            btnCancelOnPress: () {},
          ).show();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed. $e';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found with this email.';
              break;
            case 'wrong-password':
              errorMessage = 'Incorrect password.';
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

  Future<void> _loginWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final email = userCredential.user!.email;

        print(
            'TOKEN: ${await FirebaseAuth.instance.currentUser?.getIdToken()}');
        print('TOKEN 2: ${await userCredential.user!.getIdToken(true)}');

        // Ensure the ID token is available after Google sign-in
        final idToken =
            await userCredential.user!.getIdToken(true); // Forces a refresh
        if (idToken != null) {
          final profileResponse = await _userService.createProfile(email, uid);

          if (profileResponse?.toLowerCase() ==
              'profile created successfully.') {
            if (mounted) {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.bottomSlide,
                title: 'Success',
                desc: 'Profile created and logged in successfully!',
                btnOkOnPress: () {
                  GoRouter.of(context).go('/home');
                },
              ).show();
            }
          } else {
            if (mounted) {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.bottomSlide,
                title: 'Success',
                desc: 'Logged in successfully!',
                btnOkOnPress: () {
                  GoRouter.of(context).go('/home');
                },
              ).show();
            }
          }
        }
      }
    } catch (e) {
      print('Error during Google sign-in: $e');
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'An error occurred: $e',
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    double getResponsiveFontSize(double baseFontSize) {
      if (screenWidth > 480) {
        return baseFontSize * 1.2;
      } else {
        return baseFontSize;
      }
    }

    return BlurryModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.3,
      blurEffectIntensity: 5,
      child: Scaffold(
        backgroundColor:
            isDarkMode ? Color(0xFF1E1E1E) : Color.fromRGBO(197, 240, 200, 1),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: screenWidth > 1024
                        ? screenWidth * 0.4
                        : screenWidth * 0.6,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Apelo",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "From here, light will be shining everywhere in the universe",
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TextField(
                          controller: _emailController,
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(15),
                            fontFamily: 'Baloo',
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: getResponsiveFontSize(15),
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: isDarkMode ? Colors.black : Colors.white,
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
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF48B02C),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.email,
                              color: Colors.white,
                              size: getResponsiveFontSize(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Password TextBox
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TextField(
                          controller: _passController,
                          obscureText: _isPasswordHidden,
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(15),
                            fontFamily: 'Baloo',
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: getResponsiveFontSize(15),
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: isDarkMode ? Colors.black : Colors.white,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF48B02C),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
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
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF48B02C),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: getResponsiveFontSize(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          context.push('/forgot-password');
                        },
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: getResponsiveFontSize(12),
                            fontFamily: 'Baloo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E8925),
                            ),
                            child: Text(
                              'LOG IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: getResponsiveFontSize(18),
                                fontFamily: 'Baloo',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _loginWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: getResponsiveFontSize(16),
                                    fontFamily: 'Baloo',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    Center(
                      child: InkWell(
                        onTap: () {
                          widget.controller.animateToPage(1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease);
                        },
                        child: Text(
                          'CREATE AN ACCOUNT',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: getResponsiveFontSize(14),
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

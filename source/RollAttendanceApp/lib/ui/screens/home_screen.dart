import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:itproject/services/user_service.dart';
import 'package:itproject/ui/layouts/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String profile = "";
  final UserService _userService = UserService();

  Future<void> testProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _userService.testProfile();

      if (result != null) {
        profile = result;
      } else {
        profile = "Unauthorized";
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Authorired failed, $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: BlurryModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.3,
        blurEffectIntensity: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('ITP'),
            backgroundColor: Colors.blueAccent,
          ),
          body: RefreshIndicator(
            onRefresh: testProfile,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: Text(
                    'Welcome to the ITP! $profile',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

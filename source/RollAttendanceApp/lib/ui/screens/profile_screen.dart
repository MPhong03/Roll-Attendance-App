import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:itproject/services/user_service.dart';
import 'package:itproject/ui/layouts/main_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String name = "";
  String email = "";
  String profileImageUrl = "";
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Fetch profile data when the screen is accessed
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _userService.getProfile();

      if (result != null) {
        name = result.name;
        email = result.email;
        profileImageUrl = result.profileImageUrl;
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
            onRefresh: _getProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name.isNotEmpty ? name : 'Loading...',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email.isNotEmpty ? email : 'Loading...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to edit profile
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

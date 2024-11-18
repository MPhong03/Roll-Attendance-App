import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  Future<String?> getIdToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken();
    } catch (e) {
      return null;
    }
  }
}

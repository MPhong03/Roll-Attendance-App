import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleSignInService {
  static GoogleSignIn? _googleSignIn;

  static GoogleSignIn getInstance() {
    _googleSignIn ??= GoogleSignIn(
      clientId: dotenv.env['GOOGLE_CLIENT_ID']!,
      scopes: <String>[
        'email',
      ],
    );
    return _googleSignIn!;
  }
}

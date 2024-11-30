import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itproject/ui/main_view.dart';
import 'package:itproject/ui/screens/home_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itproject/ui/screens/organizations/organization_detail.dart';
import 'firebase_options.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const MainView(),
        '/home': (context) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/organization-detail') {
          final args = settings.arguments as String;

          return MaterialPageRoute(
            builder: (context) {
              return OrganizationDetailScreen(organizationId: args);
            },
          );
        }

        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

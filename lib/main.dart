import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // TODO: Replace with logo
              const Icon(
                FontAwesomeIcons.chess,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Wormhole Chess",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(FontAwesomeIcons.chessBoard),
                label: const Text("New Game"),
              ),
              StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasData) {
                  print(snapshot.data?.photoURL);
                  return ElevatedButton.icon(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    icon: const Icon(FontAwesomeIcons.personThroughWindow),
                    label: const Text("Sign Out"),
                  );
                }

                if (snapshot.hasData) {
                  // TODO: Replace with error toast
                  print(snapshot.error);
                }
                return ElevatedButton.icon(
                  onPressed: () => AuthService().signInWithGoogle(),
                  icon: const Icon(FontAwesomeIcons.google),
                  label: const Text("Sign In With Google"),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthService {
  signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    final authentication = await account?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: authentication?.accessToken,
      idToken: authentication?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

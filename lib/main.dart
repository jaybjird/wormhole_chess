import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wormhole_chess/model/game_board.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'widgets/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/games',
      builder: (context, state) => const GameScreen(),
    ),
  ]
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
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
                onPressed: () => showDialog(context: context, builder: (ctx) => NewGameDialog()),
                icon: const Icon(FontAwesomeIcons.chessBoard),
                label: const Text("New Game"),
              ),
              AuthStreamBuilder(
                onWaiting: () => const CircularProgressIndicator(),
                onHasData: () => ElevatedButton.icon(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(FontAwesomeIcons.personThroughWindow),
                  label: const Text("Sign Out"),
                ),
                onNoData: () => ElevatedButton.icon(
                  onPressed: () => AuthService().signInWithGoogle(),
                  icon: const Icon(FontAwesomeIcons.google),
                  label: const Text("Sign In With Google"),
                ),
                onError: (error) => print("$error"), // TODO: log error and toast user
              ),
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

class AuthStreamBuilder extends StatelessWidget {
  final Widget Function() onWaiting, onHasData, onNoData;
  final void Function(Object)? onError;

  const AuthStreamBuilder({
    super.key,
    required this.onWaiting,
    required this.onHasData,
    required this.onNoData,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return onWaiting();
        if (snapshot.hasData) return onHasData();
        if (snapshot.hasError && snapshot.error != null && onError != null) {
          onError!(snapshot.error!);
        }
        return onNoData();
      },
    );
  }
}

class NewGameDialog extends StatefulWidget {
  const NewGameDialog({super.key});

  @override
  State<NewGameDialog> createState() => _NewGameDialogState();
}

class _NewGameDialogState extends State<NewGameDialog> {
  bool isFourPlayer = false;

  set fourPlayer(bool selection) => setState(() => isFourPlayer = selection);

  void _startGame(BuildContext context) {
    // TODO: create a new game with the given state and pass the ID to game screen
    context.go('/games');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Game"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Text("Players"),
              const Spacer(),
              SegmentedButton<bool>(
                selected: {isFourPlayer},
                segments: const [
                  ButtonSegment<bool>(value: false, label: Text("2")),
                  ButtonSegment<bool>(value: true, label: Text("4")),
                ],
                onSelectionChanged: (selection) => fourPlayer = selection.first,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _startGame(context),
          child: const Text('Start Game'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

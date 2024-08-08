import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// TODO 1 : 로그인 과정 콘솔에 출력
// TODO 2 : 로그인 성공 시 콘솔에 출력
// TODO 3 : 로그인 성공 시, 구글에 요청해 사용자 정보 받아와서 콘솔에 출력
// TODO 4 : 로그인 성공 시, 사용자 정보를 표시하는 페이지로 화면 전환

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign In Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        return user;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign In'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Sign in with Google'),
          onPressed: () async {
            User? user = await _handleSignIn();
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(user: user),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class UserInfoPage extends StatelessWidget {
  final User user;

  UserInfoPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, ${user.displayName}!'),
            SizedBox(height: 16),
            Text('Your email is ${user.email}'),
          ],
        ),
      ),
    );
  }
}
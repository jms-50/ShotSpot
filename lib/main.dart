import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shot_spot/screens/camera_screen.dart';
import 'package:shot_spot/screens/detail_screen.dart';
import 'package:shot_spot/screens/guide_screen.dart';
import 'screens/auth/find_password_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShotSpot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const AuthGate(),
      routes: {
        '/main':(context) => const MainScreen(),
        '/camera':(context) => const CameraScreen(),
        '/home': (context) => const HomeScreen(),
        '/guide': (context) => const GuideScreen(),
        '/mypage': (context) => const MyPageScreen(),
        '/map': (context) => const MapScreen(),
        '/detail': (context) => const DetailScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/find': (context) => const FindPasswordScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 아직 연결 중인 경우
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 로그인된 유저가 있는 경우
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // 로그인되지 않은 경우
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
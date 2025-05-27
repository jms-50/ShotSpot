import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth/login_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? _userId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userPhotos = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userId = userDoc.data()?['userId'] ?? '알 수 없음';

    final photoSnapshot = await FirebaseFirestore.instance
        .collection('spot_photos')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    final photos = photoSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'docId': doc.id,
        'imageUrl': data['imageUrl'],
        'spotId': data['spotId'],
        'storagePath': data['storagePath'],// 삭제 시 사용
        'createdAt': FieldValue.serverTimestamp(),
      };
    }).toList();

    setState(() {
      _userId = userId;
      _userPhotos = photos;
      _isLoading = false;
    });
  }

  Future<void> _deletePhoto(String docId, String storagePath) async {
    try {
      await FirebaseFirestore.instance.collection('spot_photos').doc(docId).delete();
      await FirebaseStorage.instance.ref(storagePath).delete();

      setState(() {
        _userPhotos.removeWhere((photo) => photo['docId'] == docId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진이 삭제되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
    }
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('환영합니다,', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              _userId ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text('내가 올린 사진', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: _userPhotos.isEmpty
                  ? const Center(child: Text('공개 저장한 사진이 없습니다.', style: TextStyle(color: Colors.black)))
                  : ListView.builder(
                itemCount: _userPhotos.length,
                itemBuilder: (context, index) {
                  final photo = _userPhotos[index];
                  return Card(
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: GestureDetector(
                        onTap: () => _showImagePreview(photo['imageUrl']),
                        child: Image.network(photo['imageUrl'], width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      title: Text('📍 포토 스팟: ${photo['spotId']}', style: const TextStyle(color: Colors.black)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePhoto(photo['docId'], photo['storagePath']),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
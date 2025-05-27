import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CameraScreen extends StatefulWidget {
  final String spotId;
  const CameraScreen({super.key, required this.spotId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _saveToGallery() async {
    if (_image != null) {
      await Permission.storage.request();
      final result = await ImageGallerySaver.saveFile(_image!.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['isSuccess'] ? '갤러리에 저장됨' : '저장 실패')),
      );
    }
  }

  Future<void> _uploadPublicImage() async {
    if (_image == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 후 이용해주세요")),
      );
      return;
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child('spot_photos').child(fileName);

    try {
      await ref.putFile(_image!);
      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('photos').add({
        'imageUrl': imageUrl,
        'userId': user.uid,
        'spotId': widget.spotId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("공개 저장 완료")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("업로드 실패: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('사진 미리보기'), backgroundColor: Colors.black),
      body: _image == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(child: Image.file(_image!, fit: BoxFit.cover)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('개인 저장'),
                onPressed: _saveToGallery,
              ),
              ElevatedButton(
                child: const Text('공개 저장'),
                onPressed: _uploadPublicImage,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
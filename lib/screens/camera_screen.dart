import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> _cameras;
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;

  XFile? _capturedImage;
  String? _spotId;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    final selectedCamera = _cameras.firstWhere(
          (camera) =>
      camera.lensDirection ==
          (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => _cameras.first,
    );

    _controller = CameraController(selectedCamera, ResolutionPreset.medium);
    await _controller.initialize();

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _spotId = args?['name'] ?? 'unknown_spot';

    setState(() => _isCameraInitialized = true);
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isCameraInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });
    await _initializeCamera();
  }

  Future<void> _takePicture() async {
    final image = await _controller.takePicture();
    setState(() => _capturedImage = image);
  }

  Future<void> _saveToGallery() async {
    if (_capturedImage == null) return;

    final bytes = await File(_capturedImage!.path).readAsBytes();
    final result =
    await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));

    if (result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사진이 갤러리에 저장되었습니다")),
      );
    }

    setState(() => _capturedImage = null);
  }

  Future<void> _uploadToFirebase() async {
    if (_capturedImage == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final path =
        'spot_photos/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(_capturedImage!.path);

    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('spot_photos').add({
      'userId': uid,
      'spotId': _spotId ?? 'unknown',
      'imageUrl': downloadUrl,
      'storagePath': path,
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("공개 저장이 완료되었습니다")),
    );
    setState(() => _capturedImage = null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPreviewOrCamera() {
    if (_capturedImage != null) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_capturedImage!.path),
              height: 320,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("갤러리 저장"),
                  onPressed: _saveToGallery,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.public),
                  label: const Text("공개 저장"),
                  onPressed: _uploadToFirebase,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("다시 찍기"),
                  onPressed: () => setState(() => _capturedImage = null),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      if (!_isCameraInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return Stack(
        alignment: Alignment.topRight,
        children: [
          CameraPreview(_controller),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: _switchCamera,
            tooltip: '카메라 전환',
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("사진 촬영")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: _buildPreviewOrCamera()),
              if (_capturedImage == null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FloatingActionButton.extended(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("촬영"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

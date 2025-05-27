import 'package:flutter/material.dart';
import 'camera_screen.dart';

class GuidePage extends StatelessWidget {
  final String spotId;
  const GuidePage({super.key, required this.spotId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('촬영 가이드'), backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                '📷 수평을 맞추고 자연광을 활용하세요!',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CameraScreen(spotId: spotId)),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('사진 촬영'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
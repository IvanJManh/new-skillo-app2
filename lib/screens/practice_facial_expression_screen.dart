import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class PracticeFacialExpressionScreen extends StatefulWidget {
  @override
  _PracticeFacialExpressionScreenState createState() =>
      _PracticeFacialExpressionScreenState();
}

class _PracticeFacialExpressionScreenState
    extends State<PracticeFacialExpressionScreen> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Facial Expression Practice")),
      body: Center(
        child: Text("Facial Expression Practice Screen"),
      ),
    );
  }
}

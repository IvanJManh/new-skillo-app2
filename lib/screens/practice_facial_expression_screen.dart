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
  List<CameraDescription>? _cameras;
  String feedbackMessage = "Start practicing your facial expressions!";
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final frontCamera = _cameras!.firstWhere(
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

  void _analyzeFacialExpression() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    setState(() {
      isProcessing = true;
    });
    // Capture image
    final image = await _cameraController!.takePicture();
    // TODO: Send image to AI API for facial expression analysis
    // Example feedback
    setState(() {
      feedbackMessage = "Try to smile naturally.";
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Facial Expression Practice")),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(feedbackMessage, style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: isProcessing ? null : _analyzeFacialExpression,
            child: Text("Analyze Expression"),
          ),
        ],
      ),
    );
  }
}

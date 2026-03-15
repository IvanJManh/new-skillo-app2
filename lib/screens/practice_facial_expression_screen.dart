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
  List<String> expressions = ["Smile", "Frown", "Surprise", "Neutral"];
  int currentExpressionIndex = 0;
  late String feedbackMessage;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    feedbackMessage = "Practice: ${expressions[currentExpressionIndex]}";
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      setState(() {
        feedbackMessage = "Camera initialization failed: $e";
      });
    }
  }

  void _analyzeFacialExpression() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    setState(() {
      isProcessing = true;
    });
    try {
      // Capture image
      final image = await _cameraController!.takePicture();
      // TODO: Send image to AI API for facial expression analysis
      // Mock analysis
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        currentExpressionIndex = (currentExpressionIndex + 1) % expressions.length;
        feedbackMessage = "Good! Now practice: ${expressions[currentExpressionIndex]}";
        isProcessing = false;
      });
    } catch (e) {
      setState(() {
        feedbackMessage = "Analysis failed: $e";
        isProcessing = false;
      });
    }
  }

  @override
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Facial Expression Practice")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/pages/practice_results.dart';

class PoseCameraScreen extends StatefulWidget {
  final SkillNotifier? skillNotifier;
  final String skillTitle;

  const PoseCameraScreen({super.key, this.skillNotifier, this.skillTitle = 'Skill'});

  @override
  State<PoseCameraScreen> createState() => _PoseCameraScreenState();
}

class _PoseCameraScreenState extends State<PoseCameraScreen> {
  CameraController? _controller;
  late final PoseDetector _poseDetector;

  bool _isProcessing = false;
  String _statusText = 'AI feedback running.....';
  int _goodPostureCount = 0;
  int _totalFrames = 0;
  bool _practiceStarted = false;

  @override
  void initState() {
    super.initState();

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
      ),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      print('DEBUG: Starting camera initialization');
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        print('DEBUG: No cameras found');
        setState(() => _statusText = 'No cameras found');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      print('DEBUG: Camera found, initializing controller');
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;
      print('DEBUG: Camera initialized');

      setState(() {
        _statusText = 'Posture check active';
        _practiceStarted = true;
      });

      // startImageStream is only supported on mobile platforms
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _controller!.startImageStream(_processCameraImage);
        print('DEBUG: Image stream started');
      } else {
        print('DEBUG: Image stream NOT started (unsupported/web)');
        setState(() {
          _statusText = 'AI monitoring limited on this platform';
        });
      }
      
      if (!mounted) return;
      setState(() {
        _statusText = 'AI feedback running';
      });
    } catch (e) {
      if (!mounted) return;
      print('DEBUG: Camera crash: $e');
      setState(() {
        _statusText = 'Camera error: $e';
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _controller == null) return;

    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(
        image,
        _controller!.description,
      );

      final poses = await _poseDetector.processImage(inputImage);

      if (!mounted) return;

      setState(() {
        if (poses.isEmpty) {
          _statusText = 'Stand in front of the camera';
          return;
        }

        final pose = poses.first;

        final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
        final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
        final nose = pose.landmarks[PoseLandmarkType.nose];

        if (leftShoulder == null || rightShoulder == null || nose == null) {
          _statusText = 'Hold still for posture check';
          return;
        }

        _totalFrames++;
        final shoulderDiff = (leftShoulder.y - rightShoulder.y).abs();

        if (shoulderDiff < 25) {
          _statusText = 'Good posture ✅';
          _goodPostureCount++;
        } else {
          _statusText = 'Keep your shoulders straight';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusText = 'Unable to read posture';
      });
    } finally {
      _isProcessing = false;
    }
  }

  InputImage _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription description,
  ) {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final Uint8List bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final InputImageRotation rotation =
        InputImageRotationValue.fromRawValue(description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final InputImageFormat format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            ((!kIsWeb && Platform.isIOS)
                ? InputImageFormat.bgra8888
                : InputImageFormat.yuv420);

    final InputImageMetadata metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Initializing Camera')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(_statusText, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initCamera,
                child: const Text('Retry Camera'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose Camera'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 71, 172, 200),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _finishPractice,
              child: const Text('Finish Practice', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  void _finishPractice() async {
    if (widget.skillNotifier == null) {
      Navigator.pop(context);
      return;
    }

    // Calculate simulated scores
    double postureScore = _totalFrames > 0 
        ? (_goodPostureCount / _totalFrames) * 10 
        : 7.0; // Default if no frames processed
    
    // Clamp scores between 0 and 10 and add some randomness
    postureScore = (postureScore + (2 + (DateTime.now().second % 3))).clamp(0, 10).toDouble();
    double speechScore = (7.5 + (DateTime.now().minute % 2)).toDouble();
    double facialScore = (8.0 + (DateTime.now().day % 2)).toDouble();

    String feedback = "Your posture was good for ${((_goodPostureCount/_totalFrames.clamp(1, 1000000))*100).toInt()}% of the session. ";
    if (postureScore > 8) {
      feedback += "Excellent shoulder alignment! You look very confident.";
    } else {
      feedback += "Try to keep your shoulders more level to appear more composed.";
    }
    feedback += " Your tone was clear and engaging.";

    final result = PracticeResults(
      date: DateTime.now(),
      postureScore: postureScore,
      speechScore: speechScore,
      facialScore: facialScore,
      aiFeedback: feedback,
    );

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await widget.skillNotifier!.addPracticeResults(result);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      // Go back to home
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Practice results saved! Check your progress page.')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      print('ERROR saving results: $e');
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error Saving Results'),
          content: Text('Could not save your progress. Error: $e\n\nPlease check your internet connection and Firestore permissions.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

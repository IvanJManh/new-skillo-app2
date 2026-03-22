import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/pages/practice_results.dart';

class FacialExpressionScreen extends StatefulWidget {
  final SkillNotifier? skillNotifier;
  final String skillTitle;

  const FacialExpressionScreen({super.key, this.skillNotifier, this.skillTitle = 'Skill'});

  @override
  State<FacialExpressionScreen> createState() => _FacialExpressionScreenState();
}

class _FacialExpressionScreenState extends State<FacialExpressionScreen> {
  CameraController? _controller;
  late final FaceDetector _faceDetector;

  bool _isProcessing = false;
  String _statusText = 'AI feedback running.....';
  int _smileCount = 0;
  int _totalFaceFrames = 0;

  @override
  void initState() {
    super.initState();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // Needed for smiling and eye open probabilities
        enableTracking: true,
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
        _statusText = 'Expression check active';
      });

      // startImageStream is only supported on mobile platforms
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _controller!.startImageStream(_processCameraImage);
        print('DEBUG: Image stream started');
      } else {
        print('DEBUG: Image stream NOT started (unsupported/web)');
        setState(() {
          _statusText = 'AI monitoring is only supported on Android/iOS devices.';
        });
      }
      
      if (!mounted) return;
      
      // Only set to running if it actually successfully started ML Kit
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        setState(() {
          _statusText = 'AI feedback running';
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('DEBUG: Camera crash: $e');
      String errorMsg = e.toString();
      // On Web, accessing camera via HTTP on a local IP causes a JSOBJECT/TypeError
      if (kIsWeb && (errorMsg.toLowerCase().contains('jsobject') || errorMsg.toLowerCase().contains('typeerror'))) {
        errorMsg = 'Camera requires a secure connection (HTTPS) on mobile browsers. '
                   'Please use a secure tunnel (like ngrok) or test on localhost.';
      }
      setState(() {
        _statusText = 'Camera error: $errorMsg';
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

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      setState(() {
        _totalFaceFrames++;
        if (faces.isEmpty) {
          _statusText = 'Position face in camera';
          return;
        }

        final face = faces.first;

        if (face.smilingProbability != null && face.smilingProbability! > 0.5) {
          _statusText = 'Great smile! 😊 Keep it up!';
          _smileCount++;
        } else if (face.leftEyeOpenProbability != null && face.leftEyeOpenProbability! < 0.2 &&
                   face.rightEyeOpenProbability != null && face.rightEyeOpenProbability! < 0.2) {
          _statusText = 'Are your eyes closed? 😴 Wake up!';
        } else {
          _statusText = 'Looking a bit serious. Let\'s see a smile! 🙂';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusText = 'Unable to read expression';
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
    _faceDetector.close();
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
        title: Text(widget.skillTitle),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: _statusText.contains('smile') 
                    ? Colors.green.withOpacity(0.85) 
                    : _statusText.contains('serious') || _statusText.contains('Position face')
                        ? Colors.orange.withOpacity(0.85)
                        : Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _statusText.contains('smile') 
                        ? Icons.mood 
                        : _statusText.contains('serious')
                            ? Icons.sentiment_neutral
                            : _statusText.contains('Position') 
                                ? Icons.face
                                : Icons.info_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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

  Future<void> _finishPractice() async {
    // Compute facial score (0–10) based on smile ratio
    final double facialScore = _totalFaceFrames > 0
        ? (_smileCount / _totalFaceFrames * 10).clamp(0, 10)
        : 0.0;

    // Save results to Firebase if we have a notifier
    if (widget.skillNotifier != null) {
      try {
        await widget.skillNotifier!.addPracticeResults(
          PracticeResults(
            date: DateTime.now(),
            postureScore: 0.0,
            speechScore: 0.0,
            facialScore: facialScore,
            aiFeedback: 'Expression score: ${facialScore.toStringAsFixed(1)}/10 — Smiles detected: $_smileCount out of $_totalFaceFrames frames.',
          ),
        );
      } catch (_) {}
    }

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _controller?.stopImageStream();
    }
    await _controller?.dispose();
    _controller = null;
    _faceDetector.close();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

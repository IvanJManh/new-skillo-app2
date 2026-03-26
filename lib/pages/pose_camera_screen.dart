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
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: _statusText.contains('Good') 
                    ? Colors.green.withOpacity(0.85) 
                    : _statusText.contains('straight') || _statusText.contains('Hold still')
                        ? Colors.orange.withOpacity(0.85)
                        : Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _statusText.contains('Good') 
                        ? Icons.check_circle_outline 
                        : _statusText.contains('straight')
                            ? Icons.warning_amber_rounded
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
    // Compute posture score (0–10)
    final double postureScore = _totalFrames > 0
        ? (_goodPostureCount / _totalFrames * 10).clamp(0, 10)
        : 0.0;

    // Save results to Firebase if we have a notifier
    if (widget.skillNotifier != null) {
      try {
        await widget.skillNotifier!.addPracticeResults(
          PracticeResults(
            date: DateTime.now(),
            postureScore: postureScore,
            speechScore: 0.0,
            facialScore: 0.0,
            aiFeedback: 'Posture score: ${postureScore.toStringAsFixed(1)}/10 — Good posture: $_goodPostureCount out of $_totalFrames frames.',
          ),
        );
      } catch (_) {}
    }

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _controller?.stopImageStream();
    }
    await _controller?.dispose();
    _controller = null;
    _poseDetector.close();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

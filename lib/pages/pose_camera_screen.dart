import 'dart:io' show Platform;
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseCameraScreen extends StatefulWidget {
  const PoseCameraScreen({super.key});

  @override
  State<PoseCameraScreen> createState() => _PoseCameraScreenState();
}

class _PoseCameraScreenState extends State<PoseCameraScreen> {
  CameraController? _controller;
  late final PoseDetector _poseDetector;

  bool _isProcessing = false;
  String _statusText = 'AI feedback running.....';
  List<Pose> _poses = [];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
        ),
      );
    }

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: !kIsWeb && Platform.isIOS 
            ? ImageFormatGroup.bgra8888 
            : ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      if (!mounted) return;

      if (kIsWeb) {
        setState(() {
          _statusText = 'Web: AI feedback is disabled (mobile only)';
        });
      } else {
        setState(() {
          _statusText = 'Posture check active';
        });
        await _controller!.startImageStream(_processCameraImage);
        if (!mounted) return;
        setState(() {
          _statusText = 'AI feedback running';
        });
      }
    } catch (e) {
      print("Error initializing camera: $e");
      if (mounted) {
        setState(() {
          _statusText = "Error: $e";
        });
      }
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

      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);

      if (!mounted) return;

      setState(() {
        _poses = poses;
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

        final shoulderDiff = (leftShoulder.y - rightShoulder.y).abs();

        if (shoulderDiff < 25) {
          _statusText = 'Good posture ✅';
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

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription description,
  ) {
    if (kIsWeb) return null;

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

    final InputImageFormat? format =
        InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null) return null;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    if (!kIsWeb) {
      _poseDetector.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_statusText.startsWith('Error:')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pose Camera')),
        body: Center(
          child: Text(
            _statusText,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
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
          if (_poses.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: PosePainter(
                  _poses,
                  _controller!.value.previewSize!,
                  _controller!.description.sensorOrientation,
                  _controller!.description.lensDirection,
                ),
              ),
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
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.absoluteImageSize,
    this.rotation,
    this.lensDirection,
  );

  final List<Pose> poses;
  final Size absoluteImageSize;
  final int rotation;
  final CameraLensDirection lensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.greenAccent;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(
            translateX(landmark.x, rotation, size, absoluteImageSize),
            translateY(landmark.y, rotation, size, absoluteImageSize),
          ),
          4,
          dotPaint,
        );
      });

      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
        final landmark1 = pose.landmarks[type1];
        final landmark2 = pose.landmarks[type2];
        if (landmark1 != null && landmark2 != null) {
          canvas.drawLine(
            Offset(
              translateX(landmark1.x, rotation, size, absoluteImageSize),
              translateY(landmark1.y, rotation, size, absoluteImageSize),
            ),
            Offset(
              translateX(landmark2.x, rotation, size, absoluteImageSize),
              translateY(landmark2.y, rotation, size, absoluteImageSize),
            ),
            paint,
          );
        }
      }

      // Draw skeleton lines
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }

  double translateX(
      double x, int rotation, Size size, Size absoluteImageSize) {
    double transitionedX;
    switch (rotation) {
      case 90:
        transitionedX = x * size.width / absoluteImageSize.height;
        break;
      case 270:
        transitionedX = size.width - x * size.width / absoluteImageSize.height;
        break;
      default:
        transitionedX = x * size.width / absoluteImageSize.width;
        break;
    }
    if (lensDirection == CameraLensDirection.front) {
      return size.width - transitionedX;
    }
    return transitionedX;
  }

  double translateY(
      double y, int rotation, Size size, Size absoluteImageSize) {
    switch (rotation) {
      case 90:
      case 270:
        return y * size.height / absoluteImageSize.width;
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }
}

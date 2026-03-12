import 'dart:io';
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
  String _statusText = 'Starting camera...';

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
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup:
          Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();

    if (!mounted) return;

    setState(() {
      _statusText = 'Camera ready...';
    });

    await _controller!.startImageStream(_processCameraImage);

    if (!mounted) return;
    setState(() {
      _statusText = 'Detecting pose...';
    });
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
        _statusText = 'Pose error';
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
            (Platform.isIOS
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

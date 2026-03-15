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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Facial Expression Practice")),
      body: Center(
        child: Text("Facial Expression Practice Screen"),
      ),
    );
  }
}

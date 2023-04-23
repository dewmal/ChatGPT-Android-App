import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    final CameraDescription camera = cameras.first;
    controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print('Camera error $e');
    }

    if (mounted) {
      setState(() {
        isCameraReady = true;
      });
    }
  }

  void takePicture() async {
    try {
      final image = await controller.takePicture();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreview(imagePath: image.path),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreview(imagePath: pickedFile.path),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Camera Example'),
      ),
      body: Stack(
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: takePicture,
                    child: Icon(Icons.camera_alt),
                  ),
                  FloatingActionButton(
                    onPressed: pickImage,
                    child: Icon(Icons.image),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final String imagePath;

  ImagePreview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview'),
      ),
      body: Image.file(File(imagePath)),
    );
  }
}

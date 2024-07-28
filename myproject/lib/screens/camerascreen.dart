import 'package:flutter/material.dart';
import 'package:myproject/components/navbar.dart';
import 'package:camera/camera.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/screens/previewscreen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.isAIMode = false});

  final bool isAIMode;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  List<CameraDescription> cameras = [];
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      print("Cameras: $cameras");
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Controller: $controller");
    return Scaffold(
      body: Center(
          child: Stack(
        children: [
          Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 100,
            color: Colors.black,
            child: controller.value.isInitialized
                ? CameraPreview(controller)
                : Container(),
          ),
          Positioned(
              bottom: 25,
              left: SizeConfig.blockSizeHorizontal! * 40,
              right: SizeConfig.blockSizeHorizontal! * 40,
              child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 20,
                  height: SizeConfig.blockSizeHorizontal! * 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                      ),
                      onPressed: () {
                        controller.takePicture().then((value) {
                          imageFile = value;
                          print("Image Path: ${imageFile!.path}");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PreviewScreen(
                                        imagePath: imageFile!.path,
                                      )));
                        });
                      },
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 18,
                        height: SizeConfig.blockSizeHorizontal! * 18,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ))))
        ],
      )),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
      ),
    );
  }
}

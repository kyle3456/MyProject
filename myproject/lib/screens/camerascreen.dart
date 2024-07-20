import 'package:flutter/material.dart';
import 'package:myproject/components/navbar.dart';
import 'package:camera/camera.dart';
import 'package:myproject/size_config.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.isAIMode = false});

  final bool isAIMode;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Stack(
        children: [
          Container(
            // child: CameraPreview(
            //   CameraController(cameras[0], ResolutionPreset.medium),
            // ),
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 100,
            color: Colors.black,
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
                    onPressed: () {},
                    child: Container(
                      width: SizeConfig.blockSizeHorizontal! * 18,
                      height: SizeConfig.blockSizeHorizontal! * 18,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    )
                  )))
        ],
      )),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
      ),
    );
  }
}

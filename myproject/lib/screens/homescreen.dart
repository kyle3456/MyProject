import 'package:flutter/material.dart';
import 'package:myproject/size_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 80,
              height: SizeConfig.blockSizeVertical! * 15,
              child: Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("INSERT NAME", style: TextStyle(fontSize: 20, color: Colors.white)),
                          Text("INSERT Description"),
                        ],
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                      )
                    ],
                  ),
                )
              ),
            )
          ],
        ),
      )
    );
  }
}
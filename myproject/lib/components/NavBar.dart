import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key, this.currentIndex = 0});

  final int currentIndex;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      fixedColor: Colors.blue,
      currentIndex: widget.currentIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.grey,),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map, color: Colors.grey,),
          label: 'Map',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.camera, color: Colors.grey,),
        //   label: 'Camera',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, color: Colors.grey,),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        if (index == widget.currentIndex) return;
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/');
            break;
          case 1:
            Navigator.pushNamed(context, '/map');
            break;
          // case 2:
          //   Navigator.pushNamed(context, '/camera');
          //   break;
          case 2:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
    );
  }
}

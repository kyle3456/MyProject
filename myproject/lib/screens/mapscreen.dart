import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myproject/components/NavBar.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/services/locations.dart' as locations;

/*
33.61882, -117.82342  =3
33.619179, -117.822877 =5
33.618118 -117.821911 =2
33.618496 -117.823835 =1
33.619461 -117.822501 = 2
33.618062 -117.823057 =2
 */


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.61806, -117.823),
    zoom: 18,
  );

  late GoogleMapController mapController;

    Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 100,
                    height: SizeConfig.blockSizeVertical! * 100,
                    child: GoogleMap(
                      mapType: MapType.satellite,
                      initialCameraPosition: _kGooglePlex,
                      // onMapCreated: (GoogleMapController controller) {
                      //   _controller.complete(controller);
                      // },
                      onMapCreated: _onMapCreated,
                      markers: _markers.values.toSet(),
                    ))
      ),
      bottomNavigationBar: const NavBar(
        currentIndex: 1,
      ),
    );
  }
}
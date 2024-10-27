import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myproject/components/NavBar.dart';
import 'package:myproject/size_config.dart';
import 'package:myproject/services/locations.dart' as locations;


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
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
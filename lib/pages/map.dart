
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<dynamic> geojson = [];

  @override
  void initState() {
    super.initState();
    fetchPoligonos();
  }

  void fetchPoligonos() async {
    //const url = 'http://192.168.100.98:8000/api/map';
    const url = 'http://192.168.0.51:8000/api/map';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final body = response.body;
      List<dynamic> data = jsonDecode(body);
      setState(() {
        geojson = data;
      });
    } else {
      throw Exception('Error al cargar los puntos de interés');
    }
  }

  MapController mapController = MapController();
  LatLng currentLocation = LatLng(-27.332474952498472, -55.864316516887556);
  bool showMarker = false;

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      showMarker = true;
      currentLocation = LatLng(position.latitude, position.longitude);
      mapController.move(currentLocation, 15.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentLocation,
          zoom: 12.0,
        ),
        nonRotatedChildren: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          if (showMarker)
            MarkerLayer(
              markers: [
                Marker(
                  width: 20.0,
                  height: 20.0,
                  point: currentLocation,
                  builder: (ctx) => Container(
                    child: Icon(
                      Icons.circle,
                      color: Colors.blue,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          if (geojson.isNotEmpty)
            PolygonLayer(
              polygons: geojson.map((item) {
                var geojsonData = item['geojson'];
                if (geojsonData != null) {
                  return Polygon(
                    points: parseGeoJSON(geojsonData),
                    color: Colors.blue.withOpacity(0.5),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  );
                } else {
                  return Polygon(
                    points: [],
                    color: Colors.transparent,
                  );
                }
              }).toList(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        onPressed: () {
          _getLocation();
        },
        child: Icon(Icons.my_location),
      ),
    );
  }

  List<LatLng> parseGeoJSON(String geojsonData) {
  Map<String, dynamic> geojson = jsonDecode(geojsonData);
  if (geojson != null &&
      geojson['coordinates'] != null &&
      geojson['coordinates'][0] != null) {
    List<dynamic> coordinates = geojson['coordinates'][0];
    return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
  } else {
    return [];
  }
}
}


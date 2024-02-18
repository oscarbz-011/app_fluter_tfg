import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:convert';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

//Clase para crear polígonos personalizados
class CustomPolygon {
  final List<MapLatLng> points;
  final Color color;
  final Color strokeColor;
  final String zone;
  final String days;
  final String time;

  CustomPolygon({
    required this.points,
    required this.color,
    required this.strokeColor,
    required this.zone,
    required this.days,
    required this.time,
  });
}

class _MapWidgetState extends State<MapWidget> {

  TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();

  // Future<void> _showPolygonDialog(String polygonInfo) async {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Polygon Information'),
  //         content: Text(polygonInfo),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  

  List<dynamic> geojson = [];

  //Variables a usar con syncfusion_flutter_maps
  late MapZoomPanBehavior _zoomPanBehavior;
  List<CustomPolygon> _polygons = [];

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
    super.initState();
    fetchPolygons();
  }


   void fetchPolygons() async {
    const url = 'http://192.168.100.123:8000/api/map';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<CustomPolygon> polygons = [];
      for (var item in data) {
        final Map<String, dynamic> geojson = jsonDecode(item['geojson']);
        final List<dynamic> coordinates = geojson['coordinates'][0];
        List<MapLatLng> points = [];
        for (var coordinate in coordinates) {
          points.add(MapLatLng(coordinate[1], coordinate[0]));
        }
        CustomPolygon polygon = CustomPolygon(
          points: points,
          color: Color.fromARGB(
              114, 33, 149, 243), // You can customize the color if needed
          strokeColor: Color.fromARGB(
              83, 33, 149, 243), // You can customize the stroke color if needed
          zone: item['zone'],
          days: item['days'],
          time: item['time'],
        );
        polygons.add(polygon);
      }
      setState(() {
        _polygons = polygons;
      });
    } else {
      throw Exception('Failed to fetch polygons from API');
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

      body: SfMaps(
        layers: [
          MapTileLayer(
            initialZoomLevel: 12,
            initialFocalLatLng:
                MapLatLng(-27.332474952498472, -55.864316516887556),
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            zoomPanBehavior: _zoomPanBehavior,
            sublayers: [
              MapPolygonLayer(
                polygons: _polygons
                    .map((polygon) => MapPolygon(
                          points: polygon.points,
                          color: polygon.color,
                          strokeColor: polygon.strokeColor,
                          onTap: (){
                            _showPolygonInfo(context, polygon);
                          },
                        ))
                    .toSet(),
                
              ),
            ],
          ),
        ],
      ),
      
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom:80.0,
            right: 2.0,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              onPressed: () {
                _getLocation();
              },
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
    
  }
  
  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
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


  // Funcion para mostrar información del polígono al hacer click
  void _showPolygonInfo(BuildContext context, CustomPolygon polygon) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Itinerario del servicio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text('Zona: ${polygon.zone}'),
              Text('Dias: ${polygon.days}'),
              Text('Horario: ${polygon.time}'),
            ],
          ),
        );
      },
    );
  }

}

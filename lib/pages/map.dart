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

  Future<void> _showPolygonDialog(String polygonInfo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Polygon Information'),
          content: Text(polygonInfo),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

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

  // void fetchPoligonos() async {
  //   const url = 'http://192.168.100.123:8000/api/map';
  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     final body = response.body;
  //     List<dynamic> data = jsonDecode(body);
  //     setState(() {
  //       geojson = data;
  //     });
      
  //   } else {
  //     throw Exception('Error al cargar los puntos de interés');
  //   }
  // }

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
                        ))
                    .toSet(),
                tooltipBuilder: (BuildContext context, int index) {
                  final CustomPolygon polygon = _polygons[index];
                  return Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[700], // Customize tooltip background color
                      border: Border.all(
                          color: Colors.black), // Customize tooltip border
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zona: ${polygon.zone}'),
                        Text('Dias: ${polygon.days}'),
                        Text('Horario: ${polygon.time}'),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      
      // body: FlutterMap(
      //   mapController: mapController,
      //   options: MapOptions(
      //     initialCenter: currentLocation,
      //     initialZoom: 12.0,
      //   ),
      //   children: [
      //     TileLayer(
      //       urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      //       subdomains: ['a', 'b', 'c'],
      //     ),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         RichAttributionWidget(attributions: [
      //           TextSourceAttribution(
      //             '© OpenStreetMap contributors',
      //             onTap: () =>
      //                 launchUrl(Uri.parse('https://www.openstreetmap.org/')),
      //           ),
      //         ]),
      //       ],
      //     ),
      //     if (showMarker)
      //       MarkerLayer(
      //         markers: [
      //           Marker(
      //             width: 20.0,
      //             height: 20.0,
      //             point: currentLocation,
      //             child: const Icon(
      //               Icons.my_location,
      //               color: Colors.blue,
      //               size: 20.0,
      //             ),
      //           ),
      //         ],
      //       ),
      //     if (geojson.isNotEmpty)
      //       // GestureDetector(
      //       //   onTap: () {
      //       //     _showPolygonDialog(geojson.toString());
      //       //   },
      //       //   child: 
      //       PolygonLayer(
      //           polygons: geojson.map((item) {
      //             var geojsonData = item['geojson'];
      //             if (geojsonData != null) {
      //               return Polygon(
      //                 points: parseGeoJSON(geojsonData),
      //                 color: Colors.blue.withOpacity(0.5),
      //                 borderColor: Colors.blue,
      //                 borderStrokeWidth: 2,
      //                 isFilled: true,
      //               );
      //             } else {
      //               return Polygon(
      //                 points: [],
      //                 color: Colors.transparent,
      //               );
      //             }
      //           }).toList(),
      //       //  ),
      //       ),
             
              
      //         // PolygonLayer(
      //         //   polygons: geojson.map((item) {
      //         //     var geojsonData = item['geojson'];
      //         //     if (geojsonData != null) {
      //         //       return 
      //         //       Polygon(
      //         //         points: parseGeoJSON(geojsonData),
      //         //         color: Colors.blue.withOpacity(0.5),
      //         //         borderColor: Colors.blue,
      //         //         borderStrokeWidth: 2,
      //         //         isFilled: true,
                      
      //         //       );
      //         //     } else {
      //         //       return Polygon(
      //         //         points: [],
      //         //         color: Colors.transparent,
      //         //       );
      //         //     }
      //         //   }).toList(),
      //         // ),
            
            
      //   ],
      // ),
      
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
          // FloatingActionButton(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(100.0),
          //   ),
          //   onPressed: () {
          //     _getLocation();
          //   },
          //   child: Icon(Icons.my_location),
          // ),
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
}

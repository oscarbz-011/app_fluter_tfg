import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:convert';
import 'package:location/location.dart';

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

  List<dynamic> geojson = [];

  //Variables a usar con syncfusion_flutter_maps
  late MapZoomPanBehavior _zoomPanBehavior;
  List<CustomPolygon> _polygons = [];

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
    super.initState();
    fetchPolygons();
    _currentLocation();
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

  // Future<void> _getLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return;
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return;
  //   }

  //   Position position = await Geolocator.getCurrentPosition();
  //   setState(() {
  //     showMarker = true;
  //     currentLocation = LatLng(position.latitude, position.longitude);

  //     // mapController.move(currentLocation, 15.0);
  //     _zoomPanBehavior
  //       ..focalLatLng = const MapLatLng(currentLocation)
  //       ..zoomLevel = 4;
  //   });
  // }

  Future<LocationData?> _currentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = new Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    return await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfMaps(
        layers: [
          MapTileLayer(
            initialFocalLatLng:
                //MapLatLng(-27.332474952498472, -55.864316516887556),
                MapLatLng(
                    currentLocation.latitude!, currentLocation.longitude!),
            initialZoomLevel: 15,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            zoomPanBehavior: _zoomPanBehavior,
            sublayers: [
              MapPolygonLayer(
                polygons: _polygons
                    .map((polygon) => MapPolygon(
                          points: polygon.points,
                          color: polygon.color,
                          strokeColor: polygon.strokeColor,
                          onTap: () {
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
            bottom: 80.0,
            right: 2.0,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              onPressed: () {
                _currentLocation();
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
        return SizedBox(
          //padding: EdgeInsets.all(16.0),
          height: 200,
          child: Center(
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
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:syncfusion_flutter_maps/maps.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/gestures.dart';

// import 'package:geolocator/geolocator.dart';

// import 'package:url_launcher/url_launcher.dart';

// class MapWidget extends StatefulWidget {
//   const MapWidget({Key? key});

//   @override
//   _MapWidgetState createState() => _MapWidgetState();
// }

// class _MapWidgetState extends State<MapWidget> {
//   late Stream<List<CustomPolygon>> polygonsStream;

//   //Variables a usar con syncfusion_flutter_maps
//   late MapZoomPanBehavior _zoomPanBehavior;
//   List<CustomPolygon> _polygons = [];

//   @override
//   void initState() {
//     super.initState();
//     polygonsStream = fetchPolygons();
//     _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
//   }

//   Stream<List<CustomPolygon>> fetchPolygons() async* {
//     // Mantén un bucle infinito para buscar actualizaciones de polígonos continuamente
//     while (true) {
//       await Future.delayed(Duration(
//           seconds: 10)); // Espera 10 segundos antes de buscar actualizaciones

//       try {
//         const url = 'http://192.168.100.123:8000/api/map';
//         final response = await http.get(Uri.parse(url));
//         if (response.statusCode == 200) {
//           final List<dynamic> data = jsonDecode(response.body);
//           List<CustomPolygon> polygons = [];
//           for (var item in data) {
//             final Map<String, dynamic> geojson = jsonDecode(item['geojson']);
//             final List<dynamic> coordinates = geojson['coordinates'][0];
//             List<LatLng> points = [];
//             for (var coordinate in coordinates) {
//               points.add(LatLng(coordinate[1], coordinate[0]));
//             }
//             CustomPolygon polygon = CustomPolygon(
//               points: points,
//               color: Color.fromARGB(114, 33, 149, 243),
//               strokeColor: Color.fromARGB(83, 33, 149, 243),
//               zone: item['zone'],
//               days: item['days'],
//               time: item['time'],
//             );
//             polygons.add(polygon);
//           }
//           yield polygons; // Emitir la lista de polígonos actualizada
//         } else {
//           throw Exception('Failed to fetch polygons from API');
//         }
//       } catch (e) {
//         // Manejar cualquier error que ocurra al buscar polígonos
//         print('Error al obtener polígonos: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<List<CustomPolygon>>(
//         stream: polygonsStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             List<CustomPolygon> polygons = snapshot.data ?? [];
//             return SfMaps(
//               layers: [
//                 MapTileLayer(
//                   initialZoomLevel: 12,
//                   initialFocalLatLng:
//                       MapLatLng(-27.332474952498472, -55.864316516887556),
//                   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                   zoomPanBehavior: _zoomPanBehavior,
//                   sublayers: [
//                     MapPolygonLayer(
//                       polygons: _polygons
//                           .map((polygon) => MapPolygon(
//                                 points: polygon.points
//                                     .map((point) => MapLatLng(
//                                         point.latitude, point.longitude))
//                                     .toList(),
//                                 color: polygon.color,
//                                 strokeColor: polygon.strokeColor,
//                                 onTap: () {
//                                   _showPolygonInfo(context, polygon);
//                                 },
//                               ))
//                           .toSet(),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }

//   // Funcion para mostrar información del polígono al hacer click
//   void _showPolygonInfo(BuildContext context, CustomPolygon polygon) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Itinerario del servicio',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text('Zona: ${polygon.zone}'),
//               Text('Dias: ${polygon.days}'),
//               Text('Horario: ${polygon.time}'),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class CustomPolygon {
//   final List<LatLng> points;
//   final Color color;
//   final Color strokeColor;
//   final String zone;
//   final String days;
//   final String time;

//   CustomPolygon({
//     required this.points,
//     required this.color,
//     required this.strokeColor,
//     required this.zone,
//     required this.days,
//     required this.time,
//   });
// }

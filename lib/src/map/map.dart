import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

// Clase para crear polígonos personalizados
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

  // Variables a usar con syncfusion_flutter_maps
  late MapZoomPanBehavior _zoomPanBehavior;
  List<CustomPolygon> _polygons = [];

  // Controlador del flujo de datos de polígonos
  StreamController<List<CustomPolygon>> _polygonStreamController =
      StreamController<List<CustomPolygon>>();

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
    super.initState();
    _currentLocation().then((locationData) {
      if (locationData != null) {
        setState(() {
          currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
        });
      }
    });
    // Iniciar el flujo de datos de polígonos
    _startPolygonStream();
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    _polygonStreamController.close(); // Cerrar el controlador de flujo
    super.dispose();
  }

  // Inicia el flujo de datos de polígonos
  void _startPolygonStream() {
    Timer.periodic(Duration(seconds: 10), (timer) async {
      // Actualizar polígonos cada 10 segundos
      fetchPolygons();
    });
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
          color: const Color.fromARGB(
              114, 33, 149, 243), // You can customize the color if needed
          strokeColor: Color.fromARGB(
              83, 33, 149, 243), // You can customize the stroke color if needed
          zone: item['zone'],
          days: item['days'],
          time: item['time'],
        );
        polygons.add(polygon);
      }
      // Agregar polígonos al flujo de datos
      _polygonStreamController.sink.add(polygons);
    } else {
      throw Exception('Failed to fetch polygons from API');
    }
  }

  MapController mapController = MapController();
  LatLng currentLocation = LatLng(-27.332474952498472, -55.864316516887556);
  bool showMarker = false;

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
      body: StreamBuilder<List<CustomPolygon>>(
        stream: _polygonStreamController.stream,
        initialData: _polygons,
        builder: (BuildContext context,
            AsyncSnapshot<List<CustomPolygon>> snapshot) {
          return SfMaps(
            layers: [
              MapTileLayer(
                initialFocalLatLng: MapLatLng(
                  currentLocation.latitude,
                  currentLocation.longitude,
                ),
                initialZoomLevel: 15,
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                zoomPanBehavior: _zoomPanBehavior,
                sublayers: [
                  MapPolygonLayer(
                    polygons: snapshot.data!
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
          );
        },
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

  // Función para mostrar información del polígono al hacer clic
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

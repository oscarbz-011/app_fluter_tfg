import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:location/location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final int status;

  CustomPolygon({
    required this.points,
    required this.color,
    required this.strokeColor,
    required this.zone,
    required this.days,
    required this.time,
    required this.status,
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

  // Variable para almacenar la ubicación actual del dispositivo
  LocationData? _currentLocation;

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
    super.initState();
    // Obtener la ubicación actual al iniciar
    _getCurrentLocation();
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
    // Obtener la URL de la API desde el archivo .env
    String api_url = dotenv.get("API_URL", fallback: "");

    final response = await http.get(Uri.parse(api_url + 'api/map'));
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
        if (item['status'] == 1) {
          CustomPolygon polygon = CustomPolygon(
            points: points,
            color: const Color.fromARGB(114, 33, 149, 243),
            strokeColor: Color.fromARGB(208, 5, 55, 95),
            zone: item['zone'],
            days: item['days'],
            time: item['time'],
            status: item['status'],
          );
          polygons.add(polygon);
        } else {
          CustomPolygon polygon = CustomPolygon(
            points: points,
            color: Color.fromARGB(113, 220, 30, 30),
            strokeColor: Color.fromARGB(205, 116, 17, 17),
            zone: item['zone'],
            days: item['days'],
            time: item['time'],
            status: item['status'],
          );
          polygons.add(polygon);
        }
      }
      // Agregar polígonos al flujo de datos
      _polygonStreamController.sink.add(polygons);
    } else {
      throw Exception('Failed to fetch polygons from API');
    }
  }

  Future<void> _getCurrentLocation() async {
    Location location = new Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _zoomPanBehavior.focalLatLng = MapLatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
      _zoomPanBehavior.zoomLevel = 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<CustomPolygon>>(
              stream: _polygonStreamController.stream,
              initialData: _polygons,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CustomPolygon>> polygonSnapshot) {
                return SfMaps(
                  layers: [
                    MapTileLayer(
                      initialFocalLatLng: MapLatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      initialZoomLevel: 15,
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      zoomPanBehavior: _zoomPanBehavior,
                      sublayers: [
                        MapPolygonLayer(
                          polygons: polygonSnapshot.data!
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
                      markerBuilder: (BuildContext context, int index) {
                        return MapMarker(
                          latitude: _currentLocation!.latitude!,
                          longitude: _currentLocation!.longitude!,
                          child: Icon(Icons.location_on, color: Colors.red),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }

  // Función para mostrar información del polígono al hacer clic
  void _showPolygonInfo(BuildContext context, CustomPolygon polygon) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 400,
          child: Container(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Itinerario del servicio',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Zona: ${polygon.zone}',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  SizedBox(height: 10),
                  Text('Dias: ${polygon.days}',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  SizedBox(height: 10),
                  Text('Horario: ${polygon.time}',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  SizedBox(height: 10),
                  Text(
                      'Estado: ${polygon.status == 1 ? 'Activo' : 'Suspendido'}',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

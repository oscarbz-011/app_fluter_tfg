import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:location/location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

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
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();

  List<dynamic> geojson = [];

  // Variables a usar con syncfusion_flutter_maps
  late MapZoomPanBehavior _zoomPanBehavior;
  final List<CustomPolygon> _polygons = [];

  // Controlador del flujo de datos de polígonos
  final StreamController<List<CustomPolygon>> _polygonStreamController =
      StreamController<List<CustomPolygon>>();

  // Variable para almacenar la ubicación actual del dispositivo
  LocationData? _currentLocation;

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true);
    super.initState();
    // Iniciar el flujo de datos de polígonos
    _startPolygonStream();

    // Obtener la ubicación actual del dispositivo al iniciar el widget
    _getCurrentLocation().then((location) {
      setState(() {
        _currentLocation = location;
        _moveToCurrentLocation();
      });
    });
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    _polygonStreamController.close(); // Cerrar el controlador de flujo
    super.dispose();
  }

  // Inicia el flujo de datos de polígonos
  void _startPolygonStream() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Actualizar polígonos cada 3 segundos
      fetchPolygons();
    });
  }

  void fetchPolygons() async {
    // Obtener la URL de la API desde el archivo .env
    String apiUrl = dotenv.get("API_URL", fallback: "");

    final response = await http.get(Uri.parse('${apiUrl}api/map'));
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
            strokeColor: const Color.fromARGB(208, 5, 55, 95),
            zone: item['zone'],
            days: item['days'],
            time: item['time'],
            status: item['status'],
          );
          polygons.add(polygon);
        } else {
          CustomPolygon polygon = CustomPolygon(
            points: points,
            color: const Color.fromARGB(113, 220, 30, 30),
            strokeColor: const Color.fromARGB(205, 116, 17, 17),
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

  Future<LocationData?> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = Location();

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
      body: FutureBuilder<LocationData?>(
        future: _getCurrentLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras se espera la ubicación actual, se puede mostrar un indicador de carga
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Manejar el caso de error si ocurre algún problema al obtener la ubicación
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            _currentLocation = snapshot.data;
            _moveToCurrentLocation();

            // Cuando se obtiene la ubicación actual, construir el mapa
            return StreamBuilder<List<CustomPolygon>>(
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
                          child:
                              const Icon(Icons.location_on, color: Colors.red),
                        );
                      },
                      initialMarkersCount: 1, // Solo necesitamos un marcador
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
                child: Text('No se pudo obtener la ubicación actual'));
          }
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
              backgroundColor: const Color.fromARGB(255, 39, 34, 43),
              onPressed: () async {
                _currentLocation = await _getCurrentLocation();
                setState(() {
                  _moveToCurrentLocation();
                });
              },
              child: const Icon(Icons.my_location),
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
          height: 400,
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
                const SizedBox(height: 10),
                Text('Zona: ${polygon.zone}',
                    style: const TextStyle(
                      fontSize: 16,
                    )),
                const SizedBox(height: 10),
                Text('Dias: ${polygon.days}',
                    style: const TextStyle(
                      fontSize: 16,
                    )),
                const SizedBox(height: 10),
                Text('Horario: ${polygon.time}',
                    style: const TextStyle(
                      fontSize: 16,
                    )),
                const SizedBox(height: 10),
                Text('Estado: ${polygon.status == 1 ? 'Activo' : 'Suspendido'}',
                    style: const TextStyle(
                      fontSize: 16,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

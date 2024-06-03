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

  Future<LatLng> _getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LatLng>(
        future: _getCurrentLocation(),
        builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras se espera la ubicación actual, se puede mostrar un indicador de carga
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Manejar el caso de error si ocurre algún problema al obtener la ubicación
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
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
                        snapshot.data!.latitude,
                        snapshot.data!.longitude,
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
                    ),
                  ],
                );
              },
            );
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
              onPressed: () {
                _getCurrentLocation();
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

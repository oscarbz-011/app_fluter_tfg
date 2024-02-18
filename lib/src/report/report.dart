import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as http;

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final emailController = TextEditingController();
  final categoriesController = TextEditingController();
  final zoneController = TextEditingController();
  final descriptionController = TextEditingController();
  late LatLng _selectedLocation;
  late File? _image = null;
  int selectedCategory = 1;
  final formKey = GlobalKey<FormState>();

  late MapLatLng _markerPosition;
  late MapZoomPanBehavior _mapZoomPanBehavior;
  late MapTileLayerController _controller;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(0, 0); // Latitud y longitud inicial
    _controller = MapTileLayerController();
    _mapZoomPanBehavior = MapZoomPanBehavior(zoomLevel: 12);
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  Future<void> _getImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

    void updateMarkerChange(Offset position) {
        // We have converted the local point into latlng and inserted marker
        // in that position.
        _markerPosition = _controller.pixelToLatLng(position);
        if (_controller.markersCount > 0) {
        _controller.clearMarkers();
        }
        _controller.insertMarker(0);
    }

    Future<void> _sendReport() async {
        final url = Uri.parse('http://192.168.100.123:8000/api/reports');
        final response = await http.post(
        url,
        body: jsonEncode({
            'email': emailController.text,
            'categories_id': selectedCategory,
            'zone': zoneController.text,
            'description': descriptionController.text,
            'latitude': _selectedLocation.latitude,
            'longitude': _selectedLocation.longitude,
            // Añade aquí cualquier otro dato que necesites enviar
        }),
        headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
              content: Text('Reporte enviado correctamente'),
            ),
          );
            // Aquí puedes agregar cualquier lógica adicional que necesites
        } else {
        // La solicitud falló
        throw Exception('Failed to send report');
        }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Añade los campos del formulario
                //Email
                 TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                //Categoria
                DropdownButtonFormField<int>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('Servicio de Recolección'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('Ambiental'),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text('Social'),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                //Zona
                TextFormField(
                  controller: zoneController,
                  decoration: const InputDecoration(
                    labelText: 'Zona',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                //Descripción
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 300, // Ajusta la altura según sea necesario
                  child: GestureDetector(
                    onTapUp: (TapUpDetails details) {
                      updateMarkerChange(details.localPosition);
                      
                    },
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          zoomPanBehavior: _mapZoomPanBehavior,
                          initialFocalLatLng: MapLatLng(
                              -27.332474952498472, -55.864316516887556),
                          controller: _controller,
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: _markerPosition.latitude,
                              longitude: _markerPosition.longitude,
                              child: Icon(Icons.location_on, color: Colors.red),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _getImage,
                  child: Text('Seleccionar Imagen'),
                ),
                SizedBox(height: 10),
                if (_image != null) Image.file(_image!),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    // Primero, verifica si el formulario es válido
                    if (formKey.currentState!.validate()) {
                      // Si el formulario es válido, envía el reporte
                      await _sendReport();
                    }
                  },
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

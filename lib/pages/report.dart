import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:latlong2/latlong.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  late MapTileLayerController _mapController;
  late _CustomZoomPanBehavior _mapZoomPanBehavior;
  late MapLatLng _markerPosition;
  late LatLng _selectedLocation;
  late File? _image = null;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mapController = MapTileLayerController();
    _mapZoomPanBehavior = _CustomZoomPanBehavior()..onTap = updateMarkerChange;
    _selectedLocation = LatLng(0, 0);
  }

  // This function is called when the user taps on the map
  void updateMarkerChange(Offset position) {
    _markerPosition = _mapController.pixelToLatLng(position);
    if (_mapController.markersCount > 0) {
      _mapController.clearMarkers();
    }
    _mapController.insertMarker(0);
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
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 300, // Adjust height as needed
                  child: SfMaps(
                    layers: [
                      MapTileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        //initialMarkersCount: 1,
                        controller: _mapController,
                        zoomPanBehavior: _mapZoomPanBehavior,
                        markerBuilder: (BuildContext context, int index) {
                          return MapMarker(
                            latitude: _selectedLocation.latitude,
                            longitude: _selectedLocation.longitude,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                          );
                        },
                        
                      ),
                    ],
                    // onWillPan: (MapPanDetails details) {
                    //   setState(() {
                    //     final latlng = _mapController
                    //         .pixelToLatLng(details.globalFocalPoint);
                    //     _selectedLocation =
                    //         LatLng(latlng.latitude, latlng.longitude);
                    //   });
                    //   return true;
                    // },
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
                  onPressed: () {
                    // Aquí enviar los datos al endpoint HTTP
                    // Utiliza _image para enviar la imagen
                    // Utiliza _selectedLocation para enviar la ubicación
                    // Utiliza titleController.text y contentController.text para obtener el título y la descripción
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

class _CustomZoomPanBehavior extends MapZoomPanBehavior {
  late MapTapCallback onTap;

  @override
   void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent) {
      onTap(event.localPosition);
    }
    super.handleEvent(event);
  }
}


typedef MapTapCallback = void Function(Offset position);
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_flutter/Models/category_values.dart';

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
  String selectedZone = '';
  final formKey = GlobalKey<FormState>();

  late MapLatLng _markerPosition = const MapLatLng(-27.332474952498472, -55.864316516887556);
  late MapZoomPanBehavior _mapZoomPanBehavior;
  late MapTileLayerController _controller;

  @override
  void initState() {
    super.initState();
    _selectedLocation = const LatLng(0, 0); // Latitud y longitud inicial
    _controller = MapTileLayerController();
    _mapZoomPanBehavior = MapZoomPanBehavior(
      zoomLevel: 12,
      focalLatLng: const MapLatLng(-27.332474952498472, -55.864316516887556),
      showToolbar: true,
      toolbarSettings: const MapToolbarSettings(
        position: MapToolbarPosition.topLeft,
        //direction: Axis.vertical,
        iconColor: Colors.blue,
        itemBackgroundColor: Colors.transparent,
        itemHoverColor: Colors.transparent,
      ),
    );
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  Future<void> _getImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 960,
      maxHeight: 1280,
    );
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  // Función para obtener la ubicación actual
  Future<LocationData?> _currentLocation() async {
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


  // Función para actualizar la posición del marcador
  void updateMarkerChange(Offset position) {
    // We have converted the local point into latlng and inserted marker
    // in that position.
    _markerPosition = _controller.pixelToLatLng(position);
    if (_controller.markersCount > 0) {
      _controller.clearMarkers();
    }
    _controller.insertMarker(0);

    // Llamar a _selectLocation con la nueva posición
    _selectLocation(
        LatLng(_markerPosition.latitude, _markerPosition.longitude));
  }

  Future<void> _sendReport() async {
    try {

    
    // Obtener la URL de la API desde el archivo .env
    String apiUrl = dotenv.get("API_URL", fallback: "");
    final url = Uri.parse('${apiUrl}api/reports');

    // Construir la solicitud multipart/form-data
    final request = http.MultipartRequest('POST', url);

    // Agregar campos de texto
    request.fields['email'] = emailController.text;
    request.fields['categories_id'] = selectedCategory.toString();
    request.fields['zone'] = zoneController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['latitude'] = _selectedLocation.latitude.toString();
    request.fields['longitude'] = _selectedLocation.longitude.toString();

    // Agregar la imagen
    if (_image != null) {
      final file = await http.MultipartFile.fromPath('image', _image!.path);
      request.files.add(file);
    }

    // Imprimir los datos antes de enviar la solicitud
    // print('Datos enviados:');
    // print('Email: ${emailController.text}');
    // print('Categoría: $selectedCategory');
    // print('Zona: ${zoneController.text}');
    // print('Descripción: ${descriptionController.text}');
    // print('Latitud: ${_selectedLocation.latitude}');
    // print('Longitud: ${_selectedLocation.longitude}');
    // if (_image != null) {
    //   print('Imagen: ${_image!.path}');
    // }

    // Enviar la solicitud
    final streamedResponse = await request.send();

    // Manejar la respuesta
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado correctamente'),
        ),
      );
      // Limpiar los campos del formulario
      emailController.clear();
      zoneController.clear();
      descriptionController.clear();
      setState(() {
        _image = null;
      });
    } else {
      throw Exception('Hubo un error al enviar el reporte');
    }
    } catch (e) {
      //print('Error al enviar el reporte: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el reporte: $e'),
        ),
      );
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
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  items: dropdownItems,
                ),

                const SizedBox(height: 10),

                
                //Zona
                TextFormField(
                  controller: zoneController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Zona',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),

                //Descripción
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 80.0, horizontal: 14.0),
                  ),
                ),
                const SizedBox(height: 10),
                if (_selectedLocation.latitude != 0 && _selectedLocation.longitude != 0)
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        Text('Ubicación seleccionada'),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                if (_image != null)
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        
                        Image.file(
                          _image!,
                          height: 20,
                          width: 40,
                        ),
                        const Text('Imagen seleccionada'),
                        const SizedBox(height: 10),
                        
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Center(
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    ElevatedButton(
                        onPressed: () {
                          _showMap(context);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.location_on),
                            Text('Ubicación'),
                          ],
                        )
                    ),
                    ElevatedButton(
                        onPressed: _getImage,

                        child: const Row(
                          children: [
                            Icon(Icons.camera_alt),
                            Text('Imagen'),
                          ],
                        ),
                    ),
                    

                  ],
                ),
                ),
                
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    // Primero, verifica si el formulario es válido
                    if (formKey.currentState!.validate()) {
                      // Si el formulario es válido, envía el reporte
                      await _sendReport();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


 // Función para mostrar desplegar el mapa al hacer clic
  void _showMap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          //padding: EdgeInsets.all(16.0),
          height: 360,
          child: Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                      height: 260, 
                      width: MediaQuery.of(context).size.width,
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
                              initialZoomLevel: 15,
                              initialFocalLatLng: MapLatLng(
                                  _selectedLocation.latitude, _selectedLocation.longitude),
                              controller: _controller,
                              markerBuilder: (BuildContext context, int index) {
                                return MapMarker(
                                  latitude: _markerPosition.latitude,
                                  longitude: _markerPosition.longitude,
                                  child: const Icon(Icons.location_on, color: Colors.red),
                                );
                              },
                              initialMarkersCount: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: (){
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(100, 39, 34, 43),
                      minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    ), 
                    child: const Icon(Icons.check, color: Colors.white,)
                    ),
                    
              
            ],
          ),
        );
      },
    );
  }
  
}
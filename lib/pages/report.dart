import 'package:flutter/material.dart';


class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool obscure = true;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar'),
      ),
      
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                
              ),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                
              ),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Imagen',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
             
              ElevatedButton(
                onPressed: (){},
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  



  
}

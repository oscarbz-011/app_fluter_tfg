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
                
                
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                
              ),
              TextFormField(
                controller: contentController,
                
                
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                
              ),
              // TextFormField(
              //   controller: emailController,
                
              //   autofocus: true,
              //   textCapitalization: TextCapitalization.none,
              //   autofillHints: const [AutofillHints.email],
              //   keyboardType: TextInputType.emailAddress,
              //   textInputAction: TextInputAction.next,
                
              // ),
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

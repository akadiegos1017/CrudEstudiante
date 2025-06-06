import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Estudiante {
  int id;
  String nombre;
  String apellido;
  String documento;
  String email;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.email,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      documento: json['documento'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'documento': documento,
      'email': email,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Estudiantes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Estudiante> estudiantes = [];

  static const String apiUrl =
      'http://localhost:8080/estudiantes'; // <-- Cambia a tu URL real

  static const List<String> _titles = [
    'Lista de Estudiantes',
    'Agregar Estudiante',
    'Modificar Estudiante',
    'Eliminar Estudiante',
  ];

  @override
  void initState() {
    super.initState();
    cargarEstudiantesDesdeAPI();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> cargarEstudiantesDesdeAPI() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          estudiantes = data.map((json) => Estudiante.fromJson(json)).toList();
        });
      } else {
        throw Exception('Error al cargar estudiantes');
      }
    } catch (e) {
      // Manejar error, por ejemplo mostrar un SnackBar o print en consola
      print('Error en cargarEstudiantesDesdeAPI: $e');
    }
  }

  Future<Estudiante> agregarEstudianteAPI(Estudiante e) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(e.toJson()),
      );

      if (response.statusCode == 201) {
        final nuevo = Estudiante.fromJson(jsonDecode(response.body));
        await cargarEstudiantesDesdeAPI();
        setState(() {
          _selectedIndex = 0;
        });
        return nuevo;
      } else {
        throw Exception('Error al agregar estudiante');
      }
    } catch (e) {
      print('Error en agregarEstudianteAPI: $e');
      rethrow; // relanza el error para manejarlo arriba si quieres
    }
  }

  Future<void> modificarEstudianteAPI(Estudiante e) async {
    try {
      final url = '$apiUrl/${e.id}';
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(e.toJson()),
      );
      if (response.statusCode == 200) {
        await cargarEstudiantesDesdeAPI();
        setState(() {
          _selectedIndex = 0;
        });
      }
    } catch (e) {
      print('Error en modificarEstudianteAPI: $e');
    }
  }

  Future<void> eliminarEstudianteAPI(int id) async {
    try {
      final url = '$apiUrl/$id';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        await cargarEstudiantesDesdeAPI();
        setState(() {
          _selectedIndex = 0;
        });
      }
    } catch (e) {
      print('Error en eliminarEstudianteAPI: $e');
    }
  }



  Future<void> agregarEstudiante(Estudiante e) async {
    await agregarEstudianteAPI(e);
  }

  void modificarEstudiante(Estudiante modificado) async {
    await modificarEstudianteAPI(modificado);
  }

  void eliminarEstudiante(int id) async {
    await eliminarEstudianteAPI(id);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      VerEstudiantes(estudiantes: estudiantes),
      AgregarEstudiante(
        onAgregar: agregarEstudiante,
        ultimoId: estudiantes.isNotEmpty ? estudiantes.last.id : 0,
      ),
      ModificarEstudiante(
        estudiantes: estudiantes,
        onModificar: modificarEstudiante,
      ),
      EliminarEstudiante(
        estudiantes: estudiantes,
        onEliminar: eliminarEstudiante,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Ver'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Agregar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Modificar'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Eliminar'),
        ],
      ),
    );
  }
}

class VerEstudiantes extends StatelessWidget {
  final List<Estudiante> estudiantes;

  const VerEstudiantes({required this.estudiantes});

  @override
  Widget build(BuildContext context) {
    if (estudiantes.isEmpty) {
      return Center(child: Text('No hay estudiantes'));
    }
    return ListView.builder(
      itemCount: estudiantes.length,
      itemBuilder: (context, index) {
        final e = estudiantes[index];
        return ListTile(
          title: Text('${e.nombre} ${e.apellido}'),
          subtitle: Text('Documento: ${e.documento}\nEmail: ${e.email}'),
        );
      },
    );
  }
}

class AgregarEstudiante extends StatefulWidget {
  final Future<void> Function(Estudiante) onAgregar;
  final int ultimoId;

  const AgregarEstudiante({required this.onAgregar, required this.ultimoId});

  @override
  State<AgregarEstudiante> createState() => _AgregarEstudianteState();
}

class _AgregarEstudianteState extends State<AgregarEstudiante> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = Estudiante(
        id: widget.ultimoId + 1,
        nombre: _nombreCtrl.text,
        apellido: _apellidoCtrl.text,
        documento: _documentoCtrl.text,
        email: _emailCtrl.text,
      );

      try {
        await widget.onAgregar(nuevo); // Espera que se agregue

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Estudiante agregado')));

        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al agregar estudiante')));
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _documentoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: InputDecoration(labelText: 'Nombre'),
              validator:
                  (val) => val == null || val.isEmpty ? 'Ingrese nombre' : null,
            ),
            TextFormField(
              controller: _apellidoCtrl,
              decoration: InputDecoration(labelText: 'Apellido'),
              validator:
                  (val) =>
                      val == null || val.isEmpty ? 'Ingrese apellido' : null,
            ),
            TextFormField(
              controller: _documentoCtrl,
              decoration: InputDecoration(labelText: 'Número de Documento'),
              keyboardType: TextInputType.number,
              validator:
                  (val) =>
                      val == null || val.isEmpty ? 'Ingrese documento' : null,
            ),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Ingrese correo';
                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!regex.hasMatch(val)) return 'Correo inválido';
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Agregar Estudiante'),
            ),
          ],
        ),
      ),
    );
  }
}

class ModificarEstudiante extends StatefulWidget {
  final List<Estudiante> estudiantes;
  final Function(Estudiante) onModificar;

  const ModificarEstudiante({
    required this.estudiantes,
    required this.onModificar,
  });

  @override
  State<ModificarEstudiante> createState() => _ModificarEstudianteState();
}

class _ModificarEstudianteState extends State<ModificarEstudiante> {
  Estudiante? seleccionado;

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  void cargarEstudiante(Estudiante e) {
    _nombreCtrl.text = e.nombre;
    _apellidoCtrl.text = e.apellido;
    _documentoCtrl.text = e.documento;
    _emailCtrl.text = e.email;
  }

  void _submit() {
    if (seleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Seleccione un estudiante')));
      return;
    }
    if (_formKey.currentState!.validate()) {
      final modificado = Estudiante(
        id: seleccionado!.id,
        nombre: _nombreCtrl.text,
        apellido: _apellidoCtrl.text,
        documento: _documentoCtrl.text,
        email: _emailCtrl.text,
      );
      widget.onModificar(modificado);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Estudiante modificado')));
      setState(() {
        seleccionado = null;
        _formKey.currentState!.reset();
      });
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _documentoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<Estudiante>(
          value: seleccionado,
          hint: Text('Seleccione un estudiante'),
          isExpanded: true,
          items:
              widget.estudiantes.map((e) {
                return DropdownMenuItem<Estudiante>(
                  value: e,
                  child: Text('${e.nombre} ${e.apellido}'),
                );
              }).toList(),
          onChanged: (val) {
            setState(() {
              seleccionado = val;
              if (val != null) cargarEstudiante(val);
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Ingrese nombre'
                                : null,
                  ),
                  TextFormField(
                    controller: _apellidoCtrl,
                    decoration: InputDecoration(labelText: 'Apellido'),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Ingrese apellido'
                                : null,
                  ),
                  TextFormField(
                    controller: _documentoCtrl,
                    decoration: InputDecoration(
                      labelText: 'Número de Documento',
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Ingrese documento'
                                : null,
                  ),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(labelText: 'Correo'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Ingrese correo';
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!regex.hasMatch(val)) return 'Correo inválido';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Modificar Estudiante'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EliminarEstudiante extends StatelessWidget {
  final List<Estudiante> estudiantes;
  final Function(int) onEliminar;

  const EliminarEstudiante({
    required this.estudiantes,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (estudiantes.isEmpty) {
      return Center(child: Text('No hay estudiantes para eliminar'));
    }
    return ListView.builder(
      itemCount: estudiantes.length,
      itemBuilder: (context, index) {
        final e = estudiantes[index];
        return ListTile(
          title: Text('${e.nombre} ${e.apellido}'),
          subtitle: Text('Documento: ${e.documento}\nEmail: ${e.email}'),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: Text('Confirmar eliminación'),
                      content: Text('¿Eliminar a ${e.nombre} ${e.apellido}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            onEliminar(e.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Estudiante eliminado')),
                            );
                          },
                          child: Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        );
      },
    );
  }
}

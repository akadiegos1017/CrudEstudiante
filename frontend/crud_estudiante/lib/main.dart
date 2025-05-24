import 'package:flutter/material.dart';

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
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Estudiantes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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

  List<Estudiante> estudiantes = [
    Estudiante(id: 1, nombre: 'Ana', apellido: 'Pérez', documento: '12345678', email: 'ana@mail.com'),
    Estudiante(id: 2, nombre: 'Luis', apellido: 'García', documento: '87654321', email: 'luis@mail.com'),
  ];

  static const List<String> _titles = [
    'Lista de Estudiantes',
    'Agregar Estudiante',
    'Modificar Estudiante',
    'Eliminar Estudiante',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void agregarEstudiante(Estudiante e) {
    setState(() {
      estudiantes.add(e);
    });
  }

  void modificarEstudiante(Estudiante modificado) {
    setState(() {
      int index = estudiantes.indexWhere((e) => e.id == modificado.id);
      if (index != -1) {
        estudiantes[index] = modificado;
      }
    });
  }

  void eliminarEstudiante(int id) {
    setState(() {
      estudiantes.removeWhere((e) => e.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      VerEstudiantes(estudiantes: estudiantes),
      AgregarEstudiante(onAgregar: agregarEstudiante, ultimoId: estudiantes.isNotEmpty ? estudiantes.last.id : 0),
      ModificarEstudiante(estudiantes: estudiantes, onModificar: modificarEstudiante),
      EliminarEstudiante(estudiantes: estudiantes, onEliminar: eliminarEstudiante),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Ver'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Agregar'),
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
  final Function(Estudiante) onAgregar;
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final nuevo = Estudiante(
        id: widget.ultimoId + 1,
        nombre: _nombreCtrl.text,
        apellido: _apellidoCtrl.text,
        documento: _documentoCtrl.text,
        email: _emailCtrl.text,
      );
      widget.onAgregar(nuevo);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estudiante agregado')));
      _formKey.currentState!.reset();
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
              validator: (val) => val == null || val.isEmpty ? 'Ingrese nombre' : null,
            ),
            TextFormField(
              controller: _apellidoCtrl,
              decoration: InputDecoration(labelText: 'Apellido'),
              validator: (val) => val == null || val.isEmpty ? 'Ingrese apellido' : null,
            ),
            TextFormField(
              controller: _documentoCtrl,
              decoration: InputDecoration(labelText: 'Número de Documento'),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Ingrese documento' : null,
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
            ElevatedButton(onPressed: _submit, child: Text('Agregar Estudiante')),
          ],
        ),
      ),
    );
  }
}

class ModificarEstudiante extends StatefulWidget {
  final List<Estudiante> estudiantes;
  final Function(Estudiante) onModificar;

  const ModificarEstudiante({required this.estudiantes, required this.onModificar});

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seleccione un estudiante')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estudiante modificado')));
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
          items: widget.estudiantes.map((e) {
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
                    validator: (val) => val == null || val.isEmpty ? 'Ingrese nombre' : null,
                  ),
                  TextFormField(
                    controller: _apellidoCtrl,
                    decoration: InputDecoration(labelText: 'Apellido'),
                    validator: (val) => val == null || val.isEmpty ? 'Ingrese apellido' : null,
                  ),
                  TextFormField(
                    controller: _documentoCtrl,
                    decoration: InputDecoration(labelText: 'Número de Documento'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? 'Ingrese documento' : null,
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
                  ElevatedButton(onPressed: _submit, child: Text('Modificar Estudiante')),
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

  const EliminarEstudiante({required this.estudiantes, required this.onEliminar});

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
                builder: (_) => AlertDialog(
                  title: Text('Confirmar eliminación'),
                  content: Text('¿Eliminar a ${e.nombre} ${e.apellido}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        onEliminar(e.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estudiante eliminado')));
                      },
                      child: Text('Eliminar', style: TextStyle(color: Colors.red)),
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

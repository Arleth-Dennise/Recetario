import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DesayunosPage extends StatefulWidget {
  const DesayunosPage({super.key});

  @override
  _DesayunosPageState createState() => _DesayunosPageState();
}

class _DesayunosPageState extends State<DesayunosPage> {
  final List<Desayuno> desayunos = [];
  final formkey = GlobalKey<FormState>();
  final tituloControlador = TextEditingController();
  final ingredientesControlador = TextEditingController();
  final preparacionControlador = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDesayunosFromFirestore();
  }

  Future<void> _loadDesayunosFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('desayunos')
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        desayunos.clear();
        for (var doc in querySnapshot.docs) {
          desayunos.add(Desayuno(
            titulo: doc['titulo'],
            ingredientes: doc['ingredientes'],
            preparacion: doc['preparacion'],
            imagenUrl: doc['imagenUrl'], 
            userId: doc['userId'],
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desayunos'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchBar();
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: desayunos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showDesayunoDetails(context, desayunos[index]);
            },
            onLongPress: () {
              _showOpciones(context, desayunos[index]);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  desayunos[index].imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            desayunos[index].imagenUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : const Icon(Icons.breakfast_dining, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    desayunos[index].titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMenu(context);
        },
        child: Image.asset('assets/images/menunegro.png', width: 50, height: 50),
      ),
    );
  }

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _searchRecipes();
                },
                child: Text('Buscar'),
              ),
            ],
          ),
        );
      },
    );
  }

void _searchRecipes() {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredRecipes = desayunos.where((recipe) {
      return recipe.titulo.toLowerCase().contains(searchQuery) ||
          recipe.ingredientes.toLowerCase().contains(searchQuery) ||
          recipe.preparacion.toLowerCase().contains(searchQuery);
    }).toList();
    _showSearchResults(filteredRecipes);
  }

   void _showSearchResults(List<Desayuno> filteredRecipes) {
  Navigator.pop(context);
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          height: 300, // ajusta el tamaño según sea necesario
          child: Column(
            children: [
              Text('Resultados de busqueda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredRecipes[index].titulo),
                      onTap: () {
                        _showDesayunoDetails(context, filteredRecipes[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 100,
          child: Column(
            children: [
              ListTile(
                title: const Text('Agregar Desayuno'),
                onTap: () {
                  _agregarDesayuno(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _agregarDesayuno(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(50),
            child: SizedBox(
              height: 500,
              child: Form(
                key: formkey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: tituloControlador,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Agregue título";
                        }
                        if (desayunos.any((desayuno) => desayuno.titulo.toLowerCase() == value.toLowerCase())) {
                          return "Ya existe un desayuno con este título";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Título de la receta',
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: ingredientesControlador,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Agregue los ingredientes";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Ingredientes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Color.fromARGB(0, 142, 142, 160)),
                        ),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: preparacionControlador,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Preparación',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Color.fromARGB(0, 142, 142, 160)),
                        ),
                      ),
                      maxLines: 10,
                      maxLength: 3000,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        setState(() {
                          if (image != null) {
                            _image = File(image.path);
                          } else {
                            _image = null;
                          }
                        });
                      },
                      child: const Text('Seleccionar imagen'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          Desayuno newDesayuno = Desayuno(
                            titulo: tituloControlador.text,
                            ingredientes: ingredientesControlador.text,
                            preparacion: preparacionControlador.text,
                            imagen: _image,
                            userId: user.uid,
                          );
                          await _saveDesayunoToFirestore(newDesayuno);
                          setState(() {
                            desayunos.add(newDesayuno);
                            tituloControlador.clear();
                            ingredientesControlador.clear();
                            preparacionControlador.clear();
                            _image = null;
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        } else {
                          print('Por favor, complete todos los campos');
                        }
                      },
                      child: const Text('Agregar Receta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveDesayunoToFirestore(Desayuno desayuno) async {
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImageToStorage(desayuno.titulo);
    }

    await FirebaseFirestore.instance.collection('desayunos').add({
      'titulo': desayuno.titulo,
      'ingredientes': desayuno.ingredientes,
      'preparacion': desayuno.preparacion,
      'imagenUrl': imageUrl,
      'userId': desayuno.userId,
    });
  }

  Future<String?> _uploadImageToStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('desayunos/$titulo.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  void _showDesayunoDetails(BuildContext context, Desayuno desayuno) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: desayuno.imagenUrl != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(desayuno.imagenUrl!),
                        )
                      : const Icon(Icons.breakfast_dining, size: 80),
                ),
                const SizedBox(height: 20),
                Text(
                  desayuno.titulo,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingredientes:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(desayuno.ingredientes),
                const SizedBox(height: 10),
                const Text(
                  'Preparación:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(desayuno.preparacion),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  void _showOpciones(BuildContext context, Desayuno desayuno) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarDesayunoPage(
                        desayuno: desayuno,
                        desayunos: desayunos,
                        onChanged: (newDesayuno) {
                          setState(() {
                            int index = desayunos.indexOf(desayuno);
                            desayunos[index] = newDesayuno;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar'),
                onTap: () async {
                  await _deleteDesayunoFromFirestore(desayuno);
                  setState(() {
                    desayunos.remove(desayuno);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteDesayunoFromFirestore(Desayuno desayuno) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('desayunos')
        .where('titulo', isEqualTo: desayuno.titulo)
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    if (desayuno.imagenUrl != null) {
      await _deleteImageFromStorage(desayuno.titulo);
    }
  }

  Future<void> _deleteImageFromStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('desayunos/$titulo.jpg');
      await storageRef.delete();
    } catch (e) {
      print('Error al eliminar la imagen: $e');
    }
  }
}

class EditarDesayunoPage extends StatefulWidget {
  final Desayuno desayuno;
  final List<Desayuno> desayunos;
  final Function(Desayuno) onChanged;

  EditarDesayunoPage({required this.desayuno, required this.desayunos, required this.onChanged});

  @override
  _EditarDesayunoPageState createState() => _EditarDesayunoPageState();
}

class _EditarDesayunoPageState extends State<EditarDesayunoPage> {
  final formkey = GlobalKey<FormState>();
  final tituloControlador = TextEditingController();
  final ingredientesControlador = TextEditingController();
  final preparacionControlador = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    tituloControlador.text = widget.desayuno.titulo;
    ingredientesControlador.text = widget.desayuno.ingredientes;
    preparacionControlador.text = widget.desayuno.preparacion;
    _image = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Desayuno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Form(
          key: formkey,
          child: ListView(
            children: [
              TextFormField(
                controller: tituloControlador,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Agregue título";
                  }
                  if (widget.desayunos.any((desayuno) =>
                      desayuno.titulo.toLowerCase() == value.toLowerCase() && desayuno != widget.desayuno)) {
                    return "Ya existe un desayuno con este título";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Título de la receta',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: ingredientesControlador,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Agregue los ingredientes";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Ingredientes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color.fromARGB(0, 142, 142, 160)),
                  ),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: preparacionControlador,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Campo obligatorio";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Preparación',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color.fromARGB(0, 142, 142, 160)),
                  ),
                ),
                maxLines: 10,
                maxLength: 3000,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  setState(() {
                    if (image != null) {
                      _image = File(image.path);
                    } else {
                      _image = null;
                    }
                  });
                },
                child: const Text('Seleccionar imagen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formkey.currentState!.validate()) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    Desayuno updatedDesayuno = Desayuno(
                      titulo: tituloControlador.text,
                      ingredientes: ingredientesControlador.text,
                      preparacion: preparacionControlador.text,
                      imagen: _image,
                      imagenUrl: widget.desayuno.imagenUrl, // Keep the existing URL if no new image
                      userId: user.uid,
                    );
                    if (_image != null) {
                      updatedDesayuno.imagenUrl = await _uploadImageToStorage(updatedDesayuno.titulo);
                    }
                    await _updateDesayunoInFirestore(updatedDesayuno);
                    widget.onChanged(updatedDesayuno);
                    Navigator.pop(context);
                  } else {
                    print('Por favor, complete todos los campos');
                  }
                },
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateDesayunoInFirestore(Desayuno desayuno) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('desayunos')
        .where('titulo', isEqualTo: desayuno.titulo)
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.update({
          'titulo': desayuno.titulo,
          'ingredientes': desayuno.ingredientes,
          'preparacion': desayuno.preparacion,
          'imagenUrl': desayuno.imagenUrl,
        });
      }
    });
  }

  Future<String?> _uploadImageToStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('desayunos/$titulo.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }
}

class Desayuno {
  String titulo;
  String ingredientes;
  String preparacion;
  String? imagenUrl;
  File? imagen;
  String userId; // Added userId to keep track of the owner

  Desayuno({required this.titulo, required this.ingredientes, required this.preparacion, this.imagen, this.imagenUrl, required this.userId});
}


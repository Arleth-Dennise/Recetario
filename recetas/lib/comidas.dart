import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComidasPage extends StatefulWidget {
  const ComidasPage({super.key});

  @override
  _ComidasPageState createState() => _ComidasPageState();
}

class _ComidasPageState extends State<ComidasPage> {
  final List<Comida> comidas = [];
  final formkey = GlobalKey<FormState>();
  final tituloControlador = TextEditingController();
  final ingredientesControlador = TextEditingController();
  final preparacionControlador = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadComidasFromFirestore();
  }

  Future<void> _loadComidasFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('comidas')
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        comidas.clear();
        for (var doc in querySnapshot.docs) {
          comidas.add(Comida(
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
        title: const Text('Comidas'),
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: comidas.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showComidaDetails(context, comidas[index]);
            },
            onLongPress: () {
              _showOpciones(context, comidas[index]);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  comidas[index].imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            comidas[index].imagenUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : const Icon(Icons.fastfood, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    comidas[index].titulo,
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
        child: Image.asset('assets/images/menuverde.png', width: 50, height: 50),
      ),
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
                title: const Text('Agregar Comida'),
                onTap: () {
                  _agregarComida(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _agregarComida(BuildContext context) {
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
                        if (comidas.any((comida) => comida.titulo.toLowerCase() == value.toLowerCase())) {
                          return "Ya existe una comida con este título";
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

                          Comida newComida = Comida(
                            titulo: tituloControlador.text,
                            ingredientes: ingredientesControlador.text,
                            preparacion: preparacionControlador.text,
                            imagen: _image,
                            userId: user.uid,
                          );
                          await _saveComidaToFirestore(newComida);
                          setState(() {
                            comidas.add(newComida);
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

  Future<void> _saveComidaToFirestore(Comida comida) async {
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImageToStorage(comida.titulo);
    }

    await FirebaseFirestore.instance.collection('comidas').add({
      'titulo': comida.titulo,
      'ingredientes': comida.ingredientes,
      'preparacion': comida.preparacion,
      'imagenUrl': imageUrl,
      'userId': comida.userId,
    });
  }

  Future<String?> _uploadImageToStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('comidas/$titulo.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  void _showComidaDetails(BuildContext context, Comida comida) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: comida.imagenUrl != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(comida.imagenUrl!),
                        )
                      : const Icon( Icons.fastfood, size: 80),
                ),
                const SizedBox(height: 20),
                Text(
                  comida.titulo,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingredientes:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(comida.ingredientes),
                const SizedBox(height: 10),
                const Text(
                  'Preparación:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(comida.preparacion),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOpciones(BuildContext context, Comida comida) {
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
                      builder: (context) => EditarComidaPage(
                        comida: comida,
                        comidas: comidas,
                        onChanged: (newComida) {
                          setState(() {
                            int index = comidas.indexOf(comida);
                            comidas[index] = newComida;
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
                  await _deleteComidaFromFirestore(comida);
                  setState(() {
                    comidas.remove(comida);
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

  Future<void> _deleteComidaFromFirestore(Comida comida) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('comidas')
        .where('titulo', isEqualTo: comida.titulo)
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    if (comida.imagenUrl != null) {
      await _deleteImageFromStorage(comida.titulo);
    }
  }

  Future<void> _deleteImageFromStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('comidas/$titulo.jpg');
      await storageRef.delete();
    } catch (e) {
      print('Error al eliminar la imagen: $e');
    }
  }
}

class EditarComidaPage extends StatefulWidget {
  final Comida comida;
  final List<Comida> comidas;
  final Function(Comida) onChanged;

  EditarComidaPage({required this.comida, required this.comidas, required this.onChanged});

  @override
  _EditarComidaPageState createState() => _EditarComidaPageState();
}

class _EditarComidaPageState extends State<EditarComidaPage> {
  final formkey = GlobalKey<FormState>();
  final tituloControlador = TextEditingController();
  final ingredientesControlador = TextEditingController();
  final preparacionControlador = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    tituloControlador.text = widget.comida.titulo;
    ingredientesControlador.text = widget.comida.ingredientes;
    preparacionControlador.text = widget.comida.preparacion;
    _image = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Comida'),
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
                  if (widget.comidas.any((comida) =>
                      comida.titulo.toLowerCase() == value.toLowerCase() && comida != widget.comida)) {
                    return "Ya existe una comida con este título";
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

                    Comida updatedComida = Comida(
                      titulo: tituloControlador.text,
                      ingredientes: ingredientesControlador.text,
                      preparacion: preparacionControlador.text,
                      imagen: _image,
                      imagenUrl: widget.comida.imagenUrl, // Keep the existing URL if no new image
                      userId: user.uid,
                    );
                    if (_image != null) {
                      updatedComida.imagenUrl = await _uploadImageToStorage(updatedComida.titulo);
                    }
                    await _updateComidaInFirestore(updatedComida);
                    widget.onChanged(updatedComida);
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

  Future<void> _updateComidaInFirestore(Comida comida) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('comidas')
        .where('titulo', isEqualTo: comida.titulo)
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.update({
          'titulo': comida.titulo,
          'ingredientes': comida.ingredientes,
          'preparacion': comida.preparacion,
          'imagenUrl': comida.imagenUrl,
        });
      }
    });
  }

  Future<String?> _uploadImageToStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('comidas/$titulo.jpg');
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

class Comida {
  String titulo;
  String ingredientes;
  String preparacion;
  String? imagenUrl;
  File? imagen;
  String userId; // Added userId to keep track of the owner

  Comida({required this.titulo, required this.ingredientes, required this.preparacion, this.imagen, this.imagenUrl, required this.userId});
}


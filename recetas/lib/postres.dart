import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostresPage extends StatefulWidget {
  const PostresPage({super.key});

  @override
  _PostresPageState createState() => _PostresPageState();
}

class _PostresPageState extends State<PostresPage> {
  final List<Postre> postres = [];
  final formkey = GlobalKey<FormState>();
  final tituloControlador = TextEditingController();
  final ingredientesControlador = TextEditingController();
  final preparacionControlador = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadPostresFromFirestore();
  }

  Future<void> _loadPostresFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('postres')
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        postres.clear();
        for (var doc in querySnapshot.docs) {
          postres.add(Postre(
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
        title: const Text('Postres'),
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: postres.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showPostreDetails(context, postres[index]);
            },
            onLongPress: () {
              _showOpciones(context, postres[index]);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  postres[index].imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            postres[index].imagenUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : const Icon(Icons.cake, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    postres[index].titulo,
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
        child: Image.asset('assets/images/menurosa.png', width: 50, height: 50),
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
                title: const Text('Agregar Postre'),
                onTap: () {
                  _agregarPostre(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _agregarPostre(BuildContext context) {
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
                        if (postres.any((postre) => postre.titulo.toLowerCase() == value.toLowerCase())) {
                          return "Ya existe un postre con este título";
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

                          Postre newPostre = Postre(
                            titulo: tituloControlador.text,
                            ingredientes: ingredientesControlador.text,
                            preparacion: preparacionControlador.text,
                            imagen: _image,
                            userId: user.uid,
                          );
                          await _savePostreToFirestore(newPostre);
                          setState(() {
                            postres.add(newPostre);
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

  Future<void> _savePostreToFirestore(Postre postre) async {
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImageToStorage(postre.titulo);
    }

    await FirebaseFirestore.instance.collection('postres').add({
      'titulo': postre.titulo,
      'ingredientes': postre.ingredientes,
      'preparacion': postre.preparacion,
      'imagenUrl': imageUrl,
      'userId': postre.userId,
    });
  }

  Future<String?> _uploadImageToStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('postres/$titulo.jpg');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  void _showPostreDetails(BuildContext context, Postre postre) {
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
                  child: postre.imagenUrl != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(postre.imagenUrl!),
                        )
                      : const Icon(Icons.cake, size: 80),
                ),
                const SizedBox(height: 20),
                Text(
                  postre.titulo,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingredientes:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(postre.ingredientes),
                const SizedBox(height: 10),
                const Text(
                  'Preparación:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(postre.preparacion),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOpciones(BuildContext context, Postre postre) {
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
                      builder: (context) => EditarPostrePage(
                        postre: postre,
                        postres: postres,
                        onChanged: (newPostre) {
                          setState(() {
                            int index = postres.indexOf(postre);
                            postres[index] = newPostre;
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
                  await _deletePostreFromFirestore(postre);
                  setState(() {
                    postres.remove(postre);
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

  Future<void> _deletePostreFromFirestore(Postre postre) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('postres')
        .where('titulo', isEqualTo: postre.titulo)
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    if (postre.imagenUrl != null) {
      await _deleteImageFromStorage(postre.titulo);
    }
  }

  Future<void> _deleteImageFromStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('postres/$titulo.jpg');
      await storageRef.delete();
    } catch (e) {
      print('Error al eliminar la imagen: $e');
    }
  }
}

class EditarPostrePage extends StatefulWidget {
  final Postre postre;
  final List<Postre> postres;
  final Function(Postre) onChanged;

  EditarPostrePage({required this.postre, required this.postres, required this.onChanged});

  @override
  _EditarPostrePageState createState() => _EditarPostrePageState();
}

class _EditarPostrePageState extends State<EditarPostrePage> {
  final formkey = GlobalKey<FormState>();
  final tituloControlador = TextEditingController();
  final ingredientesControlador = TextEditingController();
  final preparacionControlador = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    tituloControlador.text = widget.postre.titulo;
    ingredientesControlador.text = widget.postre.ingredientes;
    preparacionControlador.text = widget.postre.preparacion;
    _image = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Postre'),
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
                  if (widget.postres.any((postre) =>
                      postre.titulo.toLowerCase() == value.toLowerCase() && postre != widget.postre)) {
                    return "Ya existe un postre con este título";
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

                    Postre updatedPostre = Postre(
                      titulo: tituloControlador.text,
                      ingredientes: ingredientesControlador.text,
                      preparacion: preparacionControlador.text,
                      imagen: _image,
                      imagenUrl: widget.postre.imagenUrl, // Keep the existing URL if no new image
                      userId: user.uid,
                    );
                    if (_image != null) {
                      updatedPostre.imagenUrl = await _uploadImageToStorage(updatedPostre.titulo);
                    }
                    await _updatePostreInFirestore(updatedPostre);
                    widget.onChanged(updatedPostre);
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

  Future<void> _updatePostreInFirestore(Postre postre) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('postres')
        .where('titulo', isEqualTo: postre.titulo)
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.update({
          'titulo': postre.titulo,
          'ingredientes': postre.ingredientes,
          'preparacion': postre.preparacion,
          'imagenUrl': postre.imagenUrl,
        });
      }
    });
  }

  Future<String?> _uploadImageToStorage(String titulo) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('postres/$titulo.jpg');
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

class Postre {
  String titulo;
  String ingredientes;
  String preparacion;
  String? imagenUrl;
  File? imagen;
  String userId; // Added userId to keep track of the owner

  Postre({required this.titulo, required this.ingredientes, required this.preparacion, this.imagen, this.imagenUrl, required this.userId});
}


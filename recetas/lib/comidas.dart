import 'package:flutter/material.dart';

class ComidasPage extends StatefulWidget {
  @override
  _ComidasPageState createState() => _ComidasPageState();
}

class _ComidasPageState extends State<ComidasPage> {


final List<Comida> comidas=[];

final formkey = GlobalKey<FormState>();
final tituloControlador= TextEditingController();
final ingredientesControlador= TextEditingController();
final preparacionControlador= TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Comidas'),
        automaticallyImplyLeading: false,
      ),
      body:
    ListView.builder(
        itemCount: comidas.length,
        itemBuilder: (context, index) {
           return Card(
                  child: ListTile(
                    title: Text(comidas[index].titulo),
                    subtitle: Text(comidas[index].ingredientes),
                    trailing: Text(comidas[index].preparacion),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMenu(context);
        },
        child: Image.asset('assets/images/menuverde.png',width: 50, height: 50),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                title: const Text('Agregar Comida'),
                onTap: () {
                  _agregarcomida(context);
              
                },
              ),
              ListTile(
                title: const Text('Editar Comida'),
                onTap: () {
                  Navigator.pop(context);
                  
                },
              ),
              ListTile(
                title: const Text('Eliminar Comida'),
                onTap: () {
                  Navigator.pop(context);
                
                },
              ),
            ],
          ),
        );
      },
    );
  }

  
void _agregarcomida(BuildContext context) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          
          child: Container(
            padding:const EdgeInsets.all(50),
            child: SizedBox(
              height: 500,
              child:Form(
                key: formkey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: tituloControlador,
                      validator: (value){
                if (value!.isEmpty){
                
                  return "Agregue titulo";
                }
                if (comidas.any((desayuno) => desayuno.titulo.toLowerCase() == value.toLowerCase())) {
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
                      validator: (value){
                if (value!.isEmpty){
                
                  return "Agregue los ingredientes";
                }
                return null;
                
                        },
                      decoration: const InputDecoration(
                        labelText: 'Ingredientes',
                        border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color:Color.fromARGB(0, 142, 142, 160) )),
                      ),
                      maxLines: 5, 
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                
                       controller: preparacionControlador,
                      validator: (value){
                if (value!.isEmpty){
                
                  return "Campo obligatorio";
                }
                return null;
                
                        },
                      decoration: const InputDecoration(
                        labelText: 'Preparación',
                        border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color:Color.fromARGB(0, 142, 142, 160) )),
                      ),
                      maxLines: 10,
                      maxLength: 3000,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          setState(() {
                             comidas.add(Comida(
                            titulo: tituloControlador.text,
                            ingredientes: ingredientesControlador.text,
                            preparacion: preparacionControlador.text,
                          ));
                          tituloControlador.clear();
                          ingredientesControlador.clear();
                          preparacionControlador.clear();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          });
                         
                        }
                        else {
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

}
class Comida {
  String titulo;
  String ingredientes;
  String preparacion;

  Comida({required this.titulo, required this.ingredientes, required this.preparacion});

   @override
  String toString() {
    return 'Título: $titulo\nIngredientes: $ingredientes\nPreparación: $preparacion';
  }
}
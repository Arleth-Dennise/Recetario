import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recetas/comidas.dart';
import 'package:recetas/configuracion.dart';
import 'package:recetas/desayunos.dart';
import 'package:recetas/favoritos.dart';
import 'package:recetas/firebase_options.dart';
import 'package:recetas/inicio_sesion.dart';
import 'package:recetas/pagina_principal.dart';
import 'package:recetas/postres.dart';
import 'package:recetas/registro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final user = FirebaseAuth.instance.currentUser;
  Widget _initialRoute;
  if (user!= null) {
    _initialRoute = HomePage();
  } else {
    _initialRoute = LoginPage();
  }

  runApp(MyApp(_initialRoute));
}

class MyApp extends StatelessWidget {
  final Widget _initialRoute;

  MyApp(this._initialRoute);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas',
      debugShowCheckedModeBanner: false,
      home: _initialRoute,
      routes: {
        '/inicio': (context) => HomePage(),
        '/inicio_sesion': (context) => LoginPage(),
        '/registro': (context) => RegistroPage(),
        '/favoritos': (context) => FavoritosPage(),
        '/configuracion': (context) => ConfiguracionPage(),
        '/desayunos': (context) => DesayunosPage(),
        '/comidas': (context) => ComidasPage(),
        '/postres': (context) => PostresPage(),
      },
    );
  }
}
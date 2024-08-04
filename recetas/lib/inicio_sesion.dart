import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color.fromARGB(255, 120, 120, 120),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 241, 246),
      //appBar: AppBar(
        //title: const Text('Iniciar sesión'),
        //backgroundColor: Color.fromARGB(255, 246, 245, 240),
        //foregroundColor: Color.fromARGB(255, 97, 22, 108),
      //),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 50),
                Image.asset('assets/images/imagen1.png', height: 200),
                SizedBox(height: 50),
                _CustomTextFormField(
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  labelText: 'Correo',
                  validator: (value) {
                    if (value!.isEmpty ||!value.contains('@')) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                _CustomTextFormField(
                  controller: _passwordController,
                  prefixIcon: null,
                  suffixIcon: _obscureText? Icons.visibility_off : Icons.visibility,
                  labelText: 'Contraseña',
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureText =!_obscureText;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            )
                        .then((value) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/inicio',
                            arguments: _emailController.text,
                          );
                        });
                      } on FirebaseAuthException catch (e) {
                              if (e.code.contains('invalid-credential')) {
                                  _showSnackBar('Las credenciales proporcionadas no son válidas');
                            } else if (e.code.contains('too-many-requests')) {
                                  _showSnackBar('Demasiadas solicitudes. Inténtelo de nuevo más tarde');
                            } else if (e.code.contains('user-not-found')) {
                                  _showSnackBar('No se encontró un usuario con esas credenciales. Regístrese primero');
                            } else {
                                  _showSnackBar('Error desconocido: ${e.code}');
                            }
                        }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 39, 34, 2),
                    backgroundColor: Color.fromARGB(255, 255, 137, 180),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Iniciar sesión'),
                ),
                // Text(_errorMessage?? '', style: TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registro');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 59, 56, 10),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('¿No tienes una cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String labelText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final VoidCallback? onSuffixIconPressed;

  _CustomTextFormField({
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onSuffixIconPressed,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<_CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
            decoration: InputDecoration(
        prefixIcon: widget.prefixIcon!= null
         ? Icon(widget.prefixIcon, size: 20)
          : null,
        suffixIcon: widget.suffixIcon!= null
         ? IconButton(
              icon: Icon(widget.suffixIcon, size: 20),
              onPressed: widget.onSuffixIconPressed,
            )
          : null,
        labelText: widget.labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      obscureText: widget.obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
    );
  }
}
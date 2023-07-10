import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/firebase_auth_service.dart';
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_sharp),
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "¡Hola! Regístrate para comenzar",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomizedTextfield(
              myController: _usernameController,
              hintText: "Nombre de usuario",
              isPassword: false,
            ),
            CustomizedTextfield(
              myController: _emailController,
              hintText: "Correo electrónico",
              isPassword: false,
            ),
            CustomizedTextfield(
              myController: _passwordController,
              hintText: "Contraseña",
              isPassword: true,
            ),
            CustomizedButton(
              buttonText: "Registrar",
              buttonColor: Colors.blue,
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await authService.signup(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _usernameController.text.trim(),
                  );

                  // Obtener el usuario actualmente autenticado
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    String userId = user.uid;

                    // Obtener la referencia a la ubicación en la base de datos en tiempo real de Firebase
                    DatabaseReference usuariosRef =
                        FirebaseDatabase.instance.reference().child('usuarios');

                    // Crear un nuevo nodo con el ID del usuario como clave
                    DatabaseReference newUsuarioRef = usuariosRef.child(userId);

                    // Guardar los datos en el nodo correspondiente
                    await newUsuarioRef.set({
                      'api':
                          'https://xw2v9yt588.execute-api.us-east-1.amazonaws.com/users/$userId',
                      'email': _emailController.text.trim(),
                      'id': userId,
                      'username': _usernameController.text.trim(),
                    });

                    // Mostrar mensaje de éxito
                    print('El usuario se registró correctamente');

                    // Consultar los datos registrados
                    usuariosRef.once().then((DatabaseEvent snapshot) {
                      DataSnapshot data = snapshot.snapshot;
                      if (data.value != null) {
                        Map<dynamic, dynamic>? usuarios =
                            data.value as Map<dynamic, dynamic>?;
                        if (usuarios != null) {
                          usuarios.forEach((key, value) {
                            print('ID: $key');
                            print('API: ${value['api']}');
                            print('Email: ${value['email']}');
                            print('ID: ${value['id']}');
                            print('Username: ${value['username']}');
                            print('---');
                          });
                        }
                      }
                    });
                  } else {
                    // No se pudo obtener el objeto de usuario
                    print('No se pudo obtener el objeto de usuario');
                  }
                } on FirebaseAuthException catch (e) {
                  // Error al crear el usuario en Firebase
                  print('Error al crear el usuario en Firebase: ${e.message}');
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.height * 0.15,
                    color: Colors.grey,
                  ),
                  const Text("Or Register with"),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.height * 0.16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.facebookF,
                        color: Colors.blue,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.google,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.apple,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 8, 8, 8.0),
              child: Row(
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Color(0xff1E232C),
                      fontSize: 15,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "  Login Now",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

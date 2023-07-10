import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  String generateResetCode() {
    // Aquí puedes implementar tu propia lógica para generar el código de restablecimiento
    // Puede ser un código aleatorio, un código basado en el correo electrónico del usuario u otro criterio específico

    // Por ejemplo, generaremos un código aleatorio de 6 dígitos
    final random = Random();
    final code = random.nextInt(999999).toString().padLeft(6, '0');

    return code;
  }

  void _sendPasswordResetEmail() async {
    final smtpServer = gmail('tu_correo_electronico', 'tu_contraseña');
    final resetCode = generateResetCode();

    final message = Message()
      ..from = Address('tu_correo_electronico', 'Tu Nombre')
      ..recipients.add(_emailController.text.trim())
      ..subject = 'Restablecer contraseña'
      ..html =
          '<p>Hola,</p>\n<p>Has solicitado restablecer tu contraseña.</p>\n<p>Haz clic en el siguiente enlace para cambiar tu contraseña:</p>\n<p><a href="https://www.tuaplicacion.com/reset?code=$resetCode">Restablecer Contraseña</a></p>';

    try {
      final sendReport = await send(message, smtpServer);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Correo de restablecimiento enviado"),
          content: const Text(
            "Se ha enviado un correo a tu dirección de correo electrónico para restablecer tu contraseña.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error al enviar el correo"),
          content: const Text(
            "Ha ocurrido un error al enviar el correo de restablecimiento. Por favor, inténtalo nuevamente.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_sharp),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "No te preocupes, a todos nos pasa. Te enviaremos un enlace para restablecer tu contraseña.",
                  style: TextStyle(
                    color: Color(0xff8391A1),
                    fontSize: 20,
                  ),
                ),
              ),
              CustomizedTextfield(
                myController: _emailController,
                hintText: "Ingresa tu correo electrónico",
                isPassword: false,
              ),
              CustomizedButton(
                buttonText: "Enviar Código",
                buttonColor: Colors.blue, // Color azul personalizado
                textColor: Colors.white,
                onPressed: _sendPasswordResetEmail,
              ),
              const Spacer(
                flex: 1,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(68, 8, 8, 8.0),
                child: Row(
                  children: [
                    const Text(
                      "¿Recuerdas tu contraseña?",
                      style: TextStyle(
                        color: Color(0xff1E232C),
                        fontSize: 15,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Text(
                        "  Iniciar Sesión",
                        style: TextStyle(
                          color: Color(0xff35C2C1),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

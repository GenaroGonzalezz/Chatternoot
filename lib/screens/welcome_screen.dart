import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/src/animation/curves.dart';
import 'package:flash_chat/Components/rounded_button.dart';


class WelcomeScreen extends StatefulWidget {
  static String id = 'Welcome Screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{
  AnimationController controller; //Controla animaciones
  //Animation animation;
  @override
  void initState() {
    super.initState(); //Inicializador
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
      upperBound: 100.0,
    );
    //animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.forward();
    // controller.addListener(() {
    //   setState(() { //Permite que la pantalla cambie al ser un stateful widget
    //     print(controller.value);
    //     print(animation.value);
    //   });
    // });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,//.withOpacity(controller.value),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/pinguino.png'),
                    height: 120//controller.value,

                  ),
                ),
                Text(
                  'Chatternoot',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,

                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: 'Iniciar Sesión', colour: Colors.lightBlueAccent, onPressed: (){
              Navigator.pushNamed(context, LoginScreen.id);
            },),
            RoundedButton(title: 'Registrar', colour: Colors.blueAccent, onPressed: (){
              Navigator.pushNamed(context, RegistrationScreen.id);
            },),
          ],
        ),
      ),
    );
  }
}


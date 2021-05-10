import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'about_us.dart';
import 'home.dart';
import 'welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'configuracion.dart';


class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;
User loggedInUser = FirebaseAuth.instance.currentUser;
//User loggedInUser;
String messageText;
final fieldText = TextEditingController();


class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{ //Verifica si hay un usuario que haya iniciado sesion
    try{
      loggedInUser = _auth.currentUser;
      final user = await _auth.currentUser;
    if (loggedInUser.emailVerified != null){
      //await currentUser.sendEmailVerification();
      loggedInUser = user;
      //print(currentUser.email);
    }
    else {
      // currentUser = user;
      // print(currentUser.email);
    }
    }
    catch(e){
      print(e);
    }
  }

  //Metodo para obtener mensajes del cloud firestore
  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs){
  //     print(message.data());
  //   }
  // }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data().cast());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
             title: Text('ChatterNoot!'),
        //     backgroundColor: Colors.black
        // ),
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.update),
              onPressed: () {
                //Implement logout functionality
                //_auth.signOut();
                //Navigator.pop(context);
                messagesStream();
              }),
        ],
        //title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController, //Controla el texto del campo
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     messageTextController.clear();
                  //     _firestore.collection('messages').add({
                  //       'text': messageText,
                  //       'sender': loggedInUser.email,
                  //     });
                  //     //Implement send functionality.
                  //   },
                  //   child: Text(
                  //     'Send',
                  //     style: kSendButtonTextStyle,
                  //   ),
                  // ),
                  IconButton(icon: Icon(Icons.double_arrow_sharp, semanticLabel: 'Enviar', size: 40, color: Colors.lightBlue,),
                      padding: EdgeInsets.only(bottom: 20, top: 5, right: 35),
                      onPressed: (){
                    messageTextController.clear();
                    _firestore.collection('messages').add({
                      'text': messageText,
                      'sender': loggedInUser.email,
                      'timestamp': FieldValue.serverTimestamp()
                    });
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  //const MessagesStream({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder <QuerySnapshot>( //Widget para desplegar un stream de datos
      stream: _firestore.collection('messages').orderBy('timestamp', descending: false).snapshots(), //Los datos seran la coleccion de mensajes en FS
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages){
          final messageText = message['text'];
          final messageSender = message['sender'];

          final currentUser = loggedInUser.email;

          if (currentUser == messageSender){

          }
          final messageBubble = MessageBubble(sender: messageSender, text: messageText, isMe: currentUser == messageSender);
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});
  //const MessageBubble({Key key}) : super(key: key);
final String sender;
final String text;
final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child:

           Column(
             mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
             children: <Widget>[
               Text(sender, style: TextStyle(color: Colors.grey, fontSize: 12.0), textAlign: TextAlign.right,),
               Row(
                 mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                 crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
           children: <Widget>[
             //Para que se vea a la izquierda el otro usuario
             if (!isMe) Material(
               elevation: 10.0,
               shape: CircleBorder(
                 side: BorderSide.none,
               ),
               child: Padding(
                 padding: EdgeInsets.only(left: 10, right: 9),
                 child: CircleAvatar(
                     backgroundColor: Colors.blueAccent,
                     child: Text(sender[0], style: TextStyle(color: Colors.white , fontSize: 18),)),
               ),
             ),
             //Mensaje
             Flexible(
               child: Material(
                 elevation: 10.0,
                 borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10), topRight: Radius.circular(-10))
                     : BorderRadius.only(topRight: Radius.circular(10.0), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                 color: isMe ? Colors.lightBlueAccent : Colors.white,
                 child: Padding(
                   padding: EdgeInsets.all(8.0),
                   child: Text(text,
                     style: TextStyle(
                       fontSize: 15.0,
                       color: isMe ? Colors.white : Colors.black,
                     ),
                   ),
                 ),
               ),
             ),

             //Para que se vea a la derecha el usuario actual
             if (isMe) Material(
               elevation: 10.0,
               shape: CircleBorder(
                 side: BorderSide.none,
               ),
               child: Padding(
                 padding: EdgeInsets.only(left: 10, right: 9),
                 child: CircleAvatar(
                   backgroundColor: Colors.blueAccent,
                     child: Text(sender[0], style: TextStyle(color: Colors.white, fontSize: 18),)),
               ),
             ),

             ],
           ),

        //Text(sender, style: TextStyle(color: Colors.grey, fontSize: 12.0), textAlign: TextAlign.right,),
                 ],
               ),
    );
  }
}





//
// mixin FirebaseUser {
// }
class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(

            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                      image:
                      const DecorationImage(
                          image:
                         //CircleAvatar(child: Text(loggedInUser.email[0]),
                        NetworkImage('https://2.bp.blogspot.com/-J5dtIRU_dqo/WZqgWuk5r3I/AAAAAAAAAAY/9CCoDfgsfyEPfAJURbzewU5wAiEZ3mIgQCLcBGAs/s1600/Pingu%25CC%2588ino2.jpg'
                           ),
                          fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.green, spreadRadius: 4),
                      ],
                    ),
                    height: 50,
                    width: 50,
                  ),
                   Text(
                    loggedInUser.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => {Navigator.pushNamed(context, Home.id)},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuración'),
            onTap: () => {
              Navigator.pushNamed(context, Configuracion.id)
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Acerca de Nosotros'),
            onTap: () => {Navigator.pushNamed(context, Acerca.id)},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () =>
            {
              _auth.signOut(),
              Navigator.pushNamed(context, WelcomeScreen.id)
            }
          ),
        ],
      ),
    );
  }
}

void clearText() {
  fieldText.clear();
}


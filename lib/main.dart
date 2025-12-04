import 'package:flutter/material.dart';
import 'widgets/custom_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini card de visite',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 194, 78, 188),
        ),
      ),
      home: const MyHomePage(title: 'Mon carte de visite flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

///fonction incrementation
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///scaffold c'est le corps de l'app
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            //pour forcer le container d'etre au centre
            Container(
              width: 400, // largeur désirée
              height: 220, // hauteur désirée
              ///delimitations de 10 sur les element
              padding: const EdgeInsets.all(
                10,
              ), // padding interne autour du CustomCard

              child: CustomCard(
                titre: "Khady Mbacke",
                sousTitre: "Etudainte en genie logiciel",
                mail: "Mail:khadijambck@gmail.com",
                repogitub: "Telephone:764038634",
                titreStyle: TextStyle(
                  color: Colors.white,
                  //style gras
                  fontWeight: FontWeight.bold,
                  //stle d'ecriture
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                ),
                sousTitreStyle: const TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.normal,
                ),
                mailStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                repogithub: TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                imagePath: 'assets/logo.png',

                couleur: const Color.fromARGB(255, 5, 5, 50),
              ),
            ),

            //pour aligner verticalement
          ],
        ),
      ),

      ////boutton
    );
  }
}

import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String titre;
  final String sousTitre;
  final String mail;
  final String repogitub;
  final TextStyle? titreStyle;
  final TextStyle? sousTitreStyle;
  final TextStyle? mailStyle;
  final TextStyle? repogithub;

  final String? imagePath;
  final Color couleur;
  //////////////
  const CustomCard({
    super.key,
    required this.titre,
    required this.sousTitre,
    required this.mail,
    required this.repogitub,
    this.titreStyle,
    this.sousTitreStyle,
    this.mailStyle,
    this.repogithub,
    this.imagePath,

    //DEFINIR UN COULEUR
    this.couleur = const Color.fromARGB(255, 247, 248, 250),
  });

  @override
  //flutter lit la methode build pour savoir ce qui sera afficher sur l'ecran
  Widget build(BuildContext context) {
    return Card(
      color: couleur,

      ///widget pratique pour minicarte liste
      child: ListTile(
        //leading widget a gauche
        leading: imagePath != null
            //une fonction ternaire
            ? Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(right: 0),

                ///clipRReect porn arrondir les coins de l'images
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(0),
                  child: Image.asset(imagePath!, fit: BoxFit.cover),
                ),
              )
            : null,
        title: Text(titre, style: titreStyle),
        //subtitle: Text(sousTitre, style: sousTitreStyle),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // tout commence à gauche
          mainAxisSize: MainAxisSize.min,
          children: [
            // TON SOUS-TITRE EXACT, ON LE GARDE
            Text(sousTitre, style: sousTitreStyle),

            ///esace entre le soustitre et le mail
            const SizedBox(height: 20),

            // MAIL
            Text(mail, style: mailStyle, softWrap: false),
            const SizedBox(height: 10),
            // REPO GITHUB / TÉLÉPHONE
            Text(repogitub, style: repogithub, softWrap: true),
            const SizedBox(height: 17),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ///snakbar message qui s'affiche au click de quelque chose
                  const snackdemo = SnackBar(
                    content: Text('ajouter avec succes'),
                    backgroundColor: Colors.green,
                    elevation: 5,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5),
                    //margin: EdgeInsets.all(5),
                    //le only on peut personaliser les cotee
                    margin: EdgeInsets.only(
                      top: 50,
                      left: 400,
                      right: 400,
                      bottom: 0,
                    ),
                  );

                  ///ScaffoldMessenger :gestionnaires des snackbar
                  ScaffoldMessenger.of(context).showSnackBar(snackdemo);
                },
                //print("Contacter moi cliqué !");
                //   child:
                //   const Text("Contacter moi");
                // },
                child: const Text("Contacter moi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

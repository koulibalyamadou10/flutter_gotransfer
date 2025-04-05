import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawerLayoute extends StatefulWidget {
  const DrawerLayoute({super.key});

  @override
  State<DrawerLayoute> createState() => _DrawerLayouteState();
}

class _DrawerLayouteState extends State<DrawerLayoute> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // En-tête utilisateur
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: const DecorationImage(
                image: AssetImage("assets/images/jpgs/koulibaly.jpg"),
                fit: BoxFit.cover,
                opacity: 0.3, // Légère transparence pour mieux voir le texte
              ),
            ),
            accountName: Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  "Koulibaly",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Roboto_Medium',
                  ),
                ),
              ],
            ),
            accountEmail: Row(
              children: [
                const Icon(Icons.email, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'koulibalyamadou10@gmail.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontFamily: 'Roboto_Medium',
                  ),
                ),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  "assets/images/jpgs/koulibaly.jpg",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            otherAccountsPictures: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.help_outline, color: Colors.white),
              ),
            ],
          ),
          // Accueil
          ListTile(
            leading: const Icon(CupertinoIcons.home, color: Color(0xFF4CAF50)), // Vert vif
            title: const Text(
              "DashBoard",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {
            },
          ),
          // Surveillance du champ
          ListTile(
            leading: const Icon(Icons.thermostat_outlined, color: Color(0xFF2196F3)), // Bleu moderne
            title: const Text(
              "Surveillance du champ",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {},
          ),
          // Contrôle de l'irrigation
          ListTile(
            leading: const Icon(Icons.water, color: Color(0xFF26A69A)), // Teal élégant
            title: const Text(
              "Contrôle de l'irrigation",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {},
          ),
          // Alertes et notifications
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Color(0xFFE91E63)), // Rose vif pour attirer l'attention
            title: const Text(
              "Alertes",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {},
          ),
          // Statistiques
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Color(0xFF9C27B0)), // Violet moderne
            title: const Text(
              "Statistiques d'utilisation",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {},
          ),
          const Divider(color: Colors.grey),
          // Documentation et support
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFFFF9800)), // Orange chaleureux
            title: const Text(
              "Documentation et supports",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {},
          ),
          // Profil utilisateur
          ListTile(
            leading: const Icon(CupertinoIcons.profile_circled, color: Color(0xFF4CAF50)), // Vert assorti au DashBoard
            title: const Text(
              "Profil",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {
            },
          ),
          const Divider(color: Colors.grey),
          // Paramètres
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF607D8B)), // Gris-bleu discret
            title: const Text(
              "Paramètres",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {},
          ),
          // Déconnexion
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFF44336)), // Rouge pour action importante
            title: const Text(
              "Se déconnecter",
              style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: "Roboto_Medium"),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
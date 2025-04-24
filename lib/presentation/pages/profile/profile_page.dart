import 'package:flutter/services.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/main.dart';
import 'package:gotransfer/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec photo de profil
            Stack(
              children: [
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  top: 60, // Ajusté pour compenser l'absence d'AppBar
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        // Photo de profil
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.onBackground,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/koulibaly.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Koulibaly Amadou',
                          style: TextStyle(
                            color: colorScheme.background,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Associé FlexyBank depuis 2022',
                          style: TextStyle(
                            color: colorScheme.background,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Section statistiques
            Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard('Transactions', '128', Icons.swap_horiz, context),
                  _buildStatCard('Transactions Effectuées', '4.2K CAD', Icons.savings, context),
                ],
              ),
            ),

            // Section options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    color: colorScheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildProfileOption(
                          icon: Icons.person_outline,
                          title: 'Informations personnelles',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.info),
                        ),
                        _buildProfileOption(
                          icon: Icons.credit_card,
                          title: 'Mes cartes bancaires',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.card),
                        ),
                        _buildProfileOption(
                          icon: Icons.lock_outline,
                          title: 'Sécurité et confidentialité',
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.notifications_none,
                          title: 'Notifications',
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.help_outline,
                          title: 'Centre d\'aide',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildProfileOption(
                          icon: Icons.brightness_4,
                          title: 'Thème de l\'application',
                          onTap: () => _showThemeSelector(context),
                        ),
                        _buildProfileOption(
                          icon: Icons.logout,
                          title: 'Déconnexion',
                          isLogout: true,
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Ajoutez cette méthode dans votre classe _ProfilePageState
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              UserRepository.setUserEmail('').then((onValue){
                UserRepository.setUserPasswordHashed('').then((onValue){
                  // Ferme toutes les pages et redirige vers le login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                        (route) => false,
                  );
                });
              });


              // Ici vous pouvez aussi ajouter la logique de nettoyage:
              // - Supprimer les données utilisateur
              // - Réinitialiser le state de l'application
              // - etc.
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choisir le thème',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 20),
            _buildThemeOption(
              context,
              icon: Icons.settings_suggest,
              title: 'Système',
              mode: ThemeMode.system,
            ),
            _buildThemeOption(
              context,
              icon: Icons.light_mode,
              title: 'Clair',
              mode: ThemeMode.light,
            ),
            _buildThemeOption(
              context,
              icon: Icons.dark_mode,
              title: 'Sombre',
              mode: ThemeMode.dark,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required ThemeMode mode,
      }) {
    final currentMode = Provider.of<ThemeNotifier>(context).themeMode;
    final isSelected = currentMode == mode;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: () {
        Provider.of<ThemeNotifier>(context, listen: false).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      BuildContext context,
      ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLogout ? Colors.red : colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout ? Colors.red : colorScheme.onBackground,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? Colors.red : colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/presentation/widgets/drawer/drawer_layout.dart';
import 'package:gotransfer/routes/app_routes.dart';

import '../../../data/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ColorScheme colorScheme;
  User user = User(
    first_name: '',
    last_name: '',
    email: '',
    phone_number: '',
    address: '',
    password: '',
    image: ''
  );

  @override
  void initState() {
    super.initState();
    UserRepository.getUser(context).then((onValue){
      if( onValue == null ) return;
      setState(() {
        user = onValue!;
        user.isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    colorScheme = theme.colorScheme;
    return Scaffold(
      drawer: DrawerLayoute(),
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec date et titre
                // Padding(
                //   padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                //   child: Row(
                //     children: [
                //       Text(
                //         "On fait quoi aujourd'hui ?",
                //         style: TextStyle(
                //           color: colorScheme.onBackground,
                //           fontSize: 16,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //       const Spacer(),
                //       Icon(
                //         Icons.notifications_outlined,
                //         color: colorScheme.primary,
                //         size: 24,
                //       ),
                //     ],
                //   ),
                // ),

                SizedBox(height: 20),

                // Titre Account
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          (user.image ?? '').isNotEmpty ?
                            ClipOval(
                              child: Image.network(
                                '${user.image}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover
                              )
                            ) :
                          Icon(
                            Icons.account_circle_outlined,
                            size: 50,
                          ),
                          SizedBox(width: 5),
                          Container(
                            width: 150,
                            height: 50,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 5,
                                  width: 150,
                                  height: 20,
                                  child: Text("${user.last_name} ${user.first_name}", style: TextStyle(fontSize: 16),),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 25,
                                  width: 150,
                                  height: 20,
                                  child: Text("Bienvenue à nouveau", style: TextStyle(fontSize: 14, color: colorScheme.primary),),
                                )
                              ],
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.notifications,
                            color: colorScheme.primary,
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Carte principale de compte premium
                      Container(
                        width: double.infinity,
                        height: 250, // Augmenté pour accommoder plus de contenu
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colorScheme.primary, colorScheme.secondary],
                          ),
                          borderRadius: BorderRadius.circular(16), // BorderRadius plus prononcé
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12, // Ombre plus diffuse
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(context, '/account-details');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ligne 1: Info utilisateur + Quick Actions
                                  Row(
                                    children: [
                                      // Avatar avec initiales
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            user.first_name.isEmpty ? '' :
                                            '${user.first_name[0].toUpperCase()}${user.last_name[0].toUpperCase()}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      // Nom utilisateur
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${user.last_name} ${user.first_name}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Compte Principal',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      // Bouton Quick Transfer
                                      IconButton(
                                        icon: Icon(Icons.send, color: Colors.white),
                                        onPressed: () {
                                          Navigator.pushNamed(context, AppRoutes.quick_transfer);
                                        },
                                        tooltip: 'Transfert rapide',
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20),

                                  // Ligne 2: Solde
                                  Text(
                                    'SOLDE DISPONIBLE',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        'GNF',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        !user.isLoaded ? '' :
                                        '${user.balance}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Ligne 3: Actions rapides
                                  SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildActionButton(Icons.qr_code, 'Scanner', () {
                                        Navigator.pushNamed(context, AppRoutes.qr_code);
                                      }),
                                      _buildActionButton(Icons.phone, 'Recharger', () {
                                        Navigator.pushNamed(context, AppRoutes.mobile_topup);
                                      }),
                                      _buildActionButton(Icons.history, 'Historique', () {
                                        Navigator.pushNamed(context, AppRoutes.historique);
                                      }),
                                      _buildActionButton(
                                        Icons.more_horiz,
                                        'Plus',
                                            () => _showMoreOptions(context), // Nouvelle fonction
                                        isMoreButton: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Cartes
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cards',
                        style: TextStyle(
                          color: colorScheme.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Voir tout',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des cartes
                _buildCardItem(
                  logo: 'assets/mastercard.png',
                  name: 'Tinkoff Gold',
                  cardType: 'Mastercard',
                  last4: '6789',
                  amount: '\$1,679.00',
                  textColor: colorScheme.onBackground,
                  secondaryTextColor: colorScheme.onBackground,
                  isCredit: true,
                ),

                Divider(height: 1, color: colorScheme.onBackground.withOpacity(0.1)),

                _buildCardItem(
                  logo: 'assets/visa.png',
                  name: 'Visa Platinum',
                  cardType: 'Visa',
                  last4: '6789',
                  amount: '\$2,246.00',
                  textColor: colorScheme.onBackground,
                  secondaryTextColor: colorScheme.onBackground,
                  isCredit: false,
                ),

                // Section Today
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aujourd\'hui',
                        style: TextStyle(
                          color: colorScheme.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Voir tout',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions du jour
                _buildTransactionItem(
                  avatarText: 'BS',
                  name: 'Bakhtyar Sattarov',
                  cardType: 'Sent',
                  paymentMethod: 'Mastercard',
                  last4: '6789',
                  amount: '-\$246.00',
                  textColor: colorScheme.onBackground,
                  secondaryTextColor: colorScheme.onBackground,
                  amountColor: Colors.red,
                ),

                Divider(height: 1, color: colorScheme.onBackground.withOpacity(0.1)),

                _buildTransactionItem(
                  avatarText: 'PC',
                  name: 'Polly Clark',
                  cardType: 'Received',
                  paymentMethod: 'Visa',
                  last4: '6789',
                  amount: '+\$975.00',
                  textColor: colorScheme.onBackground,
                  secondaryTextColor: colorScheme.onBackground,
                  amountColor: Colors.green,
                ),

                // Section Historique des Transactions
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historique',
                        style: TextStyle(
                          color: colorScheme.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tout voir',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des transactions historiques
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildHistoryItem(
                        icon: Icons.shopping_cart,
                        iconColor: Colors.blue,
                        title: 'Achat en ligne',
                        date: '28 Juillet, 2025',
                        amount: '-\$129.99',
                        textColor: colorScheme.onBackground,
                        secondaryTextColor: colorScheme.onBackground,
                        amountColor: Colors.red,
                      ),

                      Divider(height: 1, color: colorScheme.onBackground.withOpacity(0.1), indent: 16, endIndent: 16),

                      _buildHistoryItem(
                        icon: Icons.fastfood,
                        iconColor: Colors.orange,
                        title: 'Restaurant',
                        date: '27 Juillet, 2025',
                        amount: '-\$45.50',
                        textColor: colorScheme.onBackground,
                        secondaryTextColor: colorScheme.onBackground,
                        amountColor: Colors.red,
                      ),

                      Divider(height: 1, color: colorScheme.onBackground.withOpacity(0.1), indent: 16, endIndent: 16),

                      _buildHistoryItem(
                        icon: Icons.attach_money,
                        iconColor: Colors.green,
                        title: 'Salaire',
                        date: '25 Juillet, 2025',
                        amount: '+\$3,500.00',
                        textColor: colorScheme.onBackground,
                        secondaryTextColor: colorScheme.onBackground,
                        amountColor: Colors.green,
                      ),

                      Divider(height: 1, color: colorScheme.onBackground.withOpacity(0.1), indent: 16, endIndent: 16),

                      _buildHistoryItem(
                        icon: Icons.home,
                        iconColor: colorScheme.primary,
                        title: 'Loyer',
                        date: '20 Juillet, 2025',
                        amount: '-\$850.00',
                        textColor: colorScheme.onBackground,
                        secondaryTextColor: colorScheme.onBackground,
                        amountColor: Colors.red,
                      ),
                    ],
                  ),
                ),

                // Espace en bas pour éviter que le dernier élément soit coupé
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour afficher un élément de carte
  Widget _buildCardItem({
    required String logo,
    required String name,
    required String cardType,
    required String last4,
    required String amount,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isCredit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Logo de la carte (placeholder, à remplacer par une image réelle)
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: isCredit ? Colors.orange[700] : Colors.blue[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                isCredit ? 'MC' : 'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Informations de la carte
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$cardType • $last4',
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Montant
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher un élément de transaction
  Widget _buildTransactionItem({
    required String avatarText,
    required String name,
    required String cardType,
    required String paymentMethod,
    required String last4,
    required String amount,
    required Color textColor,
    required Color secondaryTextColor,
    required Color amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Avatar circulaire
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
            child: Center(
              child: Text(
                avatarText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Informations de la transaction
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$cardType • $paymentMethod • $last4',
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Montant
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.onBackground),
            title: Text('Paramètres'),
          ),
        ),
        PopupMenuItem(
          value: 'contacts',
          child: ListTile(
            leading: Icon(Icons.contacts, color: Theme.of(context).colorScheme.onBackground),
            title: Text('Mes contacts'),
          ),
        ),
        PopupMenuItem(
          value: 'beneficiaries',
          child: ListTile(
            leading: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.onBackground),
            title: Text('Bénéficiaires'),
          ),
        ),
        PopupMenuItem(
          value: 'cards',
          child: ListTile(
            leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.onBackground),
            title: Text('Cartes bancaires'),
          ),
        ),
        PopupMenuItem(
          value: 'support',
          child: ListTile(
            leading: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.onBackground),
            title: Text('Support client'),
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.secondary
    ).then((value) {
      if (value != null) {
        _handleMoreOptionSelection(value, context);
      }
    });
  }

  void _handleMoreOptionSelection(String value, BuildContext context) {
    switch (value) {
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'contacts':
        Navigator.pushNamed(context, '/contacts');
        break;
      case 'beneficiaries':
        Navigator.pushNamed(context, '/beneficiaries');
        break;
      case 'cards':
        Navigator.pushNamed(context, '/cards');
        break;
      case 'support':
        Navigator.pushNamed(context, '/support');
        break;
      case 'logout':
        _showLogoutConfirmation(context);
        break;
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter de votre compte ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Implémentez la logique de déconnexion
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Méthode helper pour créer les boutons d'action
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {bool isMoreButton = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
          // Si c'est le bouton "Plus", on ajoute un effet de scale
          style: isMoreButton ? IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ) : null,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Widget pour afficher un élément d'historique des transactions
  Widget _buildHistoryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    required String amount,
    required Color textColor,
    required Color secondaryTextColor,
    required Color amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 2.0),
      child: Row(
        children: [
          // Icône de catégorie
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Informations de la transaction
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Montant
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/presentation/widgets/drawer/drawer_layout.dart';
import 'package:gotransfer/routes/app_routes.dart';

import '../../../data/models/remittance_model.dart';
import '../../../data/models/user_model.dart';
import '../../../widgets/components/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ColorScheme colorScheme;
  bool _isLoading = true;
  User user = User(
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
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
        _isLoading = false;
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
        child: _isLoading ?
        _buildSkeletonLoader(context) :
        SingleChildScrollView(
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
                                  child: Text("${user.firstName}", style: TextStyle(fontSize: 16),),
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
                                            user.firstName.isEmpty ? '' :
                                            '${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}',
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
                                            '${user.firstName} ${user.lastName}',
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
                                        '${user.isLoaded ? user.currency : ''}',
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

                // Section Today
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: user.isLoaded
                      ? user.remittances_today.isEmpty
                      ? 1 // Pour le message vide
                      : user.remittances_today.length
                      : 1, // Pour le loading
                  itemBuilder: (context, index) {
                    if (!user.isLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (user.remittances_today.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Aucune transaction aujourd\'hui',
                          style: TextStyle(
                            color: colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      );
                    }

                    final remittance = user.remittances_today[index];
                    return Column(
                      children: [
                        _buildRemittanceItem(
                          remittance: remittance,
                          colorScheme: colorScheme,
                          context: context,
                        ),
                        if (index < user.remittances_today.length - 1)
                          Divider(
                            height: 1,
                            color: colorScheme.onBackground.withOpacity(0.1),
                          ),
                      ],
                    );
                  },
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
                        'voir tout',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions historiques


                // Liste des transactions historiques
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Utilisation dans votre UI
                      _buildHistoryList(user.remittances_last, colorScheme),
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
  Widget _buildRemittanceItem({
    required Remittance remittance,
    required ColorScheme colorScheme,
    required BuildContext context,
  }) {
    // Détermine les couleurs en fonction du statut
    final (textColor, amountColor, statusColor) = _getColorsForStatus(remittance.status, colorScheme);

    // Formatage des montants
    final amountSent = '${remittance.amountSent.toStringAsFixed(2)} ${remittance.senderCurrency}';
    final recipientAmount = '${remittance.recipientAmount.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar avec initiales
              _buildRemittanceAvatar(remittance, colorScheme),
              const SizedBox(width: 16),

              // Détails de la transaction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            remittance.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'De: User #${remittance.sender}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'À: Beneficiary #${remittance.role}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          remittance.cashoutLocation,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.payment_outlined, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          remittance.payoutOption,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Montants
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountSent,
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '→ $recipientAmount',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Frais: ${remittance.fees.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper pour l'avatar
  Widget _buildRemittanceAvatar(Remittance remittance, ColorScheme colorScheme) {
    final initials = remittance.transactionId.substring(0, 2).toUpperCase();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

// Helper pour les couleurs selon le statut
  (Color, Color, Color) _getColorsForStatus(String status, ColorScheme colorScheme) {
    return switch (status.toLowerCase()) {
      'completed' => (colorScheme.onSurface, Colors.green, Colors.green),
      'failed' => (colorScheme.onSurface, colorScheme.error, colorScheme.error),
      'pending' => (colorScheme.onSurface, Colors.orange, Colors.orange),
      _ => (colorScheme.onSurface, colorScheme.primary, colorScheme.primary),
    };
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

  Widget _buildSkeletonLoader(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          Row(
            children: [
              const SkeletonLoader(width: 50, height: 50, radius: 25),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 150, height: 16),
                  const SizedBox(height: 8),
                  SkeletonLoader(width: 100, height: 14),
                ],
              ),
              const Spacer(),
              SkeletonLoader(width: 24, height: 24, radius: 12),
            ],
          ),
          const SizedBox(height: 24),

          // Carte principale (placeholder)
          SkeletonLoader(
            width: double.infinity,
            height: 180,
            radius: 16,
          ),
          const SizedBox(height: 24),

          // Section "Aujourd'hui"
          SkeletonLoader(width: 100, height: 20),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SkeletonLoader(
              width: double.infinity,
              height: 80,
              radius: 12,
            ),
          )),

          // Section "Historique"
          const SizedBox(height: 24),
          SkeletonLoader(width: 100, height: 20),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SkeletonLoader(width: 40, height: 40, radius: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: double.infinity, height: 16),
                      const SizedBox(height: 8),
                      SkeletonLoader(width: 120, height: 12),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SkeletonLoader(width: 80, height: 16),
              ],
            ),
          )),
        ],
      ),
    );
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
// Widget pour afficher un élément d'historique des transactions
  Widget _buildHistoryItem({
    required Remittance remittance,
    required ColorScheme colorScheme,
  }) {
    // Détermine l'icône et la couleur en fonction du type de transaction
    final (icon, iconColor) = _getIconForRemittance(remittance);

    // Formatage de la date (vous pouvez utiliser le package intl pour un meilleur formatage)
    final formattedDate = '22 02 2003';//DateFormat('dd MMMM, yyyy').format(DateTime.parse(remittance.));

    // Détermine si c'est un crédit ou un débit
    final isCredit = remittance.amountSent > 0;
    final amountText = '${isCredit ? '+' : '-'}\$${remittance.amountSent.abs().toStringAsFixed(2)}';

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remittance.payoutOption,
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${remittance.transactionId} • $formattedDate',
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Montant
          Text(
            amountText,
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// Helper pour déterminer l'icône appropriée
  (IconData, Color) _getIconForRemittance(Remittance remittance) {
    if (remittance.payoutOption.toLowerCase().contains('mobile')) {
      return (Icons.phone_iphone, Colors.blue);
    } else if (remittance.payoutOption.toLowerCase().contains('card')) {
      return (Icons.credit_card, Colors.purple);
    } else if (remittance.payoutOption.toLowerCase().contains('cash')) {
      return (Icons.money, Colors.green);
    } else if (remittance.payoutOption.toLowerCase().contains('bank')) {
      return (Icons.account_balance, Colors.blueAccent);
    }
    return (Icons.receipt, Colors.orange);
  }

// Affichage de la liste historique
  Widget _buildHistoryList(List<Remittance> remittances, ColorScheme colorScheme) {
    if (remittances.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Aucune transaction recentes',
          style: TextStyle(
            color: colorScheme.onBackground.withOpacity(0.5),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...remittances.map((remittance) {
            return Column(
              children: [
                _buildHistoryItem(
                  remittance: remittance,
                  colorScheme: colorScheme,
                ),
                if (remittance != remittances.last)
                  Divider(
                    height: 1,
                    color: colorScheme.onBackground.withOpacity(0.1),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

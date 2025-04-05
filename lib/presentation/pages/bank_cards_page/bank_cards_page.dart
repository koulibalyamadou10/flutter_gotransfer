import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class BankCardsPage extends StatefulWidget {
  const BankCardsPage({super.key});

  @override
  State<BankCardsPage> createState() => _BankCardsPageState();
}

class _BankCardsPageState extends State<BankCardsPage> with SingleTickerProviderStateMixin {
  final Color _accentColor = const Color(0xFF03DAC6); // Turquoise
  final Color _textColor = const Color(0xFF121212); // Noir profond
  final Color _secondaryTextColor = const Color(0xFF757575); // Gris moyen
  late ColorScheme colorScheme;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showBackView = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> cardNumberKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> cvvCodeKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> expiryDateKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> cardHolderKey = GlobalKey();

  final List<Map<String, dynamic>> cards = [
    {
      'cardNumber': '5450 7879 4864 7854',
      'expiryDate': '10/25',
      'cardHolderName': 'ALEXANDRE DUPONT',
      'cvvCode': '456',
      'type': CardType.mastercard,
      'bankName': 'FlexyBank Gold',
      'color': const Color(0xFF1E88E5),
      'isPhysical': true,
    },
    {
      'cardNumber': '4234 5678 9012 3456',
      'expiryDate': '04/24',
      'cardHolderName': 'ALEXANDRE DUPONT',
      'cvvCode': '123',
      'type': CardType.visa,
      'bankName': 'FlexyBank Classic',
      'color': const Color(0xFF4CAF50),
      'isPhysical': false,
    },
  ];

  late TabController _tabController;
  int selectedCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final physicalCards = cards.where((card) => card['isPhysical']).toList();
    final virtualCards = cards.where((card) => !card['isPhysical']).toList();
    final theme = Theme.of(context);
    colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes cartes bancaires', style: TextStyle(color: colorScheme.background)),
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onBackground),
            onPressed: _showAddCardDialog,
          ),
        ],
      ),
      backgroundColor: colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Vos Cartes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${physicalCards.length} carte(s) physique${physicalCards.length != 1 ? "s" : ""}, ${virtualCards.length} carte(s) virtuelle${virtualCards.length != 1 ? "s" : ""}',
              style: TextStyle(
                fontSize: 14,
                color: _secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.onBackground,
            unselectedLabelColor: _secondaryTextColor,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Carte Physique'),
              Tab(text: 'Carte Virtuel'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Physical Cards
                ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: physicalCards.length,
                  itemBuilder: (context, index) {
                    return _buildCardItem(physicalCards[index], index);
                  },
                ),
                // Virtual Cards
                ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: virtualCards.length,
                  itemBuilder: (context, index) {
                    return _buildCardItem(virtualCards[index], index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, int index) {
    String maskedNumber = '**** **** **** ${card['cardNumber'].toString().substring(15)}';
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCardIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: card['color'],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                Image.asset(
                  card['type'] == CardType.visa
                      ? 'assets/images/visa.png' // Assurez-vous d'avoir le logo Visa dans vos assets
                      : 'assets/images/master-card.png', // Assurez-vous d'avoir le logo Mastercard
                  height: 30,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              maskedNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      card['cardHolderName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRES',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      card['expiryDate'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CVV',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      card['cvvCode'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    cardNumber = '';
    expiryDate = '';
    cardHolderName = '';
    cvvCode = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une carte', style: TextStyle(color: colorScheme.onBackground)),
        backgroundColor: colorScheme.background,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CreditCardForm(
                formKey: _formKey,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                cardNumberKey: cardNumberKey,
                cvvCodeKey: cvvCodeKey,
                expiryDateKey: expiryDateKey,
                cardHolderKey: cardHolderKey,
                onCreditCardModelChange: (CreditCardModel data) {
                  setState(() {
                    cardNumber = data.cardNumber;
                    expiryDate = data.expiryDate;
                    cardHolderName = data.cardHolderName;
                    cvvCode = data.cvvCode;
                  });
                },
                obscureCvv: true,
                obscureNumber: false,
                isHolderNameVisible: true,
                isCardNumberVisible: true,
                isExpiryDateVisible: true,
                enableCvv: true,
                cvvValidationMessage: 'Veuillez entrer un CVV valide',
                dateValidationMessage: 'Veuillez entrer une date valide',
                numberValidationMessage: 'Veuillez entrer un numéro valide',
                cardNumberValidator: (String? cardNumber) {
                  if (cardNumber == null || cardNumber.isEmpty || cardNumber.length < 19) {
                    return 'Numéro de carte invalide';
                  }
                  return null;
                },
                expiryDateValidator: (String? expiryDate) {
                  if (expiryDate == null || expiryDate.isEmpty || !RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
                    return 'Date invalide (MM/AA)';
                  }
                  return null;
                },
                cvvValidator: (String? cvv) {
                  if (cvv == null || cvv.isEmpty || cvv.length != 3) {
                    return 'CVV invalide';
                  }
                  return null;
                },
                cardHolderValidator: (String? cardHolderName) {
                  if (cardHolderName == null || cardHolderName.isEmpty) {
                    return 'Nom du titulaire requis';
                  }
                  return null;
                },
                isCardHolderNameUpperCase: true,
                onFormComplete: () {},
                autovalidateMode: AutovalidateMode.onUserInteraction,
                disableCardNumberAutoFillHints: false,
                inputConfiguration: InputConfiguration(
                  cardNumberDecoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(color: _accentColor)),
                    labelText: 'Numéro',
                    hintText: 'XXXX XXXX XXXX XXXX',
                    labelStyle: TextStyle(color: _secondaryTextColor),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
                  ),
                  expiryDateDecoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(color: _accentColor)),
                    labelText: 'Date d\'expiration',
                    hintText: 'XX/XX',
                    labelStyle: TextStyle(color: _secondaryTextColor),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
                  ),
                  cvvCodeDecoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(color: _accentColor)),
                    labelText: 'CVV',
                    hintText: 'XXX',
                    labelStyle: TextStyle(color: _secondaryTextColor),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
                  ),
                  cardHolderDecoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(color: _accentColor)),
                    labelText: 'Titulaire',
                    labelStyle: TextStyle(color: _secondaryTextColor),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
                  ),
                  cardNumberTextStyle: TextStyle(fontSize: 16, color: _textColor),
                  cardHolderTextStyle: TextStyle(fontSize: 16, color: _textColor),
                  expiryDateTextStyle: TextStyle(fontSize: 16, color: _textColor),
                  cvvCodeTextStyle: TextStyle(fontSize: 16, color: _textColor),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: _secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                CardType cardType = cardNumber.startsWith('4') ? CardType.visa : CardType.mastercard;
                Color cardColor = cardType == CardType.visa ? const Color(0xFF4CAF50) : const Color(0xFF1E88E5);

                setState(() {
                  cards.add({
                    'cardNumber': cardNumber,
                    'expiryDate': expiryDate,
                    'cardHolderName': cardHolderName,
                    'cvvCode': cvvCode,
                    'type': cardType,
                    'bankName': 'FlexyBank Nouvelle',
                    'color': cardColor,
                    'isPhysical': true, // Par défaut, on ajoute une carte physique
                  });
                  selectedCardIndex = cards.length - 1;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Carte ajoutée avec succès')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            child: Text('Ajouter', style: TextStyle(color: colorScheme.onBackground)),
          ),
        ],
      ),
    );
  }

  void _showCardActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.background,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: colorScheme.primary),
              title: Text('Voir les détails', style: TextStyle(color: _textColor)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  showBackView = !showBackView;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: colorScheme.primary),
              title: Text('Bloquer la carte', style: TextStyle(color: _textColor)),
              onTap: () {
                Navigator.pop(context);
                _showBlockCardDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: colorScheme.primary),
              title: Text('Supprimer la carte', style: TextStyle(color: _textColor)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteCardDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bloquer la carte', style: TextStyle(color: _textColor)),
        content: Text('Êtes-vous sûr de vouloir bloquer cette carte ?', style: TextStyle(color: _textColor)),
        backgroundColor: colorScheme.background,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: _secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carte bloquée avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la carte', style: TextStyle(color: _textColor)),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette carte ? Cette action est irréversible.',
          style: TextStyle(color: _textColor),
        ),
        backgroundColor: colorScheme.background,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: _secondaryTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                cards.removeAt(selectedCardIndex);
                if (selectedCardIndex >= cards.length) {
                  selectedCardIndex = cards.length - 1;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carte supprimée avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
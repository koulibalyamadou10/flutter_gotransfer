import 'package:flutter/material.dart';

class CurrencySelector extends StatelessWidget {
  final TextEditingController amountController;
  final List<String> availableCurrencies;
  final String selectedCurrency;
  final ValueChanged<String?> onCurrencyChanged;

  const CurrencySelector({
    Key? key,
    required this.amountController,
    required this.availableCurrencies,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  }) : super(key: key);

  // Mappage statique et final des devises aux emojis de drapeaux
  static const Map<String, String> _currencyToFlagEmoji = {
    'USD': '🇺🇸',  'EUR': '🇪🇺',  'GBP': '🇬🇧',  'JPY': '🇯🇵',  'CAD': '🇨🇦',
    'AUD': '🇦🇺',  'CNY': '🇨🇳',  'INR': '🇮🇳',  'NGN': '🇳🇬',  'GHS': '🇬🇭',
    'XOF': '🇧🇯',  'XAF': '🇨🇲',  'AED': '🇦🇪',  'AFN': '🇦🇫',  'ALL': '🇦🇱',
    'AMD': '🇦🇲',  'ANG': '🇨🇼',  'AOA': '🇦🇴',  'ARS': '🇦🇷',  'AWG': '🇦🇼',
    'AZN': '🇦🇿',  'BAM': '🇧🇦',  'BBD': '🇧🇧',  'BDT': '🇧🇩',  'BGN': '🇧🇬',
    'BHD': '🇧🇭',  'BIF': '🇧🇮',  'BMD': '🇧🇲',  'BND': '🇧🇳',  'BOB': '🇧🇴',
    'BRL': '🇧🇷',  'BSD': '🇧🇸',  'BTN': '🇧🇹',  'BWP': '🇧🇼',  'BYN': '🇧🇾',
    'BZD': '🇧🇿',  'CDF': '🇨🇩',  'CHF': '🇨🇭',  'CLP': '🇨🇱',  'COP': '🇨🇴',
    'CRC': '🇨🇷',  'CUP': '🇨🇺',  'CVE': '🇨🇻',  'CZK': '🇨🇿',  'DJF': '🇩🇯',
    'DKK': '🇩🇰',  'DOP': '🇩🇴',  'DZD': '🇩🇿',  'EGP': '🇪🇬',  'ERN': '🇪🇷',
    'ETB': '🇪🇹',  'FJD': '🇫🇯',  'FKP': '🇫🇰',  'FOK': '🇫🇴',  'GEL': '🇬🇪',
    'GGP': '🇬🇬',  'GIP': '🇬🇮',  'GMD': '🇬🇲',  'GNF': '🇬🇳',  'GTQ': '🇬🇹',
    'GYD': '🇬🇾',  'HKD': '🇭🇰',  'HNL': '🇭🇳',  'HRK': '🇭🇷',  'HTG': '🇭🇹',
    'HUF': '🇭🇺',  'IDR': '🇮🇩',  'ILS': '🇮🇱',  'IMP': '🇮🇲',  'IQD': '🇮🇶',
    'IRR': '🇮🇷',  'ISK': '🇮🇸',  'JEP': '🇯🇪',  'JMD': '🇯🇲',  'JOD': '🇯🇴',
    'KES': '🇰🇪',  'KGS': '🇰🇬',  'KHR': '🇰🇭',  'KID': '🇰🇮',  'KMF': '🇰🇲',
    'KRW': '🇰🇷',  'KWD': '🇰🇼',  'KYD': '🇰🇾',  'KZT': '🇰🇿',  'LAK': '🇱🇦',
    'LBP': '🇱🇧',  'LKR': '🇱🇰',  'LRD': '🇱🇷',  'LSL': '🇱🇸',  'LYD': '🇱🇾',
    'MAD': '🇲🇦',  'MDL': '🇲🇩',  'MGA': '🇲🇬',  'MKD': '🇲🇰',  'MMK': '🇲🇲',
    'MNT': '🇲🇳',  'MOP': '🇲🇴',  'MRU': '🇲🇷',  'MUR': '🇲🇺',  'MVR': '🇲🇻',
    'MWK': '🇲🇼',  'MXN': '🇲🇽',  'MYR': '🇲🇾',  'MZN': '🇲🇿',  'NAD': '🇳🇦',
    'NIO': '🇳🇮',  'NOK': '🇳🇴',  'NPR': '🇳🇵',  'NZD': '🇳🇿',  'OMR': '🇴🇲',
    'PAB': '🇵🇦',  'PEN': '🇵🇪',  'PGK': '🇵🇬',  'PHP': '🇵🇭',  'PKR': '🇵🇰',
    'PLN': '🇵🇱',  'PYG': '🇵🇾',  'QAR': '🇶🇶',  'RON': '🇷🇴',  'RSD': '🇷🇸',
    'RUB': '🇷🇺',  'RWF': '🇷🇼',  'SAR': '🇸🇦',  'SBD': '🇸🇧',  'SCR': '🇸🇨',
    'SDG': '🇸🇩',  'SEK': '🇸🇪',  'SGD': '🇸🇬',  'SHP': '🇸🇭',  'SLE': '🇸🇱',
    'SOS': '🇸🇴',  'SRD': '🇸🇷',  'SSP': '🇸🇸',  'STN': '🇸🇹',  'SYP': '🇸🇾',
    'SZL': '🇸🇿',  'THB': '🇹🇭',  'TJS': '🇹🇯',  'TMT': '🇹🇲',  'TND': '🇹🇳',
    'TOP': '🇹🇴',  'TRY': '🇹🇷',  'TTD': '🇹🇹',  'TVD': '🇹🇻',  'TWD': '🇹🇼',
    'TZS': '🇹🇿',  'UAH': '🇺🇦',  'UGX': '🇺🇬',  'UYU': '🇺🇾',  'UZS': '🇺🇿',
    'VES': '🇻🇪',  'VND': '🇻🇳',  'VUV': '🇻🇺',  'WST': '🇼🇸',  'XCD': '🇦🇬',
    'XDR': '🌐',  'XPF': '🇵🇫',  'YER': '🇾🇪',  'ZAR': '🇿🇦',  'ZMW': '🇿🇲',
    'ZWL': '🇿🇼',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Champ de saisie du montant
        TextField(
          controller: amountController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.5)
                : Colors.grey[100],
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: _CurrencyDisplay(
                currency: selectedCurrency,
                isSelected: true,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            hintText: '0.00',
            hintStyle: TextStyle(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Sélecteur de devise
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(0.5)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedCurrency,
              items: [
                for (final currency in availableCurrencies)
                  DropdownMenuItem(
                    value: currency,
                    child: _CurrencyDisplay(currency: currency),
                  ),
              ],
              onChanged: onCurrencyChanged,
              dropdownColor: isDarkMode
                  ? Colors.grey[850]
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              icon: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_drop_down),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyDisplay extends StatelessWidget {
  final String currency;
  final bool isSelected;

  const _CurrencyDisplay({
    required this.currency,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final flag = CurrencySelector._currencyToFlagEmoji[currency] ?? '🌐';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            flag,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            currency,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
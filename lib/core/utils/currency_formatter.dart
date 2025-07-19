import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String _defaultCurrency = 'USD';
  static String _defaultLocale = 'en_US';

  /// Set the default currency and locale
  static void setDefaults({String? currency, String? locale}) {
    if (currency != null) _defaultCurrency = currency;
    if (locale != null) _defaultLocale = locale;
  }

  /// Format amount as currency with default settings
  static String format(double amount, {String? currency, String? locale}) {
    final currencyCode = currency ?? _defaultCurrency;
    final localeCode = locale ?? _defaultLocale;

    try {
      final formatter = NumberFormat.currency(
        locale: localeCode,
        symbol: _getCurrencySymbol(currencyCode),
        decimalDigits: 2,
      );
      return formatter.format(amount);
    } catch (e) {
      // Fallback to simple formatting if locale is not supported
      return '${_getCurrencySymbol(currencyCode)}${amount.toStringAsFixed(2)}';
    }
  }

  /// Format amount as currency with specific currency code
  static String formatWithCurrency(double amount, String currencyCode) {
    try {
      final formatter = NumberFormat.currency(
        symbol: _getCurrencySymbol(currencyCode),
        decimalDigits: 2,
      );
      return formatter.format(amount);
    } catch (e) {
      return '${_getCurrencySymbol(currencyCode)}${amount.toStringAsFixed(2)}';
    }
  }

  /// Format amount as compact currency (e.g., $1.2K, $1.5M)
  static String formatCompact(double amount, {String? currency}) {
    final currencyCode = currency ?? _defaultCurrency;
    final symbol = _getCurrencySymbol(currencyCode);

    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// Get currency symbol for currency code
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'IDR':
        return 'Rp';
      case 'SGD':
        return 'S\$';
      case 'MYR':
        return 'RM';
      case 'THB':
        return '฿';
      case 'PHP':
        return '₱';
      case 'VND':
        return '₫';
      case 'KRW':
        return '₩';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'CHF';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      case 'PLN':
        return 'zł';
      case 'CZK':
        return 'Kč';
      case 'HUF':
        return 'Ft';
      case 'RUB':
        return '₽';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return 'MX\$';
      case 'ZAR':
        return 'R';
      case 'TRY':
        return '₺';
      case 'NZD':
        return 'NZ\$';
      case 'HKD':
        return 'HK\$';
      case 'TWD':
        return 'NT\$';
      default:
        return currencyCode;
    }
  }

  /// Get supported currencies list
  static List<Map<String, String>> getSupportedCurrencies() {
    return [
      {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
      {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp'},
      {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$'},
      {'code': 'MYR', 'name': 'Malaysian Ringgit', 'symbol': 'RM'},
      {'code': 'THB', 'name': 'Thai Baht', 'symbol': '฿'},
      {'code': 'PHP', 'name': 'Philippine Peso', 'symbol': '₱'},
      {'code': 'VND', 'name': 'Vietnamese Dong', 'symbol': '₫'},
      {'code': 'KRW', 'name': 'South Korean Won', 'symbol': '₩'},
      {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
      {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
      {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    ];
  }

  /// Parse currency string back to double
  static double? parseCurrency(String currencyString) {
    try {
      // Remove currency symbols and spaces
      String cleanString = currencyString
          .replaceAll(RegExp(r'[^\d.,\-]'), '')
          .replaceAll(',', '');

      return double.tryParse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Check if currency code is supported
  static bool isSupportedCurrency(String currencyCode) {
    return getSupportedCurrencies().any(
      (currency) => currency['code'] == currencyCode.toUpperCase(),
    );
  }
}

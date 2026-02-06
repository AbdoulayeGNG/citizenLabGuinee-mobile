import 'package:intl/intl.dart';

/// Utilitaires pour le formatage des données
class FormatUtils {
  /// Formater une date à la française
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Formater une date courte
  static String formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Formater une date relative (il y a 2 jours, hier, etc.)
  static String formatDateRelative(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'Il y a ${difference.inMinutes} minutes';
        }
        return 'Il y a ${difference.inHours} heures';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return formatDate(dateString);
      }
    } catch (e) {
      return dateString;
    }
  }

  /// Tronquer du texte avec ellipsis
  static String truncate(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Supprimer les tags HTML
  static String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r'<[^>]*>');
    return htmlString.replaceAll(exp, '');
  }

  /// Capitaliser la première lettre
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Convertir slug en titre lisible
  static String slugToTitle(String slug) {
    return slug
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }

  /// Formater un nombre (1000 -> 1K, 1000000 -> 1M)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Formater une URL (supprimer https://, www., etc.)
  static String formatUrl(String url) {
    return url
        .replaceAll(RegExp(r'https?://'), '')
        .replaceAll(RegExp(r'www\.'), '')
        .replaceAll(RegExp(r'/$'), '');
  }

  /// Vérifier si une URL est valide
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.contains('.') && (url.startsWith('http'));
    } catch (e) {
      return false;
    }
  }

  /// Vérifier si un email est valide
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

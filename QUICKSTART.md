# 🚀 Guide de démarrage - CitizenLab Guinée

## Prérequis

- Flutter SDK 3.10+
- Dart 3.10+
- Un WordPress avec WPGraphQL installé
- Un émulateur Android/iOS ou un appareil physique

## Installation

### 1. Cloner le projet

```bash
cd /home/abdoulaye/Documents/citizenlabguinee
```

### 2. Installer les dépendances Flutter

```bash
flutter pub get
```

### 3. Configurer l'endpoint GraphQL

Éditer [lib/config.dart](lib/config.dart) et remplacer l'URL :

```dart
static const String graphqlEndpoint = 'https://votre-wordpress.com/graphql';
```

### 4. Lancer l'app

```bash
# Android
flutter run -d emulator-5554

# iOS
flutter run -d "iPhone 14"

# Web
flutter run -d web-server
```

## Vérifier la connectivité GraphQL

### Test 1 : Requête simple (Menu)

Ouvrir [GraphQL IDE](https://votre-wordpress.com/graphql) et exécuter :

```graphql
{
  menu(id: "HEADER_MENU") {
    menuItems {
      edges {
        node {
          label
          url
        }
      }
    }
  }
}
```

### Test 2 : Requête Articles

```graphql
{
  posts(first: 5) {
    edges {
      node {
        id
        title
        slug
        excerpt
        date
        featuredImage {
          node {
            sourceUrl
            altText
          }
        }
      }
    }
  }
}
```

## Structure des répertoires créés

```
lib/
├── constants/                 # ✨ NOUVEAU
│   └── strings.dart          # Constantes de texte
├── models/                    # ✨ AMÉLIORÉ
│   ├── post.dart             # Modèle article
│   ├── page.dart             # Modèle page
│   ├── category.dart         # Modèle catégorie
│   ├── menu_item.dart        # Modèle menu
│   └── team_member.dart      # Modèle équipe
├── screens/                   # ✨ COMPLÉTÉ
│   ├── home_screen.dart      # Accueil
│   ├── article_screen.dart   # Vue article
│   ├── category_screen.dart  # Articles catégorie
│   ├── categories_screen.dart # Grille catégories
│   ├── team_screen.dart      # Équipe
│   └── search_screen.dart    # Recherche
├── services/                  # ✨ NOUVEAU
│   ├── api_service.dart      # Service Provider
│   ├── graphql_service.dart  # Client GraphQL
│   └── graphql_queries.dart  # Requêtes GraphQL
├── utils/                     # ✨ NOUVEAU
│   └── format_utils.dart     # Formatage données
├── widgets/                   # ✨ AMÉLIORÉ
│   ├── app_drawer.dart       # Navigation drawer
│   ├── post_card.dart        # Carte article
│   └── section_header.dart   # En-têtes
├── config.dart               # ✨ NOUVEAU - Configuration
├── routes.dart               # ✨ NOUVEAU - Routing
├── main.dart                 # ✨ AMÉLIORÉ
└── theme.dart               # ✨ EXISTANT
```

## 🔑 Points clés de l'implémentation

### 1. **ApiService (State Management)**

Utilise Provider + ChangeNotifier pour gérer :
- Les données (posts, menus, catégories, équipe)
- L'état (isLoading, isOffline, errorMessage)
- Le cache (Hive)

```dart
final apiService = Provider.of<ApiService>(context);
apiService.posts        // Liste des articles
apiService.menuItems    // Menu de navigation
apiService.categories   // Catégories
apiService.teamMembers  // Équipe
```

### 2. **GraphQLService (HTTP Client)**

Exécute les requêtes GraphQL avec :
- Gestion des timeouts (30s)
- Gestion des erreurs
- Parsing automatique des réponses

### 3. **Routes (Navigation)**

Configuration centralisée dans [lib/routes.dart](lib/routes.dart) :

```dart
Navigator.pushNamed(context, '/article', arguments: {'id': '123'});
Navigator.pushNamed(context, '/category', arguments: {'slug': 'news'});
```

### 4. **Thème (UI)**

Couleurs guinéennes intégrées:
- Vert: #009460
- Rouge: #CE1126
- Jaune: #FCD116

Éditable dans [lib/theme.dart](lib/theme.dart)

## 🔌 Dépendances installed

| Package | Version | Utilité |
|---------|---------|---------|
| flutter | - | Framework |
| graphql_flutter | ^5.1.0 | Client GraphQL |
| provider | ^6.0.5 | State management |
| hive | ^2.2.3 | Cache local |
| hive_flutter | ^1.1.0 | Cache pour Flutter |
| cached_network_image | ^3.2.3 | Cache images |
| connectivity_plus | ^4.0.1 | Connectivité réseau |
| url_launcher | ^6.1.12 | Ouverture URLs/emails |
| intl | ^0.19.0 | Dates internationales |

## 🐛 Debugging

### Activer les logs

Éditer [lib/config.dart](lib/config.dart) :

```dart
static const bool debugMode = true;
```

### Console Flutter

```bash
# Voir tous les logs
flutter logs

# Avec filtrage
flutter logs | grep "ApiService"
```

### DevTools

```bash
flutter pub global activate devtools
devtools
```

## ✅ Checklist avant production

- [ ] Vérifier l'endpoint GraphQL
- [ ] Tester la recherche
- [ ] Vérifier le cache Hive
- [ ] Tester mode offline
- [ ] Tester les images manquantes
- [ ] Adapter les textes (intl)
- [ ] Ajouter les assets (icônes, images)
- [ ] Configurer les réglages de build
- [ ] Signer l'APK/IPA
- [ ] Tester sur vrais appareils

## 📚 Ressources utiles

- [Flutter Documentation](https://flutter.dev/docs)
- [GraphQL Docs](https://graphql.org/)
- [WordPress WPGraphQL](https://www.wpgraphql.com/)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Hive Database](https://pub.dev/packages/hive)

## 🆘 Dépannage courant

### Erreur : `No GraphQL endpoint`

→ Vérifier l'URL dans [lib/config.dart](lib/config.dart)

### Erreur : `Cache box not opened`

→ Vérifier que `Hive.openBox('cache')` est appelé dans `main()`

### Erreur : `Offline mode`

→ Vérifier la connectivité réseau et les permissions

### Erreur : `Type casting`

→ Vérifier la structure JSON de la réponse GraphQL

## 📞 Support

- Consulter la documentation dans [DEVELOPMENT.md](DEVELOPMENT.md)
- Vérifier les logs Flutter
- Tester les requêtes GraphQL dans l'IDE WordPress

---

**Bonne chance! 🚀**

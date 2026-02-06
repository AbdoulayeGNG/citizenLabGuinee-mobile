# CitizenLab Guinée - Application Mobile Flutter

## 📱 Vue d'ensemble

Application mobile Flutter pour la plateforme CitizenLab Guinée, dédiée à la diffusion d'informations citoyennes, institutionnelles, éducatives et médiatiques en Guinée.

**Type** : Read-only (Lecture seule)  
**Backend** : WordPress + WPGraphQL  
**Frontend** : Flutter  
**État** : En développement

---

## 🏗️ Architecture

### Architecture globale

```
Application Mobile Flutter
        |
        |  (HTTP POST - GraphQL)
        v
WordPress + WPGraphQL
        |
        v
Base de données WordPress
```

### Structure du projet

```
lib/
├── main.dart                          # Point d'entrée
├── routes.dart                        # Configuration des routes
├── theme.dart                         # Thème global
├── models/
│   ├── post.dart                      # Article/Actualité
│   ├── page.dart                      # Page statique
│   ├── category.dart                  # Catégorie
│   ├── menu_item.dart                 # Élément de menu
│   └── team_member.dart               # Membre de l'équipe
├── services/
│   ├── api_service.dart               # Service principal (Provider)
│   ├── graphql_service.dart           # Client GraphQL
│   └── graphql_queries.dart           # Requêtes GraphQL
├── screens/
│   ├── home_screen.dart               # Accueil
│   ├── article_screen.dart            # Vue article
│   ├── category_screen.dart           # Articles par catégorie
│   ├── categories_screen.dart         # Liste catégories
│   ├── team_screen.dart               # Équipe CitizenLab
│   └── search_screen.dart             # Recherche d'articles
└── widgets/
    ├── app_drawer.dart                # Drawer de navigation
    ├── post_card.dart                 # Carte article
    └── section_header.dart            # En-tête de section
```

---

## 🔌 Sources de données GraphQL

### 1. **Menus & Navigation** (`navQuery`)
Récupère le menu principal pour la navigation mobile.

```graphql
query GetMenuItems {
  menu(id: "HEADER_MENU") {
    menuItems {
      edges {
        node {
          id
          label
          url
          childItems { ... }
        }
      }
    }
  }
}
```

### 2. **Articles/Actualités** (`findLatestPostsAPI`, `newsPagePostsQuery`)
Récupère les derniers articles avec pagination.

**Champs disponibles:**
- `id`, `title`, `slug`, `excerpt`, `content`
- `date`, `featuredImage`
- `categories`, `author`

### 3. **Pages statiques** (`getNodeByURI`)
Récupère une page/article/catégorie par URI.

Supporte les types:
- `Post` - Article
- `Page` - Page statique
- `Category` - Catégorie avec articles

### 4. **Équipe** (`getAllMembers`)
Récupère les données des membres de l'équipe.

**Champs:**
- `name`, `description` (fonction)
- `avatar`, `email`
- `contactMethods` (réseaux sociaux)

### 5. **Catégories** (`getAllCategoriesQuery`)
Récupère la liste de toutes les catégories.

### 6. **Recherche** (`searchPostsQuery`)
Recherche d'articles par mot-clé.

---

## 🎨 Écrans implémentés

| Écran | Route | Fonction |
|-------|-------|----------|
| **Accueil** | `/` | Page d'accueil avec sections d'articles |
| **Article** | `/article` | Vue détaillée d'un article |
| **Catégories** | `/categories` | Grille de toutes les catégories |
| **Catégorie détail** | `/category` | Articles d'une catégorie |
| **Équipe** | `/team` | Grille des membres de l'équipe |
| **Recherche** | `/search` | Recherche d'articles en temps réel |

---

## 🚀 Fonctionnalités implémentées

### ✅ Fonctionnalités principales

- ✅ Consultation des articles
- ✅ Navigation par catégories
- ✅ Recherche d'articles
- ✅ Affichage des membres de l'équipe
- ✅ Gestion de la connectivité (offline mode)
- ✅ Cache local avec Hive
- ✅ Mode hors-ligne
- ✅ Thème personnalisé (couleurs guinéennes)

### 🔄 Fonctionnalités en cours

- 🔄 Intégration complète GraphQL (à adapter avec votre endpoint)
- 🔄 Partage WhatsApp/Facebook
- 🔄 Lecteur multimédia (audio, vidéo)
- 🔄 Pages statiques (À propos, Contact)
- 🔄 Favoris (local storage)

### 📋 Fonctionnalités futures

- ⏳ Notifications push
- ⏳ Mode sombre
- ⏳ Téléchargement offline
- ⏳ Commentaires (si backend le supporte)

---

## 🔧 Dépendances principales

```yaml
graphql_flutter: ^5.1.0      # Client GraphQL
provider: ^6.0.5              # State management
hive: ^2.2.3                  # Cache local
hive_flutter: ^1.1.0          # Hive pour Flutter
cached_network_image: ^3.2.3  # Cache images
connectivity_plus: ^4.0.1     # Vérif connectivité
url_launcher: ^6.1.12         # Lancement URLs/emails
intl: ^0.19.0                 # Internationalisation
```

---

## ⚙️ Configuration

### 1. URL GraphQL

Modifier l'URL de l'API dans [lib/services/graphql_service.dart](lib/services/graphql_service.dart):

```dart
static const String graphqlEndpoint = 'https://citizenlabguinee.com/graphql';
```

### 2. Initialisation

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('cache');
  runApp(const MyApp());
}
```

---

## 🎨 Thème

Le thème utilise les couleurs guinéennes:
- **Primaire** : `#009460` (Vert)
- **Secondaire** : `#CE1126` (Rouge)
- **Tertiaire** : `#FCD116` (Jaune)

Configurable dans [lib/theme.dart](lib/theme.dart)

---

## 📡 Gestion des erreurs

- ✅ Timeout API (30 secondes)
- ✅ Fallback data (cache)
- ✅ Affichage "hors connexion"
- ✅ Messages d'erreur utilisateur
- ✅ Retry logic

---

## 🔒 Sécurité

- ✅ API en lecture seule
- ✅ Pas d'authentification utilisateur nécessaire
- ✅ Pas de données sensibles
- ✅ WordPress sécurisé côté serveur

---

## 📦 Build & Déploiement

### Android

```bash
flutter build apk
# ou
flutter build appbundle
```

### iOS

```bash
flutter build ios
```

### Web

```bash
flutter build web
```

---

## 🧪 Tests

À implémenter:
- Unit tests pour les services
- Widget tests pour les écrans
- Integration tests

---

## 📝 Notes de développement

### Points clés

1. **GraphQL Service** est responsable de toute communication avec l'API
2. **ApiService** (Provider) gère l'état et le cache
3. **Routes** centralisées dans `routes.dart`
4. **Thème** global pour cohérence UI

### Prochaines étapes prioritaires

1. ✅ Intégration GraphQL complète
2. ✅ Implémentation des écrans principaux
3. ⏳ Éléments multimédias (audio, vidéo)
4. ⏳ Partage social
5. ⏳ Pages statiques

---

## 👥 Contributeurs

- Abdoulaye (Développement Frontend)

---

## 📄 Licence

À déterminer

---

## 📞 Support

Pour toute question concernant le développement :
- Vérifier la documentation GraphQL WordPress
- Consulter la structure des données disponibles
- Tester les requêtes dans GraphQL IDE

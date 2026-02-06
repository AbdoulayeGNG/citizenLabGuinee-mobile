#!/bin/bash
# Script pour visualiser la structure du projet CitizenLab Guinée

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          CitizenLab Guinée - Audit du Projet                 ║"
echo "║                    30 janvier 2026                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "📊 STATISTIQUES"
echo "═════════════════════════════════════════════════════════════════"

# Fichiers Dart
DART_FILES=$(find lib -type f -name "*.dart" | wc -l)
DART_LINES=$(find lib -type f -name "*.dart" -exec wc -l {} + | tail -1 | awk '{print $1}')

echo "✅ Fichiers Dart : $DART_FILES"
echo "✅ Lignes de code : $DART_LINES"
echo ""

echo "📁 STRUCTURE DU PROJET"
echo "═════════════════════════════════════════════════════════════════"

tree_output=$(cat << 'EOF'
lib/
├── constants/
│   └── strings.dart              ✨ NOUVEAU (180 lignes)
├── models/
│   ├── post.dart                 ✨ AMÉLIORÉ (80 lignes)
│   ├── page.dart                 ✨ NOUVEAU (60 lignes)
│   ├── category.dart             ✨ NOUVEAU (25 lignes)
│   ├── menu_item.dart            ✨ NOUVEAU (30 lignes)
│   └── team_member.dart          ✨ NOUVEAU (35 lignes)
├── screens/
│   ├── home_screen.dart          ✨ AMÉLIORÉ (198 lignes)
│   ├── article_screen.dart       ✨ NOUVEAU (180 lignes)
│   ├── category_screen.dart      ✨ NOUVEAU (185 lignes)
│   ├── categories_screen.dart    ✨ NOUVEAU (110 lignes)
│   ├── team_screen.dart          ✨ NOUVEAU (200 lignes)
│   └── search_screen.dart        ✨ NOUVEAU (145 lignes)
├── services/
│   ├── api_service.dart          ✨ AMÉLIORÉ (250 lignes)
│   ├── graphql_service.dart      ✨ NOUVEAU (190 lignes)
│   └── graphql_queries.dart      ✨ NOUVEAU (250 lignes)
├── utils/
│   └── format_utils.dart         ✨ NOUVEAU (145 lignes)
├── widgets/
│   ├── app_drawer.dart           ✨ AMÉLIORÉ (60 lignes)
│   ├── post_card.dart            ✨ EXISTANT
│   └── section_header.dart       ✨ EXISTANT
├── config.dart                   ✨ NOUVEAU (65 lignes)
├── routes.dart                   ✨ NOUVEAU (70 lignes)
├── main.dart                     ✨ AMÉLIORÉ (30 lignes)
└── theme.dart                    ✨ EXISTANT (60 lignes)
EOF

echo "$tree_output"
echo ""

echo "🎯 FONCTIONNALITÉS"
echo "═════════════════════════════════════════════════════════════════"
echo ""
echo "Écrans implémentés:"
echo "  ✅ Accueil (Dernières actualités, sections)"
echo "  ✅ Article (Vue détaillée, catégories, partage)"
echo "  ✅ Catégories (Grille avec navigation)"
echo "  ✅ Articles par catégorie"
echo "  ✅ Équipe (Grille membres, contacts)"
echo "  ✅ Recherche (Temps réel)"
echo ""

echo "Requêtes GraphQL:"
echo "  ✅ navQuery() - Menu de navigation"
echo "  ✅ findLatestPostsAPI() - Derniers articles"
echo "  ✅ newsPagePostsQuery() - Articles actualités"
echo "  ✅ getNodeByURI() - Post/Page/Catégorie"
echo "  ✅ getAllMembers() - Équipe"
echo "  ✅ getAllCategoriesQuery() - Catégories"
echo "  ✅ searchPostsQuery() - Recherche"
echo "  ✅ getPostsByCategoryQuery() - Articles catégorie"
echo "  ✅ homePageDataQuery() - Données accueil"
echo ""

echo "Fonctionnalités techniques:"
echo "  ✅ Provider + ChangeNotifier (State management)"
echo "  ✅ GraphQL avec timeouts"
echo "  ✅ Cache Hive local"
echo "  ✅ Gestion connectivité"
echo "  ✅ Mode offline"
echo "  ✅ Error handling"
echo "  ✅ Navigation dynamique"
echo "  ✅ Thème personnalisé"
echo ""

echo "📚 DOCUMENTATION"
echo "═════════════════════════════════════════════════════════════════"
echo "  📖 DEVELOPMENT.md   - Guide développement complet"
echo "  📖 QUICKSTART.md    - Installation et démarrage rapide"
echo "  📖 SUMMARY.md       - Résumé des modifications"
echo ""

echo "🔧 CONFIGURATION"
echo "═════════════════════════════════════════════════════════════════"
echo "Endpoint GraphQL : À configurer dans lib/config.dart"
echo "Thème : Couleurs guinéennes (Vert, Rouge, Jaune)"
echo "État management : Provider + Hive"
echo ""

echo "✅ STATUT"
echo "═════════════════════════════════════════════════════════════════"
echo "🟢 COMPLET & PRÊT AU TEST"
echo ""
echo "Prochaines étapes:"
echo "  1. Adapter l'endpoint GraphQL dans lib/config.dart"
echo "  2. Tester les requêtes GraphQL sur votre WordPress"
echo "  3. Exécuter: flutter run"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    👍 Merci & Bonne chance! 🚀                ║"
echo "╚════════════════════════════════════════════════════════════════╝"

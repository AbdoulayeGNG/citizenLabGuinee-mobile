# 📄 Page "À Propos" - CitizenLab Guinée

## Aperçu

La page "À propos" (About Screen) est une page institutionnelle moderne et professionnelle qui présente CitizenLab Guinée de manière optimisée pour mobile.

## 📱 Accès

### Via le menu drawer:
Menu ☰ → Qui sommes-nous → `/about`

### Via le routing programmatique:
```dart
Navigator.pushNamed(context, '/about');
```

## 🎨 Sections

### 1️⃣ Hero Section - "Qui Sommes-Nous"
- **Badge**: "QUI NOUS SOMMES" avec fond jaune/rouge
- **Logo**: Icône en gradient (vert → jaune)
- **Titre**: "CitizenLab Guinée"
- **Description**: Texte de présentation institutionnelle
- **Design**: Card blanche avec shadow, coins arrondis (24px)

### 2️⃣ Notre Mission
- **Image placeholder**: Gradient vert-jaune avec icône lightbulb
- **Titre**: "Transformer par le numérique"
- **Contenu**: 3 items de checklist avec icônes vertes
  - ✔ Renforcer la participation citoyenne
  - ✔ Former des jeunes leaders
  - ✔ Promouvoir l'innovation civique
- **Style**: Card avec gradient jaune subtil

### 3️⃣ Nos Axes d'Intervention
- **3 cartes verticales** (mobile-first, pas de grille)
- **Chaque carte**:
  - Numéro (01, 02, 03)
  - Icône colorée (vert/jaune/rouge alternés)
  - Titre principal
  - Sous-titre descriptif
- **Gradient dynamique** selon l'axe

**Axes**:
1. Education et usage rationnel du numérique (VERT)
2. Gouvernance et innovation technologique (JAUNE)
3. Accompagnement des projets technologiques des jeunes (ROUGE)

### 4️⃣ Nos Valeurs
- **5 valeurs** affichées en cards empilées
- **Chaque card**:
  - Numéro coloré (1-5)
  - Titre de la valeur
  - Description courte (max 2 lignes)
- **Valeurs**:
  1. Inclusion
  2. Transparence
  3. Collaboration
  4. Innovation
  5. Engagement Citoyen
- **Couleurs alternées**: Vert → Jaune → Rouge

### 5️⃣ Call to Action (CTA)
- **Titre**: "Rejoignez le mouvement"
- **Sous-titre**: Message inspirant
- **Background**: Gradient VERT → JAUNE → ROUGE (drapeau guinéen)
- **Bouton**: "Nous contacter" (texte blanc sur fond coloré)
- **Fonction**: Affiche un dialog de contact

## 🎯 Couleurs Utilisées

| Couleur | Hex | RGB | Utilisation |
|---------|-----|-----|-------------|
| Rouge | #DC143C | 220, 20, 60 | Accents, boutons, drapeau |
| Jaune | #FCD116 | 252, 209, 22 | Badges, points forts |
| Vert | #007A5E | 0, 122, 94 | Éléments principaux |
| Gris | #CCCCCC | 204, 204, 204 | Texte secondaire |

## 📐 Spacing & Typography

### Padding
- Horizontal: **16px** (SafeArea)
- Section spacing: **32px**
- Card padding: **20-24px**

### Font Sizes
- Titre principal (Hero): **28px** (bold)
- Section title: **20px** (bold)
- Card title: **16-18px** (bold)
- Body text: **14-16px**
- Small text: **12-14px**

### Line Height
- Descriptions: **1.6**
- Checklists: **1.5**

## 🔧 Code Structure

### Fichier Principal
- **Location**: `lib/screens/about_screen.dart`
- **Class**: `AboutScreen` (StatefulWidget)
- **State**: `_AboutScreenState`

### Widgets Internes
1. `_buildHeroSection()` - Section héro
2. `_buildMissionSection()` - Mission
3. `_buildAxisSection()` - Axes d'intervention
4. `_buildValuesSection()` - Valeurs
5. `_buildCTASection()` - Appel à l'action

### Widgets Helpers
- `_buildChecklistItem()` - Item de checklist
- `_buildAxisCard()` - Carte axe
- `_buildValueCard()` - Carte valeur
- `_handleContactPress()` - Gestion du clic "Nous contacter"

## 🚀 Performances

- ✅ SingleChildScrollView pour le scroll fluide
- ✅ BouncingScrollPhysics pour meilleure UX
- ✅ Cards avec elevation minimale (1-3)
- ✅ Aucune image externe (placeholders avec icônes)
- ✅ Animations subtiles au scroll

## 📋 Checklist de Vérification

- [x] Page compilée sans erreurs
- [x] Intégrée au système de routing (`/about`)
- [x] Accessible depuis le menu drawer
- [x] Respecte les couleurs du drapeau guinéen
- [x] Optimisée pour mobile
- [x] Scroll fluide
- [x] CTA visible et fonctionnel
- [x] Design institutionnel et professionnel
- [x] Respecte la hiérarchie typographique

## 🎬 Prochaines Étapes

1. **Images réelles**: Remplacer les placeholders par des vraies images
2. **Page Contact**: Créer une page `/contact` pour le bouton "Nous contacter"
3. **Animations**: Ajouter des animations subtiles au scroll (Sliver)
4. **Internationalisation**: Traduire en anglais
5. **Analytics**: Tracker les clics sur la page

## 🔗 Route Disponible

```dart
// Dans routes.dart
static const String about = '/about';

// Accès programmatique
Navigator.pushNamed(context, '/about');
```

## 📞 Infos de Contact (À Remplir)

Actuellement, le dialog de contact affiche:
- Email: `info@citizenlabguinee.org`
- Téléphone: `+224 XXX XXX XXX` (À compléter)
- Adresse: `Conakry, Guinée` (À compléter)

**À faire**: Récupérer ces infos depuis l'API ou les configurer en constantes.

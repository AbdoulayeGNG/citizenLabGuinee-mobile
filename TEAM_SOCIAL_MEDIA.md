# Guide d'ajout des réseaux sociaux des membres de l'équipe

## Format de la description pour WordPress

Pour afficher les icônes des réseaux sociaux dans l'app, ajoutez les liens dans la **description** de chaque utilisateur WordPress au format suivant:

```
Votre description ou rôle ici

facebook: https://facebook.com/votre-profil
linkedin: https://linkedin.com/in/votre-profil
twitter: https://twitter.com/votre-compte
instagram: https://instagram.com/votre-compte
```

## Exemple complet

```
Développeur Mobile | Passionné par Flutter

facebook: https://facebook.com/john.doe
linkedin: https://linkedin.com/in/johndoe
twitter: https://twitter.com/johndoe
instagram: https://instagram.com/johndoe
```

## Règles importantes

1. **Un lien par ligne** - Chaque réseau social doit être sur sa propre ligne
2. **Format requis** - `[plateforme]: [URL complète]`
3. **Espaces flexibles** - Les espaces autour des `:` sont ignorés
4. **URL complète** - Assurez-vous que l'URL commence par `https://` ou `http://`
5. **Sensibilité de casse** - Les noms de plateforme ne sont pas sensibles à la casse (facebook, Facebook, FACEBOOK)

## Noms de plateforme supportés

- `facebook` → Affiche l'icône Facebook
- `linkedin` → Affiche l'icône LinkedIn
- `twitter` → Affiche l'icône Twitter
- `instagram` → Affiche l'icône Instagram

## Exemple de description WordPress

Éditez la description de l'utilisateur dans WordPress (Utilisateurs > Tous les utilisateurs > Éditer) et collez:

```
Chef de projet | Spécialiste en gouvernance ouverte

facebook: https://facebook.com/marie.kane
linkedin: https://linkedin.com/in/mariekane
twitter: https://twitter.com/mariekane
instagram: https://instagram.com/mariekane
```

## Résultat dans l'app

- Les icônes s'affichent automatiquement si les URLs sont détectées
- Cliquer sur une icône ouvre le profil dans le navigateur par défaut
- Si une URL est manquante, l'icône correspondante n'apparaît pas

## Notes

- La première ligne de la description s'affiche comme "Rôle" dans la carte
- Les lignes suivantes (avec les réseaux sociaux) sont ignorées visuellement
- Les liens invalides sont ignorés silencieusement (pas d'erreur)

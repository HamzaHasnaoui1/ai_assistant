# AI Assistant Test Suite

Ce projet contient une suite de tests automatisés pour tester l'assistant AI de la plateforme ATG (Africa Trade Gateway).

## Structure du projet

```
ai_assistant/
├── ai_assistant.robot          # Fichier principal de test Robot Framework
├── ressources/
│   ├── variables.robot         # Variables globales et configuration
│   └── keywords.robot          # Mots-clés et fonctions utilitaires
├── results/
│   ├── ai_assistant/           # Captures d'écran des tests
│   └── ai_assistant_documentation/  # Documentation et rapports
├── generate_word_report.py     # Script Python pour générer des rapports Word
└── test_screenshots_integration.py  # Script d'intégration des captures d'écran
```

## Fichiers principaux

### `ai_assistant.robot`
- Suite de tests principale pour l'assistant AI
- Tests d'authentification avec code de vérification Yopmail
- Tests de fonctionnalité de l'assistant AI
- Documentation automatique des interactions

### `ressources/variables.robot`
- Variables globales (URLs, navigateur, timeouts)
- Configuration des identifiants de test
- Paramètres de l'environnement

### `ressources/keywords.robot`
- Mots-clés réutilisables pour les tests
- Fonctions d'authentification et de navigation
- Utilitaires de capture d'écran et de documentation

## Exécution des tests

```bash
# Exécuter la suite de tests complète
robot ai_assistant.robot

# Exécuter avec des options spécifiques
robot --outputdir results --variable BROWSER:chrome ai_assistant.robot
```

## Fonctionnalités

- **Authentification automatique** avec récupération de code de vérification depuis Yopmail
- **Tests d'assistant AI** avec questions multiples depuis un fichier
- **Documentation automatique** des interactions avec captures d'écran
- **Détection automatique** de la présence de points d'interrogation (?) à la fin des réponses
- **Génération de rapports** en format Word et texte avec métriques détaillées
- **Gestion des erreurs** et validation des réponses
- **Statistiques avancées** incluant le pourcentage de réponses avec points d'interrogation

## Prérequis

- Robot Framework
- SeleniumLibrary
- Python 3.x
- Navigateur Chrome avec ChromeDriver
- Accès à Yopmail pour les codes de vérification

## Configuration

Modifiez les variables dans `ressources/variables.robot` selon votre environnement :
- URLs de test
- Identifiants de connexion
- Paramètres de navigateur
- Timeouts et délais

## Détection des Points d'Interrogation

Le système détecte automatiquement si les réponses de l'assistant AI se terminent par un point d'interrogation (?) :

- **Détection automatique** : Analyse chaque réponse pour identifier la présence de "?"
- **Métriques incluses** : Présence/absence du point d'interrogation dans tous les rapports
- **Statistiques** : Pourcentage de réponses avec points d'interrogation
- **Documentation** : Information incluse dans les logs, rapports Word et statistiques

### Exemple de sortie :
```
Question Mark at End: OUI/NON
Réponses avec Point d'Interrogation: 3/8 (37.5%)
```

### Script de démonstration :
```bash
python demo_question_mark_detection.py
```

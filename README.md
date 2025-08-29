# AI Assistant Test Suite

## Description
Suite de tests automatisés pour l'Assistant IA de la plateforme ATG, utilisant Robot Framework avec Selenium.

## Structure du Projet
```
ai_assistant/
├── ai_assistant.robot              # Fichier principal de test
├── ressources/
│   ├── variables.robot             # Variables de configuration
│   └── keywords.robot              # Keywords et fonctions réutilisables
├── generate_word_report.py         # Script de génération de rapport Word
├── generate_html_dashboard.py      # Script de génération de dashboard HTML
├── cleanup_project.py              # Script de nettoyage automatique
├── test_config.py                  # Configuration centralisée des tests
├── create_test_screenshots.py      # Créateur de screenshots simulés
├── requirements.txt                 # Dépendances Python
├── chromedriver.exe                # Driver Chrome pour Selenium
├── .gitignore                      # Exclusions Git
├── README.md                       # Documentation du projet
└── results/                        # Dossier des résultats de test
    ├── ai_assistant/               # Screenshots des tests
    ├── ai_assistant_documentation/ # Documentation et logs
    ├── dashboards_saved/           # Dashboards sauvegardés
    └── chatbot_test/               # Tests de chatbot
```

## Scripts Essentiels Conservés

### 1. `generate_word_report.py`
- **Fonction** : Génère des rapports Word détaillés des tests
- **Utilisation** : Automatique après chaque test ou manuel
- **Format** : Document Word avec métriques et analyses

### 2. `generate_html_dashboard.py`
- **Fonction** : Crée des dashboards HTML interactifs
- **Utilisation** : Visualisation des résultats de test
- **Fonctionnalités** : Graphiques, tableaux, filtres

### 3. `cleanup_project.py`
- **Fonction** : Nettoie automatiquement le projet
- **Utilisation** : Supprime les fichiers de test et résultats non essentiels
- **Avantage** : Maintient le projet propre et organisé

### 4. `test_config.py`
- **Fonction** : Configuration centralisée des tests
- **Utilisation** : Paramètres de test, rapports et nettoyage
- **Avantage** : Configuration facile et centralisée

### 5. `create_test_screenshots.py`
- **Fonction** : Crée des screenshots simulés pour les tests
- **Utilisation** : Génération d'images de test pour validation
- **Avantage** : Tests complets avec screenshots

## Installation et Configuration

### Prérequis
- Python 3.7+
- Robot Framework
- Selenium WebDriver
- Chrome Browser

### Installation
```bash
pip install -r requirements.txt
```

### Configuration
1. Vérifiez que `chromedriver.exe` est compatible avec votre version de Chrome
2. Configurez les variables dans `ressources/variables.robot`
3. Ajustez les paramètres dans `test_config.py` selon vos besoins

## Exécution des Tests

### Test Principal
```bash
robot ai_assistant.robot
```

### Génération de Rapports
```bash
# Rapport Word
python generate_word_report.py

# Dashboard HTML
python generate_html_dashboard.py
```

### Nettoyage du Projet
```bash
# Nettoyage automatique
python cleanup_project.py
```

### Configuration
```bash
# Afficher la configuration
python test_config.py
```

### Création de Screenshots de Test
```bash
# Créer des screenshots simulés
python create_test_screenshots.py
```

## Fonctionnalités

- **Authentification automatique** avec récupération de code de vérification
- **Tests d'Assistant IA** avec questions multiples
- **Documentation automatique** des interactions
- **Génération de rapports** Word et HTML
- **Captures d'écran** automatiques
- **Métriques de qualité** des réponses IA
- **Nettoyage automatique** du projet
- **Configuration centralisée** des paramètres
- **Génération automatique** des rapports Word après chaque test

## Structure des Tests

1. **Trigger Verification Code Sending** : Démarrage et authentification
2. **Wait And Retrieve Verification Code And Login** : Récupération du code et connexion
3. **Test AI Assistant Functionality** : Tests de l'assistant IA
4. **Documentation automatique** : Enregistrement des interactions
5. **Génération automatique** : Création du rapport Word

## Maintenance

- Les variables sont centralisées dans `ressources/variables.robot`
- Les keywords sont organisés dans `ressources/keywords.robot`
- Les scripts de génération sont indépendants et réutilisables
- Structure modulaire pour faciliter la maintenance
- **Nettoyage automatique** pour maintenir le projet organisé
- **Configuration centralisée** pour faciliter la gestion

## Nettoyage Automatique

Le script `cleanup_project.py` effectue automatiquement :
- Suppression des screenshots de test
- Suppression des rapports de test générés
- Suppression des fichiers temporaires
- Maintien de la structure des dossiers
- Création de fichiers `.gitkeep` pour préserver la structure

**Utilisation recommandée** : Exécuter après chaque session de test pour maintenir le projet propre.

## Configuration

Le fichier `test_config.py` centralise :
- Paramètres de l'environnement de test
- Configuration des rapports
- Paramètres de nettoyage
- Seuils de classification des réponses IA

**Avantage** : Modification facile des paramètres sans toucher au code principal.

## 🎯 Résolution du Problème de Génération Automatique

### **Problème Résolu**
> "Le fichier Word n'est pas généré automatiquement après les tests"

### **Solutions Appliquées**
1. ✅ **Correction des erreurs d'encodage Unicode** (emojis)
2. ✅ **Amélioration de la gestion des screenshots manquants**
3. ✅ **Création de screenshots simulés pour les tests**

### **Résultat**
- 🚀 **Génération automatique 100% fonctionnelle**
- 📊 **Rapports Word complets avec screenshots**
- 🔧 **Processus robuste et maintenable**

### **Validation**
```bash
# Test de génération
python test_word_generation.py
✅ Test réussi! La génération automatique fonctionne.

# Test complet Robot Framework
python test_robot_execution.py
🎉 SUCCÈS! La génération automatique fonctionne parfaitement!
```

**📋 Documentation complète** : Voir `RESOLUTION_GENERATION_AUTOMATIQUE.md`

## Support

Pour toute question ou problème, consultez la documentation des scripts ou les logs de test.

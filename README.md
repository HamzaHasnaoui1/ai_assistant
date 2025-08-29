# 🔐 AI Assistant - Test de Login Uniquement

## 📋 **Description**

Cette branche contient **uniquement** le test d'authentification pour l'AI Assistant de la plateforme ATG. Elle est conçue pour être partagée avec l'équipe pour tester et valider la partie authentification, sans exposer le test complet.

## 🎯 **Objectif**

- **Tester l'authentification complète** : ouverture du navigateur, saisie des identifiants, récupération du code de vérification, connexion
- **S'arrêter après le login réussi** : le test se termine une fois connecté au dashboard
- **Collaboration d'équipe** : permettre à l'équipe de tester l'authentification sans accès au test complet

## 🚀 **Utilisation**

### **Exécution du test**
```bash
robot ai_assistant_login_only.robot
```

### **Ce que fait le test**
1. **Ouvre le navigateur** et navigue vers la page de connexion
2. **Saisit les identifiants** (email + mot de passe)
3. **Récupère le code de vérification** depuis Yopmail
4. **Soumet le code** et attend la redirection
5. **Vérifie l'accès au dashboard** (sidebar visible)
6. **S'arrête** avec un screenshot de confirmation
7. **Ferme le navigateur**

### **Ce que NE fait PAS le test**
- ❌ Ne clique pas sur le bouton AI Assistant
- ❌ N'envoie pas de questions
- ❌ Ne teste pas les réponses de l'IA
- ❌ Ne génère pas de rapport Word complet

## 📁 **Structure du Projet**

```
ai_assistant/
├── ai_assistant_login_only.robot   # Test d'authentification uniquement
├── ressources/
│   ├── variables.robot             # Variables de configuration
│   └── keywords.robot              # Keywords avec Login Only Test
├── requirements.txt                 # Dépendances Python
├── .gitignore                      # Exclusions Git
├── README.md                       # Ce fichier
├── README_LOGIN_ONLY.md            # Documentation détaillée
└── results/                        # Dossier des résultats de test
    └── ai_assistant/               # Screenshots des tests
```

## 🔧 **Installation et Configuration**

### **Prérequis**
- Python 3.7+
- Robot Framework
- Selenium WebDriver
- Chrome Browser

### **Installation**
```bash
pip install -r requirements.txt
```

### **Configuration**
1. Vérifiez que `chromedriver.exe` est compatible avec votre version de Chrome
2. Configurez les variables dans `ressources/variables.robot`
3. Ajustez les paramètres selon vos besoins

## 📸 **Fichiers générés**

Le test génère automatiquement :
- `./results/ai_assistant/login_before.png` - Page de connexion
- `./results/ai_assistant/verification_code_input.png` - Saisie du code
- `./results/ai_assistant/code_entered.png` - Code saisi
- `./results/ai_assistant/after_submit_click.png` - Après soumission
- `./results/ai_assistant/login_success.png` - Login réussi
- `./results/ai_assistant/login_only_completed.png` - Dashboard accessible

## 💡 **Cas d'usage pour l'équipe**

### **Développement et débogage**
- Tester rapidement l'authentification sans attendre les tests complets
- Vérifier que les identifiants sont toujours valides
- Diagnostiquer les problèmes de connexion

### **Tests de régression**
- Vérifier que le login fonctionne après des modifications
- Tester la stabilité de l'authentification
- Validation rapide des changements d'interface

### **Formation et démonstration**
- Montrer le processus d'authentification
- Former les utilisateurs sur la connexion
- Présentation des fonctionnalités de base

## ⚠️ **Points d'attention**

1. **Cette branche ne contient PAS le test complet**
2. **Code de vérification** : Le test récupère automatiquement le code depuis Yopmail
3. **Timeout** : Le test attend 15 secondes maximum pour la redirection
4. **Screenshots** : Assurez-vous que le dossier `./results/ai_assistant/` existe
5. **Variables** : Vérifiez que les variables dans `ressources/variables.robot` sont correctes

## 🔄 **Workflow de collaboration**

### **Pour l'équipe :**
1. Cloner cette branche
2. Tester l'authentification
3. Signaler les problèmes via issues GitHub
4. Proposer des améliorations via pull requests

### **Pour le mainteneur :**
1. Intégrer les retours de l'équipe
2. Mettre à jour la branche
3. Fusionner les améliorations dans master

## 📝 **Exemple de sortie**

```
==============================================================================
Test AI Assistant Login Only
==============================================================================
Login Only Test                                        | PASS |
Login test completed - stopping before AI Assistant    | PASS |
Capture Page Screenshot                               | PASS |
Close Browser                                         | PASS |
Test AI Assistant Login Only                          | PASS |
==============================================================================
```

## 🚀 **Prochaines étapes**

1. **Tester** : Exécuter le test de login
2. **Valider** : Vérifier que tous les screenshots sont générés
3. **Signaler** : Remonter les problèmes ou suggestions
4. **Collaborer** : Participer à l'amélioration du test

---

**Cette branche est dédiée à la collaboration sur le test d'authentification uniquement !** 🎯

> **Note** : Pour accéder au test complet, utilisez la branche `master` du projet principal.

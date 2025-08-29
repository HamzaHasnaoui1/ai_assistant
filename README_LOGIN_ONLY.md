# 🔐 Test de Login Uniquement - AI Assistant

## 📋 **Description**

Ce fichier `ai_assistant_login_only.robot` permet de tester **uniquement la partie authentification** de l'application AI Assistant, sans procéder aux tests de fonctionnalité.

## 🎯 **Objectif**

- **Tester l'authentification complète** : ouverture du navigateur, saisie des identifiants, récupération du code de vérification, connexion
- **S'arrêter après le login réussi** : le test se termine une fois connecté au dashboard


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



## 📁 **Fichiers générés**

Le test génère uniquement :
- `./results/ai_assistant/login_before.png` - Page de connexion
- `./results/ai_assistant/verification_code_input.png` - Saisie du code
- `./results/ai_assistant/code_entered.png` - Code saisi
- `./results/ai_assistant/after_submit_click.png` - Après soumission
- `./results/ai_assistant/login_success.png` - Login réussi
- `./results/ai_assistant/login_only_completed.png` - Dashboard accessible

## 🔧 **Configuration**

Le test utilise les mêmes variables que le test complet :
- `${YOPMAIL_EMAIL}` - Email pour la connexion
- `${YOPMAIL_PASSWORD}` - Mot de passe
- `${UAT_BASE_URL}` - URL de l'application
- `${BROWSER}` - Navigateur à utiliser

## 💡 **Cas d'usage**

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

1. **Code de vérification** : Le test récupère automatiquement le code depuis Yopmail
2. **Timeout** : Le test attend 15 secondes maximum pour la redirection
3. **Screenshots** : Assurez-vous que le dossier `./results/ai_assistant/` existe
4. **Variables** : Vérifiez que les variables dans `ressources/variables.robot` sont correctes

## 🔄 **Différences avec le test complet**

| Aspect | Test Complet | Test Login Uniquement |
|--------|--------------|----------------------|
| **Durée** | ~3-5 minutes | ~1-2 minutes |
| **Fonctionnalités** | Login + AI Assistant | Login uniquement |
| **Screenshots** | Tous les écrans | Écrans de connexion |
| **Rapport Word** | Automatique | Aucun |
| **Utilisation** | Tests complets | Tests rapides |

## 📝 **Exemple de sortie**

```
==============================================================================
Test AI Assistant Login Only
==============================================================================
Trigger Verification Code Sending                    | PASS |
Wait And Retrieve Verification Code And Login        | PASS |
Login test completed - stopping before AI Assistant  | PASS |
Capture Page Screenshot                             | PASS |
Close Browser                                       | PASS |
Test AI Assistant Login Only                        | PASS |
==============================================================================
```

## 🚀 **Prochaines étapes**

Si le test de login fonctionne correctement, vous pouvez :
1. **Exécuter le test complet** : `robot ai_assistant.robot`
2. **Modifier les variables** dans `ressources/variables.robot`
3. **Personnaliser le test** selon vos besoins
4. **Ajouter des validations** supplémentaires si nécessaire

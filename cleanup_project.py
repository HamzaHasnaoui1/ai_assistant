#!/usr/bin/env python3
"""
Script de nettoyage automatique pour le projet AI Assistant Test Suite
Supprime les fichiers de test et résultats non essentiels
"""

import os
import glob
import shutil
from datetime import datetime, timedelta

def cleanup_project():
    """Nettoie le projet en supprimant les fichiers non essentiels"""
    
    print("🧹 Début du nettoyage du projet AI Assistant...")
    
    # Fichiers à supprimer
    files_to_remove = [
        # Screenshots de test
        "selenium-screenshot-*.png",
        
        # Rapports de test générés
        "results/ai_assistant_documentation/test_report_*.docx",
        "results/ai_assistant_documentation/dashboard_test_*.html",
        "results/ai_assistant_documentation/current_test_*.txt",
        "results/ai_assistant_documentation/~$st_report_*.docx",
        
        # Fichiers de rapport Robot Framework
        "report.html",
        "log.html",
        "output.xml",
        
        # Dossiers Python
        "__pycache__",
    ]
    
    # Supprimer les fichiers
    for pattern in files_to_remove:
        files = glob.glob(pattern)
        for file_path in files:
            try:
                if os.path.isfile(file_path):
                    os.remove(file_path)
                    print(f"✅ Supprimé: {file_path}")
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
                    print(f"✅ Supprimé: {file_path}")
            except Exception as e:
                print(f"❌ Erreur lors de la suppression de {file_path}: {e}")
    
    # Nettoyer les dossiers de résultats (garder la structure)
    results_dirs = [
        "results/ai_assistant_documentation/screenshots",
        "results/ai_assistant",
        "results/dashboards_saved",
        "results/chatbot_test"
    ]
    
    for dir_path in results_dirs:
        if os.path.exists(dir_path):
            try:
                # Supprimer le contenu mais garder le dossier
                for item in os.listdir(dir_path):
                    item_path = os.path.join(dir_path, item)
                    if os.path.isfile(item_path):
                        os.remove(item_path)
                        print(f"✅ Supprimé: {item_path}")
                    elif os.path.isdir(item_path):
                        shutil.rmtree(item_path)
                        print(f"✅ Supprimé: {item_path}")
                
                # Créer un fichier .gitkeep pour maintenir la structure
                gitkeep_file = os.path.join(dir_path, ".gitkeep")
                if not os.path.exists(gitkeep_file):
                    with open(gitkeep_file, 'w') as f:
                        f.write("# Dossier maintenu pour la structure du projet\n")
                    print(f"📁 Créé: {gitkeep_file}")
                    
            except Exception as e:
                print(f"❌ Erreur lors du nettoyage de {dir_path}: {e}")
    
    # Créer un fichier .gitkeep dans le dossier principal de documentation
    doc_dir = "results/ai_assistant_documentation"
    if os.path.exists(doc_dir):
        gitkeep_file = os.path.join(doc_dir, ".gitkeep")
        if not os.path.exists(gitkeep_file):
            with open(gitkeep_file, 'w') as f:
                f.write("# Dossier maintenu pour la structure du projet\n")
            print(f"📁 Créé: {gitkeep_file}")
    
    print("\n🎉 Nettoyage terminé !")
    print("\n📋 Fichiers conservés:")
    print("   - ai_assistant.robot (fichier principal de test)")
    print("   - ressources/ (variables et keywords)")
    print("   - generate_word_report.py (génération rapport Word)")
    print("   - generate_html_dashboard.py (génération dashboard HTML)")
    print("   - requirements.txt (dépendances)")
    print("   - README.md (documentation)")
    print("   - .gitignore (exclusions Git)")
    print("   - chromedriver.exe (driver Chrome)")

if __name__ == "__main__":
    cleanup_project()

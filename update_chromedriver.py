#!/usr/bin/env python3
"""
Script pour mettre à jour automatiquement ChromeDriver
Télécharge la version compatible avec votre version de Chrome
"""

import os
import sys
import subprocess
import re
import requests
import zipfile
import platform
from pathlib import Path

def get_chrome_version():
    """Récupère la version de Chrome installée"""
    try:
        if platform.system() == "Windows":
            # Windows - vérifier le registre ou le chemin d'installation
            chrome_paths = [
                r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                os.path.expanduser(r"~\AppData\Local\Google\Chrome\Application\chrome.exe")
            ]
            
            for path in chrome_paths:
                if os.path.exists(path):
                    result = subprocess.run([path, "--version"], 
                                         capture_output=True, text=True, shell=True)
                    if result.returncode == 0:
                        version_match = re.search(r'Chrome\s+(\d+)\.', result.stdout)
                        if version_match:
                            return int(version_match.group(1))
            
            # Fallback: essayer de lancer Chrome
            result = subprocess.run(["chrome", "--version"], 
                                 capture_output=True, text=True, shell=True)
            if result.returncode == 0:
                version_match = re.search(r'Chrome\s+(\d+)\.', result.stdout)
                if version_match:
                    return int(version_match.group(1))
                    
        elif platform.system() == "Darwin":  # macOS
            result = subprocess.run(["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "--version"], 
                                 capture_output=True, text=True)
            if result.returncode == 0:
                version_match = re.search(r'Chrome\s+(\d+)\.', result.stdout)
                if version_match:
                    return int(version_match.group(1))
        else:  # Linux
            result = subprocess.run(["google-chrome", "--version"], 
                                 capture_output=True, text=True)
            if result.returncode == 0:
                version_match = re.search(r'Chrome\s+(\d+)\.', result.stdout)
                if version_match:
                    return int(version_match.group(1))
                    
    except Exception as e:
        print(f"Erreur lors de la récupération de la version Chrome: {e}")
    
    return None

def get_chromedriver_version():
    """Récupère la version de ChromeDriver installée"""
    try:
        result = subprocess.run(["chromedriver", "--version"], 
                             capture_output=True, text=True)
        if result.returncode == 0:
            version_match = re.search(r'ChromeDriver\s+(\d+)\.', result.stdout)
            if version_match:
                return int(version_match.group(1))
    except Exception as e:
        print(f"ChromeDriver non trouvé ou erreur: {e}")
    
    return None

def download_chromedriver(chrome_version):
    """Télécharge la version compatible de ChromeDriver"""
    try:
        # URL de base pour ChromeDriver
        base_url = "https://chromedriver.storage.googleapis.com"
        
        # Trouver la version compatible (même version majeure)
        chromedriver_version = chrome_version
        
        # Télécharger la liste des versions disponibles
        versions_url = f"{base_url}/LATEST_RELEASE_{chromedriver_version}"
        response = requests.get(versions_url)
        
        if response.status_code == 200:
            chromedriver_version = response.text.strip()
            print(f"Version ChromeDriver compatible trouvée: {chromedriver_version}")
        else:
            print(f"Impossible de trouver la version compatible, utilisation de la version {chromedriver_version}")
        
        # Déterminer la plateforme
        if platform.system() == "Windows":
            platform_name = "win32"
        elif platform.system() == "Darwin":
            platform_name = "mac64"
        else:
            platform_name = "linux64"
        
        # URL de téléchargement
        download_url = f"{base_url}/{chromedriver_version}/chromedriver_{platform_name}.zip"
        
        print(f"Téléchargement de ChromeDriver depuis: {download_url}")
        
        # Télécharger
        response = requests.get(download_url)
        if response.status_code == 200:
            # Sauvegarder le fichier
            zip_path = "chromedriver.zip"
            with open(zip_path, "wb") as f:
                f.write(response.content)
            
            # Extraire
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(".")
            
            # Nettoyer
            os.remove(zip_path)
            
            # Rendre exécutable sur Unix
            if platform.system() != "Windows":
                os.chmod("chromedriver", 0o755)
            
            print("ChromeDriver téléchargé et installé avec succès!")
            return True
        else:
            print(f"Erreur lors du téléchargement: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"Erreur lors du téléchargement: {e}")
        return False

def main():
    print("=== Mise à jour automatique de ChromeDriver ===\n")
    
    # Vérifier la version de Chrome
    chrome_version = get_chrome_version()
    if chrome_version is None:
        print("❌ Impossible de détecter la version de Chrome")
        print("Assurez-vous que Google Chrome est installé")
        return False
    
    print(f"✅ Version Chrome détectée: {chrome_version}")
    
    # Vérifier la version de ChromeDriver
    chromedriver_version = get_chromedriver_version()
    if chromedriver_version is not None:
        print(f"✅ Version ChromeDriver actuelle: {chromedriver_version}")
        
        if chromedriver_version == chrome_version:
            print("✅ ChromeDriver est déjà à jour!")
            return True
        else:
            print(f"⚠️  Versions incompatibles: Chrome {chrome_version} vs ChromeDriver {chromedriver_version}")
    else:
        print("⚠️  ChromeDriver non trouvé")
    
    # Télécharger la version compatible
    print(f"\n🔄 Téléchargement de ChromeDriver version {chrome_version}...")
    success = download_chromedriver(chrome_version)
    
    if success:
        print("\n✅ ChromeDriver mis à jour avec succès!")
        print("Vous pouvez maintenant exécuter vos tests Robot Framework")
        return True
    else:
        print("\n❌ Échec de la mise à jour de ChromeDriver")
        print("Veuillez télécharger manuellement depuis: https://chromedriver.chromium.org/")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

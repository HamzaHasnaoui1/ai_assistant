#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour générer automatiquement des rapports Word à partir des fichiers current_test_*.txt
Génère un rapport Word professionnel avec mise en forme pour chaque test
"""

import os
import glob
import re
from datetime import datetime
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml.shared import OxmlElement, qn
from docx.enum.table import WD_TABLE_ALIGNMENT

class WordReportGenerator:
    def __init__(self, output_dir="./results"):
        self.output_dir = output_dir
        self.ai_doc_dir = os.path.join(output_dir, "ai_assistant_documentation")
        
    def find_current_test_files(self):
        """Trouve tous les fichiers current_test_*.txt"""
        pattern = os.path.join(self.ai_doc_dir, "current_test_*.txt")
        return glob.glob(pattern)
    
    def parse_test_file(self, file_path):
        """Parse le contenu d'un fichier de test et extrait les informations"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extraire le nom du fichier de test
            test_name = os.path.basename(file_path)
            
            # Extraire les interactions en utilisant une approche différente
            interactions = []
            
            # Chercher toutes les occurrences de "AI ASSISTANT INTERACTION DOCUMENTATION"
            import re
            pattern = r'AI ASSISTANT INTERACTION DOCUMENTATION(.*?)(?=AI ASSISTANT INTERACTION DOCUMENTATION|$)'
            matches = re.findall(pattern, content, re.DOTALL)
            
            for match in matches:
                # Ajouter le titre de section au début
                section = "AI ASSISTANT INTERACTION DOCUMENTATION" + match
                # Extraire les informations de l'interaction
                interaction = self.extract_interaction_info(section)
                if interaction:
                    interactions.append(interaction)
            
            # Si aucune interaction trouvée avec la nouvelle méthode, essayer l'ancienne
            if not interactions:
                print("⚠️ Nouvelle méthode de parsing échouée, essai avec l'ancienne méthode...")
                sections = content.split("========================================")
                
                for section in sections:
                    if "AI ASSISTANT INTERACTION DOCUMENTATION" in section and len(section.strip()) > 100:
                        # Extraire les informations de l'interaction
                        interaction = self.extract_interaction_info(section)
                        if interaction:
                            interactions.append(interaction)
            
            return {
                'test_name': test_name,
                'file_path': file_path,
                'interactions': interactions,
                'total_interactions': len(interactions)
            }
            
        except Exception as e:
            print(f"Erreur lors du parsing de {file_path}: {e}")
            return None
    
    def extract_interaction_info(self, section):
        """Extrait les informations d'une interaction depuis une section"""
        try:
            # Extraire le timestamp
            timestamp_match = re.search(r'Timestamp: (.+)', section)
            timestamp = timestamp_match.group(1).strip() if timestamp_match else "N/A"
            
            # Extraire la question
            question_match = re.search(r'Question Asked:\s*\n"([^"]+)"', section, re.DOTALL)
            question = question_match.group(1).strip() if question_match else "N/A"
            
            # Extraire la réponse
            answer_match = re.search(r'AI Response:\s*\n"([^"]+)"', section, re.DOTALL)
            answer = answer_match.group(1).strip() if answer_match else "N/A"
            
            # Extraire la catégorie
            category_match = re.search(r'Response Category: (.+)', section)
            category = category_match.group(1).strip() if category_match else "N/A"
            
            # Extraire la longueur
            length_match = re.search(r'Response Length: (\d+) characters', section)
            length = length_match.group(1) if length_match else "N/A"
            
            # Extraire le nombre de mots
            words_match = re.search(r'Word Count: (\d+)', section)
            words = words_match.group(1) if words_match else "N/A"
            
            # Extraire le score de qualité
            quality_match = re.search(r'Quality Score: ([\d.]+)%', section)
            quality = quality_match.group(1) if quality_match else "N/A"
            
            # Extraire la présence du point d'interrogation
            question_mark_match = re.search(r'Question Mark at End: (.+)', section)
            question_mark = question_mark_match.group(1).strip() if question_mark_match else "N/A"
            
            # Extraire les chemins des screenshots
            q_screenshot_match = re.search(r'Question Screenshot: (.+)', section)
            q_screenshot = q_screenshot_match.group(1).strip() if q_screenshot_match else "N/A"
            
            r_screenshot_match = re.search(r'Response Screenshot: (.+)', section)
            r_screenshot = r_screenshot_match.group(1).strip() if r_screenshot_match else "N/A"
            
            return {
                'timestamp': timestamp,
                'question': question,
                'answer': answer,
                'category': category,
                'length': length,
                'words': words,
                'quality': quality,
                'question_mark': question_mark,
                'q_screenshot': q_screenshot,
                'r_screenshot': r_screenshot
            }
            
        except Exception as e:
            print(f"Erreur lors de l'extraction des informations: {e}")
            return None
    
    def create_word_document(self, test_data):
        """Crée un document Word pour un test donné"""
        try:
            # Créer un nouveau document
            doc = Document()
            
            # Titre principal
            title = doc.add_heading('Rapport de Test - Assistant IA', 0)
            title.alignment = WD_ALIGN_PARAGRAPH.CENTER
            
            # Ajouter un logo ou image de l'entreprise (optionnel)
            # doc.add_picture('logo_atg.png', width=Inches(2))
            
            # Informations du test
            doc.add_heading('Informations Générales', level=1)
            
            info_table = doc.add_table(rows=1, cols=2)
            info_table.style = 'Table Grid'
            
            # En-têtes
            header_cells = info_table.rows[0].cells
            header_cells[0].text = 'Propriété'
            header_cells[1].text = 'Valeur'
            
            # Informations
            info_data = [
                ('Nom du Test', test_data['test_name']),
                ('Fichier Source', test_data['file_path']),
                ('Nombre Total d\'Interactions', str(test_data['total_interactions'])),
                ('Date de Génération', datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            ]
            
            for prop, value in info_data:
                row_cells = info_table.add_row().cells
                row_cells[0].text = prop
                row_cells[1].text = value
            
            # Résumé des interactions
            doc.add_heading('Résumé des Interactions', level=1)
            
            if test_data['interactions']:
                summary_table = doc.add_table(rows=1, cols=6)
                summary_table.style = 'Table Grid'
                
                # En-têtes du résumé
                summary_headers = summary_table.rows[0].cells
                summary_headers[0].text = 'N°'
                summary_headers[1].text = 'Timestamp'
                summary_headers[2].text = 'Question'
                summary_headers[3].text = 'Catégorie'
                summary_headers[4].text = 'Score Qualité'
                summary_headers[5].text = 'Point d\'Interrogation'
                
                # Données du résumé
                for i, interaction in enumerate(test_data['interactions'], 1):
                    row_cells = summary_table.add_row().cells
                    row_cells[0].text = str(i)
                    row_cells[1].text = interaction['timestamp']
                    row_cells[2].text = interaction['question'][:50] + "..." if len(interaction['question']) > 50 else interaction['question']
                    row_cells[3].text = interaction['category']
                    row_cells[4].text = f"{interaction['quality']}%"
                    row_cells[5].text = interaction['question_mark']
            
            # Détails des interactions
            doc.add_heading('Détails des Interactions', level=1)
            
            for i, interaction in enumerate(test_data['interactions'], 1):
                # Titre de l'interaction
                doc.add_heading(f'Interaction {i}', level=2)
                
                # Section Question
                doc.add_heading('Question', level=3)
                doc.add_paragraph(interaction['question'])
                
                # Section Réponse IA
                doc.add_heading('Réponse IA', level=3)
                doc.add_paragraph(interaction['answer'])
                
                # Tableau des métriques
                metrics_table = doc.add_table(rows=1, cols=2)
                metrics_table.style = 'Table Grid'
                metrics_table.alignment = WD_TABLE_ALIGNMENT.CENTER
                
                # En-têtes
                metrics_headers = metrics_table.rows[0].cells
                metrics_headers[0].text = 'Métrique'
                metrics_headers[1].text = 'Valeur'
                
                # Métriques
                metrics_data = [
                    ('Timestamp', interaction['timestamp']),
                    ('Catégorie', interaction['category']),
                    ('Longueur', f"{interaction['length']} caractères"),
                    ('Mots', interaction['words']),
                    ('Score Qualité', f"{interaction['quality']}%"),
                    ('Point d\'Interrogation', interaction['question_mark'])
                ]
                
                for prop, value in metrics_data:
                    row_cells = metrics_table.add_row().cells
                    row_cells[0].text = prop
                    row_cells[1].text = value
                
                # Section Captures d'écran
                doc.add_heading('Captures d\'écran', level=3)
                
                # Captures d'écran avec gestion d'erreur
                self.add_screenshots_to_document(doc, interaction, i)
                
                # Ajouter un espace entre les interactions
                doc.add_paragraph()
            
            # Statistiques détaillées
            if test_data['interactions']:
                doc.add_heading('Statistiques Détaillées', level=1)
                
                # Calculer les statistiques
                categories = [i['category'] for i in test_data['interactions']]
                qualities = [float(i['quality']) for i in test_data['interactions'] if i['quality'] != 'N/A']
                lengths = [int(i['length']) for i in test_data['interactions'] if i['length'] != 'N/A']
                words = [int(i['words']) for i in test_data['interactions'] if i['words'] != 'N/A']
                question_marks = [i['question_mark'] for i in test_data['interactions']]
                
                # Statistiques principales
                main_stats_data = [
                    ('Nombre Total d\'Interactions', str(len(test_data['interactions']))),
                    ('Catégories Présentes', ', '.join(set(categories))),
                    ('Score Qualité Moyen', f"{sum(qualities)/len(qualities):.2f}%" if qualities else "N/A"),
                    ('Longueur Moyenne', f"{sum(lengths)/len(lengths):.0f} caractères" if lengths else "N/A"),
                    ('Mots Moyens', f"{sum(words)/len(words):.0f} mots" if words else "N/A"),
                    ('Réponses avec Point d\'Interrogation', f"{question_marks.count('OUI')}/{len(question_marks)} ({question_marks.count('OUI')/len(question_marks)*100:.1f}%)" if question_marks else "N/A")
                ]
                
                main_stats_table = doc.add_table(rows=1, cols=2)
                main_stats_table.style = 'Table Grid'
                main_stats_table.alignment = WD_TABLE_ALIGNMENT.CENTER
                
                # En-têtes
                main_stats_headers = main_stats_table.rows[0].cells
                main_stats_headers[0].text = 'Métrique'
                main_stats_headers[1].text = 'Valeur'
                
                # Statistiques principales
                for metric, value in main_stats_data:
                    row_cells = main_stats_table.add_row().cells
                    row_cells[0].text = metric
                    row_cells[1].text = value
                
                doc.add_paragraph()
                
                # Statistiques des extrêmes
                if qualities:
                    extreme_stats_data = [
                        ('Score Qualité Maximum', f"{max(qualities):.2f}%"),
                        ('Score Qualité Minimum', f"{min(qualities):.2f}%"),
                        ('Écart de Qualité', f"{max(qualities) - min(qualities):.2f}%")
                    ]
                    
                    extreme_stats_table = doc.add_table(rows=1, cols=2)
                    extreme_stats_table.style = 'Table Grid'
                    extreme_stats_table.alignment = WD_TABLE_ALIGNMENT.CENTER
                    
                    # En-têtes
                    extreme_headers = extreme_stats_table.rows[0].cells
                    extreme_headers[0].text = 'Métrique'
                    extreme_headers[1].text = 'Valeur'
                    
                    # Statistiques des extrêmes
                    for metric, value in extreme_stats_data:
                        row_cells = extreme_stats_table.add_row().cells
                        row_cells[0].text = metric
                        row_cells[1].text = value
                
                doc.add_paragraph()
                
                # Analyse par catégorie
                category_analysis = {}
                for interaction in test_data['interactions']:
                    cat = interaction['category']
                    if cat not in category_analysis:
                        category_analysis[cat] = {'count': 0, 'qualities': [], 'lengths': []}
                    
                    category_analysis[cat]['count'] += 1
                    if interaction['quality'] != 'N/A':
                        category_analysis[cat]['qualities'].append(float(interaction['quality']))
                    if interaction['length'] != 'N/A':
                        category_analysis[cat]['lengths'].append(int(interaction['length']))
                
                if category_analysis:
                    doc.add_heading('Analyse par Catégorie', level=2)
                    
                    cat_table = doc.add_table(rows=1, cols=4)
                    cat_table.style = 'Table Grid'
                    cat_table.alignment = WD_TABLE_ALIGNMENT.CENTER
                    
                    # En-têtes
                    cat_headers = cat_table.rows[0].cells
                    cat_headers[0].text = 'Catégorie'
                    cat_headers[1].text = 'Nombre'
                    cat_headers[2].text = 'Qualité Moyenne'
                    cat_headers[3].text = 'Longueur Moyenne'
                    
                    # Données par catégorie
                    for cat, data in category_analysis.items():
                        row_cells = cat_table.add_row().cells
                        row_cells[0].text = cat
                        row_cells[1].text = str(data['count'])
                        
                        if data['qualities']:
                            avg_quality = sum(data['qualities']) / len(data['qualities'])
                            row_cells[2].text = f"{avg_quality:.2f}%"
                        else:
                            row_cells[2].text = "N/A"
                        
                        if data['lengths']:
                            avg_length = sum(data['lengths']) / len(data['lengths'])
                            row_cells[3].text = f"{avg_length:.0f} chars"
                        else:
                            row_cells[3].text = "N/A"
            
            # Galerie des captures d'écran
            if test_data['interactions']:
                doc.add_heading('Galerie des Captures d\'écran', level=1)
                self.add_summary_screenshots(doc, test_data)
            
            # Pied de page
            doc.add_paragraph()
            footer = doc.add_paragraph('Rapport généré automatiquement par le système de test ATG')
            footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
            
            return doc
            
        except Exception as e:
            print(f"Erreur lors de la création du document Word: {e}")
            return None
    
    def add_screenshots_to_document(self, doc, interaction, interaction_number):
        """Ajoute les captures d'écran au document Word"""
        try:
            # Captures d'écran de la question
            if interaction['q_screenshot'] != 'N/A':
                q_screenshot_path = interaction['q_screenshot']
                if os.path.exists(q_screenshot_path):
                    doc.add_paragraph(f'Question {interaction_number}:')
                    try:
                        # Insérer l'image avec une taille appropriée
                        doc.add_picture(q_screenshot_path, width=Inches(6))
                        doc.add_paragraph(f'Fichier: {os.path.basename(q_screenshot_path)}')
                    except Exception as e:
                        doc.add_paragraph(f'❌ Erreur lors de l\'insertion de l\'image: {e}')
                        doc.add_paragraph(f'Chemin: {q_screenshot_path}')
                else:
                    doc.add_paragraph(f'❌ Capture d\'écran question non trouvée: {q_screenshot_path}')
            else:
                doc.add_paragraph('Aucune capture d\'écran de question disponible')
            
            # Espace entre les captures
            doc.add_paragraph()
            
            # Captures d'écran de la réponse
            if interaction['r_screenshot'] != 'N/A':
                r_screenshot_path = interaction['r_screenshot']
                if os.path.exists(r_screenshot_path):
                    doc.add_paragraph(f'Réponse {interaction_number}:')
                    try:
                        # Insérer l'image avec une taille appropriée
                        doc.add_picture(r_screenshot_path, width=Inches(6))
                        doc.add_paragraph(f'Fichier: {os.path.basename(r_screenshot_path)}')
                    except Exception as e:
                        doc.add_paragraph(f'❌ Erreur lors de l\'insertion de l\'image: {e}')
                        doc.add_paragraph(f'Chemin: {r_screenshot_path}')
                else:
                    doc.add_paragraph(f'❌ Capture d\'écran réponse non trouvée: {r_screenshot_path}')
            else:
                doc.add_paragraph('Aucune capture d\'écran de réponse disponible')
            
            # Espace après les captures
            doc.add_paragraph()
            
        except Exception as e:
            doc.add_paragraph(f'❌ Erreur lors de l\'ajout des captures d\'écran: {e}')
    
    def add_summary_screenshots(self, doc, test_data):
        """Ajoute un résumé des captures d'écran à la fin du document"""
        try:
            doc.add_heading('Galerie des Captures d\'écran', level=1)
            
            # Créer un tableau pour organiser les captures
            screenshot_table = doc.add_table(rows=1, cols=2)
            screenshot_table.style = 'Table Grid'
            screenshot_table.alignment = WD_TABLE_ALIGNMENT.CENTER
            
            # En-têtes
            headers = screenshot_table.rows[0].cells
            headers[0].text = 'Question'
            headers[1].text = 'Réponse'
            
            # Ajouter les captures d'écran dans le tableau
            for i, interaction in enumerate(test_data['interactions'], 1):
                row_cells = screenshot_table.add_row().cells
                
                # Cellule Question
                if interaction['q_screenshot'] != 'N/A' and os.path.exists(interaction['q_screenshot']):
                    try:
                        row_cells[0].add_paragraph(f'Q{i}:')
                        row_cells[0].add_picture(interaction['q_screenshot'], width=Inches(2.5))
                    except:
                        row_cells[0].text = f'Q{i}: Image non disponible'
                else:
                    row_cells[0].text = f'Q{i}: Aucune image'
                
                # Cellule Réponse
                if interaction['r_screenshot'] != 'N/A' and os.path.exists(interaction['r_screenshot']):
                    try:
                        row_cells[1].add_paragraph(f'R{i}:')
                        row_cells[1].add_picture(interaction['r_screenshot'], width=Inches(2.5))
                    except:
                        row_cells[1].text = f'R{i}: Image non disponible'
                else:
                    row_cells[1].text = f'R{i}: Aucune image'
            
        except Exception as e:
            doc.add_paragraph(f'❌ Erreur lors de l\'ajout de la galerie: {e}')
    
    def save_word_document(self, doc, test_data):
        """Sauvegarde le document Word"""
        try:
            # Créer le nom du fichier Word
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            word_filename = f"rapport_test_{timestamp}.docx"
            word_path = os.path.join(self.ai_doc_dir, word_filename)
            
            # Sauvegarder le document
            doc.save(word_path)
            print(f"Rapport Word sauvegardé: {word_path}")
            
            return word_path
            
        except Exception as e:
            print(f"Erreur lors de la sauvegarde du document Word: {e}")
            return None
    
    def generate_all_reports(self):
        """Génère des rapports Word pour tous les tests trouvés"""
        print("Recherche des fichiers de test...")
        test_files = self.find_current_test_files()
        
        if not test_files:
            print("Aucun fichier de test trouvé.")
            return
        
        print(f"Trouvé {len(test_files)} fichier(s) de test.")
        
        for test_file in test_files:
            print(f"\nTraitement de: {test_file}")
            
            # Parser le fichier de test
            test_data = self.parse_test_file(test_file)
            if not test_data:
                print(f"Impossible de parser {test_file}")
                continue
            
            # Créer le document Word
            doc = self.create_word_document(test_data)
            if not doc:
                print(f"Impossible de créer le document Word pour {test_file}")
                continue
            
            # Sauvegarder le document
            word_path = self.save_word_document(doc, test_data)
            if word_path:
                print(f"Rapport Word généré avec succès: {word_path}")
            else:
                print(f"Échec de la sauvegarde du rapport Word pour {test_file}")
    
    def generate_report_for_latest_test(self):
        """Génère un rapport Word pour le test le plus récent"""
        test_files = self.find_current_test_files()
        
        if not test_files:
            print("Aucun fichier de test trouvé.")
            return None
        
        # Trier par date de modification (le plus récent en premier)
        test_files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
        latest_test = test_files[0]
        
        print(f"Génération du rapport pour le test le plus récent: {latest_test}")
        
        # Parser le fichier de test
        test_data = self.parse_test_file(latest_test)
        if not test_data:
            print(f"Impossible de parser {latest_test}")
            return None
        
        # Créer le document Word
        doc = self.create_word_document(test_data)
        if not doc:
            print(f"Impossible de créer le document Word pour {latest_test}")
            return None
        
        # Sauvegarder le document
        word_path = self.save_word_document(doc, test_data)
        if word_path:
            print(f"Rapport Word généré avec succès: {word_path}")
            return word_path
        else:
            print(f"Échec de la sauvegarde du rapport Word pour {latest_test}")
            return None

def main():
    """Fonction principale"""
    print("=== Générateur de Rapports Word pour Tests ATG ===")
    
    # Créer le générateur
    generator = WordReportGenerator()
    
    # Vérifier que le répertoire existe
    if not os.path.exists(generator.ai_doc_dir):
        print(f"Le répertoire {generator.ai_doc_dir} n'existe pas.")
        return
    
    # Générer le rapport pour le test le plus récent
    print("\nGénération du rapport pour le test le plus récent...")
    word_path = generator.generate_report_for_latest_test()
    
    if word_path:
        print(f"\n✅ Rapport Word généré avec succès: {word_path}")
    else:
        print("\n❌ Échec de la génération du rapport Word")

if __name__ == "__main__":
    main()

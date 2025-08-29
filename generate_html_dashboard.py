#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to generate an HTML dashboard showing the latest test information
and a button to display test history in a modal window
"""

import os
import glob
import re
from datetime import datetime
import json

class HTMLDashboardGenerator:
    def __init__(self, output_dir="./results"):
        self.output_dir = output_dir
        self.ai_doc_dir = os.path.join(output_dir, "ai_assistant_documentation")
        
    def find_current_test_files(self):
        """Finds all current_test_*.txt files"""
        pattern = os.path.join(self.ai_doc_dir, "current_test_*.txt")
        return glob.glob(pattern)
    
    def find_test_reports(self):
        """Finds all test_report_*.docx files"""
        pattern = os.path.join(self.ai_doc_dir, "test_report_*.docx")
        return glob.glob(pattern)
    
    def parse_test_file(self, file_path):
        """Parses the content of a test file and extracts information"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract test file name
            test_name = os.path.basename(file_path)
            
            # Extract interactions using regex pattern
            interactions = []
            pattern = r'AI ASSISTANT INTERACTION DOCUMENTATION(.*?)(?=AI ASSISTANT INTERACTION DOCUMENTATION|$)'
            matches = re.findall(pattern, content, re.DOTALL)
            
            for match in matches:
                section = "AI ASSISTANT INTERACTION DOCUMENTATION" + match
                interaction = self.extract_interaction_info(section)
                if interaction:
                    interactions.append(interaction)
            
            # If no interactions found, try alternative method
            if not interactions:
                sections = content.split("========================================")
                for section in sections:
                    if "AI ASSISTANT INTERACTION DOCUMENTATION" in section and len(section.strip()) > 100:
                        interaction = self.extract_interaction_info(section)
                        if interaction:
                            interactions.append(interaction)
            
            return {
                'test_name': test_name,
                'file_path': file_path,
                'interactions': interactions,
                'total_interactions': len(interactions),
                'modification_date': datetime.fromtimestamp(os.path.getmtime(file_path)).strftime('%Y-%m-%d %H:%M:%S')
            }
            
        except Exception as e:
            print(f"Error parsing {file_path}: {e}")
            return None
    
    def extract_interaction_info(self, section):
        """Extracts interaction information from a section"""
        try:
            # Extract timestamp
            timestamp_match = re.search(r'Timestamp: (.+)', section)
            timestamp = timestamp_match.group(1).strip() if timestamp_match else "N/A"
            
            # Extract question
            question_match = re.search(r'Question Asked:\s*\n"([^"]+)"', section, re.DOTALL)
            question = question_match.group(1).strip() if question_match else "N/A"
            
            # Extract answer
            answer_match = re.search(r'AI Response:\s*\n"([^"]+)"', section, re.DOTALL)
            answer = answer_match.group(1).strip() if answer_match else "N/A"
            
            # Extract category
            category_match = re.search(r'Response Category: (.+)', section)
            category = category_match.group(1).strip() if category_match else "N/A"
            
            # Extract length
            length_match = re.search(r'Response Length: (\d+) characters', section)
            length = length_match.group(1) if length_match else "N/A"
            
            # Extract word count
            words_match = re.search(r'Word Count: (\d+)', section)
            words = words_match.group(1) if words_match else "N/A"
            
            # Extract quality score
            quality_match = re.search(r'Quality Score: ([\d.]+)%', section)
            quality = quality_match.group(1) if quality_match else "N/A"
            
            # Extract question mark presence
            question_mark_match = re.search(r'Question Mark at End: (.+)', section)
            question_mark = question_mark_match.group(1).strip() if question_mark_match else "N/A"
            
            return {
                'timestamp': timestamp,
                'question': question,
                'answer': answer,
                'category': category,
                'length': length,
                'words': words,
                'quality': quality,
                'question_mark': question_mark
            }
            
        except Exception as e:
            print(f"Error extracting information: {e}")
            return None
    
    def get_test_history(self):
        """Gets the history of all tests"""
        test_files = self.find_current_test_files()
        history = []
        
        for test_file in test_files:
            test_data = self.parse_test_file(test_file)
            if test_data:
                # Calculate statistics
                if test_data['interactions']:
                    qualities = [float(i['quality']) for i in test_data['interactions'] if i['quality'] != 'N/A']
                    lengths = [int(i['length']) for i in test_data['interactions'] if i['length'] != 'N/A']
                    categories = [i['category'] for i in test_data['interactions']]
                    
                    avg_quality = sum(qualities)/len(qualities) if qualities else 0
                    avg_length = sum(lengths)/len(lengths) if lengths else 0
                    category_distribution = {cat: categories.count(cat) for cat in set(categories)}
                else:
                    avg_quality = 0
                    avg_length = 0
                    category_distribution = {}
                
                history.append({
                    'test_name': test_data['test_name'],
                    'date': test_data['modification_date'],
                    'total_interactions': test_data['total_interactions'],
                    'avg_quality': round(avg_quality, 2),
                    'avg_length': round(avg_length, 0),
                    'category_distribution': category_distribution,
                    'file_path': test_file  # Add file path for later use
                })
        
        # Sort by date (most recent first)
        history.sort(key=lambda x: x['date'], reverse=True)
        return history
    
    def get_test_by_name(self, test_name):
        """Gets detailed data for a specific test by name"""
        test_files = self.find_current_test_files()
        
        for test_file in test_files:
            if os.path.basename(test_file) == test_name:
                return self.parse_test_file(test_file)
        
        return None
    
    def generate_html_dashboard(self):
        """Generates the HTML dashboard"""
        # Get latest test data
        test_files = self.find_current_test_files()
        if not test_files:
            return "Aucun fichier de test trouvé."
        
        # Sort by modification date (most recent first)
        test_files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
        latest_test = test_files[0]
        latest_test_data = self.parse_test_file(latest_test)
        
        if not latest_test_data:
            return "Erreur lors de l'analyse du fichier de test."
        
        # Get test history
        test_history = self.get_test_history()
        
        # Calculate statistics for latest test
        if latest_test_data['interactions']:
            qualities = [float(i['quality']) for i in latest_test_data['interactions'] if i['quality'] != 'N/A']
            lengths = [int(i['length']) for i in latest_test_data['interactions'] if i['length'] != 'N/A']
            words = [int(i['words']) for i in latest_test_data['interactions'] if i['words'] != 'N/A']
            categories = [i['category'] for i in latest_test_data['interactions']]
            question_marks = [i['question_mark'] for i in latest_test_data['interactions']]
            
            avg_quality = sum(qualities)/len(qualities) if qualities else 0
            avg_length = sum(lengths)/len(lengths) if lengths else 0
            avg_words = sum(words)/len(words) if words else 0
            category_distribution = {cat: categories.count(cat) for cat in set(categories)}
            question_mark_count = question_marks.count('YES')
        else:
            avg_quality = 0
            avg_length = 0
            avg_words = 0
            category_distribution = {}
            question_mark_count = 0
        
        # Generate HTML content
        html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Dashboard - AI Assistant</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
        }}
        
        .header {{
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }}
        
        .header h1 {{
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }}
        
        .header p {{
            font-size: 1.2em;
            opacity: 0.9;
        }}
        
        .methods-section {{
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 30px;
        }}
        
        .methods-section h3 {{
            color: #333;
            margin-bottom: 20px;
            font-size: 1.5em;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }}
        
        .method-card {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid #667eea;
        }}
        
        .method-card h4 {{
            color: #333;
            margin-bottom: 15px;
            font-size: 1.2em;
        }}
        
        .method-table {{
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }}
        
        .method-table th, .method-table td {{
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }}
        
        .method-table th {{
            background-color: #667eea;
            color: white;
            font-weight: bold;
        }}
        
        .method-table tr:nth-child(even) {{
            background-color: #f2f2f2;
        }}
        
        .dashboard-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        
        .card {{
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }}
        
        .card:hover {{
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        }}
        
        .card h3 {{
            color: #333;
            margin-bottom: 15px;
            font-size: 1.3em;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }}
        
        .stat-item {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }}
        
        .stat-label {{
            font-weight: 600;
            color: #555;
        }}
        
        .stat-value {{
            font-weight: bold;
            color: #667eea;
        }}
        
        .interactions-section {{
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            margin-bottom: 30px;
        }}
        
        .interactions-section h3 {{
            color: #333;
            margin-bottom: 20px;
            font-size: 1.5em;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }}
        
        .interaction-item {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            border-left: 4px solid #667eea;
        }}
        
        .interaction-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            flex-wrap: wrap;
            gap: 10px;
        }}
        
        .interaction-number {{
            background: #667eea;
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.9em;
        }}
        
        .interaction-category {{
            padding: 5px 12px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.8em;
            text-transform: uppercase;
        }}
        
        .category-long {{ background: #28a745; color: white; }}
        .category-medium {{ background: #ffc107; color: #333; }}
        .category-short {{ background: #dc3545; color: white; }}
        
        .interaction-timestamp {{
            color: #666;
            font-size: 0.9em;
        }}
        
        .interaction-content {{
            margin-bottom: 15px;
        }}
        
        .question-section, .answer-section {{
            margin-bottom: 15px;
        }}
        
        .question-section h4, .answer-section h4 {{
            color: #333;
            margin-bottom: 8px;
            font-size: 1.1em;
        }}
        
        .question-text, .answer-text {{
            background: white;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #e9ecef;
            line-height: 1.6;
        }}
        
        .screenshots-section {{
            margin-top: 20px;
            padding: 20px;
            background: white;
            border-radius: 10px;
            border: 1px solid #e9ecef;
        }}
        
        .screenshots-section h4 {{
            color: #333;
            margin-bottom: 15px;
            font-size: 1.1em;
        }}
        
        .screenshot-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }}
        
        .screenshot-item {{
            text-align: center;
        }}
        
        .screenshot-item img {{
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            border: 2px solid #e9ecef;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }}
        
        .screenshot-item img:hover {{
            transform: scale(1.05);
            box-shadow: 0 8px 25px rgba(0,0,0,0.2);
        }}
        
        .screenshot-caption {{
            margin-top: 10px;
            font-size: 0.9em;
            color: #666;
            font-weight: 600;
        }}
        
        .interaction-metrics {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 10px;
            margin-top: 15px;
        }}
        
        .metric-item {{
            text-align: center;
            padding: 10px;
            background: white;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }}
        
        .metric-value {{
            font-size: 1.2em;
            font-weight: bold;
            color: #667eea;
            display: block;
        }}
        
        .metric-label {{
            font-size: 0.8em;
            color: #666;
            text-transform: uppercase;
        }}
        
        .history-button {{
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 25px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            margin: 20px auto;
            display: block;
        }}
        
        .history-button:hover {{
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.3);
        }}
        
        .modal {{
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
        }}
        
        .modal-content {{
            background-color: white;
            margin: 5% auto;
            padding: 30px;
            border-radius: 15px;
            width: 90%;
            max-width: 800px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }}
        
        .modal-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #667eea;
        }}
        
        .modal-title {{
            color: #333;
            font-size: 1.8em;
            margin: 0;
        }}
        
        .close {{
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: color 0.3s ease;
        }}
        
        .close:hover {{
            color: #667eea;
        }}
        
        .history-table {{
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }}
        
        .history-table th, .history-table td {{
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }}
        
        .history-table th {{
            background-color: #667eea;
            color: white;
            font-weight: bold;
        }}
        
        .history-table tr:nth-child(even) {{
            background-color: #f2f2f2;
        }}
        
        .history-table tr:hover {{
            background-color: #e9ecef;
        }}
        
        .category-badge {{
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: bold;
            text-transform: uppercase;
        }}
        
        .view-test-btn {{
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
        }}
        
        .view-test-btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }}
        
        @media (max-width: 768px) {{
            .dashboard-grid {{
                grid-template-columns: 1fr;
            }}
            
            .interaction-header {{
                flex-direction: column;
                align-items: flex-start;
            }}
            
            .interaction-metrics {{
                grid-template-columns: repeat(2, 1fr);
            }}
            
            .screenshot-grid {{
                grid-template-columns: 1fr;
            }}
            
            .modal-content {{
                width: 95%;
                margin: 10% auto;
                padding: 20px;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Test Dashboard</h1>
            <p>AI Assistant - Latest test performed</p>
        </div>
        
        <!-- Calculation methods section -->
        <div class="methods-section">
            <h3>🧮 Calculation Methods</h3>
            
            <div class="method-card">
                <h4>📊 Response Category Classification</h4>
                <p>AI responses are automatically classified into three categories based on length and word thresholds:</p>
                <table class="method-table">
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th>Character Threshold</th>
                            <th>Word Threshold</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>LONG</strong></td>
                            <td>> 250 characters</td>
                            <td>> 50 words</td>
                            <td>Detailed and complete responses</td>
                        </tr>
                        <tr>
                            <td><strong>MEDIUM</strong></td>
                            <td>≥ 100 characters</td>
                            <td>≥ 20 words</td>
                            <td>Balanced and moderate responses</td>
                        </tr>
                        <tr>
                            <td><strong>SHORT</strong></td>
                            <td>< 100 characters</td>
                            <td>< 20 words</td>
                            <td>Short and concise responses</td>
                        </tr>
                    </tbody>
                </table>
                <p><em>Note: A response is classified as LONG if it exceeds EITHER threshold. MEDIUM requires satisfying BOTH thresholds. SHORT applies when BOTH thresholds are below the minimum.</em></p>
            </div>
            
            <div class="method-card">
                <h4>⭐ Quality Score Calculation</h4>
                <p>The quality score is calculated based on the response length relative to the LONG threshold:</p>
                <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 15px 0; text-align: center; font-family: monospace; font-size: 1.1em;">
                    <strong>Quality Score = min(100, (Response Length / 250) × 100)</strong>
                </div>
                <p><strong>Where:</strong></p>
                <ul style="margin-left: 20px; line-height: 1.6;">
                    <li><strong>Response Length</strong> = Number of characters in the AI response</li>
                    <li><strong>250</strong> = Character threshold for LONG category</li>
                    <li><strong>The score is capped at 100% maximum</strong></li>
                    <li><strong>Higher scores</strong> indicate responses closer to or exceeding the LONG threshold</li>
                </ul>
            </div>
        </div>
        
        <div class="dashboard-grid">
            <div class="card">
                <h3>📋 General Information</h3>
                <div class="stat-item">
                    <span class="stat-label">Test Name:</span>
                    <span class="stat-value">{latest_test_data['test_name']}</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Modification Date:</span>
                    <span class="stat-value">{latest_test_data['modification_date']}</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Total Interactions:</span>
                    <span class="stat-value">{latest_test_data['total_interactions']}</span>
                </div>
            </div>
            
            <div class="card">
                <h3>📈 Average Statistics</h3>
                <div class="stat-item">
                    <span class="stat-label">Quality Score:</span>
                    <span class="stat-value">{avg_quality:.1f}%</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Average Length:</span>
                    <span class="stat-value">{avg_length:.0f} characters</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Average Words:</span>
                    <span class="stat-value">{avg_words:.0f} words</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Question Marks:</span>
                    <span class="stat-value">{question_mark_count}/{latest_test_data['total_interactions']}</span>
                </div>
            </div>
            
            <div class="card">
                <h3>🏷️ Category Distribution</h3>
                {self._generate_category_distribution_html(category_distribution)}
            </div>
        </div>
        
        <button class="history-button" onclick="openHistoryModal()">
            📚 View Test History
        </button>
        
        <div class="interactions-section">
            <h3>🔄 Interaction Details</h3>
            {self._generate_interactions_html(latest_test_data['interactions'])}
        </div>
    </div>
    
    <!-- History modal -->
    <div id="historyModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">📚 Test History</h2>
                <span class="close" onclick="closeHistoryModal()">&times;</span>
            </div>
            <div id="historyContent">
                {self._generate_history_html(test_history)}
            </div>
        </div>
    </div>
    
    <!-- Image modal -->
    <div id="imageModal" class="modal">
        <div class="modal-content" style="max-width: 90%; max-height: 90vh; text-align: center;">
            <div class="modal-header">
                <h2 class="modal-title" id="imageModalTitle">📸 Screenshot</h2>
                <span class="close" onclick="closeImageModal()">&times;</span>
            </div>
            <div id="imageModalContent">
                <img id="modalImage" src="" alt="Screenshot" style="max-width: 100%; max-height: 70vh; border-radius: 8px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
            </div>
        </div>
    </div>
    
    <!-- Test Details Modal -->
    <div id="testDetailsModal" class="modal">
        <div class="modal-content" style="max-width: 95%; max-height: 90vh;">
            <div class="modal-header">
                <h2 class="modal-title" id="testDetailsModalTitle">📊 Test Details</h2>
                <span class="close" onclick="closeTestDetailsModal()">&times;</span>
            </div>
            <div id="testDetailsContent">
                <!-- Content will be loaded dynamically -->
            </div>
        </div>
    </div>
    
    <script>
        function openHistoryModal() {{
            document.getElementById('historyModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }}
        
        function closeHistoryModal() {{
            document.getElementById('historyModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }}
        
        function openImageModal(imageSrc, title) {{
            document.getElementById('modalImage').src = imageSrc;
            document.getElementById('imageModalTitle').textContent = title;
            document.getElementById('imageModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }}
        
        function closeImageModal() {{
            document.getElementById('imageModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }}
        
        function viewTestDetails(testName) {{
            // Close history modal first
            closeHistoryModal();
            
            // Show test details modal
            document.getElementById('testDetailsModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
            
            // Update title
            document.getElementById('testDetailsModalTitle').textContent = '📊 Test Details: ' + testName;
            
            // Show loading message
            var content = '<div style="text-align: center; padding: 40px;">' +
                '<h3>Loading details for: ' + testName + '</h3>' +
                '<p>Generating detailed dashboard...</p>' +
                '<div style="margin: 20px 0;">' +
                    '<button onclick="generateTestDetails(\\'' + testName + '\\')" class="view-test-btn" style="font-size: 1.1em; padding: 15px 30px;">' +
                        '🚀 Generate Test Details Dashboard' +
                    '</button>' +
                '</div>' +
                '<p><em>This will create a complete HTML dashboard for the selected test.</em></p>' +
            '</div>';
            document.getElementById('testDetailsContent').innerHTML = content;
        }}
        
        function generateTestDetails(testName) {{
            // Show generating message
            var content = '<div style="text-align: center; padding: 40px;">' +
                '<h3>🔄 Generating Dashboard...</h3>' +
                '<p>Creating detailed view for: <strong>' + testName + '</strong></p>' +
                '<div style="margin: 20px 0;">' +
                    '<div style="display: inline-block; width: 40px; height: 40px; border: 4px solid #f3f3f3; border-top: 4px solid #667eea; border-radius: 50%; animation: spin 1s linear infinite;"></div>' +
                '</div>' +
                '<p>Please wait while the dashboard is being generated...</p>' +
                '<style>' +
                    '@keyframes spin {{' +
                        '0% {{ transform: rotate(0deg); }}' +
                        '100% {{ transform: rotate(360deg); }}' +
                    '}}' +
                '</style>' +
            '</div>';
            document.getElementById('testDetailsContent').innerHTML = content;
            
            // Simulate generation process (in real implementation, this would call a backend API)
            setTimeout(function() {{
                var successContent = '<div style="text-align: center; padding: 40px;">' +
                    '<h3>✅ Dashboard Generated!</h3>' +
                    '<p>Detailed dashboard for: <strong>' + testName + '</strong></p>' +
                    '<div style="margin: 30px 0;">' +
                        '<button onclick="openTestDetailsFile(\\'' + testName + '\\')" class="view-test-btn" style="font-size: 1.1em; padding: 15px 30px; background: linear-gradient(45deg, #28a745, #20c997);">' +
                            '📁 Open Test Details Dashboard' +
                        '</button>' +
                    '</div>' +
                    '<p><em>The dashboard file has been created and is ready to view.</em></p>' +
                    '<p><strong>Note:</strong> Use the button above to open the detailed dashboard in a new tab.</p>' +
                '</div>';
                document.getElementById('testDetailsContent').innerHTML = successContent;
            }}, 2000);
        }}
        
        function openTestDetailsFile(testName) {{
            // Close the modal
            closeTestDetailsModal();
            
            // Show instructions
            var message = 'To view the detailed dashboard for ' + testName + ':\\n\\n1. Run this command in your terminal:\\n   python generate_test_details.py \\"' + testName + '\\"\\n\\n2. Open the generated HTML file in your browser\\n\\n3. Or use: python open_dashboard.py to find the latest file';
            alert(message);
        }}
        
        function closeTestDetailsModal() {{
            document.getElementById('testDetailsModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }}
        
        // Fermer les modals en cliquant à l'extérieur
        window.onclick = function(event) {{
            const historyModal = document.getElementById('historyModal');
            const imageModal = document.getElementById('imageModal');
            const testDetailsModal = document.getElementById('testDetailsModal');
            
            if (event.target === historyModal) {{
                closeHistoryModal();
            }}
            if (event.target === imageModal) {{
                closeImageModal();
            }}
            if (event.target === testDetailsModal) {{
                closeTestDetailsModal();
            }}
        }}
        
        // Fermer les modals avec la touche Escape
        document.addEventListener('keydown', function(event) {{
            if (event.key === 'Escape') {{
                closeHistoryModal();
                closeImageModal();
                closeTestDetailsModal();
            }}
        }});
    </script>
</body>
</html>
        """
        
        return html_content
    
    def _generate_category_distribution_html(self, category_distribution):
        """Generate HTML for category distribution"""
        if not category_distribution:
            return '<p>No categories available</p>'
        
        html = ''
        for category, count in category_distribution.items():
            category_class = f"category-{category.lower()}"
            html += f'''
            <div class="stat-item">
                <span class="stat-label">{category}:</span>
                <span class="stat-value">{count}</span>
            </div>
            '''
        return html
    
    def _generate_interactions_html(self, interactions):
        """Generate HTML for interactions"""
        if not interactions:
            return '<p>No interactions available</p>'
        
        html = ''
        for i, interaction in enumerate(interactions, 1):
            category_class = f"category-{interaction['category'].lower()}"
            
            # Generate screenshots for this interaction
            screenshots_html = self._generate_screenshots_html(i, interaction)
            
            html += f'''
            <div class="interaction-item">
                <div class="interaction-header">
                    <span class="interaction-number">#{i}</span>
                    <span class="interaction-category {category_class}">{interaction['category']}</span>
                    <span class="interaction-timestamp">{interaction['timestamp']}</span>
                </div>
                
                <div class="interaction-content">
                    <div class="question-section">
                        <h4>❓ Question Asked:</h4>
                        <div class="question-text">{interaction['question']}</div>
                    </div>
                    
                    <div class="answer-section">
                        <h4>🤖 AI Response:</h4>
                        <div class="answer-text">{interaction['answer']}</div>
                    </div>
                </div>
                
                <div class="interaction-metrics">
                    <div class="metric-item">
                        <span class="metric-value">{interaction['length']}</span>
                        <span class="metric-label">Characters</span>
                    </div>
                    <div class="metric-item">
                        <span class="metric-value">{interaction['words']}</span>
                        <span class="metric-label">Words</span>
                    </div>
                    <div class="metric-item">
                        <span class="metric-value">{interaction['quality']}%</span>
                        <span class="metric-label">Quality</span>
                    </div>
                    <div class="metric-item">
                        <span class="metric-value">{interaction['question_mark']}</span>
                        <span class="metric-label">Question Mark</span>
                    </div>
                </div>
                
                {screenshots_html}
            </div>
            '''
        return html
    
    def _generate_history_html(self, test_history):
        """Generate HTML for test history"""
        if not test_history:
            return '<p>No history available</p>'
        
        html = '''
        <table class="history-table">
            <thead>
                <tr>
                    <th>Test</th>
                    <th>Date</th>
                    <th>Interactions</th>
                    <th>Average Quality</th>
                    <th>Average Length</th>
                    <th>Categories</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
        '''
        
        for i, test in enumerate(test_history):
            categories_str = ', '.join([f"{cat}: {count}" for cat, count in test['category_distribution'].items()])
            html += f'''
            <tr>
                <td><strong>{test['test_name']}</strong></td>
                <td>{test['date']}</td>
                <td>{test['total_interactions']}</td>
                <td>{test['avg_quality']}%</td>
                <td>{test['avg_length']} characters</td>
                <td>{categories_str}</td>
                <td><button class="view-test-btn" onclick="viewTestDetails('{test['test_name'].replace("'", "\\'")}')">👁️ View Details</button></td>
            </tr>
            '''
        
        html += '''
            </tbody>
        </table>
        '''
        
        return html
    
    def _generate_screenshots_html(self, interaction_number, interaction):
        """Generate HTML for screenshots of an interaction"""
        try:
            # Find corresponding screenshots
            screenshots_dir = os.path.join(self.ai_doc_dir, "screenshots")
            if not os.path.exists(screenshots_dir):
                return ""
            
            # Patterns to find screenshots
            question_pattern = f"question_{interaction_number}-*.png"
            answer_pattern = f"reponse_{interaction_number}-*.png"
            
            question_files = glob.glob(os.path.join(screenshots_dir, question_pattern))
            answer_files = glob.glob(os.path.join(screenshots_dir, answer_pattern))
            
            if not question_files and not answer_files:
                return ""
            
            html = '''
            <div class="screenshots-section">
                <h4>📸 Interaction Screenshots</h4>
                <div class="screenshot-grid">
            '''
            
            # Add question screenshot
            if question_files:
                # Take the most recent file
                question_file = max(question_files, key=os.path.getmtime)
                question_filename = os.path.basename(question_file)
                html += f'''
                <div class="screenshot-item">
                    <img src="screenshots/{question_filename}" alt="Question {interaction_number}" onclick="openImageModal(this.src, 'Question {interaction_number}')" style="cursor: pointer;">
                    <div class="screenshot-caption">Question {interaction_number}</div>
                </div>
                '''
            
            # Add answer screenshot
            if answer_files:
                # Take the most recent file
                answer_file = max(answer_files, key=os.path.getmtime)
                answer_filename = os.path.basename(answer_file)
                html += f'''
                <div class="screenshot-item">
                    <img src="screenshots/{answer_filename}" alt="Answer {interaction_number}" onclick="openImageModal(this.src, 'Answer {interaction_number}')" style="cursor: pointer;">
                    <div class="screenshot-caption">Answer {interaction_number}</div>
                </div>
                '''
            
            html += '''
                </div>
            </div>
            '''
            
            return html
            
        except Exception as e:
            print(f"Error generating screenshots: {e}")
            return ""
    
    def save_html_dashboard(self, html_content):
        """Saves the HTML dashboard to a file"""
        try:
            # Create HTML filename
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            html_filename = f"dashboard_test_{timestamp}.html"
            html_path = os.path.join(self.ai_doc_dir, html_filename)
            
            # Save HTML file
            with open(html_path, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            print(f"Dashboard HTML sauvegardé: {html_path}")
            return html_path
            
        except Exception as e:
            print(f"Erreur lors de la sauvegarde du dashboard HTML: {e}")
            return None
    
    def generate_andSave_dashboard(self):
        """Generates and saves the HTML dashboard"""
        print("Génération du dashboard HTML...")
        
        # Generate HTML content
        html_content = self.generate_html_dashboard()
        
        if html_content == "Aucun fichier de test trouvé." or html_content == "Erreur lors de l'analyse du fichier de test.":
            print(f"❌ {html_content}")
            return None
        
        # Save HTML file
        html_path = self.save_html_dashboard(html_content)
        
        if html_path:
            print(f"✅ Dashboard HTML généré avec succès: {html_path}")
            return html_path
        else:
            print("❌ Échec de la génération du dashboard HTML")
            return None

def main():
    """Main function"""
    print("=== Générateur de Dashboard HTML pour les tests ATG ===")
    
    # Create generator
    generator = HTMLDashboardGenerator()
    
    # Check if directory exists
    if not os.path.exists(generator.ai_doc_dir):
        print(f"Le répertoire {generator.ai_doc_dir} n'existe pas.")
        return
    
    # Generate and save dashboard
    html_path = generator.generate_andSave_dashboard()
    
    if html_path:
        print(f"\n✅ Dashboard HTML généré avec succès: {html_path}")
        print("Ouvrez le fichier dans votre navigateur pour visualiser le dashboard.")
    else:
        print("\n❌ Échec de la génération du dashboard HTML")

if __name__ == "__main__":
    main()

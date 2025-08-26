*** Settings ***
Documentation     Test suite for testing AI Assistant with automatic verification code retrieval from Yopmail
Library           SeleniumLibrary
Library           String
Library           OperatingSystem
Library           Process
Resource          ressources/variables.robot
Resource          ressources/keywords.robot

*** Variables ***
${YOPMAIL_URL}       https://yopmail.com/fr/wm
${YOPMAIL_EMAIL}     shadowadmin@yopmail.com
${YOPMAIL_PASSWORD}  Admin@123
${UAT_BASE_URL}      https://uat.atg.africa/workspace
${QUESTIONS_FILE}    ${OUTPUT_DIR}/ai_assistant_documentation/questions.txt
${AI_RESPONSE_WAIT_SEC}    180
${AI_RESPONSE_POLL_INTERVAL}    2
${LONG_CHAR_THRESHOLD}    250
${LONG_WORD_THRESHOLD}    50
${MEDIUM_CHAR_THRESHOLD}    100
${MEDIUM_WORD_THRESHOLD}    20
${GENERATE_WORD_REPORT}    ${TRUE}

*** Test Cases ***
Test AI Assistant Chatbot
    Trigger Verification Code Sending
    Wait And Retrieve Verification Code And Login
    Test AI Assistant Functionality
    Close Browser

*** Keywords ***
Trigger Verification Code Sending
    # Open browser with simple options
    Open Browser    ${UAT_BASE_URL}/auth?sign-in    ${BROWSER}
    Set Selenium Speed    ${SELSPEED}
    Maximize Browser Window
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/login_before.png
    Input Text    (//input[@id='dark-input'])[1]    ${YOPMAIL_EMAIL}
    Input Text    (//input[@id='dark-input'])[2]    ${YOPMAIL_PASSWORD}
    Click Element    xpath=//button[@type='submit' and contains(@class, 'ant-btn') and contains(., 'Sign in')]
    Wait Until Element Is Visible    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']    timeout=10s
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/verification_code_input.png

Wait And Retrieve Verification Code And Login
    # Reduced wait time to avoid code expiration
    Sleep    2s
    Execute JavaScript    window.open('${YOPMAIL_URL}', '_blank')
    Switch Window    NEW
    Wait Until Page Contains Element    id=login    timeout=10s
    Input Text    id=login    shadowadmin
    Click Element    id=refreshbut
    Sleep    1s

    # Wait for email to load and check iframe content
    Sleep    3s
    
    # Check if email content is in iframe
    ${iframe_present}=    Run Keyword And Return Status    Page Should Contain Element    id=ifmail    timeout=5s
    
    IF    ${iframe_present}
        # Email content is in iframe - select it and check content
        Select Frame    id=ifmail
        ${email_found}=    Run Keyword And Return Status    Wait Until Page Contains    ATG Platform    timeout=5s
        
        IF    not ${email_found}
            ${email_found}=    Run Keyword And Return Status    Wait Until Page Contains    Africa Trade Gateway    timeout=5s
        END
        
        IF    not ${email_found}
            ${email_found}=    Run Keyword And Return Status    Wait Until Page Contains    MFA Code    timeout=5s
        END
        
        # Get email content from iframe
        ${email_content}=    Get Text    xpath=//body
        Unselect Frame
        
    ELSE
        # Try to find email content in main page
        ${email_found}=    Run Keyword And Return Status    Wait Until Page Contains    ATG Platform    timeout=5s
        
        IF    not ${email_found}
            ${email_found}=    Run Keyword And Return Status    Wait Until Page Contains    Africa Trade Gateway    timeout=5s
        END
        
        IF    not ${email_found}
            ${email_found}=    Run Keyword And Return Status    Wait Until Page Contains    MFA Code    timeout=5s
        END
        
        # Get email content from main page
        ${email_content}=    Get Text    xpath=//body
    END

    Should Be True    ${email_found}    msg=No ATG verification email found

    ${verification_code}=    Extract Verification Code    ${email_content}
    Should Match Regexp    ${verification_code}    ^\\d{6}$

    Set Suite Variable    ${verification_code}

    Close Window
    Switch Window    MAIN

        # Focus, input and submit IMMEDIATELY using classic Input Text
    Log    Focusing field and entering verification code: ${verification_code}    INFO
    
    # Focus the input field first by clicking on it
    Click Element    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']
    
    # Input the verification code using classic Input Text
    Input Text    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']    ${verification_code}
    
    # Take screenshot to confirm code is entered
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/code_entered.png
    
    # Verify code is still in the field before submitting
    ${code_before_submit}=    Get Element Attribute    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']    value
    Log    Code in field before submit: ${code_before_submit}    INFO
    
    # If code was removed, try to re-enter it
    IF    ${code_before_submit} != ${verification_code}
        Log    Code was removed before submit, re-entering: ${verification_code}    WARN
        Input Text    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']    ${verification_code}
        Sleep    0.5s
        ${code_before_submit}=    Get Element Attribute    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']    value
        Should Be Equal    ${code_before_submit}    ${verification_code}    msg=Code still not entered correctly before submit
    END
    
    # Click Submit button IMMEDIATELY after verification
    Log    Submitting verification code immediately: ${verification_code}    INFO
    Click Element    xpath=//button[@type='submit' and contains(@class, 'ant-btn') and contains(@class, 'ant-btn-default') and contains(., 'Submit')]
    
    # Take screenshot after submit click
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/after_submit_click.png
    
    # Wait a moment for the page to process the submit
    Sleep    2s
    
    # Log that we're proceeding to login verification
    Log    Proceeding to login verification after successful submit    INFO
    
    # Wait for successful login and redirect to workspace
    Wait Until Location Is    ${UAT_BASE_URL}    timeout=15s
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/login_success.png
    Wait Until Element Is Visible    //aside[contains(@class, 'ant-layout-sider')]    timeout=10s

Extract Verification Code
    [Arguments]    ${email_content}
    [Documentation]    Extracts the 6-digit verification code from email content
    
    # Look for pattern: "Please use this one-time code to log in to the Africa Trade Gateway (ATG): XXXXXX"
    ${code_match}=    Get Regexp Matches    ${email_content}    code to log in to the Africa Trade Gateway \\(ATG\\): <strong>(\\d{6})</strong>    1
    
    # If no match found, try alternative patterns
    IF    ${code_match} == @{EMPTY}
        ${code_match}=    Get Regexp Matches    ${email_content}    <strong>(\\d{6})</strong>    1
    END
    
    # If still no match, try to find any 6-digit number
    IF    ${code_match} == @{EMPTY}
        ${code_match}=    Get Regexp Matches    ${email_content}    (\\d{6})    1
    END
    
    # Extract the first match
    ${verification_code}=    Set Variable    ${code_match}[0]
    
    # Validate that we got a 6-digit code
    Should Match Regexp    ${verification_code}    ^\\d{6}$
    
    # Log the extracted code for debugging
    Log    Extracted verification code: ${verification_code}    INFO
    
    RETURN    ${verification_code}

Test AI Assistant Functionality
    # Créer un nom de fichier unique pour ce test au début
    # FORMAT SECURISE POUR WINDOWS: YYYYMMDD_HHMMSS (exemple: 20250825_161554)
    # IMPORTANT: Ce format évite l'OSError sur Windows
    ${test_start_timestamp}=    Get Time    format=%Y%m%d_%H%M%S
    # Additional safety: ensure timestamp is safe for Windows filenames
    ${test_start_timestamp_safe}=    Replace String    ${test_start_timestamp}    -    ${EMPTY}
    ${test_start_timestamp_safe}=    Replace String    ${test_start_timestamp_safe}    :    ${EMPTY}
    ${test_start_timestamp_safe}=    Replace String    ${test_start_timestamp_safe}    ${SPACE}    _
    ${current_test_filename}=    Set Variable    ${OUTPUT_DIR}/ai_assistant_documentation/current_test_${test_start_timestamp_safe}.txt
    Set Suite Variable    ${current_test_filename}
    Log    Test started, current test file: ${current_test_filename}    INFO
    Log    Timestamp original: ${test_start_timestamp}, safe: ${test_start_timestamp_safe}    INFO
    
    # Click on AI Assistant button after successful login
    Log    Clicking on AI Assistant button after successful login    INFO

    # Wait for AI Assistant button to be visible (using provided absolute xpath)
    Wait Until Element Is Visible    xpath=//*[@id="root"]/div/section/header/div/div[3]/div[3]/div[1]/div/div[1]    timeout=15s
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/ai_assistant_button_visible.png
    
    # Click on AI Assistant button using the absolute xpath
    Click Element    xpath=//*[@id="root"]/div/section/header/div/div[3]/div[3]/div[1]/div/div[1]
    Log    AI Assistant button clicked successfully    INFO
    
    # Wait for AI Assistant interface to load
    Sleep    3s
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/ai_assistant_interface.png
    
    # Verify AI Assistant interface elements
    Log    Verifying AI Assistant interface elements    INFO

    # Wait for the input field to be visible
    Wait Until Element Is Visible    xpath=//input[contains(@placeholder,'Enter a prompt here')]    timeout=10s
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/ai_assistant_input_visible.png

    # Send multiple questions read from a file, each sent separately and documented
    Send Questions From File    ${QUESTIONS_FILE}

    Log    AI Assistant functionality test completed successfully    INFO
    
    # Générer automatiquement le rapport Word si activé
    IF    ${GENERATE_WORD_REPORT}
        Generate Word Report After Test
    END

Document AI Interaction
    [Arguments]    ${question}    ${answer}    ${category}    ${length}    ${question_screenshot}=${EMPTY}    ${response_screenshot}=${EMPTY}
    ${doc_dir}=    Set Variable    ${OUTPUT_DIR}/ai_assistant_documentation
    # Ensure directory exists with error handling
    ${dir_exists}=    Run Keyword And Return Status    Directory Should Exist    ${doc_dir}
    IF    not ${dir_exists}
        Create Directory    ${doc_dir}
        Log    Created directory: ${doc_dir}    INFO
    ELSE
        Log    Directory already exists: ${doc_dir}    INFO
    END

    # Use Windows-safe timestamp format for filenames
    ${timestamp}=    Get Time    format=%Y-%m-%d %H:%M:%S
    ${timestamp_safe}=    Get Time    format=%Y%m%d_%H%M%S
    
    # Fichier 1: Historique complet de tous les tests
    ${history_filename}=    Set Variable    ${doc_dir}/ai_interactions_full_log.txt
    
    # Fichier 2: Interactions du test actuel (utiliser le nom créé au début du test)
    # Le nom est déjà défini dans Test AI Assistant Functionality avec Set Suite Variable
    # Pas besoin de générer un nouveau timestamp ici
    ${current_test_filename}=    Set Variable    ${current_test_filename}

    ${words}=    Split String    ${answer}
    ${word_count}=    Get Length    ${words}

    # Détecter si la réponse se termine par un point d'interrogation
    ${ends_with_question_mark}=    Run Keyword And Return Status    Should Match Regexp    ${answer}    \\?$
    ${question_mark_present}=    Set Variable If    ${ends_with_question_mark}    OUI    NON

    # Calculer la matrice de qualité de la réponse
    ${quality_score}=    Evaluate    min(100, (${length} / ${LONG_CHAR_THRESHOLD}) * 100)
    ${quality_score}=    Evaluate    round(${quality_score}, 2)

    # Contenu pour l'historique complet
    ${history_content}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    AI ASSISTANT INTERACTION DOCUMENTATION
    ...    ========================================
    ...    
    ...    Timestamp: ${timestamp}
    ...    
    ...    ========================================
    ...    INTERACTION DETAILS
    ...    ========================================
    ...    
    ...    Question Asked:
    ...    "${question}"
    ...    
    ...    AI Response:
    ...    "${answer}"
    ...    
    ...    ========================================
    ...    SCREENSHOTS
    ...    ========================================
    ...    
    ...    Question Screenshot: ${question_screenshot}
    ...    Response Screenshot: ${response_screenshot}
    ...    
    ...    ========================================
    ...    ANALYSIS & METRICS
    ...    ========================================
    ...    
    ...    Response Category: ${category}
    ...    Response Length: ${length} characters
    ...    Word Count: ${word_count}
    ...    Quality Score: ${quality_score}%
    ...    Question Mark at End: ${question_mark_present}
    ...    
    ...    ========================================
    ...    THRESHOLDS USED
    ...    ========================================
    ...    
    ...    - LONG: > ${LONG_CHAR_THRESHOLD} chars OR > ${LONG_WORD_THRESHOLD} words
    ...    - MEDIUM: >= ${MEDIUM_CHAR_THRESHOLD} chars OR >= ${MEDIUM_WORD_THRESHOLD} words
    ...    - SHORT: < ${MEDIUM_CHAR_THRESHOLD} chars AND < ${MEDIUM_WORD_THRESHOLD} words
    ...    
    ...    ========================================
    ...    END OF DOCUMENTATION
    ...    ========================================

    # Contenu pour le test actuel (une seule interaction)
    ${current_test_content}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    AI ASSISTANT INTERACTION DOCUMENTATION
    ...    ========================================
    ...    
    ...    Timestamp: ${timestamp}
    ...    
    ...    ========================================
    ...    INTERACTION DETAILS
    ...    ========================================
    ...    
    ...    Question Asked:
    ...    "${question}"
    ...    
    ...    AI Response:
    ...    "${answer}"
    ...    
    ...    ========================================
    ...    SCREENSHOTS
    ...    ========================================
    ...    
    ...    Question Screenshot: ${question_screenshot}
    ...    Response Screenshot: ${response_screenshot}
    ...    
    ...    ========================================
    ...    ANALYSIS & METRICS
    ...    ========================================
    ...    
    ...    Response Category: ${category}
    ...    Response Length: ${length} characters
    ...    Word Count: ${word_count}
    ...    Quality Score: ${quality_score}%
    ...    Question Mark at End: ${question_mark_present}
    ...    
    ...    ========================================
    ...    THRESHOLDS USED
    ...    ========================================
    ...    
    ...    - LONG: > ${LONG_CHAR_THRESHOLD} chars OR > ${LONG_WORD_THRESHOLD} words
    ...    - MEDIUM: >= ${MEDIUM_CHAR_THRESHOLD} chars OR >= ${MEDIUM_WORD_THRESHOLD} words
    ...    - SHORT: < ${MEDIUM_CHAR_THRESHOLD} chars AND < ${MEDIUM_WORD_THRESHOLD} words
    ...    
    ...    ========================================
    ...    END OF DOCUMENTATION
    ...    ========================================

    # 1. Ajouter à l'historique complet (append)
    # Ensure history file exists before appending
    ${history_exists}=    Run Keyword And Return Status    File Should Exist    ${history_filename}
    IF    not ${history_exists}
        Log    Creating history file: ${history_filename}    INFO
        Create File    ${history_filename}    ${EMPTY}
        Log    Created history file: ${history_filename}    INFO
    ELSE
        Log    History file already exists: ${history_filename}    INFO
    END
    Append To File    ${history_filename}    ${history_content}\n\n
    Log    AI interaction appended to history: ${history_filename}    INFO

    # 2. Ajouter au fichier du test actuel (append pour accumuler toutes les interactions)
    # D'abord créer le fichier s'il n'existe pas, puis append
    # Additional safety: ensure filename is valid before file operations
    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${current_test_filename}
    IF    not ${file_exists}
        # Validate filename before creating file
        Log    Creating new test file with filename: ${current_test_filename}    INFO
        # Create the file with empty content first
        Create File    ${current_test_filename}    ${EMPTY}
        Log    Created new test file: ${current_test_filename}    INFO
    ELSE
        Log    Test file already exists: ${current_test_filename}    INFO
    END
    # Now append to the file
    Append To File    ${current_test_filename}    ${current_test_content}\n\n
    Log    Current test interaction appended to: ${current_test_filename}    INFO

    # Also append to a master log file
    ${master_log}=    Set Variable    ${doc_dir}/ai_interactions_master_log.txt
    ${log_entry}=    Set Variable    [${timestamp}] Q: "${question}" | A: "${answer}" | Category: ${category} | Length: ${length} | Words: ${word_count} | Quality: ${quality_score}% | Question Mark: ${question_mark_present} | Screenshots: Q=${question_screenshot} R=${response_screenshot}

    # Créer le fichier master log s'il n'existe pas, puis append
    ${master_exists}=    Run Keyword And Return Status    File Should Exist    ${master_log}
    IF    not ${master_exists}
        Log    Creating master log file: ${master_log}    INFO
        Create File    ${master_log}    ${EMPTY}
        Log    Created master log file: ${master_log}    INFO
    ELSE
        Log    Master log file already exists: ${master_log}    INFO
    END
    Append To File    ${master_log}    ${log_entry}\n
    Log    Entry added to master log: ${master_log}    INFO

# New keywords to support sending multiple questions from a file
Send Questions From File
    [Arguments]    ${file_path}
    [Documentation]    Lit chaque ligne du fichier ${file_path} et envoie la question séparément.
    # Read file content and split into lines (ignore empty lines)
    ${content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${content}
    # Create screenshots directory for AI Assistant interactions
    ${screens_dir}=    Set Variable    ${OUTPUT_DIR}/ai_assistant_documentation/screenshots
    # Ensure screenshots directory exists with error handling
    ${screens_dir_exists}=    Run Keyword And Return Status    Directory Should Exist    ${screens_dir}
    IF    not ${screens_dir_exists}
        Create Directory    ${screens_dir}
        Log    Created screenshots directory: ${screens_dir}    INFO
    ELSE
        Log    Screenshots directory already exists: ${screens_dir}    INFO
    END
    ${total}=    Get Length    ${lines}
    # Supprimer les lignes vides et doublons
    ${unique_questions}=    Create List
    FOR    ${line}    IN    @{lines}
        ${q}=    Strip String    ${line}
        ${q_empty}=    Run Keyword And Return Status    Should Be Equal    ${q}    ${EMPTY}
        Run Keyword If    ${q_empty}    Continue For Loop
        ${already_exists}=    Run Keyword And Return Status    List Should Contain Value    ${unique_questions}    ${q}
        Run Keyword If    not ${already_exists}    Append To List    ${unique_questions}    ${q}
    END

    ${total}=    Get Length    ${unique_questions}
    FOR    ${idx}    IN RANGE    0    ${total}
        ${q}=    Get From List    ${unique_questions}    ${idx}
        ${display_idx}=    Evaluate    ${idx} + 1
        Log    Sending question (${display_idx}/${total}): ${q}    INFO

        # For the FIRST question: do NOT click New Chat before sending. Use the current conversation.
        # For subsequent questions, assume we already clicked New Chat after the previous response.
        # Ensure input field is ready in all cases
        Run Keyword And Ignore Error    Wait Until Page Does Not Contain    Thinking...    timeout=${AI_RESPONSE_WAIT_SEC}s
        Sleep    2s    # Attendre un peu plus avant de chercher le champ de saisie
        Wait Until Element Is Visible    xpath=//input[contains(@placeholder,'Enter a prompt here')]    timeout=60s
        Wait Until Element Is Enabled    xpath=//input[contains(@placeholder,'Enter a prompt here')]    timeout=30s
        Scroll Element Into View    xpath=//input[contains(@placeholder,'Enter a prompt here')]
        Click Element    xpath=//input[contains(@placeholder,'Enter a prompt here')]
        Clear Element Text    xpath=//input[contains(@placeholder,'Enter a prompt here')]
        Input Text    xpath=//input[contains(@placeholder,'Enter a prompt here')]    ${q}
              
        # Capture screenshot after entering the question; use filename-safe timestamp to avoid overwriting
        ${shot_ts}=    Get Time    format=%Y-%m-%d_%H-%M-%S
        ${shot_ts_safe}=    Replace String    ${shot_ts}    :    -
        ${shot_ts_safe}=    Replace String    ${shot_ts_safe}    ${SPACE}    _
        ${q_shot}=    Set Variable    ${screens_dir}/question_${display_idx}-${shot_ts_safe}.png
        Capture Page Screenshot    ${q_shot}

  #     Envoyer la touche ENTER après la saisie
        Press Keys    xpath=//input[contains(@placeholder,'Enter a prompt here')]    RETURN        Log    Question submitted, waiting for AI response    INFO
       
        ${ai_response}=    Wait For AI Response And Return Text    ${AI_RESPONSE_WAIT_SEC}    ${AI_RESPONSE_POLL_INTERVAL}
        Log    AI Response received for question '${q}': ${ai_response}    INFO
        # Capture screenshot after receiving the response; use filename-safe timestamp to avoid overwriting
        ${resp_ts}=    Get Time    format=%Y-%m-%d_%H-%M-%S
        ${resp_ts_safe}=    Replace String    ${resp_ts}    :    -
        ${resp_ts_safe}=    Replace String    ${resp_ts_safe}    ${SPACE}    _
        ${r_shot}=    Set Variable    ${screens_dir}/reponse_${display_idx}-${resp_ts_safe}.png
        Capture Page Screenshot    ${r_shot}
        ${response_length}=    Get Length    ${ai_response}
        # Compute word count for classification
        ${resp_words}=    Split String    ${ai_response}
        ${resp_word_count}=    Get Length    ${resp_words}
        # Categorize response using character and word thresholds
        IF    ${response_length} > ${LONG_CHAR_THRESHOLD} or ${resp_word_count} > ${LONG_WORD_THRESHOLD}
            ${response_category}=    Set Variable    LONG
        ELSE IF    ${response_length} >= ${MEDIUM_CHAR_THRESHOLD} or ${resp_word_count} >= ${MEDIUM_WORD_THRESHOLD}
            ${response_category}=    Set Variable    MEDIUM
        ELSE
            ${response_category}=    Set Variable    SHORT
        END
        # Document interaction with screenshots
        Document AI Interaction    ${q}    ${ai_response}    ${response_category}    ${response_length}    ${q_shot}    ${r_shot}
        Sleep    1s

        # Après réception de la réponse : si ce n'est pas la dernière question, cliquez sur 'New Chat' pour préparer la suivante
        ${is_last}=    Evaluate    ${idx} == ${total} - 1
        Run Keyword If    not ${is_last}    Log    Clicking 'New Chat' to prepare next question...    INFO
        Run Keyword If    not ${is_last}    Run Keyword And Ignore Error    Click Element    xpath=//button[@title='Toggle conversation history']
        
        # Essayer d'abord le nouveau sélecteur avec les classes spécifiques
        ${visible_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class,'sc-crKdwm')]//button[contains(@class,'sc-cFPxvH')]    timeout=5s
        Run Keyword If    ${visible_ok}    Execute JavaScript    document.querySelector('.sc-crKdwm button').click();
        
        # Si le premier essai échoue, essayer avec le contenu du texte
        IF    not ${visible_ok}
            Log    Premier sélecteur échoué, essai avec le texte...    WARN
            ${visible_ok2}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//button[contains(.,'New Chat')]    timeout=5s
            Run Keyword If    ${visible_ok2}    Execute JavaScript    Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('New Chat')).click();
        END
        
        # Si toujours pas visible, essayer une approche plus agressive avec JavaScript
        IF    not ${visible_ok} and not ${visible_ok2}
            Log    Tentative de clic avec JavaScript...    WARN
            Execute JavaScript
            ...    var buttons = Array.from(document.querySelectorAll('button'));
            ...    var newChatBtn = buttons.find(b => b.textContent.includes('New Chat'));
            ...    if(newChatBtn) {
            ...        newChatBtn.scrollIntoView();
            ...        newChatBtn.click();
            ...    }
        END
        
        # Attendre un peu après le clic
        Sleep    1s
        
        # Vérifier si le nouveau chat a été créé
        ${chat_created}=    Run Keyword And Return Status    Wait Until Page Contains    No conversations yet    timeout=5s
        
        # Si le nouveau chat n'est pas créé, réessayer avec un clic forcé
        IF    not ${chat_created}
            Log    Tentative de clic forcé...    WARN
            Execute JavaScript
            ...    var btn = document.evaluate("//button[contains(.,'New Chat')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
            ...    if(btn) { btn.click(); }
        END
        
        Sleep    1s
    END

Wait For AI Response And Return Text
    [Arguments]    ${timeout_sec}=180    ${poll_interval}=2
    [Documentation]    Attend la fin de génération de la réponse et retourne le texte complet.
    
    # Attendre que "Thinking" disparaisse en vérifiant à intervalles réguliers
    ${end_time}=    Evaluate    time.time() + ${timeout_sec}
    
    WHILE    time.time() < ${end_time}
        ${thinking_visible}=    Run Keyword And Return Status    Page Should Contain    Thinking
        IF    not ${thinking_visible}    BREAK
        Sleep    ${poll_interval}
    END
    
    # Attendre un peu plus longtemps pour laisser la réponse s'afficher complètement
    Sleep    5s
    
    # Vérifier si le message d'erreur est présent
    ${error_present}=    Run Keyword And Return Status    Page Should Contain    ⚠️ Sorry, I encountered an error
    
    # Si le message d'erreur est présent, le noter mais ne pas réessayer
    IF    ${error_present}
        Log    Message d'erreur détecté dans la réponse    WARN
    END
    
    # Récupérer la réponse
    # Attendre un peu plus pour s'assurer que la réponse est complètement chargée
    Sleep    3s
    
    # Récupérer toutes les réponses possibles
    ${responses}=    Execute JavaScript
    ...    return Array.from(document.querySelectorAll('[class*="content"]'))
    ...            .filter(el => el.innerText && !el.innerText.includes('Sorry') && !el.innerText.includes('Thinking'))
    ...            .map(el => el.innerText);
    
    # Vérifier si des réponses ont été trouvées
    ${responses_length}=    Get Length    ${responses}
    IF    ${responses_length} == 0
        ${response}=    Set Variable    No responses found
    ELSE
        # Prendre la dernière réponse (la plus récente)
        ${response}=    Set Variable    ${responses}[-1]
    END
    
    # Vérifier si la réponse est valide avant de la traiter
    ${response_valid}=    Run Keyword And Return Status    Should Not Be Equal    ${response}    None
    IF    not ${response_valid}
        ${response}=    Set Variable    No response detected
    ELSE
        # Nettoyer et sécuriser la réponse pour éviter les problèmes de syntaxe
        ${response}=    Replace String    ${response}    \n    ${SPACE}
        ${response}=    Replace String    ${response}    \r    ${SPACE}
        ${response}=    Replace String    ${response}    '    ${SPACE}
        ${response}=    Replace String    ${response}    "    ${SPACE}
    END
    
    # Si la réponse est vide ou non trouvée, réessayer avec une autre approche
    ${response_length}=    Get Length    ${response}
    
    # Utiliser une approche plus sûre pour vérifier si la réponse est vide
    ${is_empty_response}=    Run Keyword And Return Status    Should Be True    ${response_length} == 0
    
    IF    ${is_empty_response}
        ${response}=    Execute JavaScript
        ...    return document.querySelector('.sc-dkmUuB')?.innerText || 'No response detected';
    END
    
    # Final validation - ensure response is a safe string
    ${final_response}=    Run Keyword And Return Status    Should Be True    ${response_length} > 0
    IF    not ${final_response}
        ${response}=    Set Variable    Response validation failed
    END
    
    RETURN    ${response}

Generate Word Report After Test
    [Documentation]    Génère automatiquement un rapport Word après la fin du test
    Log    Génération automatique du rapport Word...    INFO
    
    # Vérifier que le fichier de test existe
    ${test_file_exists}=    Run Keyword And Return Status    File Should Exist    ${current_test_filename}
    IF    not ${test_file_exists}
        Log    Fichier de test non trouvé, impossible de générer le rapport Word    WARN
        RETURN
    END
    
    # Générer le rapport Word en utilisant Python
    ${python_script}=    Set Variable    generate_word_report.py
    ${python_script_exists}=    Run Keyword And Return Status    File Should Exist    ${python_script}
    
    IF    ${python_script_exists}
        Log    Exécution du script Python pour générer le rapport Word    INFO
        ${result}=    Run Process    python    ${python_script}    cwd=${CURDIR}
        Log    Sortie du script Python: ${result.stdout}    INFO
        IF    ${result.rc} == 0
            Log    Rapport Word généré avec succès    INFO
        ELSE
            Log    Erreur lors de la génération du rapport Word: ${result.stderr}    WARN
        END
    ELSE
        Log    Script Python non trouvé, génération manuelle du rapport Word    INFO
        # Alternative: créer un rapport simple en utilisant les keywords Robot Framework
        Create Simple Word Report
    END

Create Simple Word Report
    [Documentation]    Crée un rapport Word simple en utilisant les fonctionnalités Robot Framework
    Log    Création d'un rapport Word simple...    INFO
    
    # Créer un fichier de rapport simple
    ${current_time}=    Get Time    format=%Y%m%d_%H%M%S
    ${report_filename}=    Set Variable    ${OUTPUT_DIR}/ai_assistant_documentation/rapport_simple_${current_time}.txt
    ${report_content}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    RAPPORT DE TEST - ASSISTANT IA
    ...    ========================================
    ...    Date de génération: ${current_time}
    ...    Fichier de test: ${current_test_filename}
    ...    ========================================
    ...    Ce rapport a été généré automatiquement après la fin du test.
    ...    Pour un rapport Word complet, exécutez le script Python: generate_word_report.py
    ...    ========================================
    
    Create File    ${report_filename}    ${report_content}
    Log    Rapport simple créé: ${report_filename}    INFO

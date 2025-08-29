*** Settings ***
Documentation     Test suite for AI Assistant login only - stops before clicking AI Assistant button
Library           SeleniumLibrary
Library           String
Library           OperatingSystem
Library           Process
Resource          ressources/variables.robot
Resource          ressources/keywords.robot

*** Test Cases ***
Test AI Assistant Login Only
    Login Only Test
    # Test stops here - login completed successfully
    # The test stops after successful login and dashboard access
    Log    Login test completed - stopping before AI Assistant functionality    INFO
    Capture Page Screenshot    ${OUTPUT_DIR}/ai_assistant/login_completed_dashboard.png
    Close Browser

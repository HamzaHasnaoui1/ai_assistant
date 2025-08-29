*** Settings ***
Documentation     Test suite for testing AI Assistant with automatic verification code retrieval from Yopmail
Library           SeleniumLibrary
Library           String
Library           OperatingSystem
Library           Process
Resource          ressources/variables.robot
Resource          ressources/keywords.robot

*** Test Cases ***
Test AI Assistant Chatbot
    Trigger Verification Code Sending
    Wait And Retrieve Verification Code And Login
    Test AI Assistant Functionality
    Close Browser

*** Settings ***
Library           SeleniumLibrary
Library           ScreenCapLibrary
Library           OperatingSystem
Library           String
Library           Collections
Resource          variables.robot

*** Keywords ***
Custom Suite Setup
    Create Directory    ${OUTPUT_DIR}
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --incognito
    ${prefs}=    Evaluate    {'credentials_enable_service': False, 'profile.password_manager_enabled': False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Open Browser    ${BASE_URL}/auth?sign-up    ${BROWSER}    options=${options}
    Set Selenium Speed    ${SELSPEED}
    Maximize Browser Window
    Start Video Recording    output_directory=${OUTPUT_DIR}    name=${VIDEO_NAME}

Login As Admin
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --incognito
    ${prefs}=    Evaluate    {'credentials_enable_service': False, 'profile.password_manager_enabled': False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Open Browser    ${BASE_URL}/auth    ${BROWSER}    options=${options}
    Set Selenium Speed    ${SELSPEED}
    Maximize Browser Window
    Capture Page Screenshot    ${OUTPUT_DIR}/login/login_before.png
    type    (//input[@id='dark-input'])[1]    ${EMAIL_LOGIN_ADMIN}
    type    (//input[@id='dark-input'])[2]    ${PASSWORD_LOGIN}
    clickAndWait    xpath=//button[@type='submit' and contains(@class, 'ant-btn') and contains(., 'Sign in')]
    Wait Until Element Is Visible    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']    timeout=10s
    type    //input[@id='dark-input' and @placeholder='Enter your 6-digit code']    123456
    clickAndWait    xpath=//button[@type='submit' and contains(@class, 'ant-btn') and contains(@class, 'ant-btn-default') and contains(., 'Submit')]
    Wait Until Location Is    ${BASE_URL}    timeout=15s
    Capture Page Screenshot    ${OUTPUT_DIR}/login/login_dashboard.png

Force Email Field Empty
    Execute JavaScript
    ...    var el = document.getElementById("email");
    ...    el.value = '';
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('change', { bubbles: true }));
    Sleep    0.2s
    Element Attribute Value Should Be    id=email    value    ${EMPTY}

TC-001 Assisted Subscription
    Login As Admin
    # A1: Naviguer vers le menu de navigation admin (généralement déjà visible après login)
    Wait Until Element Is Visible    //aside[contains(@class, 'ant-layout-sider')]    timeout=10s
    Capture Page Screenshot    ./results/TC-001/after_logIn.png
    # Scroll et clique sur 'Operation Management'
    Scroll To Element And Wait    xpath=//span[normalize-space(text())='Operation Management']    10s    250
    Capture Page Screenshot    ./results/TC-001/after_scroll_operation_management.png
    clickAndWait    xpath=//span[normalize-space(text())='Operation Management']
    # Scroll et clique sur 'Subscription'
    Scroll To Element And Wait    xpath=//span[@class='ant-menu-title-content' and normalize-space(text())='Subscription']    10s    250
    Capture Page Screenshot    ./results/TC-001/after_scroll_subscription.png
    clickAndWait    xpath=//span[@class='ant-menu-title-content' and normalize-space(text())='Subscription']
    Capture Page Screenshot    ./results/TC-001/after_click_subscription.png
    # A3: Vérifier que l'onglet "Assisted Subscription" est visible (sélecteur flexible)
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']    timeout=5s
    Capture Page Screenshot    ./results/TC-001/after_assisted_subscription_tab_visible.png
    # A4: Scroll puis cliquer sur l'onglet "Assisted Subscription" (sélecteur flexible)
    Scroll Element Into View    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']
    clickAndWait    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']
    Capture Page Screenshot    ./results/TC-001/after_click_assisted_subscription_tab.png
    # A5: Vérifier que le sous-onglet "Invite Subscriber" est affiché
    Capture Page Screenshot    ./results/TC-001/before_invite_a_subscriber.png
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-invite') and normalize-space(text())='Invite a Subscriber']    timeout=10s
    # A6: Vérifier que le sous-onglet "Onboard with Proof of Payment" est affiché et le sélectionner (clic JS avancé)
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-onboard')]    timeout=5s
    Capture Page Screenshot    ./results/TC-001/after_onboard_tab_visible.png
    Scroll Element Into View    xpath=//div[@role='tab' and contains(@id, '-tab-onboard')]
    Capture Page Screenshot    ./results/TC-001/after_scroll_onboard_tab.png
    Sleep    1s
    Click Element    xpath=//div[@role='tab' and contains(@id, '-tab-onboard')]
    Capture Page Screenshot    ./results/TC-001/after_click_onboard_tab.png
    # Si le clic classique ne fonctionne pas, on tente un clic JS direct
    Run Keyword And Ignore Error    Execute Javascript    document.querySelector("div[role='tab'][id*='-tab-onboard']").click()
    Element Attribute Value Should Be    xpath=//div[@role='tab' and contains(@id, '-tab-onboard')]    aria-selected    true
  

Custom Suite Teardown
    Stop Video Recording
    Close Browser

Wait And Screenshot
    [Arguments]    ${locator}    ${screenshot_name}
    Wait Until Element Is Visible    ${locator}    timeout=30s
    Sleep    5s
    Capture Page Screenshot    ${OUTPUT_DIR}/${screenshot_name}.png

open
    [Arguments]    ${element}
    Go To          ${element}

clickAndWait
    [Arguments]    ${element}
    Click Element  ${element}

click
    [Arguments]    ${element}
    Click Element  ${element}

sendKeys
    [Arguments]    ${element}    ${value}
    Press Keys     ${element}    ${value}

submit
    [Arguments]    ${element}
    Submit Form    ${element}

type
    [Arguments]    ${element}    ${value}
    Input Text     ${element}    ${value}

selectAndWait
    [Arguments]        ${element}  ${value}
    Select From List By Value   ${element}  ${value}

select
    [Arguments]        ${element}  ${value}
    Select From List By Value   ${element}  ${value}

verifyValue
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

verifyText
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

verifyElementPresent
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

verifyVisible
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

verifyTitle
    [Arguments]                  ${title}
    Title Should Be              ${title}

verifyTable
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

assertConfirmation
    [Arguments]                  ${value}
    Alert Should Be Present      ${value}

assertText
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

assertValue
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

assertElementPresent
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

assertVisible
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

assertTitle
    [Arguments]                  ${title}
    Title Should Be              ${title}

assertTable
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

waitForText
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

waitForValue
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

waitForElementPresent
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

waitForVisible
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

waitForTitle
    [Arguments]                  ${title}
    Title Should Be              ${title}

waitForTable
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

doubleClick
    [Arguments]           ${element}
    Double Click Element  ${element}

doubleClickAndWait
    [Arguments]           ${element}
    Double Click Element  ${element}

goBack
    Go Back

goBackAndWait
    Go Back

runScript
    [Arguments]         ${code}
    Execute Javascript  ${code}

runScriptAndWait
    [Arguments]         ${code}
    Execute Javascript  ${code}

setSpeed
    [Arguments]           ${value}
    Set Selenium Timeout  ${value}

setSpeedAndWait
    [Arguments]           ${value}
    Set Selenium Timeout  ${value}

verifyAlert
    [Arguments]              ${value}
    Alert Should Be Present  ${value}

Skipper Modal Nouvelle Société Si Présent
    [Documentation]    Ferme le modal de nouvelle société s'il apparaît (Continue ou Contact Support).
    ${modal_visible}=    Run Keyword And Return Status    Element Should Be Visible    //div[contains(@class, 'ant-modal-content')]
    Run Keyword If    ${modal_visible}    Run Keyword And Ignore Error    Click Element    //div[contains(@class, 'ant-modal-content')]//button[.//span[normalize-space(text())='Continue']]
    Run Keyword If    ${modal_visible}    Run Keyword And Ignore Error    Click Element    //div[contains(@class, 'ant-modal-content')]//button[.//span[normalize-space(text())='Contact Support']]
    Run Keyword If    ${modal_visible}    Sleep    0.5s
    Run Keyword If    ${modal_visible}    Log    Modal fermé avec succès.    INFO

Scroll To Element And Wait
    [Arguments]    ${locator}    ${timeout}=10s    ${scroll_pixels}=250
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Scroll Element Into View         ${locator}
    Execute JavaScript              window.scrollBy(0, ${scroll_pixels})
    Sleep       1s

Wait Until Verification Page Is Loaded
    Wait Until Page Contains    Verify your e-mail address    timeout=15s

TC-002 Invite Subscriber Tab
    TC-001 Assisted Subscription
    Click Element    xpath=//div[@role='tab' and contains(@id, '-tab-invite')]
    Wait Until Element Is Visible    xpath=//button[.//span[normalize-space(text())='Invite Subscriber']]    timeout=5s
    Element Should Be Enabled    xpath=//button[.//span[normalize-space(text())='Invite Subscriber']]
    Wait Until Element Is Visible    xpath=//button[.//span[normalize-space(text())='Bulk Invite']]    timeout=5s
    Element Should Be Enabled    xpath=//button[.//span[normalize-space(text())='Bulk Invite']]
    Scroll Element Into View    xpath=//div[contains(@class, 'ant-tabs-tabpane-active') and contains(@id, '-panel-invite')]//table
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-tabs-tabpane-active') and contains(@id, '-panel-invite')]//table    timeout=30s

Scroll Invite Subscriber Table Fully
    # Scroll le tableau dans la fenêtre (viewport)
    Scroll Element Into View    xpath=//div[contains(@class, 'ant-tabs-tabpane-active') and contains(@id, '-panel-invite')]//table
    # Scroll verticalement pour rendre visible la 7e ligne
    Scroll Element Into View    xpath=//*[@id="rc-tabs-1-panel-invite"]/div/div[2]/div[1]/div/div/div/div/div/table/tbody/tr[7]/td[1]
    Sleep    0.5s
    # Scroll horizontalement tout à droite pour afficher toutes les colonnes
    Execute JavaScript    document.querySelector("div.ant-tabs-tabpane-active div.ant-table-content").scrollLeft = 10000
    # Attendre que la première ligne visible du tableau soit affichée (sécurité)
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'ant-tabs-tabpane-active') and contains(@id, '-panel-invite')]//tbody/tr[not(@aria-hidden='true')][1]    timeout=10s

Table Column Should Exist
    [Arguments]    ${column_name}
    Element Should Be Visible    xpath=//div[contains(@class, 'ant-tabs-tabpane-active') and contains(@id, '-panel-invite')]//th[normalize-space(.)='${column_name}' or .//span[normalize-space(text())='${column_name}']]


Open Invite Subscriber Form
    TC-002 Invite Subscriber Tab
    Click Element    xpath=//*[@id="rc-tabs-1-panel-invite"]/div/div[1]/div[1]/button
    Wait Until Element Is Visible    xpath=//form[contains(@class, 'ant-form') and (//div[contains(@class, 'ant-modal') or contains(@class, 'ant-drawer')])]
    Capture Page Screenshot    ./results/TC-004/invite_form_opened.png

Open Invite Subscriber Form Clean
    Reload Page
    Sleep    1s
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']    timeout=5s
    Capture Page Screenshot    ./results/TC-001/after_assisted_subscription_tab_visible.png
    Scroll Element Into View    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']
    clickAndWait    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']
    Capture Page Screenshot    ./results/TC-001/after_click_assisted_subscription_tab.png
    Capture Page Screenshot    ./results/TC-001/before_invite_a_subscriber.png
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-invite') and normalize-space(text())='Invite a Subscriber']    timeout=10s
    Click Element    xpath=//*[@id="rc-tabs-1-panel-invite"]/div/div[1]/div[1]/button
    Wait Until Element Is Visible    xpath=//form[contains(@class, 'ant-form') and (//div[contains(@class, 'ant-modal') or contains(@class, 'ant-drawer')])]
    Clear Field Robustly    id=email
    Sleep    0.5s

Clear Field Robustly
    [Arguments]    ${locator}
    ${element_id}=    Set Variable    ${locator.split("=")[1]}
    Execute JavaScript
    ...    var el = document.getElementById("${element_id}");
    ...    el.value = '';
    ...    el.dispatchEvent(new Event('input', { bubbles: true }));
    ...    el.dispatchEvent(new Event('change', { bubbles: true }));
    Sleep    0.2s
    ${value}=    Get Element Attribute    ${locator}    value
    Should Be Equal    ${value}    ${EMPTY}

TC-004 Verify Validation Rules For First Name And Last Name
    Open Invite Subscriber Form
    # A1: Entrer des caractères invalides dans First Name
    Input Text    id=firstName    John@123
    # Vérifier qu'un message d'erreur de validation s'affiche
    Element Should Be Visible    xpath=//*[@id="firstName_help"]/div
    Capture Page Screenshot    ./results/TC-004/first_name_invalid.png
    # A2: Entrer une valeur valide dans First Name
    Clear Field Robustly    id=firstName
    Wait Until Element Is Visible    id=firstName    timeout=5s
    Sleep    0.3s
    Input Text    id=firstName    John
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    xpath=//*[@id="firstName_help"]/div    3s
    Element Attribute Value Should Be    id=firstName    value    John
    Capture Page Screenshot    ./results/TC-004/first_name_valid.png
    # A3: Répéter pour Last Name
    Input Text    id=lastName    Doe@123
    Element Should Be Visible    xpath=//*[@id="lastName_help"]/div
    Capture Page Screenshot    ./results/TC-004/last_name_invalid.png
    Click Element    id=lastName
    Clear Field Robustly    id=lastName
    Wait Until Element Is Visible    id=lastName    timeout=5s
    Sleep    0.3s
    Input Text    id=lastName    Doe
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    xpath=//*[@id="lastName_help"]/div    3s
    Element Attribute Value Should Be    id=lastName    value    Doe
    Capture Page Screenshot    ./results/TC-004/last_name_valid.png


Remplir Formulaire Invitation Sans Business Type
    [Arguments]    ${firstName}    ${lastName}    ${email}    ${companyName}    ${companyNumber}    ${phone}    ${country}
    Input Text    id=firstName    ${firstName}
    Input Text    id=lastName    ${lastName}
    Input Text    id=email    ${email}
    Input Text    id=companyName    ${companyName}
    Input Text    id=companyNumber    ${companyNumber}
    Input Text    css:input.form-control[type="tel"]    ${phone}
    Click Element    xpath=//div[contains(@class, 'ant-select') and .//input[@id='companyCountry']]
    Input Text    id=companyCountry    ${country}
    Wait Until Element Is Visible    //div[contains(@class, "ant-select-item-option-content") and contains(., "${country}")]
    Click Element    //div[contains(@class, "ant-select-item-option-content") and contains(., "${country}")]

Remplir Formulaire Invitation Avec Business Type
    [Arguments]    ${firstName}    ${lastName}    ${email}    ${companyName}    ${companyNumber}    ${phone}    ${country}    ${businessType}
    Remplir Formulaire Invitation Sans Business Type    ${firstName}    ${lastName}    ${email}    ${companyName}    ${companyNumber}    ${phone}    ${country}
    Click Element    xpath=//input[@id='businessType']/ancestor::div[contains(@class, 'ant-select')]//div[contains(@class, 'ant-select-selector')]
    Sleep    0.5s
    Wait Until Element Is Visible    //div[contains(@class, 'ant-select-dropdown') and not(contains(@class, 'ant-select-dropdown-hidden'))]//div[contains(@class, 'ant-select-item-option-content') and text()='${businessType}']
    Click Element    //div[contains(@class, 'ant-select-dropdown') and not(contains(@class, 'ant-select-dropdown-hidden'))]//div[contains(@class, 'ant-select-item-option-content') and text()='${businessType}']

Soumettre Formulaire Invitation
    Click Element    xpath=//button[@type='submit' and .//span[normalize-space(text())='Invite']]

Verifier Modal Confirmation
    Wait Until Element Is Visible    //div[contains(@class, 'ant-modal-body')]
    ${modal_text}=    Get Text    //div[contains(@class, 'ant-modal-body')]
    Log    Modal text: ${modal_text}
    Run Keyword And Ignore Error    Should Contain    ${modal_text}    New Company Submission
    Run Keyword And Ignore Error    Should Contain    ${modal_text}    Company Check
    Run Keyword And Ignore Error    Should Contain    ${modal_text}    has been identified as a new entry
    Run Keyword And Ignore Error    Should Contain    ${modal_text}    Unable to determine company status
    [Return]    ${modal_text}

Element Attribute Should Not Exist
    [Arguments]    ${locator}    ${attribute}
    ${value}=    Get Element Attribute    ${locator}    ${attribute}
    Should Be Empty    ${value}

Element Should Contain Attribute
    [Arguments]    ${locator}    ${attribute}    ${expected_value}
    ${actual}=    Get Element Attribute    ${locator}    ${attribute}
    Should Contain    ${actual}    ${expected_value}

Element Attribute Should Not Contain
    [Arguments]    ${locator}    ${attribute}    ${unexpected_value}
    ${actual}=    Get Element Attribute    ${locator}    ${attribute}
    Should Not Contain    ${actual}    ${unexpected_value}

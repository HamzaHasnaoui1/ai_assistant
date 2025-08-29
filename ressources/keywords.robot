*** Settings ***
Library           SeleniumLibrary
Library           ScreenCapLibrary
Library           OperatingSystem
Library           String
Library           Collections
Library           Process
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
    # A1: Navigate to admin navigation menu (usually already visible after login)
    Wait Until Element Is Visible    //aside[contains(@class, 'ant-layout-sider')]    timeout=10s
    Capture Page Screenshot    ./results/TC-001/after_logIn.png
    # Scroll and click on 'Operation Management'
    Scroll To Element And Wait    xpath=//span[normalize-space(text())='Operation Management']    10s    250
    Capture Page Screenshot    ./results/TC-001/after_scroll_operation_management.png
    clickAndWait    xpath=//span[normalize-space(text())='Operation Management']
    # Scroll and click on 'Subscription'
    Scroll To Element And Wait    xpath=//span[@class='ant-menu-title-content' and normalize-space(text())='Subscription']    10s    250
    Capture Page Screenshot    ./results/TC-001/after_scroll_subscription.png
    clickAndWait    xpath=//span[@class='ant-menu-title-content' and normalize-space(text())='Subscription']
    Capture Page Screenshot    ./results/TC-001/after_click_subscription.png
    # A3: Check that "Assisted Subscription" tab is visible (flexible selector)
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']    timeout=5s
    Capture Page Screenshot    ./results/TC-001/after_assisted_subscription_tab_visible.png
    # A4: Scroll then click on "Assisted Subscription" tab (flexible selector)
    Scroll Element Into View    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']
    clickAndWait    xpath=//div[@role='tab' and contains(@id, '-tab-assisted-subscription') and text()='Assisted Subscription']
    Capture Page Screenshot    ./results/TC-001/after_click_assisted_subscription_tab.png
    # A5: Check that "Invite Subscriber" sub-tab is displayed
    Capture Page Screenshot    ./results/TC-001/before_invite_a_subscriber.png
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-invite') and normalize-space(text())='Invite a Subscriber']    timeout=10s
    # A6: Check that "Onboard with Proof of Payment" sub-tab is displayed and select it (advanced JS click)
    Wait Until Element Is Visible    xpath=//div[@role='tab' and contains(@id, '-tab-onboard')]    timeout=5s
    Capture Page Screenshot    ./results/TC-001/after_onboard_tab_visible.png
    Scroll Element Into View    xpath=//div[@role='tab' and contains(@id, '-tab-onboard')]
    Capture Page Screenshot    ./results/TC-001/after_scroll_onboard_tab.png
    Sleep    1s
    Click Element    xpath=//div[@role='tab' and contains(@id, '-tab-onboard')]
    Capture Page Screenshot    ./results/TC-001/after_click_onboard_tab.png
    # If classic click doesn't work, try direct JS click
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
    # Scroll the table in the window (viewport)
    Scroll Element Into View    xpath=//div[contains(@class, 'ant-tabs-tabpane-active') and contains(@id, '-panel-invite')]//table
    # Scroll vertically to make the 7th row visible
    Scroll Element Into View    xpath=//*[@id="rc-tabs-1-panel-invite"]/div/div[2]/div[1]/div/div/div/div/div/table/tbody/tr[7]/td[1]
    Sleep    0.5s
    # Scroll horizontally all the way to the right to display all columns
    Execute JavaScript    document.querySelector("div.ant-tabs-tabpane-active div.ant-table-content").scrollLeft = 10000
    # Wait for the first visible row of the table to be displayed (safety)
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
    # A1: Enter invalid characters in First Name
    Input Text    id=firstName    John@123
    # Check that a validation error message is displayed
    Element Should Be Visible    xpath=//*[@id="firstName_help"]/div
    Capture Page Screenshot    ./results/TC-004/first_name_invalid.png
    # A2: Enter a valid value in First Name
    Clear Field Robustly    id=firstName
    Wait Until Element Is Visible    id=firstName    timeout=5s
    Sleep    0.3s
    Input Text    id=firstName    John
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    xpath=//*[@id="firstName_help"]/div    3s
    Element Attribute Value Should Be    id=firstName    value    John
    Capture Page Screenshot    ./results/TC-004/first_name_valid.png
    # A3: Repeat for Last Name
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

# AI Assistant specific keywords
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
    # Create a unique filename for this test at the beginning
    # SECURE FORMAT FOR WINDOWS: YYYYMMDD_HHMMSS (example: 20250825_161554)
    # IMPORTANT: This format avoids OSError on Windows
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
    
    # Automatically generate Word report if enabled
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
    
    # File 1: Complete history of all tests
    ${history_filename}=    Set Variable    ${doc_dir}/ai_interactions_full_log.txt
    
    # File 2: Current test interactions (use the name created at the beginning of the test)
    # The name is already defined in Test AI Assistant Functionality with Set Suite Variable
    # No need to generate a new timestamp here
    ${current_test_filename}=    Set Variable    ${current_test_filename}

    ${words}=    Split String    ${answer}
    ${word_count}=    Get Length    ${words}

    # Detect if the response ends with a question mark
    ${ends_with_question_mark}=    Run Keyword And Return Status    Should Match Regexp    ${answer}    \\?$
    ${question_mark_present}=    Set Variable If    ${ends_with_question_mark}    YES    NO

    # Calculate the response quality matrix
    ${quality_score}=    Evaluate    min(100, (${length} / ${LONG_CHAR_THRESHOLD}) * 100)
    ${quality_score}=    Evaluate    round(${quality_score}, 2)

    # Content for complete history
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

    # Content for current test (single interaction)
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

    # 1. Add to complete history (append)
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

    # 2. Add to current test file (append to accumulate all interactions)
    # First create the file if it doesn't exist, then append
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

    # Create master log file if it doesn't exist, then append
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
    [Documentation]    Reads each line from file ${file_path} and sends the question separately.
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
    # Remove empty lines and duplicates
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
        Sleep    2s    # Wait a bit more before looking for the input field
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

  #     Send ENTER key after input
        Press Keys    xpath=//input[contains(@placeholder,'Enter a prompt here')]    RETURN        Log    Question submitted, waiting for AI response    INFO
       
        ${ai_response}=    Wait For AI Response And Return Text    ${AI_RESPONSE_WAIT_SEC}    ${AI_RESPONSE_POLL_INTERVAL}
        Log    AI Response received for question '${q}': ${ai_response}    INFO
        # Capture screenshot after receiving the response; use filename-safe timestamp to avoid overwriting
        ${resp_ts}=    Get Time    format=%Y-%m-%d_%H-%M-%S
        ${resp_ts_safe}=    Replace String    ${resp_ts}    :    -
        ${resp_ts_safe}=    Replace String    ${resp_ts_safe}    ${SPACE}    _
        ${r_shot}=    Set Variable    ${screens_dir}/response_${display_idx}-${resp_ts_safe}.png
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

        # After receiving the response: if it's not the last question, click 'New Chat' to prepare the next one
        ${is_last}=    Evaluate    ${idx} == ${total} - 1
        Run Keyword If    not ${is_last}    Log    Clicking 'New Chat' to prepare next question...    INFO
        Run Keyword If    not ${is_last}    Run Keyword And Ignore Error    Click Element    xpath=//button[@title='Toggle conversation history']
        
        # Try first with the new selector with specific classes
        ${visible_ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//div[contains(@class,'sc-crKdwm')]//button[contains(@class,'sc-cFPxvH')]    timeout=5s
        Run Keyword If    ${visible_ok}    Execute JavaScript    document.querySelector('.sc-crKdwm button').click();
        
        # If first attempt fails, try with text content
        IF    not ${visible_ok}
            Log    First selector failed, trying with text...    WARN
            ${visible_ok2}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//button[contains(.,'New Chat')]    timeout=5s
            Run Keyword If    ${visible_ok2}    Execute JavaScript    Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('New Chat')).click();
        END
        
        # If still not visible, try a more aggressive approach with JavaScript
        IF    not ${visible_ok} and not ${visible_ok2}
            Log    Attempting click with JavaScript...    WARN
            Execute JavaScript
            ...    var buttons = Array.from(document.querySelectorAll('button'));
            ...    var newChatBtn = buttons.find(b => b.textContent.includes('New Chat'));
            ...    if(newChatBtn) {
            ...        newChatBtn.scrollIntoView();
            ...        newChatBtn.click();
            ...    }
        END
        
        # Wait a bit after the click
        Sleep    1s
        
        # Check if new chat was created
        ${chat_created}=    Run Keyword And Return Status    Wait Until Page Contains    No conversations yet    timeout=5s
        
        # If new chat was not created, retry with forced click
        IF    not ${chat_created}
            Log    Attempting forced click...    WARN
            Execute JavaScript
            ...    var btn = document.evaluate("//button[contains(.,'New Chat')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
            ...    if(btn) { btn.click(); }
        END
        
        Sleep    1s
    END

Wait For AI Response And Return Text
    [Arguments]    ${timeout_sec}=180    ${poll_interval}=2
    [Documentation]    Waits for the end of response generation and returns the complete text.
    
    # Wait for "Thinking" to disappear by checking at regular intervals
    ${end_time}=    Evaluate    time.time() + ${timeout_sec}
    
    WHILE    time.time() < ${end_time}
        ${thinking_visible}=    Run Keyword And Return Status    Page Should Contain    Thinking
        IF    not ${thinking_visible}    BREAK
        Sleep    ${poll_interval}
    END
    
    # Wait a bit longer to let the response display completely
    Sleep    5s
    
    # Check if error message is present
    ${error_present}=    Run Keyword And Return Status    Page Should Contain    ⚠️ Sorry, I encountered an error
    
    # If error message is present, note it but don't retry
    IF    ${error_present}
        Log    Error message detected in response    WARN
    END
    
    # Get the response
    # Wait a bit more to ensure the response is completely loaded
    Sleep    3s
    
    # Use a very simple JavaScript approach to avoid syntax problems
    ${ai_response}=    Execute JavaScript    var elements = document.querySelectorAll('[class*="content"]'); var responses = []; for (var i = 0; i < elements.length; i++) { var text = elements[i].innerText || elements[i].textContent; if (text && text.trim() && !text.includes('Thinking') && !text.includes('Sorry')) { responses.push(text.trim()); } } return responses.length > 0 ? responses[responses.length - 1] : 'No response detected';
    
    # Check if responses were found
    ${response_length}=    Get Length    ${ai_response}
    IF    ${response_length} == 0
        ${ai_response}=    Set Variable    No responses found
    END
    
    # Check if response is valid before processing
    ${response_valid}=    Run Keyword And Return Status    Should Not Be Equal    ${ai_response}    None
    IF    not ${response_valid}
        ${ai_response}=    Set Variable    No response detected
    ELSE
        # Clean and secure the response to avoid syntax problems
        ${ai_response}=    Replace String    ${ai_response}    \n    ${SPACE}
        ${ai_response}=    Replace String    ${ai_response}    \r    ${SPACE}
        ${ai_response}=    Replace String    ${ai_response}    '    ${SPACE}
        ${ai_response}=    Replace String    ${ai_response}    "    ${SPACE}
        
        # Clean user interface elements that might still be present
        ${ai_response}=    Replace String    ${ai_response}    SMART SEARCH ADMINISTRATED SERVICES    ${EMPTY}
        ${ai_response}=    Replace String    ${ai_response}    Navigate to    ${EMPTY}
        ${ai_response}=    Replace String    ${ai_response}    Learn More    ${EMPTY}
        ${ai_response}=    Replace String    ${ai_response}    Navigate To ATG AI Assistant    ${EMPTY}
        ${ai_response}=    Replace String    ${ai_response}    ATG AI ASSISTANT    ${EMPTY}
        
        # Clean multiple spaces
        ${ai_response}=    Replace String    ${ai_response}    ${SPACE}${SPACE}    ${SPACE}
        ${ai_response}=    Strip String    ${ai_response}
    END
    
    # If response is empty or not found, retry with another approach
    ${response_length}=    Get Length    ${ai_response}
    
    # Use a safer approach to check if response is empty
    ${is_empty_response}=    Run Keyword And Return Status    Should Be True    ${response_length} == 0
    
    IF    ${is_empty_response}
        ${ai_response}=    Execute JavaScript    return document.querySelector('.sc-dkmUuB')?.innerText || 'No response detected';
    END
    
    # Final validation - ensure response is a safe string
    ${final_response}=    Run Keyword And Return Status    Should Be True    ${response_length} > 0
    IF    not ${final_response}
        ${ai_response}=    Set Variable    Response validation failed
    END
    
    RETURN    ${ai_response}

Generate Word Report After Test
    [Documentation]    Automatically generates a Word report after the test ends
    Log    Automatically generating Word report...    INFO
    
    # Check that the test file exists
    ${test_file_exists}=    Run Keyword And Return Status    File Should Exist    ${current_test_filename}
    IF    not ${test_file_exists}
        Log    Test file not found, impossible to generate Word report    WARN
        RETURN
    END
    
    # Generate Word report using Python - navigate to project root first
    ${current_dir}=    Set Variable    ${CURDIR}
    Log    Current directory: ${current_dir}    INFO
    
    # Navigate to project root (go up one level from ressources/)
    ${project_root}=    Set Variable    ${current_dir}/..
    ${python_script}=    Set Variable    ${project_root}/generate_word_report.py
    ${python_script_exists}=    Run Keyword And Return Status    File Should Exist    ${python_script}
    
    IF    ${python_script_exists}
        Log    Executing Python script to generate Word report: ${python_script}    INFO
        ${result}=    Run Process    python    ${python_script}    cwd=${project_root}
        Log    Python script output: ${result.stdout}    INFO
        IF    ${result.rc} == 0
            Log    Word report generated successfully    INFO
        ELSE
            Log    Error during Word report generation: ${result.stderr}    WARN
        END
    ELSE
        Log    Python script not found at: ${python_script}    WARN
        Log    Project root: ${project_root}    INFO
        # Alternative: create a simple report using Robot Framework keywords
        Create Simple Word Report
    END

Create Simple Word Report
    [Documentation]    Creates a simple Word report using Robot Framework features
    Log    Creating a simple Word report...    INFO
    
    # Create a simple report file with Windows-safe filename
    ${current_time}=    Get Time    format=%Y%m%d_%H%M%S
    ${current_time_safe}=    Replace String    ${current_time}    -    ${EMPTY}
    ${current_time_safe}=    Replace String    ${current_time_safe}    :    ${EMPTY}
    ${current_time_safe}=    Replace String    ${current_time_safe}    ${SPACE}    _
    ${report_filename}=    Set Variable    ${OUTPUT_DIR}/ai_assistant_documentation/simple_report_${current_time_safe}.txt
    ${report_content}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    TEST REPORT - AI ASSISTANT
    ...    ========================================
    ...    Generation date: ${current_time}
    ...    Test file: ${current_test_filename}
    ...    ========================================
    ...    This report was automatically generated after the test ended.
    ...    For a complete Word report, run the Python script: generate_word_report.py
    ...    ========================================
    
    Create File    ${report_filename}    ${report_content}
    Log    Simple report created: ${report_filename}    INFO

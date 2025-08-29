*** Variables ***
${FIRST_NAME}        hamza
${LAST_NAME}         hamza
${PASSWORD}          Admin@123
${COUNTRY}           Morocco
${OUTPUT_DIR}        ./results
${VIDEO_NAME}        test_registration
${BROWSER}           chrome
${SELSPEED}          0.1s
${BASE_URL}          https://uat.atg.africa/workspace
${PHONE_NUMBER}      666666666
${NB_INSCRIPTIONS}    2
${EMAIL_LOGIN_ADMIN}        shadowadmin@yopmail.com
${PASSWORD_LOGIN}     Admin@123
${EMAIL_LOGIN}        testhamza1@yopmail.com

# AI Assistant specific variables
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
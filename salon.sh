#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
MAIN_MENU() {
  echo -e '\n~~~~~ MY SALON ~~~~~\n'
  echo -e '\nWelcome to My Salon, how can I help you?\n'
  
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
#get available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services WHERE available = true")

#servces are not available
if [[ -z $AVAILABLE_SERVICES ]]
then
MAIN_MENU "I could not find that service. What would you like today?"
else
# display available services
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
MAIN_MENU "That is not a valid number."
else
SERVICE_AVAILABILITY=$($PSQL "SELECT available FROM services WHERE service_id = $SERVICE_ID_SELECTED AND available = true")
if [[ -z $SERVICE_AVAILABILITY ]]
then
MAIN_MENU "I could not find that service. What would you like today?"
else
# get customer info
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
# if customer doesn't exist
if [[ -z $CUSTOMER_NAME ]]
then
echo -e "\nI don't have a record of that number, What's your name?"
read CUSTOMER_NAME
INSERT_CUSTOMER_RESULTS=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nWhat time would you like your ${SERVICE_NAME}, ${CUSTOMER_NAME}?"
read SERVICE_TIME
INSERT_APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')");
echo -e "\nI have put you down for a ${SERVICE_NAME} at ${SERVICE_TIME}, ${CUSTOMER_NAME}."
else
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
echo -e "\nWhat time would you like your ${SERVICE_NAME}, ${CUSTOMER_NAME}?"
read SERVICE_TIME
INSERT_APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')");
echo -e "\nI have put you down for a ${SERVICE_NAME} at ${SERVICE_TIME}, ${CUSTOMER_NAME}."
fi
fi
fi
fi
}

MAIN_MENU

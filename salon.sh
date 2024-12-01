#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon  --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

SERVICES_MENU(){
echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"
read SERVICE_ID_SELECTED
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *$//')

if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
then
# no such service
echo -e "\nI could not find that service. What would you like today?"
SERVICES_MENU
else
# service exit
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# no record
  if [[ -z $CUSTOMER_ID ]]
  then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *$//')
  # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' AND name = '$CUSTOMER_NAME'")
  # get sppointment time
  echo -e "\nWhat time would you like your $FORMATTED_SERVICE_NAME, $FORMATTED_CUSTOMER_NAME?"
  read SERVICE_TIME
  #insert new appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."

# customer exist
  else
  # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *$//')
  # get appointment time
  echo -e "\nWhat time would you like your $FORMATTED_SERVICE_NAME, $FORMATTED_CUSTOMER_NAME?"
  read SERVICE_TIME
  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
  fi
fi
}

SERVICES_MENU

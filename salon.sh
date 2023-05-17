#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ Salon Shop ~~~\n"

SERVICE_MENU () {
  # display additional context message if there is one
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to the Salon Shop! What service would you like?\n"

  # get available services and list them
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
  echo "$SERVICE_ID) $NAME"
  done

  # read selected service
  echo -e "\nType the number of the service requested (e.g. 1)"
  read SERVICE_ID_SELECTED

  # validate the input being a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # return to service menu
    SERVICE_MENU "Invalid input. Enter a number."
  else
    # get service name
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # validate the input being an existing service
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      # return to service menu
      SERVICE_MENU "Sorry! That service does not exist."
    else
      # get customer phone and name if the phone number exists
      echo -e "\nThank you for your selection of$SERVICE_NAME_SELECTED. Please enter your phone number:"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # if the customer does not exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get customer name
        echo -e "\nHello new customer! Please enter your name:"
        read CUSTOMER_NAME

        # insert information for new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # get time for service
      echo -e "\nWhat time would you like your$SERVICE_NAME_SELECTED appointment, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # insert appointment information after getting customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # success message
      echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SERVICE_MENU
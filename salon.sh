#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples -c"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display services
  echo -e "\nWhat would you like to do?"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  echo "x) EXIT"

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    x|X) exit ;;
    *) GET_SERVICE $SERVICE_ID_SELECTED ;;
  esac

}

GET_SERVICE() {
  echo -e "\n Selected service is $1"
       # get serivice_id
      SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $1")

      # if not valid
      if [[ -z $SERVICE_ID_SELECTED ]]
      then
        # send to service menu
        SERVICE_MENU "Invalid service $1"
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME

          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        # get time
        echo -e "\nWhen would you like to have your service performed?"
        read SERVICE_TIME
        # insert appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        # get service name
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

        # send to main menu
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      
    fi
}


SERVICE_MENU
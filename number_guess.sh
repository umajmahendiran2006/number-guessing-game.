#!/bin/bash

# Database query variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Secret number generation
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt for username
echo "Enter your username:"
read USERNAME

# Query database for user
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# Check if user exists
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Initialize guess tracking
GUESS_COUNT=0
echo "Guess the secret number between 1 and 1000:"

# Guess loop
while true
do
  read GUESS
  ((GUESS_COUNT++))

  # Input validation
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Higher/Lower/Win checks
  if (( GUESS == SECRET_NUMBER ))
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $GUESS_COUNT)")
    break
  elif (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done
# feat: user database
# fix: text formats
# feat: random math
# refactor: loops

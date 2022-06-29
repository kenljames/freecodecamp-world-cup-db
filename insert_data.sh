#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get team_id for winner
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert winner into teams table
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi

      # get new team_id for winner
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      echo New team id is: $WINNER_TEAM_ID
    fi

    # get team_id for opponent
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      # insert opponent into teams table
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      # get new team_id for opponent
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      echo New team id is: $OPPONENT_TEAM_ID
    fi

    # insert game info
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into into games, $YEAR $ROUND with $WINNER vs $OPPONENT
    fi
  fi
done

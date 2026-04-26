#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

function select_team_id() {
  if [[ $# -eq 1 ]]; then
    echo $($PSQL "SELECT team_id FROM teams WHERE name = '$1'")
  fi
}

function insert_teams() {
  if [[ $# -eq 1 ]]; then
    TEAM_ID=$(select_team_id "$1")
    if [[ -z $TEAM_ID ]]; then
      INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
      if [[ $INSERT_RESULT == "INSERT 0 1" ]]; then
        echo $(select_team_id "$1")
      fi
    else
        echo $TEAM_ID
    fi
  fi 
}

while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR = "year" ]]; then
    continue
  fi
  WINNER_ID=$(insert_teams "$WINNER")
  OPPONENT_ID=$(insert_teams "$OPPONENT")
  INSERT_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
  VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")"
done < games.csv

#!/bin/bash

function scan(){
  local table_name=${1:-"wcpfs-games-test"}
  aws dynamodb scan --table-name $table_name
}

function query(){
  if [ -z $2 ]; then
    echo "Missing game id to query"
    exit 1
  fi

  local table_name=${1:-"wcpfs-games-test"}
  local game_id=`string_value $2`
  aws dynamodb query --table-name $table_name --key-conditions "{\"id\": {\"AttributeValueList\": [$game_id], \"ComparisonOperator\": \"EQ\"}}" --attributes-to-get "id" "title" "seats" "email_ids" "discussion"
}

function empty_array(){
  if [ $# -lt 3 ]; then
    echo "empty_array usage:"
    echo "./bin/db_ops emptyArray <table> <game_id> <field_name>"
    echo "     Ex: ./bin/db_ops emptyArray wcpfs-games-test 56088e90-f894-4282-a244-b211bd7fdaea seats"
    exit 1
  fi

  local table_name=${1:-"wcpfs-games-test"}
  local game_id=`string_value $2`
  local field_name=$3
  aws dynamodb update-item --table-name $table_name --key "{\"id\": $game_id}" --attribute-updates "{\"$field_name\": {\"Value\": {\"L\": []}, \"Action\": \"PUT\"}}" 
}

function delete_game(){
  if [ -z $2 ]; then
    echo "delete_game: Must supply game id"
    exit 1
  fi
  local table_name=${1:-"wcpfs-games-test"}
  local game_id=`string_value $2`
  aws dynamodb delete-item --table-name $table_name --key "{\"id\": $game_id}" 
}

function update_field(){
  if [ $# -lt 4 ]; then
    echo "update_field usage:"
    echo "./bin/db_ops update_field <table> <game_id> <field_name> <new_val>"
    echo "     Ex: ./bin/db_ops emptyArray wcpfs-games-test 56088e90-f894-4282-a244-b11ebd7fdaea seats \`./bin/db_ops.sh string_array \"alexdisney@gmail.com\" \"brady@gmail.com\"\`"
    exit 1
  fi

  local table_name=${1:-"wcpfs-games-test"}
  local game_id=`string_value $2`
  local field_name=$3
  local new_val=$4
  aws dynamodb update-item --table-name $table_name --key "{\"id\": $game_id}" --attribute-updates "{\"$field_name\": {\"Value\": $new_val, \"Action\": \"PUT\"}}" 
}

function delete_field(){
  if [ $# -lt 3 ]; then
    echo "delete_field usage:"
    echo "./bin/db_ops delete_field <table> <game_id> <field_name>"
    echo "     Ex: ./bin/db_ops emptyArray wcpfs-games-test 56088e90-f894-4282-a244-b211bd7fdaea email_ids"
    exit 1
  fi

  local table_name=${1:-"wcpfs-games-test"}
  local game_id=`string_value $2`
  local field_name=$3
  aws dynamodb update-item --table-name $table_name --key "{\"id\": $game_id}" --attribute-updates "{\"$field_name\": {\"Action\": \"DELETE\"}}" 
}

function string_value() {
  echo "{\"S\": \"$1\"}"
}

function join { 
  local IFS="$1"; shift; echo "$*"; 
}

function string_array() {
  strings=()
  for str in $*; do
    strings+=("`string_value $str`")
  done

  echo "{\"L\":[`join , ${strings[@]}`]}"
}

function usage() {
  echo "Usage:"
  echo "./bin/db_ops.sh <command> <table> <options>"
  echo "     Ex: ./bin/db_ops.sh query wcpfs-games-test"
}

if [ $1 == "-h" ]; then
  usage
  exit 1
fi

if [ $# -lt 1 ]; then
  echo "Missing command name"
  echo ""
  usage
  exit 1
fi

command=$1
table_name=${2:-"wcpfs-games-test"}
shift 2

eval $command $table_name $*

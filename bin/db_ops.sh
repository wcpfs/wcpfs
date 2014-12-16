#!/bin/bash

function scan(){
  local table_name=${1:-"wcpfs-games-test"}
  aws dynamodb scan --table-name $table_name
}

function query(){
  aws dynamodb query --table-name wcpfs-games --key-conditions "{\"gameId\": {\"AttributeValueList\": [{\"S\": \"460acdd5-3aea-4c2d-ac44-ff1b96b89e40\"}], \"ComparisonOperator\": \"EQ\"}}" --attributes-to-get "gameId" "title" "seats" "email_ids" "discussion"
}

function emptySeats(){
  aws dynamodb update-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"56088e90-f894-4282-a244-b2eebd7fdaea\"}}" --attribute-updates "{\"seats\": {\"Value\": {\"L\": []}, \"Action\": \"PUT\"}}" 
}

function deleteItem(){
  aws dynamodb delete-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"460acdd5-3aea-4c2d-ac44-ff1b96b89e40\"}}" 
}

function update_gm_email(){
  aws dynamodb update-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"460acdd5-3aea-4c2d-ac44-ff1b96b89e40\"}}" --attribute-updates "{\"gm_email\": {\"Value\": {\"S\": \"chapman.jeffrey@gmail.com\"}, \"Action\": \"PUT\"}}" 
}

function update_email_ids(){
  aws dynamodb update-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"460acdd5-3aea-4c2d-ac44-ff1b96b89e40\"}}" --attribute-updates "{\"email_ids\": {\"Value\": {\"L\": []}, \"Action\": \"PUT\"}}" 
}

function deleteSeat(){
  aws dynamodb update-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"56088e90-f894-4282-a244-b2eebd7fdaea\"}}" --attribute-updates "{\"email_ids\": {\"Action\": \"DELETE\"}}" 
}

eval $*

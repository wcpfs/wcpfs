#!/bin/bash

function scan(){
  aws dynamodb scan --table-name wcpfs-games-test
}

function query(){
  aws dynamodb query --table-name wcpfs-games-test --key-conditions "{\"gameId\": {\"AttributeValueList\": [{\"S\": \"56088e90-f894-4282-a244-b2eebd7fdaea\"}], \"ComparisonOperator\": \"EQ\"}}" --attributes-to-get "gameId" "title" "seats" "email_ids" "discussion"
}

function emptySeats(){
  aws dynamodb update-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"56088e90-f894-4282-a244-b2eebd7fdaea\"}}" --attribute-updates "{\"seats\": {\"Value\": {\"L\": []}, \"Action\": \"PUT\"}}" 
}

function update(){
  aws dynamodb update-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"56088e90-f894-4282-a244-b2eebd7fdaea\"}}" --attribute-updates "{\"email_ids\": {\"Value\": {\"L\": []}, \"Action\": \"PUT\"}}" 
}

function deleteSeat(){
  aws dynamodb update-item --table-name wcpfs-games-test --key "{\"gameId\": {\"S\": \"56088e90-f894-4282-a244-b2eebd7fdaea\"}}" --attribute-updates "{\"email_ids\": {\"Action\": \"DELETE\"}}" 
}

eval $*

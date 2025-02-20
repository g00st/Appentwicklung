#!/bin/bash

BASE_URL="http://192.168.2.24:3000"
return=0
check_response() {
    local response=$1
    local status_code=$2
    if [[ "$status_code" != "200" && "$status_code" != "201" ]]; then
        echo -e "\033[0;31mError: Response code $status_code\033[0m"
        echo -e "\033[0;31mResponse body:\033[0m"
        echo "$response"
    else
        echo -e "\033[0;32mSuccess: Response code $status_code\033[0m"
        echo -e "\033[0;32mResponse body:\033[0m"
        echo "$response" | jq
        return=-1
    fi
}




# ---------------------------------------- Job tests ----------------------------
# Example job data

END_POINT="jobs"
DATA='{
  "seed_type": "Rumex_Azetos_fuck",
  "plate_type": "150_QuickPot",
  "target_count": 5,
  "creation_date": "2024-01-30T10:00:00Z",
  "completion_count": 0,
  "finish_time": null
}'


# Test POST /jobs
echo "Testing POST /jobs"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT" -H "Content-Type: application/json" -d "$DATA")
id=$(jq -r '._id' /tmp/response.json)
check_response "$(cat /tmp/response.json)" "$response"
echo "Created Job ID: $id"

# Test GET /jobs
echo "\nTesting GET /$END_POINT"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json "$BASE_URL/$END_POINT")
check_response "$(cat /tmp/response.json)" "$response"

# Test GET /jobs/{id}
if [ "$id" != "null" ]; then
    echo "\nTesting GET /$END_POINT/$id"
    response=$(curl -s -w "%{http_code}" -o /tmp/response.json "$BASE_URL/$END_POINT/$id")
    check_response "$(cat /tmp/response.json)" "$response"
fi

# Test PUT /jobs/{id}
if [ "$id" != "null" ]; then
    echo "\nTesting PUT /$END_POINT/$id"
    update_data='{"completion_count": 50}'
    response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X PUT "$BASE_URL/$END_POINT/$id" -H "Content-Type: application/json" -d "$update_data")
    check_response "$(cat /tmp/response.json)" "$response"
fi

# # Test DELETE /jobs/{id}
# if [ "$id" != "null" ]; then
#     echo "\nTesting DELETE /$END_POINT/$id"
#     response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X DELETE "$BASE_URL/$END_POINT/$id")
#     check_response "$(cat /tmp/response.json)" "$response"
# fi


# ---------------------------------------- Plate tests ----------------------------
# Example job data
plate_data='{
  "name": "test123",
  "g_code": "HIII"
}'

END_POINT="plates"

# Test POST /Plate
echo "Testing POST /$END_POINT"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT" -H "Content-Type: application/json" -d "$plate_data")
id=$(jq -r '._id' /tmp/response.json)
check_response "$(cat /tmp/response.json)" "$response"
echo "Created Plate ID: $id"

# Test GET /Plate
echo "\nTesting GET /$END_POINT"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json "$BASE_URL/$END_POINT")
check_response "$(cat /tmp/response.json)" "$response"

# Test GET /Plate/{id}
if [ "$id" != "null" ]; then
    echo "\nTesting GET /$END_POINT/$id"
    response=$(curl -s -w "%{http_code}" -o /tmp/response.json "$BASE_URL/$END_POINT/$id")
    check_response "$(cat /tmp/response.json)" "$response"
fi

# Test PUT /Plate/{id}
if [ "$id" != "null" ]; then
    echo "\nTesting PUT /$END_POINT/$id"
    update_data='{"completion_count": 50}'
    response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X PUT "$BASE_URL/$END_POINT/$id" -H "Content-Type: application/json" -d "$update_data")
    check_response "$(cat /tmp/response.json)" "$response"
fi

# Test DELETE /Plate/{id}
if [ "$id" != "null" ]; then
    echo "\nTesting DELETE /$END_POINT/$id"
    response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X DELETE "$BASE_URL/$END_POINT/$id")
    check_response "$(cat /tmp/response.json)" "$response"
fi





# ---------------------------------------- Job RUN  test ----------------------------
# Example job data
plate_data='{
  "name": "150QuickPod",
  "g_code": "G1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X63 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X95 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X127 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X159 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X193 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X226 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X259 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X292 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X326 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X359 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X392 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X425 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X458 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X491 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 Z0 F20000\nG1 X0 F20000\nG1 Z25 F20000\nG4 P500\nTURN_PUMP_ON\nG4 P500\nG1 Z0 F20000\n\nG1 X520 F20000\nG1 Z20 F20000\nG4 P500\nTURN_PUMP_OFF\nG4 P500\nG1 Z0 F20000\n\nG1 X0 F20000\n"
}'


END_POINT="plates"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT" -H "Content-Type: application/json" -d "$plate_data")
id=$(jq -r '._id' /tmp/response.json)
check_response "$(cat /tmp/response.json)" "$response"
echo "Created Plate ID: $id"


DATA=$(cat <<EOF
{
  "seed_type": "corn",
  "plate_type": "$id",
  "target_count": 5,
  "creation_date": "2024-01-30T10:00:00Z",
  "completion_count": 0,
  "finish_time": null
}
EOF
)


END_POINT="jobs"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT" -H "Content-Type: application/json" -d "$DATA")
id=$(jq -r '._id' /tmp/response.json)
check_response "$(cat /tmp/response.json)" "$response"
echo "Created Job ID: $id"
sleep 9
END_POINT="run"
echo "Testing POST /$END_POINT/$id"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT/$id")
check_response "$(cat /tmp/response.json)" "$response"
sleep 9
END_POINT="run"
echo "Testing POST /$END_POINT/$id"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT/$id")
check_response "$(cat /tmp/response.json)" "$response"
sleep 9
END_POINT="run"
echo "Testing POST /$END_POINT/$id"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT/$id")
check_response "$(cat /tmp/response.json)" "$response"
sleep 9
END_POINT="run"
echo "Testing POST /$END_POINT/$id"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT/$id")
check_response "$(cat /tmp/response.json)" "$response"
sleep 9
END_POINT="run"
echo "Testing POST /$END_POINT/$id"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT/$id")
check_response "$(cat /tmp/response.json)" "$response"
sleep 9
END_POINT="run"
echo "Testing POST /$END_POINT/$id"
response=$(curl -s -w "%{http_code}" -o /tmp/response.json -X POST "$BASE_URL/$END_POINT/$id")
check_response "$(cat /tmp/response.json)" "$response"


exit $return

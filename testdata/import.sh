#!/usr/bin/env bash

#      ██╗ ██████╗ ██╗███╗   ██╗    ██████╗  █████╗ ████████╗ █████╗ ████████╗██╗   ██╗██████╗ ███████╗
#      ██║██╔═══██╗██║████╗  ██║    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝
#      ██║██║   ██║██║██╔██╗ ██║    ██║  ██║███████║   ██║   ███████║   ██║    ╚████╔╝ ██████╔╝█████╗
# ██   ██║██║   ██║██║██║╚██╗██║    ██║  ██║██╔══██║   ██║   ██╔══██║   ██║     ╚██╔╝  ██╔═══╝ ██╔══╝
# ╚█████╔╝╚██████╔╝██║██║ ╚████║    ██████╔╝██║  ██║   ██║   ██║  ██║   ██║      ██║   ██║     ███████╗
#  ╚════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝     ╚══════╝
# This script imports example data into elasticsearch
# The docs are available here:
# https://www.elastic.co/guide/en/elasticsearch/reference/current/parent-join.html#parent-join

# The join datatype is a special field that creates parent/child relation within
# documents of the same index. The relations section defines a set of possible relations
# within the documents, each relation being a parent name and a child name.
# A parent/child relation can be defined as follows:


# curl -X POST "localhost:9200/visits/_delete_by_query?pretty" -H 'Content-Type: application/json' -d'
# {
#     "query": {
#         "match_all": {}
#     }
# }
# '
# curl -X DELETE "localhost:9200/visits?pretty" -H 'Content-Type: application/json'
# curl -X PUT "localhost:9200/visits?pretty" -H 'Content-Type: application/json' -d'
# {
#     "mappings": {
#         "properties": {
#             "do_visit": {
#                 "type": "join",
#                 "relations": {
#                     "device": "visit"
#                 }
#             },
#             "@timestamp": {
#                 "type": "date",
#                 "format": "epoch_millis"
#             }
#         }
#     }
# }
# '

# Create a device

# https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-refresh.html
# https://www.elastic.co/guide/en/elasticsearch/reference/current/common-options.html

millepoch=$(( $(date '+%s%N') / 1000000))
device_id=$(echo -n "$millepoch" | md5sum | awk '{print $1}')
description=$(curl -s https://baconipsum.com/api/?type=meat-and-filler | jq '.[1]')

curl -X PUT "localhost:9200/visits/_doc/$device_id?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "device_id": "'"$device_id"'",
    "description": '"$description"',
    "@timestamp": '"$millepoch"',
    "do_visit": {
        "name": "device"
    }
}
'

for i in $(seq 1 $(( ( RANDOM % 20 )  + 1 ))); do

echo "Generating $i visit..."
sleep "$(seq 0 .01 3 | shuf | head -n1)"

millepoch=$(( $(date '+%s%N') / 1000000))
visit_id=$(echo -n "$millepoch" | md5sum | awk '{print $1}')


curl -X PUT "localhost:9200/visits/_doc/$visit_id?routing=1&refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "visit_id": "'"$visit_id"'",
    "@timestamp": '"$millepoch"',
    "url": "/page_num/'"$i"'",
    "do_visit": {
        "name": "visit",
        "parent": "'"$device_id"'"
    }
}
'

done

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


curl -X POST "localhost:9200/visite/_delete_by_query?pretty" -H 'Content-Type: application/json' -d'
{
    "query": {
        "match_all": {}
    }
}
'

curl -X DELETE "localhost:9200/visite?pretty" -H 'Content-Type: application/json'

curl -X PUT "localhost:9200/visite?pretty" -H 'Content-Type: application/json' -d'
{
    "mappings": {
        "properties": {
            "effettua": {
                "type": "join",
                "relations": {
                    "dispositivo": "visita"
                }
            },
            "@timestamp": {
                "type": "date",
                "format": "epoch_millis"
            }
        }
    }
}
'

# To index a document with a join,
# the name of the relation and the optional parent of the document must be provided in the source.
# For instance the following example creates two parent documents in the question context:

# https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-refresh.html
# https://www.elastic.co/guide/en/elasticsearch/reference/current/common-options.html

curl -X PUT "localhost:9200/visite/_doc/dispositivo1?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "id_dispositivo": "dispositivo1",
    "descrizione": "dispositivo bellissimo rosso e potente",
    "@timestamp": 1579720909839,
    "effettua": {
        "name": "dispositivo"
    }
}
'
curl -X PUT "localhost:9200/visite/_doc/dispositivo2?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "id_dispositivo": "dispositivo2",
    "descrizione": "carrozzone schifoso verde metallizzato",
    "@timestamp": 1579720909839,
    "effettua": {
        "name": "dispositivo"
    }
}
'
curl -X PUT "localhost:9200/visite/_doc/dispositivo3?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "id_dispositivo": "dispositivo3",
    "descrizione": "dispositivo rosa schic!",
    "@timestamp": 1579720909839,
    "effettua": {
        "name": "dispositivo"
    }
}
'

# The following examples shows how to index two child documents:

curl -X PUT "localhost:9200/visite/_doc/visita1?routing=1&refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "id_visita": "visita1",
    "@timestamp": 1579720909839,
    "effettua": {
        "name": "visita",
        "parent": "dispositivo1"
    }
}
'
curl -X PUT "localhost:9200/visite/_doc/visita2?routing=1&refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "id_visita": "visita2",
    "@timestamp": 1579720909839,
    "effettua": {
        "name": "visita",
        "parent": "dispositivo1"
    }
}
'
curl -X PUT "localhost:9200/visite/_doc/visita3?routing=1&refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "id_visita": "visita3",
    "@timestamp": 1579720909839,
    "effettua": {
        "name": "visita",
        "parent": "dispositivo2"
    }
}
'

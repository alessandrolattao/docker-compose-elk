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

curl -X PUT "localhost:9200/my_index?pretty" -H 'Content-Type: application/json' -d'
{
    "mappings": {
        "properties": {
            "my_join_field": {
                "type": "join",
                "relations": {
                    "question": "answer"
                }
            }
        }
    }
}
'

# To index a document with a join,
# the name of the relation and the optional parent of the document must be provided in the source.
# For instance the following example creates two parent documents in the question context:

curl -X PUT "localhost:9200/my_index/_doc/1?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "text": "This is a question",
    "my_join_field": {
        "name": "question"
    }
}
'
curl -X PUT "localhost:9200/my_index/_doc/2?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "text": "This is another question",
    "my_join_field": {
        "name": "question"
    }
}
'

# When indexing parent documents,
# you can choose to specify just the name of the relation as a shortcut
# instead of encapsulating it in the normal object notation:

curl -X PUT "localhost:9200/my_index/_doc/1?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "text": "This is a question",
    "my_join_field": "question"
}
'
curl -X PUT "localhost:9200/my_index/_doc/2?refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "text": "This is another question",
    "my_join_field": "question"
}
'

# The following examples shows how to index two child documents:

curl -X PUT "localhost:9200/my_index/_doc/3?routing=1&refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "text": "This is an answer",
    "my_join_field": {
        "name": "answer",
        "parent": "1"
    }
}
'
curl -X PUT "localhost:9200/my_index/_doc/4?routing=1&refresh&pretty" -H 'Content-Type: application/json' -d'
{
    "text": "This is another answer",
    "my_join_field": {
        "name": "answer",
        "parent": "1"
    }
}
'

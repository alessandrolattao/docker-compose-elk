# docker-compose-elk

Local ELK stack to use with docker-compose.

I created this project to explore the parent-child paradigm as shown in the documentation: <https://www.elastic.co/guide/en/elasticsearch/reference/current/parent-join.html>

## Docker Compose reference

<https://docs.docker.com/compose/compose-file/>

## Elasticsearch configuration

<https://www.elastic.co/guide/en/elasticsearch/reference/7.5/docker.html>

## Logstash configuration

<https://www.elastic.co/guide/en/logstash/7.5/docker-config.html>

## Kibana configuration

<https://www.elastic.co/guide/en/kibana/7.5/docker.html>

## Effettuare query

### Get all entries

```json
GET /visits/_search
{
  "query": {
        "match_all": {}
    }
}
```

### Get all visits

```json
GET /visits/_search
{
    "query": {
        "has_parent" : {
            "parent_type" : "device",
            "query" : {
              "match_all": {}
            }
        }
    }
}
```

### Get devices that has visits

```json
GET /visits/_search
{
    "query": {
        "has_child": {
            "type" : "visits",
            "query" : {
              "match_all": {}
            }
        }
    }
}
```

### Get all devices that has visits and visita

```json
GET /visits/_search
{
  "query": {
      "has_child": {
        "type": "visit",
        "min_children": 1, "max_children": 10,
        "query": { "match_all": {} },
        "inner_hits": {}
      }
  }
}
```

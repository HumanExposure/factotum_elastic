# Factotum Elasticsearch

## Indexes

### `dashboard`

Install the mappings for the `dashboard` index with a `PUT` command in the Kibana console:
```
PUT dashboard/
{
  "mappings": {
    "doc": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        ... the rest of mappings/dashboard.json
```

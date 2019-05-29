# Factotum Elasticsearch

## Indexes

### `factotum_chemicals`

Added on ticket https://github.com/HumanExposure/factotum/issues/799
Fields specified in https://github.com/HumanExposure/factotum/issues/797

> User enters chemical name, CAS, or SID in search box. Search should search on the raw_cas and raw_chem_name fields (in dashboard_rawchem), and on the true_cas, true_chemname, and sid fields (in dashboard_dsstoxlookup)

Install the mappings for the `factotum_chemicals` with a `PUT` command in the Kibana console:
```
PUT factotum_chemicals/
{
  "mappings": {
    "doc": {
      "properties": {
        "data_document_id": {
          "type": "integer"
        },
        ... the rest of factotum_chemicals.json
```

To load the documents without using `pipelines.yml`, run `logstash -f ./pipelines/factotum_chemicals_pipeline.conf`.

Test queries:
```
GET /factotum_chemicals/_search/
{
    "query": {
      "query_string" : {
            "query" : "Cobalt oxide" 
        }
    }
}
# With PROD data
GET /factotum_chemicals/_search/
{
    "query": {
      "query_string" : {
            "query" : "Glyphosate" 
        }
    }
}

GET /factotum_chemicals/_search/
{
    "query": {
        "query_string" : {
            "default_field" : "raw_chem_name",
            "query" : "alcohol"
        }
    }
}

GET /factotum_chemicals/_search/
{
    "query": {
        "query_string" : {
            "default_field" : "raw_cas",
            "query" : "64-17-5"
        }
    }
}

GET /factotum_chemicals/_search/
{
    "query": {
        "query_string" : {
            "default_field" : "true_cas",
            "query" : "64-17-5"
        }
    }
}

GET /factotum_chemicals/_search/
{
    "query": {
        "query_string" : {
            "default_field" : "true_chemname",
            "query" : "Ethanol"
        }
    }
}
```

```


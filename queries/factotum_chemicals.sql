SELECT
    'Chemical' as facet_model_name,
    extracted_text_id AS data_document_id,
    (SELECT COUNT(*)
    FROM dashboard_productdocument
    WHERE document_id = extracted_text_id) AS product_count,
    raw_cas,
    raw_chem_name,
    dss.sid,
    dss.true_cas,
    dss.true_chemname
FROM dashboard_rawchem rc
    LEFT JOIN dashboard_dsstoxlookup dss ON rc.dsstox_id = dss.id
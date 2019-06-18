SELECT
    'Chemical' as facet_model_name,
    rc.id as rawchem_id,
    rc.raw_cas,
    rc.raw_chem_name,
    dss.sid as dtxsid,
    dss.true_cas,
    dss.true_chemname,
    dd.id as data_document_id,
    dd.title as data_document_title,
    (SELECT
        CONCAT(
            '/media/',
            dg.fs_id,
            '/pdf/document_',
            dd.id,
            '.',
            (SELECT
                SUBSTRING_INDEX(
                    dd.filename, 
                    '.',
                    -1
                )
            )
        )
    ) as data_document_pdf,
    p.id as product_id,
    p.title as product_title,
    puc.id as puc_id,
    puc.gen_cat as puc_gen_cat,
    puc.prod_fam as puc_prod_fam,
    puc.prod_type as puc_prod_type,
    puc.description as puc_description,
    puc.kind as puc_kind,
    (SELECT
        UNIX_TIMESTAMP(
            GREATEST(
                COALESCE(dss.updated_at, 0),
                COALESCE(et.updated_at, 0),
                COALESCE(dd.updated_at, 0),
                COALESCE(pd.updated_at, 0),
                COALESCE(p.updated_at, 0),
                COALESCE(pp.updated_at, 0),
                COALESCE(puc.updated_at, 0)
            )
        )
    ) AS updated_at
FROM
    dashboard_rawchem rc
    INNER JOIN dashboard_extractedtext et ON rc.extracted_text_id = et.data_document_id
    INNER JOIN dashboard_datadocument dd ON et.data_document_id = dd.id
    INNER JOIN dashboard_datagroup dg ON dd.data_group_id = dg.id
    LEFT JOIN dashboard_dsstoxlookup dss ON rc.dsstox_id = dss.id
    LEFT JOIN dashboard_productdocument pd ON dd.id = pd.document_id
    LEFT JOIN dashboard_product p ON pd.product_id = p.id
    LEFT JOIN dashboard_producttopuc pp ON p.id = pp.product_id
    LEFT JOIN dashboard_puc puc ON pp.puc_id = puc.id
WHERE
    dss.updated_at > :sql_last_value OR
    et.updated_at > :sql_last_value OR
    dd.updated_at > :sql_last_value OR
    pd.updated_at > :sql_last_value OR
    p.updated_at > :sql_last_value OR
    pp.updated_at > :sql_last_value OR
    puc.updated_at > :sql_last_value
ORDER BY
    updated_at;

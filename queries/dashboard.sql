SELECT
    rc.id as rawchem_id,
    rc.raw_cas as rawchem_cas,
    rc.raw_chem_name as rawchem_name,
    dss.sid as truechem_dtxsid,
    dss.true_cas as truechem_cas,
    dss.true_chemname as truechem_name,
    dd.id as datadocument_id,
    gt.code as datadocument_grouptype,
    dd.title as datadocument_title,
    dd.subtitle as datadocument_subtitle,
    p.id as product_id,
    p.upc as product_upc,
    p.manufacturer as product_manufacturer,
    p.brand_name as product_brandname,
    p.title as product_title,
    (SELECT
        CONCAT(
            p.short_description,
            '\n\n',
            p.long_description
        )
    ) as product_description,
    puc.id as puc_id,
    puc.kind as puc_kind,
    puc.gen_cat as puc_gencat,
    puc.prod_fam as puc_prodfam,
    puc.prod_type as puc_prodtype,
    puc.description as puc_description,
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
    INNER JOIN dashboard_grouptype gt ON dg.group_type_id = gt.id
    LEFT JOIN dashboard_dsstoxlookup dss ON rc.dsstox_id = dss.id
    LEFT JOIN dashboard_productdocument pd ON dd.id = pd.document_id
    LEFT JOIN dashboard_product p ON pd.product_id = p.id
    LEFT JOIN dashboard_producttopuc pp ON p.id = pp.product_id
    LEFT JOIN dashboard_puc puc ON pp.puc_id = puc.id
WHERE
    dss.updated_at > :sql_last_value OR
    et.updated_at > :sql_last_value OR
    dd.updated_at > :sql_last_value OR
    dg.updated_at > :sql_last_value OR
    pd.updated_at > :sql_last_value OR
    p.updated_at > :sql_last_value OR
    pp.updated_at > :sql_last_value OR
    puc.updated_at > :sql_last_value
ORDER BY
    updated_at;

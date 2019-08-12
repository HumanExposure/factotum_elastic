SELECT
    id.rawchem_id as rawchem_id,
    NULLIF(rc.raw_cas, "") as rawchem_cas,
    NULLIF(rc.raw_chem_name, "") as rawchem_name,
    NULLIF(dss.sid, "") as truechem_dtxsid,
    NULLIF(dss.true_cas, "") as truechem_cas,
    NULLIF(dss.true_chemname, "") as truechem_name,
    id.datadocument_id as datadocument_id,
    (
        CASE
            WHEN gt.code IS NULL THEN NULL
            WHEN gt.code = "" THEN NULL
            ELSE CONCAT(gt.title, " (", gt.code, ")")
        END
    ) as datadocument_grouptype,
    NULLIF(dd.title, "") as datadocument_title,
    NULLIF(dd.subtitle, "") as datadocument_subtitle,
    id.product_id as product_id,
    NULLIF(p.upc, "") as product_upc,
    NULLIF(p.manufacturer, "") as product_manufacturer,
    NULLIF(p.brand_name, "") as product_brandname,
    NULLIF(p.title, "") as product_title,
    NULLIF(p.short_description, "") as product_shortdescription,
    NULLIF(p.long_description, "") as product_longdescription,
    id.puc_id as puc_id,
    NULLIF(puc.kind, "") as puc_kind,
    NULLIF(puc.gen_cat, "") as puc_gencat,
    NULLIF(puc.prod_fam, "") as puc_prodfam,
    NULLIF(puc.prod_type, "") as puc_prodtype,
    NULLIF(puc.description, "") as puc_description,
    (SELECT
        UNIX_TIMESTAMP(
            GREATEST(
                COALESCE(elp.updated_at, 0),
                COALESCE(ehh.updated_at, 0),
                COALESCE(efu.updated_at, 0),
                COALESCE(ec.updated_at, 0),
                COALESCE(dss.updated_at, 0),
                COALESCE(et.updated_at, 0),
                COALESCE(dd.updated_at, 0),
                COALESCE(dg.updated_at, 0),
                COALESCE(dg.updated_at, 0),
                COALESCE(gt.updated_at, 0),
                COALESCE(pd.updated_at, 0),
                COALESCE(p.updated_at, 0),
                COALESCE(pp.updated_at, 0),
                COALESCE(puc.updated_at, 0)
            )
        )
    ) AS updated_at
FROM
    `logstash.id|id` id
    LEFT JOIN dashboard_rawchem rc ON id.rawchem_id = rc.id
    LEFT JOIN dashboard_datadocument dd ON id.datadocument_id = dd.id
    LEFT JOIN dashboard_product p ON id.product_id = p.id
    LEFT JOIN dashboard_puc puc ON id.puc_id = puc.id
    LEFT JOIN dashboard_extractedlistpresence elp ON id.rawchem_id = elp.rawchem_ptr_id
    LEFT JOIN dashboard_extractedhhrec ehh ON id.rawchem_id = ehh.rawchem_ptr_id
    LEFT JOIN dashboard_extractedfunctionaluse efu ON id.rawchem_id = efu.rawchem_ptr_id
    LEFT JOIN dashboard_extractedchemical ec ON id.rawchem_id = ec.rawchem_ptr_id
    LEFT JOIN dashboard_extractedtext et ON id.datadocument_id = et.data_document_id
    LEFT JOIN dashboard_productdocument pd ON id.datadocument_id = pd.document_id
    LEFT JOIN dashboard_producttopuc pp ON id.product_id = pp.product_id
    LEFT JOIN dashboard_dsstoxlookup dss ON rc.dsstox_id = dss.id
    LEFT JOIN dashboard_datagroup dg ON dd.data_group_id = dg.id
    LEFT JOIN dashboard_grouptype gt ON dg.group_type_id = gt.id
WHERE
    elp.updated_at > :sql_last_value OR
    ehh.updated_at > :sql_last_value OR
    efu.updated_at > :sql_last_value OR
    ec.updated_at > :sql_last_value OR
    dss.updated_at > :sql_last_value OR
    et.updated_at > :sql_last_value OR
    dd.updated_at > :sql_last_value OR
    dg.updated_at > :sql_last_value OR
    dg.updated_at > :sql_last_value OR
    gt.updated_at > :sql_last_value OR
    pd.updated_at > :sql_last_value OR
    p.updated_at > :sql_last_value OR
    pp.updated_at > :sql_last_value OR
    puc.updated_at > :sql_last_value
ORDER BY
    updated_at;

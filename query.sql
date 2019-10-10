SELECT
    id.rawchem_id as rawchem_id,
    NULLIF(rc.raw_cas, "") as rawchem_cas,
    NULLIF(rc.raw_chem_name, "") as rawchem_name,
    NULLIF(dss.sid, "") as truechem_dtxsid,
    NULLIF(dss.true_cas, "") as truechem_cas,
    NULLIF(dss.true_chemname, "") as truechem_name,
    id.datadocument_id as datadocument_id,
    NULLIF(gt.title, "") as datadocument_grouptype,
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
    NULLIF(puc.gen_cat, "") as puc_gencatfacet,
    NULLIF(puc.prod_fam, "") as puc_prodfam,
    NULLIF(puc.prod_type, "") as puc_prodtype,
    NULLIF(puc.description, "") as puc_description
FROM
    `logstash.id|id` id
    LEFT JOIN dashboard_rawchem rc ON id.rawchem_id = rc.id
    LEFT JOIN dashboard_datadocument dd ON id.datadocument_id = dd.id
    LEFT JOIN dashboard_product p ON id.product_id = p.id
    LEFT JOIN dashboard_puc puc ON id.puc_id = puc.id
    LEFT JOIN dashboard_dsstoxlookup dss ON rc.dsstox_id = dss.id
    LEFT JOIN dashboard_datagroup dg ON dd.data_group_id = dg.id
    LEFT JOIN dashboard_grouptype gt ON dg.group_type_id = gt.id

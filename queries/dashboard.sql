-- create the rawchem to datadocument relationships
CREATE OR REPLACE VIEW `rawchem==datadocument` AS
    SELECT
        rc.id AS rawchem_id,
        dd.id AS datadocument_id
    FROM
        dashboard_rawchem rc
        LEFT JOIN dashboard_extractedtext et ON rc.extracted_text_id = et.data_document_id
        LEFT JOIN dashboard_datadocument dd ON et.data_document_id = dd.id;
CREATE OR REPLACE VIEW `rawchem!=datadocument` AS
    SELECT
        NULL AS rawchem_id,
        dd.id AS datadocument_id
    FROM
        dashboard_datadocument dd
    WHERE
        dd.id NOT IN (SELECT data_document_id FROM dashboard_extractedtext WHERE data_document_id IS NOT NULL);
CREATE OR REPLACE VIEW `rawchem|datadocument` AS
    SELECT * FROM `rawchem==datadocument`
    UNION ALL
    SELECT * FROM `rawchem!=datadocument`;

-- create the datadocument to product relationships
CREATE OR REPLACE VIEW `datadocument==product` AS
    SELECT
        rc_dd.datadocument_id AS datadocument_id,
        p.id AS product_id
    FROM
        (SELECT datadocument_id FROM `rawchem==datadocument` WHERE datadocument_id IS NOT NULL GROUP BY datadocument_id) rc_dd
        LEFT JOIN dashboard_productdocument pd ON rc_dd.datadocument_id = pd.document_id
        LEFT JOIN dashboard_product p ON pd.product_id = p.id;
CREATE OR REPLACE VIEW `datadocument!=product` AS
    SELECT
        NULL AS datadocument_id,
        p.id AS product_id
    FROM
        dashboard_product p
    WHERE
        p.id NOT IN (SELECT product_id FROM dashboard_productdocument WHERE product_id IS NOT NULL);
CREATE OR REPLACE VIEW `datadocument|product` AS
    SELECT * FROM `datadocument==product`
    UNION ALL
    SELECT * FROM `datadocument!=product`;
-- create the product to puc relationships
CREATE OR REPLACE VIEW `product==puc` AS
    SELECT
        dd_p.product_id AS product_id,
        puc.id AS puc_id
    FROM
        (SELECT product_id FROM `datadocument==product` WHERE product_id IS NOT NULL GROUP BY product_id) dd_p
        LEFT JOIN dashboard_producttopuc pp ON dd_p.product_id = pp.product_id
        LEFT JOIN dashboard_puc puc ON pp.product_id = puc.id;
CREATE OR REPLACE VIEW `product!=puc` AS
    SELECT
        NULL AS product_id,
        puc.id AS puc_id
    FROM
        dashboard_puc puc
    WHERE
        puc.id NOT IN (SELECT puc_id FROM `product==puc` WHERE puc_id IS NOT NULL);
CREATE OR REPLACE VIEW `product|puc` AS
    SELECT * FROM `product==puc`
    UNION ALL
    SELECT * FROM `product!=puc`;
-- "full outer join" all id's
CREATE OR REPLACE VIEW `id|id` AS
    SELECT
        rawchem_id,
        datadocument_id,
        product_id,
        puc_id 
    FROM
        `rawchem|datadocument`
        NATURAL LEFT JOIN `datadocument|product`
        NATURAL LEFT JOIN `product|puc`
    UNION
    SELECT
        rawchem_id,
        datadocument_id,
        product_id,
        puc_id 
    FROM
        `rawchem|datadocument`
        NATURAL RIGHT JOIN `datadocument|product`
        NATURAL LEFT JOIN `product|puc`
    UNION
    SELECT
        rawchem_id,
        datadocument_id,
        product_id,
        puc_id 
    FROM
        `rawchem|datadocument`
        NATURAL RIGHT JOIN `datadocument|product`
        NATURAL RIGHT JOIN `product|puc`;
--Actual Logstash query
CREATE OR REPLACE VIEW `logstash_dashboard` AS
    SELECT
        id.rawchem_id,
        rc.raw_cas as rawchem_cas,
        rc.raw_chem_name as rawchem_name,
        dss.sid as truechem_dtxsid,
        dss.true_cas as truechem_cas,
        dss.true_chemname as truechem_name,
        id.datadocument_id,
        gt.code as datadocument_grouptype,
        dd.title as datadocument_title,
        dd.subtitle as datadocument_subtitle,
        id.product_id,
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
        id.puc_id,
        puc.kind as puc_kind,
        puc.gen_cat as puc_gencat,
        puc.prod_fam as puc_prodfam,
        puc.prod_type as puc_prodtype,
        puc.description as puc_description,
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
        `id|id` id
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
        elp.updated_at > 0 OR
        ehh.updated_at > 0 OR
        efu.updated_at > 0 OR
        ec.updated_at > 0 OR
        dss.updated_at > 0 OR
        et.updated_at > 0 OR
        dd.updated_at > 0 OR
        dg.updated_at > 0 OR
        dg.updated_at > 0 OR
        gt.updated_at > 0 OR
        pd.updated_at > 0 OR
        p.updated_at > 0 OR
        pp.updated_at > 0 OR
        puc.updated_at > 0
    ORDER BY
        updated_at;

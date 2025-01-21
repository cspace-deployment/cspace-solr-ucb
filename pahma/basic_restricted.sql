SELECT DISTINCT ON (cc.objectnumber)
    cc.id,
    hcc.name                                                            AS csid_s,
    cp.sortableobjectnumber                                             AS objsortnum_s,
    cc.objectnumber                                                     AS objmusno_s,
    getdispl(cp.pahmatmslegacydepartment)                               AS objdept_s,
    getdispl(cc.collection)                                             AS objtype_s,
    ocg.objectcount                                                     AS objcount_s,
    ocg.objectcountnote                                                 AS objcountnote_s,
    cp.portfolioseries                                                  AS objkeelingser_s,
    regexp_replace(cp.pahmafieldlocverbatim, E'[\\t\\n\\r]+', ' ', 'g') AS objfcpverbatim_s
FROM collectionobjects_common cc
    JOIN misc ON (
        cc.id = misc.id 
        AND misc.lifecyclestate <> 'deleted')
    JOIN hierarchy hcc ON (hcc.id = cc.id)
    LEFT OUTER JOIN collectionobjects_pahma cp ON (cp.id = cc.id)
    LEFT OUTER JOIN hierarchy hocg ON (cc.id = hocg.parentid AND hocg.primarytype = 'objectCountGroup')
    LEFT OUTER JOIN objectcountgroup ocg ON (hocg.id = ocg.id)
    LEFT OUTER JOIN collectionobjects_pahma_pahmaobjectstatuslist osl ON (cc.id = osl.id)
WHERE getdispl(ocg.objectcounttype) = 'piece count'
AND getdispl(osl.item) IN (
    'accessioned',
    'deaccessioned',
    'number not used',
    'recataloged',
    'not received',
    'on deposit')
ORDER BY 
    cc.objectnumber,
    ocg.objectcountdate
    DESC NULLS LAST;

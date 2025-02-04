SELECT DISTINCT ON (cc.objectnumber)
    cc.id,
    hcc.name                                                            AS csid_s,
    cp.sortableobjectnumber                                             AS objsortnum_s,
    cc.objectnumber                                                     AS objmusno_s,
    GETDISPL(cp.pahmatmslegacydepartment)                               AS objdept_s,
    GETDISPL(cc.collection)                                             AS objtype_s,
    ocg.objectcount                                                     AS objcount_s,
    ocg.objectcountnote                                                 AS objcountnote_s,
    cp.portfolioseries                                                  AS objkeelingser_s,
    regexp_replace(cp.pahmafieldlocverbatim, E'[\\t\\n\\r]+', ' ', 'g') AS objfcpverbatim_s
FROM collectionobjects_common cc
    JOIN misc m ON (
        cc.id = m.id
        AND m.lifecyclestate <> 'deleted')
    JOIN hierarchy hcc ON (hcc.id = cc.id)
    LEFT OUTER JOIN collectionobjects_pahma cp ON (cp.id = cc.id)
    LEFT OUTER JOIN hierarchy hocg ON (
        cc.id = hocg.parentid
        AND hocg.primarytype = 'objectCountGroup')
    LEFT OUTER JOIN objectcountgroup ocg ON (
        hocg.id = ocg.id
        AND GETDISPL(ocg.objectcounttype) = 'piece count')
ORDER BY 
    cc.objectnumber,
    ocg.objectcountdate
    DESC NULLS LAST;

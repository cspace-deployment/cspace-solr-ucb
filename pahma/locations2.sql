SELECT DISTINCT on (cc.objectnumber)
    hcc.name                                AS object_csid_s,
    -- cc.id                                AS id,
    -- GETDISPL(cc.computedcurrentlocation) AS storagelocation_s,
    -- GETDISPL(ca.computedcrate)           AS computedcrate_s,
    cc.objectnumber                         AS objectnumber_s,
    cp.sortableobjectnumber                 AS sortableobjectnumber_s,
    ocg.objectcount                         AS objectcount_s,
    ong.objectName                          AS objectname_s, 
    ocg.objectcountnote                     AS count_s
FROM collectionobjects_common cc
    JOIN misc m ON (
        cc.id = m.id
        AND m.lifecyclestate <> 'deleted')
    JOIN hierarchy hcc ON (cc.id = hcc.id)
    LEFT OUTER JOIN hierarchy hong ON (
        cc.id = hong.parentid 
        AND hong.pos = 0 
        AND hong.primarytype = 'objectNameGroup')
    LEFT OUTER JOIN objectnamegroup ong ON (hong.id = ong.id)
    LEFT OUTER JOIN collectionobjects_pahma cp ON (cc.id = cp.id)
    LEFT OUTER JOIN collectionobjects_anthropology ca ON (cc.id = ca.id)
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

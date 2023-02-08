SELECT cc.id,
       CASE
           WHEN STRING_AGG(DISTINCT REGEXP_REPLACE(osl.item, '^.*\)''(.*)''$', '\1'), '␥') ~ '(^deaccessioned|transferred|repatriated|sold|exchanged|discarded|red-lined|destroyed)'
           THEN
               'Deaccessioned'
           ELSE
               ''
           END                                                                    AS deaccessioned_s,
       STRING_AGG(DISTINCT REGEXP_REPLACE(osl.item, '^.*\)''(.*)''$', '\1'), '␥') AS "status_ss"
FROM collectionobjects_common cc
         LEFT OUTER JOIN collectionobjects_pahma_pahmaobjectstatuslist osl ON (cc.id = osl.id)
         JOIN misc m ON (m.id = cc.id AND m.lifecyclestate <> 'deleted')
GROUP BY cc.id;

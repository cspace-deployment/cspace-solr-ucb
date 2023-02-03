SELECT cc.id,
       'nagpra' as nagpra_relevant_s
FROM collectionobjects_common cc
         LEFT OUTER JOIN collectionobjects_pahma_pahmaobjectstatuslist osl ON (cc.id = osl.id)
         JOIN misc m ON (m.id = cc.id AND m.lifecyclestate <> 'deleted')
         JOIN collectionobjects_pahma cp ON (cc.id = cp.id)

WHERE REGEXP_REPLACE(osl.item, '^.*\)''(.*)''$', '\1') NOT IN (
    'not received',
    'on deposit',
    'number not used',
    'deaccessioned',
    'recataloged')
AND  regexp_replace(cp.pahmatmslegacydepartment, '^.*\)''(.*)''$', '\1') NOT IN (
     'Nonnative California (archaeology and ethnology)',
     'Nonnative US and Canada (except California)',
     'Loans in',
     'Archives',
     'Audio recordings',
     'Maps',
     'Registration',
     '(not assigned)',
     'South America', -- (except Ancient Peru)
     'Ancient Peru',
     'Africa', --  (except Ancient Egypt)'
     'Ancient Egypt',
     'Asia', --  (except western Russia)
     'Still and motion photography',
     'South America', --  (except Ancient Peru)
     'Drawings and paintings',
     'Classical Mediterranean'
)

GROUP BY cc.id;
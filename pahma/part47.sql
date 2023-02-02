SELECT cc.id,
       REGEXP_REPLACE(pog.anthropologyplaceowner, '^.*\)''(.*)''$', '\1') as anthropologyplaceowner_s,
       pog.anthropologyplaceownershipnote                                 as anthropologyplaceownershipnote_s
FROM collectionobjects_common cc
         JOIN collectionobjects_pahma_pahmafieldcollectionplacelist fcp
              ON (fcp.id = cc.id AND (fcp.pos = 0 OR fcp.pos IS NULL))
         JOIN places_common pc ON (pc.shortidentifier = REGEXP_REPLACE(fcp.item, '^.*item:name\((.*?)\)''.*', '\1'))
         JOIN hierarchy hp ON (hp.parentid = pc.id AND hp.primarytype = 'anthropologyPlaceOwnerGroup' AND hp.pos = 0)
         JOIN anthropologyplaceownergroup pog ON (pog.id = hp.id)
WHERE pog.anthropologyplaceowner IS NOT NULL
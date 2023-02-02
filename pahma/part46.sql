SELECT DISTINCT cc.id,
STRING_AGG(DISTINCT REGEXP_REPLACE(ocg.objectclassname, '^.*\)''(.*)''$', '\1'),'␥') AS "objobjectclass_ss",
STRING_AGG(DISTINCT utils.objectclass_hierarchy.objectclass_hierarchy, '␥') AS "objobjectclasstree_ss"
FROM collectionobjects_common cc
JOIN hierarchy hc ON (hc.parentid=cc.id AND hc.primarytype='objectClassGroup')
JOIN objectClassGroup ocg ON (ocg.id=hc.id)
LEFT OUTER JOIN concepts_common cnc ON (cnc.shortidentifier=REGEXP_REPLACE(ocg.objectclassname, '^.*item:name\((.*?)\)''.*', '\1'))
LEFT OUTER JOIN hierarchy ccsid ON (cnc.id=ccsid.id)
LEFT OUTER JOIN utils.objectclass_hierarchy ON (ccsid.name= utils.objectclass_hierarchy.objectclasscsid)
GROUP BY cc.id

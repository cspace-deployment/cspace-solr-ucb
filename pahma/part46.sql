SELECT DISTINCT cc.id,
STRING_AGG(DISTINCT UPPER(SUBSTRING(REGEXP_REPLACE(ocg.objectclassname, '^.*\)''(.*)''$', '\1'),1,1))||SUBSTRING(REGEXP_REPLACE(ocg.objectclassname, '^.*\)''(.*)''$', '\1'),2),'␥') AS "objobjectclass_ss",
STRING_AGG(
    DISTINCT
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(
        REPLACE(utils.objectclass_hierarchy.objectclass_hierarchy,'@','')
        ,'|a','|A')
        ,'|b','|B')
        ,'|c','|C')
        ,'|d','|D')
        ,'|e','|E')
        ,'|f','|F')
        ,'|g','|G')
        ,'|h','|H')
        ,'|i','|I')
        ,'|j','|J')
        ,'|k','|K')
        ,'|l','|L')
        ,'|m','|M')
        ,'|n','|N')
        ,'|o','|O')
        ,'|p','|P')
        ,'|q','|Q')
        ,'|r','|R')
        ,'|s','|S')
        ,'|t','|T')
        ,'|u','|U')
        ,'|v','|V')
        ,'|w','|W')
        ,'|x','|X')
        ,'|y','|Y')
        ,'|z','|Z'),
    '␥') AS "objobjectclasstree_ss"
FROM collectionobjects_common cc
JOIN hierarchy hc ON (hc.parentid=cc.id AND hc.primarytype='objectClassGroup')
JOIN objectClassGroup ocg ON (ocg.id=hc.id)
LEFT OUTER JOIN concepts_common cnc ON (cnc.shortidentifier=REGEXP_REPLACE(ocg.objectclassname, '^.*item:name\((.*?)\)''.*', '\1'))
LEFT OUTER JOIN hierarchy ccsid ON (cnc.id=ccsid.id)
LEFT OUTER JOIN utils.objectclass_hierarchy ON (ccsid.name= utils.objectclass_hierarchy.objectclasscsid)
GROUP BY cc.id;

SELECT cc.id, spd.datedisplaydate AS "objproddate_s",
CASE
        WHEN spd.dateearliestsingleera = '' THEN SUBSTRING(CAST((DATE(spd.dateearliestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN (spd.dateearliestsingleera = 'ce' OR spd.dateearliestsingleera = 'urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(ce)''CE'''  OR spd.dateearliestsingleera ='urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(ce)''AD/CE''') THEN SUBSTRING(CAST((DATE(spd.dateearliestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN spd.dateearliestsingleera IS NULL THEN SUBSTRING(CAST((DATE(spd.dateearliestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN (spd.dateearliestsingleera = 'bce' OR spd.dateearliestsingleera = 'urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(bce)''BC/BCE'''  OR spd.dateearliestsingleera ='urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(bce)''BCE''') THEN '-'||SUBSTRING(CAST((DATE(spd.dateearliestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN (spd.dateearliestsingleera = 'bp' OR spd.dateearliestsingleera = 'urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(bp)''BP''') AND DATE_PART('year', spd.dateearliestscalarvalue) <= 1950
                THEN CASE
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 4
                                THEN (1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 3
                                THEN '0'||(1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 2
                                THEN '00'||(1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 1
                                THEN '000'||(1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        ELSE (1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                END
        WHEN spd.dateearliestsingleera = 'bp' AND DATE_PART('year', spd.dateearliestscalarvalue) > 1950
                THEN CASE
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 5
                                THEN (1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 4
                                THEN '-0'||ABS(1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 3
                                THEN '-00'||ABS(1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.dateearliestscalarvalue) AS text)) = 2
                                THEN '-000'||ABS(1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                        ELSE '-'||(1950-DATE_PART('year', spd.dateearliestscalarvalue))||SUBSTRING(CAST(spd.dateearliestscalarvalue AS text),5,6)||'T19:00:00Z'
                END
        ELSE DATE(spd.dateearliestscalarvalue)||'T19:00:00Z'
        END AS "objproddate_begin_dt",
CASE
        WHEN spd.datelatestera = '' THEN SUBSTRING(CAST((DATE(spd.datelatestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN (spd.datelatestera = 'ce' OR spd.datelatestera='urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(ce)''CE'''  OR spd.datelatestera ='urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(ce)''AD/CE''') THEN SUBSTRING(CAST((DATE(spd.datelatestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN spd.datelatestera IS NULL THEN SUBSTRING(CAST((DATE(spd.datelatestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN (spd.datelatestera = 'bce' OR spd.datelatestera = 'urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(bce)''BC/BCE'''  OR spd.datelatestera ='urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(bce)''BCE''') THEN '-'||SUBSTRING(CAST((DATE(spd.datelatestscalarvalue)+1) AS text),1,10)||'T19:00:00Z'
        WHEN (spd.datelatestera = 'bp' OR spd.datelatestera = 'urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(dateera):item:name(bp)''BP''') AND DATE_PART('year', spd.datelatestscalarvalue) <= 1950
                THEN CASE
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 4
                                THEN (1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 3
                                THEN '0'||ABS(1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 2
                                THEN '00'||ABS(1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 1
                                THEN '000'||ABS(1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        ELSE (1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                END
        WHEN spd.datelatestera = 'bp' AND DATE_PART('year', spd.datelatestscalarvalue) > 1950
                THEN CASE
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 5
                                THEN (1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 4
                                THEN '-0'||ABS(1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 3
                                THEN '-00'||ABS(1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        WHEN CHAR_LENGTH(CAST(1950-DATE_PART('year', spd.datelatestscalarvalue) AS text)) = 2
                                THEN '-000'||ABS(1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                        ELSE '-'||(1950-DATE_PART('year', spd.datelatestscalarvalue))||SUBSTRING(CAST(spd.datelatestscalarvalue AS text),5,6)||'T19:00:00Z'
                END
        ELSE DATE(spd.datelatestscalarvalue)||'T19:00:00Z'
        END AS "objproddate_end_dt"
FROM collectionobjects_common cc
JOIN hierarchy hpd ON (hpd.parentid=cc.id AND hpd.primarytype='structuredDateGroup' AND hpd.name='collectionobjects_common:objectProductionDateGroupList' AND (hpd.pos=0 or hpd.pos IS NULL))
JOIN structureddategroup spd ON (spd.id=hpd.id)
WHERE spd.datedisplaydate IS NOT NULL;

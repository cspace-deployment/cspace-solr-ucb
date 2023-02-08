SELECT id, nagpra_relevant_s FROM
(SELECT cc.id,
       STRING_AGG(osl.item,'␥') as objstatus,
       cp.pahmatmslegacydepartment,
       utils.placename_hierarchy.place_hierarchy,
       'eligible' as nagpra_relevant_s
FROM collectionobjects_common cc
	LEFT OUTER JOIN collectionobjects_pahma_pahmaobjectstatuslist osl ON (cc.id=osl.id)
	JOIN misc m ON (m.id=cc.id AND m.lifecyclestate='project')
	JOIN collectionobjects_pahma cp ON (cc.id=cp.id)
	JOIN collectionobjects_pahma_pahmafieldcollectionplacelist fcp ON (fcp.id=cc.id)
	JOIN places_common pc ON (pc.shortidentifier=REGEXP_REPLACE(fcp.item, '^.*item:name\((.*)\)''.*', '\1'))
	JOIN hierarchy pcsid ON (pc.id=pcsid.id)
	JOIN utils.placename_hierarchy ON (pcsid.name=utils.placename_hierarchy.placecsid)
GROUP BY cc.id,cp.pahmatmslegacydepartment,utils.placename_hierarchy.place_hierarchy) AS foo
WHERE   objstatus NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses05)''deaccessioned''%'
	AND objstatus NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses32)''on deposit''%'
	AND objstatus NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses18)''number not used''%'
	AND objstatus NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses17)''not received''%'
	AND objstatus NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses25)''recataloged''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(NonnativeCaliforniaarchaeologyandethnology1645142411253)''Nonnative California (archaeology and ethnology)''%'
	AND pahmatmslegacydepartment NOT LIKE 'urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(NonnativeUSandCanadaexceptCalifornia1645142411311)''Nonnative US and Canada (except California)''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment55)''Loans in''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(Archives1645142411361)''Archives''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment14)''Audio recordings''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment17)''Maps''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment50)''Registration''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment95)''(not assigned)''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment06)''South America (except Ancient Peru)''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment07)''Ancient Peru''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment08)''Africa (except Ancient Egypt)''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment09)''Ancient Egypt''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment12)''Asia (except western Russia)''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment18)''Still and motion photography''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment06)''South America (except Ancient Peru)''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment16)''Drawings and paintings''%'
	AND pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment11)''Classical Mediterranean''%'
	AND (place_hierarchy ILIKE '%United States%'
        OR place_hierarchy ILIKE '%Hawaii%')

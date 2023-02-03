SELECT cc.id,
       'nagpra' as nagpra_relevant_s
FROM collectionobjects_common cc
	LEFT OUTER JOIN collectionobjects_pahma_pahmaobjectstatuslist osl ON (cc.id=osl.id)
	JOIN misc m ON (m.id=cc.id AND m.lifecyclestate='project')
	JOIN collectionobjects_pahma cp ON (cc.id=cp.id)
	JOIN collectionobjects_pahma_pahmafieldcollectionplacelist fcp ON (fcp.id=cc.id AND (fcp.pos=0 OR fcp.pos IS NULL))
	JOIN places_common pc ON (pc.shortidentifier=REGEXP_REPLACE(fcp.item, '^.*item:name\((.*)\)''.*', '\1'))
	JOIN hierarchy pcsid ON (pc.id=pcsid.id)
	JOIN utils.placename_hierarchy ON (pcsid.name=utils.placename_hierarchy.placecsid)

WHERE   osl.item NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses05)''deaccessioned''%'
	AND osl.item NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses32)''on deposit''%'
	AND osl.item NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses18)''number not used''%'
	AND osl.item NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses17)''not received''%'
	AND osl.item NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaObjectStatuses):item:name(pahmaObjectStatuses25)''recataloged''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(NonnativeCaliforniaarchaeologyandethnology1645142411253)''Nonnative California (archaeology and ethnology)''%'
	AND cp.pahmatmslegacydepartment NOT LIKE 'urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(NonnativeUSandCanadaexceptCalifornia1645142411311)''Nonnative US and Canada (except California)''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment55)''Loans in''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(Archives1645142411361)''Archives''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment14)''Audio recordings''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment17)''Maps''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment50)''Registration''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment95)''(not assigned)''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment06)''South America (except Ancient Peru)''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment07)''Ancient Peru''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment08)''Africa (except Ancient Egypt)''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment09)''Ancient Egypt''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment12)''Asia (except western Russia)''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment18)''Still and motion photography''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment06)''South America (except Ancient Peru)''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment16)''Drawings and paintings''%'
	AND cp.pahmatmslegacydepartment NOT LIKE '%urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(pahmaTmsLegacyDepartments):item:name(pahmaTMSLegacyDepartment11)''Classical Mediterranean''%'
	AND (  utils.placename_hierarchy.place_hierarchy ILIKE '%United States%'
        OR utils.placename_hierarchy.place_hierarchy ILIKE '%Hawaii%')

GROUP BY cc.id;
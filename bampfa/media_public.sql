SELECT 
h2.name objectcsid,
cc.objectnumber,
h1.name mediacsid,
mc.description,
b.name,
mc.creator creatorRefname,
mc.creator creator,
mc.blobcsid,
mc.copyrightstatement,
mc.identificationnumber,
mc.rightsholder rightsholderRefname,
mc.rightsholder rightsholder,
mc.contributor,
mb.imageNumber

FROM media_common mc

LEFT OUTER JOIN media_bampfa mb ON (mb.id = mc.id)
JOIN misc ON (mc.id = misc.id AND misc.lifecyclestate <> 'deleted')
LEFT OUTER JOIN hierarchy h1 ON (h1.id = mc.id)
INNER JOIN relations_common r ON (h1.name = r.objectcsid)
LEFT OUTER JOIN hierarchy h2 ON (r.subjectcsid = h2.name)
LEFT OUTER JOIN collectionobjects_common cc ON (h2.id = cc.id)

JOIN hierarchy h3 ON (mc.blobcsid = h3.name)
LEFT OUTER JOIN blobs_common b ON (h3.id = b.id)
WHERE mb.websitedisplaylevel IS DISTINCT FROM 'No public display'

ORDER BY mb.imageNumber ASC

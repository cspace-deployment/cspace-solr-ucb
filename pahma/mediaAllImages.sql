-- revised mediaAllImages.sql query to 
-- convert subqueries to CTE,
-- removed extraneous joins,
-- change loj to join, 
-- exclude deleted relations, media, collectionObjects, blobs

with objects_media as (
  select
    rc.objectcsid as objectcsid,
    hcc.id as objectid,
    rc.subjectcsid as mediacsid,
    hmc.id as mediaid
  from relations_common rc
  join misc mrc on (
    rc.id = mrc.id 
    and mrc.lifecyclestate != 'deleted')
  join hierarchy hcc on (
    rc.objectcsid = hcc.name
    and rc.objectdocumenttype = 'CollectionObject'
    and hcc.primarytype = 'CollectionObjectTenant15')
  join misc mcc on (
    hcc.id = mcc.id 
    and mcc.lifecyclestate != 'deleted')
  join hierarchy hmc on (
    rc.subjectcsid = hmc.name
    and rc.subjectdocumenttype = 'Media'
    and hmc.primarytype = 'MediaTenant15')
  join misc mmc on (
    hmc.id = mmc.id  
    and mmc.lifecyclestate != 'deleted')
),

objectlist as (
  select distinct objects_media.objectid
  from objects_media
),

objects as (
  select
    objectlist.objectid,
    cc.objectnumber,
    getdispl(cp.pahmatmslegacydepartment) as pahmatmslegacydepartment
  from objectlist
  join collectionobjects_common cc on (objectlist.objectid = cc.id)
  join collectionobjects_pahma cp on (cc.id = cp.id)
),

statuses as (
  select
    objectlist.objectid,
    string_agg(distinct getdispl(osl.item),'␥') as objectstatus
  from objectlist
  join collectionobjects_pahma_pahmaobjectstatuslist osl ON (objectlist.objectid = osl.id)
  group by objectlist.objectid
),

medialist as (
  select distinct objects_media.mediaid
  from objects_media
),

media as (
  select
    medialist.mediaid,
    regexp_replace(mc.description,E'[\\t\\n\\r]+', ' ', 'g') as description,
    mc.creator as creatorRefname,
    getdispl(mc.creator) as creator,
    mc.blobcsid,
    mc.copyrightstatement,
    mc.identificationnumber,
    mc.rightsholder as rightsholderRefname,
    getdispl(mc.rightsholder) as rightsholder,
    mc.contributor,
    mp.approvedforweb,
    mp.primarydisplay
  from medialist
  join media_common mc on (medialist.mediaid = mc.id)
  join media_pahma mp on (mc.id = mp.id)
),

bloblist as (
  select distinct media.blobcsid
  from media
),

blobs as (
  select
    hbc.name as blobcsid,
    bc.name,
    bc.mimetype,
    c.data as md5
  from bloblist
  join hierarchy hbc on (bloblist.blobcsid = hbc.name)
  join blobs_common bc ON (hbc.id = bc.id)
  join misc mbc on (
    bc.id = mbc.id 
    and mbc.lifecyclestate != 'deleted')
  left outer join hierarchy hc ON (
    bc.repositoryid = hc.parentid 
    and hc.primarytype = 'content')
  left outer join content c ON (hc.id = c.id)
)

select
  objects_media.objectcsid,
  objects.objectnumber,
  objects_media.mediacsid,
  media.description,
  blobs.name,
  media.creatorRefname,
  media.creator,
  media.blobcsid,
  media.copyrightstatement,
  media.identificationnumber,
  media.rightsholderRefname,
  media.rightsholder,
  media.contributor,
  media.approvedforweb,
  objects.pahmatmslegacydepartment,
  statuses.objectstatus,
  media.primarydisplay,
  blobs.mimetype,
  blobs.md5
from objects_media
left outer join objects on (objects_media.objectid = objects.objectid)
left outer join media on (objects_media.mediaid = media.mediaid)
left outer join blobs on (media.blobcsid = blobs.blobcsid)
left outer join statuses on (objects.objectid = statuses.objectid)
order by objects.objectnumber, media.identificationnumber
;

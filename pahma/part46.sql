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
        ,'|z','|Z')
        ,'|Equipment|','|')
        ,'|Object groupings|','|')
        ,'Language-related concepts|','')
        ,'Culture and related concepts|','')
        ,'Physical Attributes Facet|','')
        ,'Attributes and Properties (hierarchy name)|','')
        ,'Attributes and properties by specific type|','')
        ,'Objects Facet|','')
        ,'Furnishings and Equipment (hierarchy name)|','')
        ,'Tools and Equipment (hierarchy name)|','')
        ,'Equipment by profession or discipline|','')
        ,'Visual and Verbal Communication (hierarchy name)|','')
        ,'Information Forms (hierarchy name)|','')
        ,'Information forms (objects)|','')
        ,'Information artifacts by function|','')
        ,'Object Genres (hierarchy name)|','')
        ,'Object genres (object classifications)|','')
        ,'Object genres by function|','')
        ,'Equipment by process|','')
        ,'Equipment by context|','')
        ,'Components (hierarchy name)|','')
        ,'Biological components|','')
        ,'Human components|','')
        ,'Heat- or fire-related attributes|','')
        ,'Integrity-related attributes|','')
        ,'Measuring Devices (hierarchy name)|','')
        ,'Measuring devices (instruments)|','')
        ,'Measuring devices for extent|','')
        ,'Measuring devices for forces|','')
        ,'Sound Devices (hierarchy name)|','')
        ,'Sound devices by acoustical characteristics|','')
        ,'Containers (hierarchy name)|','')
        ,'Containers by form|','')
        ,'Components (object parts)|','')
        ,'Components by specific context|','')
        ,'Weapons and Ammunition (hierarchy name)|','')
        ,'Projectile weapons with nonexplosive propellant|','')
        ,'Visual Works (hierarchy name)|','')
        ,'Visual works (works)|','')
        ,'Visual works by material or technique|','')
        ,'Visual works by form|','')
        ,'Visual works by function|','')
        ,'Costume (hierarchy name)|','')
        ,'Costume (mode of fashion)|','')
        ,'Jewelry by location|','')
        ,'Exchange Media (hierarchy name)|','')
        ,'Money by form|','')
        ,'Object genres by form|','')
        ,'Object genres by material or technique|','')
        ,'Object Groupings and Systems (hierarchy name)|','')
        ,'Object groupings by general context|','')
        ,'Record Status Facet|','')
        ,'Containers by function or context|','')
        ,'Components by general context|','')
        ,'Object portions (components by general context)|','')
        ,'Baskets by form|','')
        ,'Animal components|','')
        ,'Equipment by material processed|','')
        ,'Agents Facet|','')
        ,'Living Organisms (hierarchy name)|','')
        ,'Living organisms (entities)|','')
        ,'Organisms by condition|','')
        ,'People (hierarchy name)|','')
        ,'People (agents)|','')
        ,'People by gender or sex|','')
        ,'Sculpture by technique|','')
        ,'Sculpture by subject type|','')
        ,'Agricultural equipment by material processed|','')
        ,'Design Elements (hierarchy name)|','')
        ,'Design elements (attributes)|','')
        ,'Patterns by specific type|','')
        ,'Form-related attributes|','')
        ,'Size/dimensions|','')
        ,'Size/dimensions by specific type|','')
        ,'Coverings and hangings by form|','')
        ,'Coverings and hangings by specific type|','')
        ,'Architectural elements by building type|','')
        ,'Costume by function|','')
        ,'Associated Concepts Facet|','')
        ,'Associated Concepts (hierarchy name)|','')
        ,'Concepts in the arts and humanities|','')
        ,'Concepts relating to the creative process|','')
        ,'Money by material|','')
        ,'Coins by origin|','')
        ,'Later Western World coins by denomination name|','')
        ,'Languages and writing systems|','')
        ,'Languages and writing systems by specific type|','')
        ,'Culminating and edge ornaments in architecture|','')
        ,'Skeleton components (animal components)|','')
        ,'Watercraft by specific type|','')
        ,'Watercraft by form|','')
        ,'Watercraft by end configuration|','')
        ,'Watercraft by general type|','')
        ,'Symmetrical-ended watercraft|','')
        ,'Watercraft by construction|','')
        ,'Artistic concepts|','')
        ,'Transportation Vehicles (hierarchy name)|','')
        ,'Baskets by function or context|','')
        ,'Visual works by location or context|','')
        ,'Built Environment (hierarchy name)|','')
        ,'Single Built Works (hierarchy name)|','')
        ,'Single built works by specific type|','')
        ,'Single built works by function|','')
        ,'Cups by form|','')
        ,'Cups by function|','')
        ,'Bottles by form|','')
        ,'Bottles by function|','')
        ,'Footwear by form|','')
        ,'Furnishings (hierarchy name)|','')
        ,'Furnishings (works)|','')
        ,'Furnishings by form or function|','')
        ,'Furniture by form or function|','')
        ,'Lighting devices by form|','')
        ,'Hardware by form|','')
        ,'Weighing devices by form|','')
        ,'Sound devices by function|','')
        ,'Styles and Periods Facet|','')
        ,'Styles and Periods (hierarchy name)|','')
        ,'Styles, periods, and cultures by region|','')
        ,'Americas, The (styles)|','')
        ,'Jewelry by form|','')
        ,'Ropework (genre by technique)|','')
        ,'Sound devices by function|','')
        ,'Wearing blankets by origin or style|','')
        ,'Photographs by form|','')
        ,'Photographs by form: format|','')
        ,'Drawings by material or technique|','')
        ,'Containers by location|','')
        ,'Documents by function|','')
        ,'Document genres|','')
        ,
    '␥') AS "objobjectclasstree_ss"
FROM collectionobjects_common cc
JOIN hierarchy hc ON (hc.parentid=cc.id AND hc.primarytype='objectClassGroup')
JOIN objectClassGroup ocg ON (ocg.id=hc.id)
LEFT OUTER JOIN concepts_common cnc ON (cnc.shortidentifier=REGEXP_REPLACE(ocg.objectclassname, '^.*item:name\((.*?)\)''.*', '\1'))
LEFT OUTER JOIN hierarchy ccsid ON (cnc.id=ccsid.id)
LEFT OUTER JOIN utils.objectclass_hierarchy ON (ccsid.name= utils.objectclass_hierarchy.objectclasscsid)
GROUP BY cc.id;

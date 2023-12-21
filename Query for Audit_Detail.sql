SELECT
    Base.Id
    , Base.SinkCreatedOn
    , Base.action
    , Base.operation
    , Base.objectid
    , Base.objectid_entitytype
    , Base.userid
    , Base.userid_entitytype
    , c.logicalName
    , c.oldValue
    , c.newValue
FROM audit Base
    CROSS APPLY OPENJSON(Base.changedata, '$.changedAttributes')
        WITH(logicalName nvarchar(100), oldValue nvarchar(MAX), newValue nvarchar(MAX))  c
LEFT OUTER JOIN audit_detail a    
    ON Base.Id = a.Id
    --AND c.logicalName = a.logicalName
WHERE a.Id IS NULL 
    AND Base.operation < 4
    AND ISJSON(Base.changedata) = 1
    AND Base.SinkCreatedOn >= (Select Max(AD.SinkCreatedOn) from audit_detail AD)
ORDER by Base.SinkCreatedOn ASC
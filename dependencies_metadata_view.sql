DROP VIEW IF EXISTS dbo.dependencies_metadata_view
GO
CREATE VIEW dbo.dependencies_metadata_view
AS
SELECT  TOP 500000  
     s.name+'.'+o.name AS referencing_entity_name 
    ,referenced_schema_name AS referenced_schema_name
	,referenced_entity_name AS referenced_entity_name
    ,CASE WHEN referenced_schema_name IS NULL THEN  referenced_entity_name ELSE
	 referenced_schema_name+'.'+ referenced_entity_name END AS long_referenced_entity_name
	,(select case count(*) when 0 then 'n' else 'y' end from sys.objects o where o.name=d.referenced_entity_name) AS
	[Is there a permanent object with the referenced name?]
	,referenced_server_name
    ,referenced_database_name 
FROM 
           sys.sql_expression_dependencies d WITH (NOLOCK)
INNER JOIN sys.objects o WITH (NOLOCK) ON o.object_id=d.referencing_id
INNER JOIN sys.schemas s WITH (NOLOCK) ON o.schema_id=s.schema_id
ORDER BY 1,2

DROP VIEW IF EXISTS dbo.object_list_view
GO
-- This view lets one reference user objects in SQL server metadata tables without having to join 
-- all of the metadata tables by hand
CREATE VIEW dbo.object_list_view
AS
SELECT 
s.name+'.'+o.name AS object_name,
o.name AS short_object_name, 
s.name AS schema_name, 
o.object_id, 
type, 
CASE type_desc WHEN 'USER_TABLE' THEN 'table' 
               WHEN 'SQL_STORED_PROCEDURE' THEN 'procedure'
               WHEN 'VIEW' THEN 'view' 
			   WHEN 'SQL_SCALAR_FUNCTION' THEN 'function' 
			   ELSE type_desc END AS type_desc, 

isnull(object_definition(object_id),'') as definition,
-- To keep line breaks in definitions when copying/pasting,go to Tool->Options->Query Results ->Results to Grid and
-- check "Retain CR/LF on copy or save"
create_date,
modify_date
FROM 
               sys.objects o 
INNER JOIN     sys.schemas s ON o.schema_id=s.schema_id
WHERE 
type_desc   IN 
('VIEW','SQL_SCALAR_FUNCTION','USER_TABLE','SQL_STORED_PROCEDURE')
GO


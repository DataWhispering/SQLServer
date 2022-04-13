DROP VIEW IF EXISTS dbo.table_column_metadata_view
GO
CREATE VIEW dbo.table_column_metadata_view
AS
SELECT TOP 200000
TABLE_SCHEMA+'.'+TABLE_NAME AS table_name, ordinal_position as column_position,column_name, COLUMN_DEFAULT AS column_default
,IS_NULLABLE AS nullable	,DATA_TYPE	as data_type,
CHARACTER_MAXIMUM_LENGTH AS max_length,
CASE COLLATION_NAME	WHEN 'SQL_Latin1_General_CP1_CI_AS' THEN 'case-insensitive' WHEN 'SQL_Latin1_General_CP1_CS_AS' THEN 'case-insensitive'
ELSE COLLATION_NAME END AS collation
FROM INFORMATION_SCHEMA.COLUMNS c WITH (NOLOCK)
WHERE 
TABLE_NAME in (SELECT name FROM sys.tables)
ORDER BY table_name, ordinal_position

DROP VIEW IF EXISTS  dbo.table_size_view
GO
CREATE VIEW dbo.table_size_view
AS
SELECT 
   s.Name+'.'+t.NAME AS TableName,
   s.Name AS SchemaName,
   t.NAME AS ShortTableName,d.name as FileGroup,  
   -- Note that if a table and/or its index span more than one file group, this query may show the same table more than once and
   -- thus the numbers could be inflated for such tables
   p.rows,
   -- Space usage is shown in gigabyes.  If space usage is small enough, it may show as 0.00 GB, but this does not mean that no space is used.
   -- It just means that when looking at space usage, I'm not looking at every megabyte
   CAST(ROUND(((SUM(a.total_pages) * 8) / (1024.00*1024)), 2) AS NUMERIC(36, 2)) AS TotalSpaceGB,
   CAST(ROUND(((SUM(a.used_pages) * 8) / (1024.00*1024)), 2) AS NUMERIC(36, 2)) AS UsedSpaceGB ,
   CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / (1024.00*1024), 2) AS NUMERIC(36, 2)) AS UnusedSpaceGB,
   round(avg(DDIPS.avg_fragmentation_in_percent),2) as avg_fragmentation,
   sum(DDIPS.page_count) as page_count
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN 
 sys.data_spaces d on i.data_space_id=d.data_space_id
 INNER JOIN sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS on t.object_id=DDIPS.object_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
	and t.type='U'
GROUP BY 
    t.Name, s.Name, p.Rows,d.name

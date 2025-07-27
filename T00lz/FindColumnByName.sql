select 
    o.name,c.name 
    from sys.columns            c
        inner join sys.objects  o on c.object_id=o.object_id
        where c.name like '%Permission%'
    order by o.name,c.column_id
    
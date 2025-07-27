SELECT name, create_date, modify_date 'md' ,*
FROM sys.objects
WHERE type = 'P'  and modify_date > '1/1/2018'
order by modify_date desc

select name, 
       create_date, 
       modify_date
 from sys.triggers 
 where modify_date > '1/1/2018'
 order by modify_date desc
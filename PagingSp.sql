/reate procedure PaggingStoredProcedure --paggingtesting 1,30
@PageNo int =0,
@PageSize int =0 
As
declare @cmdS varchar(max) 
declare @cmd varchar(max) 
declare @cmdE varchar(max) 

select @cmdS = 'SELECT 
[IPRACID]
,[VUNAME]
,[VPASSWORD]
,[VTITLE]
,[VFNAME]
,[VLNAME]
FROM [Surrex_CureMD].[dbo].[CMUSXHD]'

--This will tell wheter to do pagging or not
IF @pageno <> 0 and @pagesize <> 0 
BEGIN
create table #tempList --temporary table to insert selective records in for retrieval
(
IPRACID int ,
VUNAME varchar(50),
VPASSWORD varchar(50),
VTITLE varchar (30) ,
VFNAME varchar(50) ,
VLNAME varchar(50) ,
)
declare @IPRACID int 
declare @VUNAME varchar(50)
declare @VPASSWORD varchar(50)
declare @VTITLE varchar (30) 
declare @VFNAME varchar(50) 
declare @VLNAME varchar(50) 

declare @totalrec int 
declare @totalrPages int 
declare @AbsPos int 
select @abspos = 1 

select @cmdE = 'declare list scroll cursor for '+ @cmdS
Execute(@cmdE)
open list
select @totalrec = @@cursor_rows	-- total No of rows returned by query
if (((@pageno-1) * @Pagesize)+1) <= @totalrec -- Check if the total no of record no reuired by pae is exist in returned reult
BEGIN
declare @postions int -- variable to store roecord no from which fetch has to start
select @postions =(((@pageno-1) * @Pagesize)+1) -- roecord no from which fetch has to start
fetch absolute @postions from list into @IPRACID ,@VUNAME ,@VPASSWORD,@VTITLE,@VFNAME,@VLNAME
while @@fetch_status = 0 and @abspos <= @pagesize	
BEGIN
insert into #templist ( IPRACID ,VUNAME ,VPASSWORD,VTITLE,VFNAME,VLNAME) values(@IPRACID ,@VUNAME ,@VPASSWORD,@VTITLE,@VFNAME,@VLNAME)
select @abspos=@abspos+1
fetch next from list into @IPRACID ,@VUNAME ,@VPASSWORD,@VTITLE,@VFNAME,@VLNAME
end	
close list
deallocate list
select @totalrec as TotalRec,ceiling(convert(numeric(9,4),@totalrec)/convert(numeric(9,4),@pagesize)) as TotalPage,IPRACID ,VUNAME ,VPASSWORD,VTITLE,VFNAME,VLNAME from #templist
drop table #templist
return 0
end
else --the record no requird by page is not avilabe send empty recordset
BEGIN
close list
deallocate list
select * from #TEMPLIST where IPRACID =-1
drop table #templist
return 0
END	
END
ELSE -- Donot do pagging
BEGIN
SELECT @CMD = @CMD
execute (@cmdS + @cmd)
return 0
END
GO
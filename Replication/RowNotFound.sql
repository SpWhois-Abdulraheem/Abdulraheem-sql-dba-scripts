/* ERROR: The Row was not found at the Subscriber When Applying the replicated command. */

      --Step 1 Reun the below query at the distributor database to get the artricle id and the publisher database id.


select *
from msrepl_commands (nolock)
where command_id = 1 and xact_seqno = 0x0005FE440001F8CF000800000000


      --Step 2 Run the below query from the output of Step2 on Distributor DB.
      
      
EXEC sp_browsereplcmds @article_id = 390, @command_id = 1 , @xact_seqno_start = '0x0005FE440001F8CF000800000000', @xact_seqno_end = '0x0005FE440001F8CF000800000000',@publisher_database_id = 1

      --Step 3 Copy the command from the output of step 2

{CALL [sp_MSdel_dboPLPolicyAutoCoverages] (3682287,3,2,'COLL')}

--Step 4 EXEC sp_helptext sp_MSdel_dboPLPolicyAutoCoverages


EXEC sp_helptext sp_MSdel_dboPLPolicyAutoCoverages


create procedure [sp_MSdel_dboPLPolicyAutoCoverages]  
  @pkc1 int,  
  @pkc2 int,  
  @pkc3 int,  
  @pkc4 varchar(20)  
as  
begin    
 delete [dbo].[PLPolicyAutoCoverages]  
where [PolicyID] = @pkc1  
  and [EndmtNum] = @pkc2  
  and [UnitNum] = @pkc3  
  and [CoverageName] = @pkc4  
if @@rowcount = 0  
    if @@microsoftversion>0x07320000  
        exec sp_MSreplraiserror 20598  
end    

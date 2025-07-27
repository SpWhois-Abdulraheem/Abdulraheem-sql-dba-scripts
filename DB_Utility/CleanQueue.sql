Use DB_Utility
GO
--Use if the queue is behind and not catching up
declare @c uniqueidentifier
while(1=1)
begin
    select top 1 @c = conversation_handle from dbo.BlockedProcessReportQueue
    if (@@ROWCOUNT = 0)
    break
    end conversation @c with cleanup
end

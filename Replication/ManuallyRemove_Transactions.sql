USE distribution
GO

DECLARE
    @min_distretention int = 72,
    @max_distretention int = 100,
    @no_applock bit = 0,
	@cutoff_time datetime

select @cutoff_time = dateadd(hour, -@max_distretention, getdate())
exec dbo.sp_MSdistribution_delete @min_distretention, @cutoff_time
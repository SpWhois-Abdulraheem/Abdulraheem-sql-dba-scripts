select
op.name 'Opportuinity'
,op.id 'Opportunity ID'
,i.name 'Incentive'
,i.id 'Incentive ID'
,            replace(STUFF((    SELECT ' ,' + p2.name AS [text()]
                        
                        from incentive i2 
						join IncentiveProvider opv2 on i2.id = opv2.incentiveId
						join Provider p2 on opv2.providerId = p2.id
                        WHERE
                         i2.Id = i.id
                        FOR XML PATH('') 
                        ), 1, 1, '' ),'&amp;','&') 'Provider(s)'
,cu.lastName+ ' ,'+cu.firstName 'Owner'
,ifp.accountingPeriod
,ifp.projectedExpense
from incentive i 
join Opportunity op on i.opportunityId = op.id
join CimsUser cu on op.ownerId = cu.id
join IncentiveFinancialProjection ifp on i.financialId = ifp.incentiveFinancialId
where ifp.projectedExpense <> 0
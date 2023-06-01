
SELECT patattr.[PatientId],
      min(patattr.[Timestamp]) as [Timestamp],
      min(patattr.[Name]) as Name, --these all have the same length so choosing any is fine 
      max(patattr.[Value]) as Value -- String_agg does not exist to combine all PN numbers: choose the longest one
  FROM [Philips.PatientData].[dbo].[External_PatientStringAttribute] as patattr
  WHERE patattr.Name = 'LifetimeID' and patattr.Value != '' and patattr.PatientId in (
	select distinct Id from [Philips.PatientData].[dbo].[External_Patient] where ClinicalUnit in ('U16_8_NEO', 'NEO','DS-NEO','DS-NEO-PL9')
) and 
not patattr.PatientId in (--Patients whose latest entry is a discharge older than 2 month ago
 SELECT t1.Id
  FROM [Philips.PatientData].[dbo].[External_Patient] t1
	where t1.Timestamp = (--Latest entry older than 2 month ago
	select max(t2.timestamp) from [Philips.PatientData].[dbo].[External_Patient] t2 where t2.Id=t1.Id and t2.Timestamp<= DATEADD(month, -2, getdate())
	)
	and t1.admitstate=2 
)
and not patattr.Value in ('191212121212','test','JF','1234567','123','123456789','201212121212','12345',
						'0000','00000','mt test','191111111111','190001010005','190001010002', '21258',
						'190001010001','191212121234','30731','191010101010','190001010007','19000101004','190001010004',
						'190202020202','190606060606','54321','12345','987650000000','180606060606','30341','999999-9999','12123',
						'9876','123456','AF, Gb','gb','9999','1234','11111','1111','gb olszowska','221114','121212121212','190001010009','190001010003','123456543211','180404040404')
  group by  patattr.[PatientId]
  order by Timestamp desc
  

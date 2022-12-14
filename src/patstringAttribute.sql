/****** Script for SelectTopNRows command from SSMS  ******/
SELECT patattr.[PatientId],
      min(patattr.[Timestamp]) as [Timestamp],
      min(patattr.[Name]) as Name, --these all have the same length so choosing any is fine 
      max(patattr.[Value]) as Value -- String_agg does not exist to combine all PN numbers: choose the longest one
  FROM [Philips.PatientData].[dbo].[External_PatientStringAttribute] as patattr
  WHERE patattr.Name = 'LifetimeID' and patattr.Value != '' and patattr.PatientId in (
	select distinct Id from [Philips.PatientData].[dbo].[External_Patient] where ClinicalUnit in ('U16_8_NEO', 'NEO','DS-NEO','DS-NEO-PL9')
) and not patattr.Value  in ('191212121212','test','JF','1234567','123','123456789','201212121212','0000','00000','mt test','191111111111')
  group by  patattr.[PatientId]
  order by Timestamp desc

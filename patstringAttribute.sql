/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct patattr.[PatientId]
      ,patattr.[Timestamp]
      ,patattr.[Name]
      ,patattr.[Value]
  FROM [Philips.PatientData].[dbo].[External_PatientStringAttribute] as patattr,
  [Philips.PatientData].[dbo].[External_Patient] as pat
  WHERE patattr.Name = 'LifetimeID' and patattr.Value != '' 
  and patattr.PatientId = pat.[Id] and pat.[ClinicalUnit] in ('U16_8_NEO', 'NEO','DS-NEO','DS-NEO-PL9')
  ORDER BY Timestamp DESC
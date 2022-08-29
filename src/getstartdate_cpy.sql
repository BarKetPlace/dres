SELECT format ( min([Timestamp]),'yyyy-MM-dd HH:mm:ss' ) as "start_date"
  FROM [Philips.PatientData].[dbo].[External_PatientStringAttribute]
  where Name='LifetimeID' and Value = __clean_pn__
SELECT convert(varchar(32), min([Timestamp]),121) as "start_date"
  FROM [Philips.PatientData].[dbo].[External_PatientStringAttribute]
  where Name='LifetimeID' and Value = __clean_pn__

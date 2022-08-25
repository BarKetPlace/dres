IF OBJECT_ID('EthicalPatients','U') IS NOT NULL 
	DROP TABLE EthicalPatients

CREATE TABLE EthicalPatients(EthicalPatient VARCHAR(50))
--- Patient ID's with ethical apprival should be appended to the array below
insert into EthicalPatients values ('20170404-5085')

-- Quick-fix to only return patients for which ethical approval exists ("ethicalpatients")
SELECT TOP (1) val.[PatientId] as 'Hash', pat.[Value] as 'LifetimeID'
--HF
--FROM  [Philips.PatientData].[dbo].[External_WaveSample] val JOIN [Philips.PatientData].[dbo].[External_PatientStringAttribute] pat

--LF
FROM  [Philips.PatientData].[dbo].[External_NumericValue] val JOIN [Philips.PatientData].[dbo].[External_PatientStringAttribute] pat

ON (val.[PatientId] = pat.[PatientId] AND pat.Name = ('LifeTimeId'))
WHERE pat.Value  IN (SELECT EthicalPatient COLLATE SQL_Latin1_General_CP1_CI_AS FROM EthicalPatients)
--=@Personn 
-- IN (SELECT EthicalPatient COLL
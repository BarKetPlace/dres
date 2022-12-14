

SELECT top 10000 convert(varchar(32), DATEADD(Day,0, val.[TimeStamp]),121) as [Timestamp],val.[SequenceNumber], 
			CONVERT(VARCHAR(max), val.[WaveSamples], 1) as [WaveSamples], val.[WaveId],
			map.[BasePhysioId], map.[PhysioId], map.[Label], map.[UnitLabel],map.[UnitCode],
            map.[Channel],map.[SamplePeriod], map.[IsSlowWave],
            map.[ScaleLower], map.[ScaleUpper], map.[CalibrationScaledLower],
            map.[CalibrationScaledUpper], map.[CalibrationAbsLower], map.[CalibrationAbsUpper], map.[CalibrationType],
            map.[EcgLeadPlacement],map.[LowEdgeFrequency], map.[HighEdgeFrequency],map.[IsDerived],pat.BedLabel,pat.ClinicalUnit

FROM  (select top 1 pat.*
			from  External_Patient pat
			join External_PatientStringAttribute psa
			on (psa.PatientId=pat.Id)
			where psa.Value=__clean_pn__ and pat.AdmitState=1 and pat.Timestamp <= __start_date__ order by Timestamp asc) pat,
			[Philips.PatientData].[dbo].[External_WaveSample] val 
	  JOIN [Philips.PatientData].[dbo].[External_PatientStringAttribute] psa
		ON (val.[PatientId] = psa.[PatientId] AND psa.Name = ('LifeTimeId'))
	  JOIN [Philips.PatientData].[dbo].[External_Wave] map
	    ON map.Id = val.WaveId

WHERE psa.Value=__clean_pn__ and val.Timestamp>=__start_date__ and val.Timestamp < __end_date__
order by Timestamp ASC

--OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY 

--SELECT top 10000 convert(varchar(23), DATEADD(Day,0, val.[TimeStamp]),121) as [Timestamp],val.[SequenceNumber], 
--			CONVERT(VARCHAR(max), val.[WaveSamples], 1) as [WaveSamples], val.[WaveId],
--			map.[BasePhysioId], map.[PhysioId], map.[Label], map.[UnitLabel],map.[UnitCode],
--            map.[Channel],map.[SamplePeriod], map.[IsSlowWave],
--            map.[ScaleLower], map.[ScaleUpper], map.[CalibrationScaledLower],
--            map.[CalibrationScaledUpper], map.[CalibrationAbsLower], map.[CalibrationAbsUpper], map.[CalibrationType],
--            map.[EcgLeadPlacement],map.[LowEdgeFrequency], map.[HighEdgeFrequency],map.[IsDerived]

--FROM  [Philips.PatientData].[dbo].[External_WaveSample] val 
--	  JOIN [Philips.PatientData].[dbo].[External_PatientStringAttribute] pat
--		ON (val.[PatientId] = pat.[PatientId] AND pat.Name = ('LifeTimeId'))
--	  JOIN [Philips.PatientData].[dbo].[External_Wave] map
--	    ON map.Id = val.WaveId

--WHERE pat.Value= and val.SequenceNumber >= order by Timestamp ASC
----OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY 

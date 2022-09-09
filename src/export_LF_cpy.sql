/****** Script for Merging all variables sharing the same label  ******/
/****** 20170626/eliskullberg: See below for some revisions and comments *****/ 


-- Quick-fix to only return patients for which ethical approval exists ("ethicalpatients")
SELECT top 500000 convert(varchar(32), DATEADD(Day,0, val.[TimeStamp]),121) as [Timestamp],
       val.[SequenceNumber], val.[Value],
	   map.[Id], map.[BasePhysioId], map.[PhysioId], map.[SubPhysioId], map.[Label] , map.[SubLabel],  map.[UnitLabel],pat.BedLabel,pat.ClinicalUnit
	   --map.[IsAperiodic],map.[Validity], map.[LowerLimit], map.[UpperLimit], map.[IsManual], map.[MaxValues], map.[Scale]

FROM  (select top 1 pat.*
			from  External_Patient pat
			join External_PatientStringAttribute psa
			on (psa.PatientId=pat.Id)
			where psa.Value=__clean_pn__ and pat.AdmitState=1 and pat.Timestamp <= __start_date__ order by Timestamp asc) pat,
			[Philips.PatientData].[dbo].[External_NumericValue] val
	  JOIN [Philips.PatientData].[dbo].[External_PatientStringAttribute] psa
		ON (val.[PatientId] = psa.[PatientId] AND psa.Name = ('LifeTimeId'))
	  JOIN [Philips.PatientData].[dbo].[External_Numeric] map
	    ON map.Id = val.NumericId

WHERE psa.Value=__clean_pn__ and val.Value is not NULL and val.TimeStamp>= __start_date__ and val.TimeStamp < __end_date__
order by Timestamp ASC
--OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY 

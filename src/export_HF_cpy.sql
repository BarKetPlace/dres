
declare @pid uniqueidentifier
      , @lid nvarchar(50) 
	  , @bed nvarchar(50)
	  , @unit nvarchar(50) 
	  , @admit datetimeoffset(3) 
    
SELECT @pid=v.patientid , @lid=v.LifetimeId, @bed=bedlabel, @unit=clinicalunit
    -- in case there is more than one admission, you should check the date! 
    , @admit= min(p.timestamp)
  FROM [rs].[dbo].[v_patient_list] v
  inner join [Philips.PatientData]._export.patient_ p
on v.patientid = p.id 
where LifetimeId = __clean_pn__
  and AdmitState = 1 
group by v.patientid , v.LifetimeId , bedlabel, clinicalunit

select top 5000
convert(varchar(32), val.[TimeStamp], 121) as [Timestamp],val.[SequenceNumber], 
			CONVERT(VARCHAR(max), val.[WaveSamples], 1) as [WaveSamples], val.[WaveId],
			map.[BasePhysioId], map.[PhysioId], map.[Label], map.[UnitLabel],map.[UnitCode],
            map.[Channel],map.[SamplePeriod], map.[IsSlowWave],
            map.[ScaleLower], map.[ScaleUpper], map.[CalibrationScaledLower],
            map.[CalibrationScaledUpper], map.[CalibrationAbsLower], map.[CalibrationAbsUpper], map.[CalibrationType],
            map.[EcgLeadPlacement], map.[LowEdgeFrequency], map.[HighEdgeFrequency], map.[IsDerived], @bed as [BedLabel], @unit as [ClinicalUnit]

from [Philips.PatientData].[dbo].[External_Wave] map  with (nolock)
inner join  [Philips.PatientData].[dbo].[External_WaveSample] val  with (nolock)
on map.id = val.WaveId 
and map.TimeStamp >= DATEADD(hh, -2., CAST(__start_date__ AS datetimeoffset(3))) 
     and map.TimeStamp <  DATEADD(hh,  2., __end_date__) 
and val.TimeStamp >= __start_date__
	and val.TimeStamp < __end_date__	
where patientid = @pid 
order by Timestamp ASC

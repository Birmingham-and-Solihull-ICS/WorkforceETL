/*
Siti Hassan
BSOL 1236 Provider Workforce
17-October-2024
*/

USE EAT_Reporting_BSOL;

/*=================================================================================================
	1. Main Output			
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
    LoadDate
)
SELECT DISTINCT
	Maincode,
    Yearmonth,
    Provider,
	Value,
    LoadDate
FROM ##BSOL_1236_PWR_New_Raw_Data src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main]

/*=================================================================================================
	2. WTE Overall			
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Overall] (
	Maincode,
    Yearmonth,
    Provider,
	Value,
    StaffWTEDetail,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
	Yearmonth,
	Provider,
	Value,
	[Summary Staff WTE Detail],
	[Reference Sheet]
FROM ##BSOL_1236_Overall src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Overall] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Overall] 
/*=================================================================================================
	3. WTE Staff Group		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Staff_Group] (
	Maincode,
	Yearmonth,
	Provider, 
	Value,
	StaffGroup,
	StaffType,
	StaffWTEDetail,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
	Yearmonth,
	Provider,
	Value,
	[Staff Group],
	[Staff Type],
	[Substantive Staff by Staff Group],
	[Reference Sheet]
FROM ##BSOL_1236_Staff_Group src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Staff_Group] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
	  AND src.[Staff Group] = dest.StaffGroup
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Staff_Group]

/*=================================================================================================
	4. WTE Bank & Agency		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Bank_Agency] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
    StaffGroup,
	StaffType,
	BankOrAgency,
	StaffWTEDetail,
	ReferenceSheet  
)
SELECT DISTINCT
	Maincode,
    Yearmonth,
    Provider,
	Value,
	[Staff Group],
	[Staff Type],
	[Bank/Agency],
	[Bank/Agency Staff by Staff Group],
	[Reference Sheet]
FROM ##BSOL_1236_Bank_Agency src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Bank_Agency] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
	  AND src.[Staff Group] = dest.StaffGroup
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Bank_Agency]

/*=================================================================================================
	5. KPI		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_KPI] (
	Maincode,
	Yearmonth,
	Provider,
	Value,
	KPI,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
	Yearmonth,
	Provider,
	Value,
	[Workforce KPI],
	[Reference Sheet]
FROM ##BSOL_1236_KPI src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_KPI] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_KPI]

/*=================================================================================================
	6. Main Vacancy	
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	StaffGroup,
	StaffType,
	VacancyDetail,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
	Yearmonth,
	Provider,
	Value,
	[Staff Group],
	[Staff Type],
	[Workforce Vacancies],
	[Reference Sheet]
FROM ##BSOL_1236_Vacancy src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy]

/*=================================================================================================
	7. International Recruitment (IR)		
=================================================================================================*/
INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_IR] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	MeasureDetail,
	Breakdown,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
	Yearmonth,
	Provider,
	Value,
	Measure,
	[Measure Detail],
	Breakdown,
	[Reference Sheet]
FROM ##BSOL_1236_IR src
WHERE NOT EXISTS(
 SELECT 1
 FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_IR] dest
 WHERE src.Maincode = dest.Maincode
	AND src.Yearmonth = dest.Yearmonth
	AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_IR]
/*=================================================================================================
	8. AHP International Recruitment (IR)	
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_AHP_IR] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	MeasureDetail,
	StaffGroup ,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
	Yearmonth,
	Provider,
	Value,
	Measure,
	[Measure Detail],
	[Staff Group],
	[Reference Sheet]
FROM ##BSOL_1236_AHP_IR src
WHERE NOT EXISTS(
 SELECT 1
 FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_AHP_IR] dest
 WHERE src.Maincode = dest.Maincode
	AND src.Yearmonth = dest.Yearmonth
	AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_AHP_IR]

/*=================================================================================================
	9. Maternity	
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Maternity] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	StaffGroup,
	StaffType,
	OriginalColumn,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	[Staff Group],
	[Staff Type],
	[Original Column],
	[Reference Sheet]
FROM ##BSOL_1236_Maternity src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Maternity] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Maternity]

/*=================================================================================================
	10. PNA		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PNA] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	MeasureDetail,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	[Measure Detail],
	[Reference Sheet]
FROM ##BSOL_1236_PNA src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PNA]  dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PNA] 

/*=================================================================================================
	11. PMA		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PMA] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	MeasureDetail,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	[Measure Detail],
	[Reference Sheet]
FROM ##BSOL_1236_PMA src
WHERE NOT EXISTS (
    SELECT 1
    FROM  [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PMA] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM  [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PMA]

/*=================================================================================================
	12. HCSW		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	MeasureDetail,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	[Measure Detail],
	[Reference Sheet]
FROM ##BSOL_1236_HCSW src
WHERE NOT EXISTS(
	SELECT 1
	FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW] dest
	WHERE src.Maincode = dest.Maincode
	AND src.Yearmonth = dest.Yearmonth
	AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW] 

/*=================================================================================================
	13. HCSW Vacancy	
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW_Vacancy] (
    Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	MeasureDetail,
	ReferenceSheet
)
SELECT DISTINCT
	Maincode,
    Yearmonth,
    Provider,
	Value,
	Measure,
	[Measure Detail],
	[Reference Sheet]
FROM ##BSOL_1236_HCSW_Vacancy_Rate src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW_Vacancy] dest
    WHERE src.Maincode = dest.Maincode
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW_Vacancy] 

/*=================================================================================================
	14. Vacancy Rate		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy_Rate] (
    Provider,
	Yearmonth,
	TotalStaffVacancyWTE,       -- In Month Overall Staff Vacancies WTE
	TotalSubstantiveStaffWTE,   -- Total WTE Substantive Staff
	Total,
	VacancyRate,
	VacancyType
    
)
SELECT DISTINCT
	Provider,
	Yearmonth,
	Vacancy,
	Substantive,
	Total,
	Rate,
	Type
FROM ##BSOL_1236_Vacancy_Rate_Calc src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy_Rate] dest
    WHERE src.Type = dest.VacancyType
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM  [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy_Rate]

/*=================================================================================================
	15. Staffing Actual vs Plan		
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Staff_Actual_Plan] (
    Provider,
	Yearmonth,
	Substantive,       
	[Plan],   
	DifferenceWTE, -- Substantive minus Plan
	PctDifference, -- Difference relative to Plan (Difference WTE/Plan)
	VacancyRate,
	VacancyType
)
SELECT DISTINCT
	Provider,
	Yearmonth,
	Substantive,       
	[Plan],
	Difference_WTE,
	Percentage_Difference,
	VacancyRate,
	Type
FROM ##BSOL_1236_Staffing_Actual_Plan src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Staff_Actual_Plan]  dest
    WHERE src.Type = dest.VacancyType
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Staff_Actual_Plan] 

/*=================================================================================================
	16. Sickness and Turnover	
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Sickness_Turnover] (
    Provider,
	Yearmonth,
	RateType,
	Measure,
	Value
)
SELECT DISTINCT
	Provider,
	Yearmonth,
	[Reference Sheet],
	Metric,
	Value
FROM ##BSOL_1236_Sickness_Turnover src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Sickness_Turnover] dest
    WHERE src.Metric = dest.Measure
      AND src.Yearmonth = dest.Yearmonth
      AND src.Provider = dest.Provider
);

--SELECT * FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Sickness_Turnover]

/*=================================================================================================
	17. Main Overview page	
=================================================================================================*/

INSERT INTO [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main_Overview] (
    Measure,
	StaffGroup,
	System,
	Yearmonth,
	Date,
	Value
)
SELECT DISTINCT
	Metric,
	[Staff Group],
	System,
	Period,
	Date,
	Value
FROM ##BSOL_1236_Main_Overview src
WHERE NOT EXISTS (
    SELECT 1
    FROM [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main_Overview] dest
    WHERE src.Metric = dest.Measure
      AND src.Period = dest.Yearmonth
      AND src.System = dest.System
	  AND src.[Staff Group] = dest.StaffGroup
);

--SELECT * FROM  [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main_Overview]

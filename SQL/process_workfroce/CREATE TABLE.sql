/*
Siti Hassan
BSOL 1236 Provider Workforce
17-October-2024
*/


/*=================================================================================================
	1. Main Output			
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
    LoadDate DATE,
    CONSTRAINT PK_BSOL_1236_PWR_Main UNIQUE (Maincode, Yearmonth, Provider)
);


/*=================================================================================================
	2. WTE Overall			
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Overall] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
    StaffWTEDetail VARCHAR(80),
	ReferenceSheet VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_WTE_Overall UNIQUE (Maincode, Yearmonth, Provider)
);


/*=================================================================================================
	3. WTE Staff Group		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Staff_Group] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
    StaffGroup VARCHAR(80),
	StaffType VARCHAR(80),
	StaffWTEDetail VARCHAR(100),
	ReferenceSheet VARCHAR (20)
    CONSTRAINT PK_BSOL_1236_PWR_WTE_Staff_Group UNIQUE (Maincode, Yearmonth, Provider, StaffGroup)
);


/*=================================================================================================
	4. WTE Bank & Agency		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_WTE_Bank_Agency] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
    StaffGroup VARCHAR(80),
	StaffType VARCHAR(80),
	BankOrAgency VARCHAR(25),
	StaffWTEDetail VARCHAR(100),
	ReferenceSheet VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_WTE_Bank_Agency UNIQUE (Maincode, Yearmonth, Provider, StaffGroup)
);

/*=================================================================================================
	5. KPI		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_KPI] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
    KPI VARCHAR(100),
	ReferenceSheet VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_KPI UNIQUE (Maincode, Yearmonth, Provider)
);


/*=================================================================================================
	6. Main Vacancy	
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	StaffGroup VARCHAR(80),
	StaffType VARCHAR(80),
	VacancyDetail VARCHAR(100),
	ReferenceSheet VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_Vacancy UNIQUE (Maincode, Yearmonth, Provider)
);

/*=================================================================================================
	7. International Recruitment (IR)		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_IR] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	Measure VARCHAR(80),
	MeasureDetail VARCHAR(200),
	Breakdown VARCHAR(200),
	ReferenceSheet VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_IR UNIQUE (Maincode, Yearmonth, Provider)
);


/*=================================================================================================
	8. AHP International Recruitment (IR)	
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_AHP_IR] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	Measure VARCHAR(80),
	MeasureDetail VARCHAR(200),
	StaffGroup VARCHAR(200),
	ReferenceSheet VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_AHP_IR UNIQUE (Maincode, Yearmonth, Provider)
);


/*=================================================================================================
	9. Maternity	
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Maternity] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	Measure VARCHAR(80),
	StaffGroup VARCHAR(200),
	StaffType VARCHAR(100),
	OriginalColumn VARCHAR(200),
	ReferenceSheet VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_Maternity UNIQUE (Maincode, Yearmonth, Provider)
);

/*=================================================================================================
	10. PNA		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PNA] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	Measure VARCHAR(50),
	MeasureDetail VARCHAR(100),
	ReferenceSheet VARCHAR(6),
    CONSTRAINT PK_BSOL_1236_PWR_PNA UNIQUE (Maincode, Yearmonth, Provider)
);

/*=================================================================================================
	11. PMA		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_PMA] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	Measure VARCHAR(50),
	MeasureDetail VARCHAR(100),
	ReferenceSheet VARCHAR(6),
    CONSTRAINT PK_BSOL_1236_PWR_PMA UNIQUE (Maincode, Yearmonth, Provider)
);

/*=================================================================================================
	12. HCSW		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	Measure VARCHAR(80),
	MeasureDetail VARCHAR(200),
	ReferenceSheet VARCHAR(6),
    CONSTRAINT PK_BSOL_1236_PWR_HCSW UNIQUE (Maincode, Yearmonth, Provider)
);

/*=================================================================================================
	13. HCSW Vacancy	
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_HCSW_Vacancy] (
    Maincode VARCHAR(25) NOT NULL,
    Yearmonth VARCHAR(6) NOT NULL,
    Provider VARCHAR(10) NOT NULL,
	Value DECIMAL(18,2),
	Measure VARCHAR(80),
	MeasureDetail VARCHAR(80),
	ReferenceSheet VARCHAR(6),
    CONSTRAINT PK_BSOL_1236_PWR_HCSW_Vacancy UNIQUE (Maincode, Yearmonth, Provider)
);

/*=================================================================================================
	14. Vacancy Rate		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Vacancy_Rate] (
    Provider VARCHAR(20) NOT NULL,
	Yearmonth VARCHAR(6) NOT NULL,
	TotalStaffVacancyWTE DECIMAL(18,2),       -- In Month Overall Staff Vacancies WTE
	TotalSubstantiveStaffWTE DECIMAL(18,2),   -- Total WTE Substantive Staff
	Total DECIMAL(18,2),
	VacancyRate DECIMAL(18,2),
	VacancyType VARCHAR(50),
    CONSTRAINT PK_BSOL_1236_PWR_Vacancy_Rate UNIQUE (Provider, Yearmonth, VacancyType)
);

/*=================================================================================================
	15. Staffing Actual vs Plan		
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Staff_Actual_Plan] (
    Provider VARCHAR(20) NOT NULL,
	Yearmonth VARCHAR(6) NOT NULL,
	Substantive DECIMAL(18,2),       
	[Plan] DECIMAL(18,2),   
	DifferenceWTE DECIMAL(18,2), -- Substantive minus Plan
	PctDifference DECIMAL(18,2), -- Difference relative to Plan (Difference WTE/Plan)
	VacancyRate DECIMAL(18,2),
	VacancyType VARCHAR(50),
    CONSTRAINT PK_BBSOL_1236_PWR_Staff_Actual_Plan UNIQUE (Provider, Yearmonth, VacancyType)
);

/*=================================================================================================
	16. Sickness and Turnover	
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Sickness_Turnover] (
    Provider VARCHAR(10) NOT NULL,
	Yearmonth VARCHAR(6) NOT NULL,
	RateType VARCHAR(50),
	Measure VARCHAR(20),
	Value DECIMAL (18,2),
    CONSTRAINT PK_BSOL_1236_PWR_Sickness_Turnover UNIQUE (Provider, Yearmonth, RateType, Measure)
);

/*=================================================================================================
	17. Main Overview page	
=================================================================================================*/

CREATE TABLE [EAT_Reporting_BSOL].[Development].[BSOL_1236_PWR_Main_Overview] (
    Measure VARCHAR(30),
	StaffGroup VARCHAR(80),
	System VARCHAR(20) NOT NULL,
	Yearmonth VARCHAR(6) NOT NULL,
	Date DATE,
	Value DECIMAL(18,2),
    CONSTRAINT PK_BSOL_1236_PWR_Main_Overview UNIQUE (Yearmonth, System, Measure, StaffGroup)
);

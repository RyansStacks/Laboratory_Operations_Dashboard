USE Laboratory;
GO

------------------------------------------------------------
-- DROP EXISTING WAREHOUSE TABLES (FACTS FIRST)
------------------------------------------------------------
IF OBJECT_ID('wh.fact_lab_event') IS NOT NULL DROP TABLE wh.fact_lab_event;
IF OBJECT_ID('wh.fact_analyzer_qc') IS NOT NULL DROP TABLE wh.fact_analyzer_qc;

IF OBJECT_ID('wh.dim_clinic')      IS NOT NULL DROP TABLE wh.dim_clinic;
IF OBJECT_ID('wh.dim_date')        IS NOT NULL DROP TABLE wh.dim_date;
IF OBJECT_ID('wh.dim_patient')     IS NOT NULL DROP TABLE wh.dim_patient;
IF OBJECT_ID('wh.dim_provider')    IS NOT NULL DROP TABLE wh.dim_provider;
IF OBJECT_ID('wh.dim_specimen')    IS NOT NULL DROP TABLE wh.dim_specimen;
IF OBJECT_ID('wh.dim_test')        IS NOT NULL DROP TABLE wh.dim_test;
GO

------------------------------------------------------------
-- DIM_CLINIC
------------------------------------------------------------
CREATE TABLE wh.dim_clinic (
    ClinicDurableKey     VARCHAR(MAX),
    ClinicName           VARCHAR(MAX),
    Region               VARCHAR(MAX),
    HasUrineCollection   VARCHAR(MAX),
    IsCurrent            VARCHAR(MAX),
    RowEffectiveDate     VARCHAR(MAX),
    RowEndDate           VARCHAR(MAX),
    RowStatus            VARCHAR(MAX)
);
GO

------------------------------------------------------------
-- DIM_DATE
------------------------------------------------------------
CREATE TABLE wh.dim_date (
    DateKey             VARCHAR(MAX),
    Date                VARCHAR(MAX),
    DayOfWeek           VARCHAR(MAX),
    Month               VARCHAR(MAX),
    Quarter             VARCHAR(MAX),
    Year                VARCHAR(MAX),
    IsWeekend           VARCHAR(MAX),
    IsHoliday           VARCHAR(MAX),
    IsCurrent           VARCHAR(MAX),
    RowEffectiveDate    VARCHAR(MAX),
    RowEndDate          VARCHAR(MAX),
    RowStatus           VARCHAR(MAX)
);
GO

------------------------------------------------------------
-- DIM_PATIENT
------------------------------------------------------------
CREATE TABLE wh.dim_patient (
    PatientDurableKey   VARCHAR(MAX),
    PatientName         VARCHAR(MAX),
    Age                 VARCHAR(MAX),
    AgeGroup            VARCHAR(MAX),
    Sex                 VARCHAR(MAX),
    InsuranceType       VARCHAR(MAX),
    IsCurrent           VARCHAR(MAX),
    RowEffectiveDate    VARCHAR(MAX),
    RowEndDate          VARCHAR(MAX),
    RowStatus           VARCHAR(MAX)
);
GO

------------------------------------------------------------
-- DIM_PROVIDER
------------------------------------------------------------
CREATE TABLE wh.dim_provider (
    ProviderDurableKey  VARCHAR(MAX),
    ProviderName        VARCHAR(MAX),
    Specialty           VARCHAR(MAX),
    ProviderGroup       VARCHAR(MAX),
    IsCurrent           VARCHAR(MAX),
    RowEffectiveDate    VARCHAR(MAX),
    RowEndDate          VARCHAR(MAX),
    RowStatus           VARCHAR(MAX)
);
GO

------------------------------------------------------------
-- DIM_SPECIMEN
------------------------------------------------------------
CREATE TABLE wh.dim_specimen (
    SpecimenDurableKey  VARCHAR(MAX),
    SpecimenType        VARCHAR(MAX),
    TubeType            VARCHAR(MAX),
    CollectionMethod    VARCHAR(MAX),
    VolumeML            VARCHAR(MAX),
    IsCurrent           VARCHAR(MAX),
    RowEffectiveDate    VARCHAR(MAX),
    RowEndDate          VARCHAR(MAX),
    RowStatus           VARCHAR(MAX)
);
GO

------------------------------------------------------------
-- DIM_TEST
------------------------------------------------------------
CREATE TABLE wh.dim_test (
    TestDurableKey      VARCHAR(MAX),
    TestName            VARCHAR(MAX),
    TestCategory        VARCHAR(MAX),
    LOINCCode           VARCHAR(MAX),
    ExpectedTATMinutes  VARCHAR(MAX),
    IsCurrent           VARCHAR(MAX),
    RowEffectiveDate    VARCHAR(MAX),
    RowEndDate          VARCHAR(MAX),
    RowStatus           VARCHAR(MAX)
);
GO

------------------------------------------------------------
-- FACT_LAB_EVENT (FIXED — 18 COLUMNS)
------------------------------------------------------------
CREATE TABLE wh.fact_lab_event (
    LabEventKey         VARCHAR(MAX),
    PatientDurableKey   VARCHAR(MAX),
    ProviderDurableKey  VARCHAR(MAX),
    ClinicDurableKey    VARCHAR(MAX),
    TestDurableKey      VARCHAR(MAX),
    SpecimenDurableKey  VARCHAR(MAX),
    DateKey             VARCHAR(MAX),
    OrderDateTime       VARCHAR(MAX),
    CollectionDateTime  VARCHAR(MAX),
    ReceivedDateTime    VARCHAR(MAX),
    ResultedDateTime    VARCHAR(MAX),
    RejectionFlag       VARCHAR(MAX),
    RejectionReason     VARCHAR(MAX),
    RedrawFlag          VARCHAR(MAX),
    MissingFlag         VARCHAR(MAX),
    ResultFlag          VARCHAR(MAX),
    ResultValue         VARCHAR(MAX),
    Status              VARCHAR(MAX)
);
GO

------------------------------------------------------------
-- FACT_ANALYZER_QC
------------------------------------------------------------
CREATE TABLE wh.fact_analyzer_qc (
    QCEventKey          VARCHAR(MAX),
    AnalyzerID          VARCHAR(MAX),
    TestDurableKey      VARCHAR(MAX),
    DateKey             VARCHAR(MAX),
    QCDateTime          VARCHAR(MAX),
    QCStatus            VARCHAR(MAX),
    DowntimeMinutes     VARCHAR(MAX),
    RowStatus           VARCHAR(MAX)
);
GO

-- ===========================
-- STAGING DIMENSIONS
-- ===========================

CREATE TABLE stg.dim_patient (
    PatientDurableKey     VARCHAR(50),
    PatientName           VARCHAR(200),
    Age                   VARCHAR(10),
    AgeGroup              VARCHAR(20),
    Sex                   VARCHAR(10),
    InsuranceType         VARCHAR(50),
    IsCurrent             VARCHAR(10),
    RowEffectiveDate      VARCHAR(50),
    RowEndDate            VARCHAR(50),
    RowStatus             VARCHAR(10)
);

CREATE TABLE stg.dim_provider (
    ProviderDurableKey    VARCHAR(50),
    ProviderName          VARCHAR(200),
    Specialty             VARCHAR(100),
    ProviderGroup         VARCHAR(100),
    IsCurrent             VARCHAR(10),
    RowEffectiveDate      VARCHAR(50),
    RowEndDate            VARCHAR(50),
    RowStatus             VARCHAR(10)
);

CREATE TABLE stg.dim_clinic (
    ClinicDurableKey      VARCHAR(50),
    ClinicName            VARCHAR(200),
    Region                VARCHAR(50),
    HasUrineCollection    VARCHAR(10),
    IsCurrent             VARCHAR(10),
    RowEffectiveDate      VARCHAR(50),
    RowEndDate            VARCHAR(50),
    RowStatus             VARCHAR(10)
);

CREATE TABLE stg.dim_test (
    TestDurableKey        VARCHAR(50),
    TestName              VARCHAR(200),
    TestCategory          VARCHAR(50),
    LOINCCode             VARCHAR(50),
    ExpectedTATMinutes    VARCHAR(10),
    IsCurrent             VARCHAR(10),
    RowEffectiveDate      VARCHAR(50),
    RowEndDate            VARCHAR(50),
    RowStatus             VARCHAR(10)
);

CREATE TABLE stg.dim_specimen (
    SpecimenDurableKey    VARCHAR(50),
    SpecimenType          VARCHAR(50),
    TubeType              VARCHAR(50),
    CollectionMethod      VARCHAR(50),
    VolumeML              VARCHAR(20),
    IsCurrent             VARCHAR(10),
    RowEffectiveDate      VARCHAR(50),
    RowEndDate            VARCHAR(50),
    RowStatus             VARCHAR(10)
);

CREATE TABLE stg.dim_date (
    DateKey               VARCHAR(50),
    Date                  VARCHAR(50),
    DayOfWeek             VARCHAR(10),
    Month                 VARCHAR(10),
    Quarter               VARCHAR(10),
    Year                  VARCHAR(10),
    IsWeekend             VARCHAR(10),
    IsHoliday             VARCHAR(10),
    IsCurrent             VARCHAR(10),
    RowEffectiveDate      VARCHAR(50),
    RowEndDate            VARCHAR(50),
    RowStatus             VARCHAR(10)
);

-- ===========================
-- STAGING FACTS
-- ===========================

CREATE TABLE stg.fact_lab_event (
    LabEventKey           VARCHAR(50),
    PatientDurableKey     VARCHAR(50),
    ProviderDurableKey    VARCHAR(50),
    ClinicDurableKey      VARCHAR(50),
    TestDurableKey        VARCHAR(50),
    SpecimenDurableKey    VARCHAR(50),
    DateKey               VARCHAR(50),
    OrderDateTime         VARCHAR(50),
    CollectionDateTime    VARCHAR(50),
    ReceivedDateTime      VARCHAR(50),
    ResultedDateTime      VARCHAR(50),
    ResultValue           VARCHAR(50),
    ResultFlag            VARCHAR(20),
    RejectionFlag         VARCHAR(10),
    RejectionReason       VARCHAR(100),
    RedrawFlag            VARCHAR(10),
    MissingTestFlag       VARCHAR(10),
    Status                VARCHAR(20),
    RowStatus             VARCHAR(10)
);

CREATE TABLE stg.fact_analyzer_qc (
    QCEventKey            VARCHAR(50),
    AnalyzerID            VARCHAR(50),
    TestDurableKey        VARCHAR(50),
    DateKey               VARCHAR(50),
    QCDateTime            VARCHAR(50),
    QCStatus              VARCHAR(20),
    DowntimeMinutes       VARCHAR(20),
    RowStatus             VARCHAR(10)
);

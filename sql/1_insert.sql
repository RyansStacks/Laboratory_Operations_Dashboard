USE Laboratory;
GO

------------------------------------------------------------
-- TRUNCATE DIMENSIONS FIRST
------------------------------------------------------------
TRUNCATE TABLE stg.dim_clinic;
TRUNCATE TABLE stg.dim_date;
TRUNCATE TABLE stg.dim_patient;
TRUNCATE TABLE stg.dim_provider;
TRUNCATE TABLE stg.dim_specimen;
TRUNCATE TABLE stg.dim_test;

------------------------------------------------------------
-- TRUNCATE FACTS
------------------------------------------------------------
TRUNCATE TABLE stg.fact_analyzer_qc;
TRUNCATE TABLE stg.fact_lab_event;

------------------------------------------------------------
-- DIM_CLINIC
------------------------------------------------------------
BULK INSERT stg.dim_clinic
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\dim_clinic.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

------------------------------------------------------------
-- DIM_DATE
------------------------------------------------------------
BULK INSERT stg.dim_date
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\dim_date.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

------------------------------------------------------------
-- DIM_PATIENT
------------------------------------------------------------
BULK INSERT stg.dim_patient
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\dim_patient.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

------------------------------------------------------------
-- DIM_PROVIDER
------------------------------------------------------------
BULK INSERT stg.dim_provider
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\dim_provider.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

------------------------------------------------------------
-- DIM_SPECIMEN
------------------------------------------------------------
BULK INSERT stg.dim_specimen
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\dim_specimen.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

------------------------------------------------------------
-- DIM_TEST
------------------------------------------------------------
BULK INSERT stg.dim_test
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\dim_test.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

------------------------------------------------------------
-- FACT_ANALYZER_QC
------------------------------------------------------------
BULK INSERT stg.fact_analyzer_qc
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\fact_analyzer_qc.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

------------------------------------------------------------
-- FACT_LAB_EVENT
------------------------------------------------------------
BULK INSERT stg.fact_lab_event
FROM 'C:\Users\bqbpb\OneDrive\Desktop\Lab_Project\data\fact_lab_event.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIELDQUOTE = '"',
    TABLOCK,
    CODEPAGE = '65001'
);

GO

USE Laboratory;
GO

/* ============================================================
   LOAD DIMENSIONS
   ============================================================ */

------------------------------------------------------------
-- DIM_CLINIC
------------------------------------------------------------
TRUNCATE TABLE wh.dim_clinic;

INSERT INTO wh.dim_clinic
SELECT *
FROM stg.dim_clinic;


------------------------------------------------------------
-- DIM_DATE
------------------------------------------------------------
TRUNCATE TABLE wh.dim_date;

INSERT INTO wh.dim_date
SELECT *
FROM stg.dim_date;


------------------------------------------------------------
-- DIM_PATIENT
------------------------------------------------------------
TRUNCATE TABLE wh.dim_patient;

INSERT INTO wh.dim_patient
SELECT *
FROM stg.dim_patient;


------------------------------------------------------------
-- DIM_PROVIDER
------------------------------------------------------------
TRUNCATE TABLE wh.dim_provider;

INSERT INTO wh.dim_provider
SELECT *
FROM stg.dim_provider;


------------------------------------------------------------
-- DIM_SPECIMEN
------------------------------------------------------------
TRUNCATE TABLE wh.dim_specimen;

INSERT INTO wh.dim_specimen
SELECT *
FROM stg.dim_specimen;


------------------------------------------------------------
-- DIM_TEST
------------------------------------------------------------
TRUNCATE TABLE wh.dim_test;

INSERT INTO wh.dim_test
SELECT *
FROM stg.dim_test;



/* ============================================================
   LOAD FACTS
   ============================================================ */

------------------------------------------------------------
-- FACT_LAB_EVENT
------------------------------------------------------------
TRUNCATE TABLE wh.fact_lab_event;

INSERT INTO wh.fact_lab_event
SELECT *
FROM stg.fact_lab_event;


------------------------------------------------------------
-- FACT_ANALYZER_QC
------------------------------------------------------------
TRUNCATE TABLE wh.fact_analyzer_qc;

INSERT INTO wh.fact_analyzer_qc
SELECT *
FROM stg.fact_analyzer_qc;

GO

USE Laboratory;
GO

------------------------------------------------------------
-- SIMPLE ROW COUNTS FOR EACH VIEW
------------------------------------------------------------

SELECT 'vw_SpecimenQuality' AS ViewName,
       COUNT(*) AS TotalRows
FROM vw.vw_SpecimenQuality;
GO

SELECT 'vw_TAT_And_AnalyzerPerformance' AS ViewName,
       COUNT(*) AS TotalRows
FROM vw.vw_TAT_And_AnalyzerPerformance;
GO

SELECT 'vw_ProviderOrderingPatterns' AS ViewName,
       COUNT(*) AS TotalRows
FROM vw.vw_ProviderOrderingPatterns;
GO

------------------------------------------------------------
-- OPTIONAL: SAMPLE 10 ROWS FROM EACH VIEW
------------------------------------------------------------

SELECT TOP 10 * FROM vw.vw_SpecimenQuality;
GO

SELECT TOP 10 * FROM vw.vw_TAT_And_AnalyzerPerformance;
GO

SELECT TOP 10 * FROM vw.vw_ProviderOrderingPatterns;
GO

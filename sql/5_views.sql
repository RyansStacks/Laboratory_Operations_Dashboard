USE Laboratory;
GO

/* ============================================================
   VIEW 1: Specimen Quality & Front-End Workflow
   ============================================================ */
CREATE OR ALTER VIEW vw.vw_SpecimenQuality AS
WITH Base AS (
    SELECT
        fle.LabEventKey,
        fle.TestDurableKey,
        fle.ClinicDurableKey,
        fle.SpecimenDurableKey,
        fle.RejectionFlag,
        fle.RejectionReason,
        fle.RedrawFlag,
        fle.MissingFlag AS MissingTestFlag,
        TRY_CAST(fle.OrderDateTime      AS DATETIME) AS OrderDateTime,
        TRY_CAST(fle.CollectionDateTime AS DATETIME) AS CollectionDateTime,
        TRY_CAST(fle.ReceivedDateTime   AS DATETIME) AS ReceivedDateTime,
        TRY_CAST(fle.ResultedDateTime   AS DATETIME) AS ResultedDateTime,
        DATEDIFF(
            MINUTE,
            TRY_CAST(fle.CollectionDateTime AS DATETIME),
            TRY_CAST(fle.ReceivedDateTime   AS DATETIME)
        ) AS CollectionToAccessionMinutes,
        dd.Year,
        dd.Month,
        dd.DayOfWeek,
        DATEPART(HOUR, TRY_CAST(fle.OrderDateTime AS DATETIME)) AS OrderHour
    FROM wh.fact_lab_event fle
    JOIN wh.dim_date dd
        ON fle.DateKey = dd.DateKey
),

MonthlyRejection AS (
    SELECT
        b.Year,
        b.Month,
        b.ClinicDurableKey,
        b.RejectionReason,
        COUNT(*) AS RejectedCount,
        COUNT(*) * 1.0 / NULLIF(
            COUNT(*) OVER (PARTITION BY b.Year, b.Month, b.ClinicDurableKey),
            0
        ) AS RejectionRate
    FROM Base b
    WHERE b.RejectionFlag = 1
    GROUP BY b.Year, b.Month, b.ClinicDurableKey, b.RejectionReason
),

MissingTests AS (
    SELECT
        b.Year,
        b.Month,
        b.ClinicDurableKey,
        COUNT(*) AS MissingTestCount,
        COUNT(*) * 1.0 / NULLIF(
            COUNT(*) OVER (PARTITION BY b.Year, b.Month, b.ClinicDurableKey),
            0
        ) AS MissingRate
    FROM Base b
    WHERE b.MissingTestFlag = 1
    GROUP BY b.Year, b.Month, b.ClinicDurableKey
),

MissingTestsWithClinic AS (
    SELECT
        m.Year,
        m.Month,
        m.ClinicDurableKey,
        m.MissingTestCount,
        m.MissingRate,
        c.HasUrineCollection
    FROM MissingTests m
    JOIN wh.dim_clinic c
        ON m.ClinicDurableKey = c.ClinicDurableKey
),

PendingQueue AS (
    SELECT
        b.Year,
        b.Month,
        b.DayOfWeek,
        b.OrderHour,
        COUNT(*) AS PendingCount,
        AVG(COUNT(*)) OVER (
            PARTITION BY b.DayOfWeek
            ORDER BY b.OrderHour
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS RollingPendingAvg
    FROM Base b
    WHERE b.CollectionDateTime IS NULL
    GROUP BY b.Year, b.Month, b.DayOfWeek, b.OrderHour
),

RedrawRate AS (
    SELECT
        b.Year,
        b.Month,
        b.TestDurableKey,
        t.TestName,
        COUNT(*) AS RedrawCount,
        COUNT(*) * 1.0 / NULLIF(
            COUNT(*) OVER (PARTITION BY b.Year, b.Month, b.TestDurableKey),
            0
        ) AS RedrawRate
    FROM Base b
    JOIN wh.dim_test t
        ON b.TestDurableKey = t.TestDurableKey
    WHERE b.RedrawFlag = 1
    GROUP BY b.Year, b.Month, b.TestDurableKey, t.TestName
)

SELECT
    b.LabEventKey,
    b.TestDurableKey,
    b.ClinicDurableKey,
    b.SpecimenDurableKey,
    b.RejectionFlag,
    b.RejectionReason,
    b.RedrawFlag,
    b.MissingTestFlag,
    b.OrderDateTime,
    b.CollectionDateTime,
    b.ReceivedDateTime,
    b.ResultedDateTime,
    b.CollectionToAccessionMinutes,
    b.Year,
    b.Month,
    b.DayOfWeek,
    b.OrderHour,
    mr.RejectedCount,
    mr.RejectionRate,
    mt.MissingTestCount,
    mt.MissingRate,
    mt.HasUrineCollection,
    pq.PendingCount,
    pq.RollingPendingAvg,
    rr.RedrawCount,
    rr.RedrawRate,
    rr.TestName
FROM Base b
LEFT JOIN MonthlyRejection mr
    ON b.Year = mr.Year
   AND b.Month = mr.Month
   AND b.ClinicDurableKey = mr.ClinicDurableKey
   AND b.RejectionReason = mr.RejectionReason
LEFT JOIN MissingTestsWithClinic mt
    ON b.Year = mt.Year
   AND b.Month = mt.Month
   AND b.ClinicDurableKey = mt.ClinicDurableKey
LEFT JOIN PendingQueue pq
    ON b.Year = pq.Year
   AND b.Month = pq.Month
   AND b.DayOfWeek = pq.DayOfWeek
   AND b.OrderHour = pq.OrderHour
LEFT JOIN RedrawRate rr
    ON b.Year = rr.Year
   AND b.Month = rr.Month
   AND b.TestDurableKey = rr.TestDurableKey;
GO


/* ============================================================
   VIEW 2: Turnaround Time & Analyzer Performance
   ============================================================ */
CREATE OR ALTER VIEW vw.vw_TAT_And_AnalyzerPerformance AS
WITH Base AS (
    SELECT
        fle.LabEventKey,
        fle.TestDurableKey,
        fle.ClinicDurableKey,
        fle.DateKey,
        TRY_CAST(fle.OrderDateTime      AS DATETIME) AS OrderDateTime,
        TRY_CAST(fle.CollectionDateTime AS DATETIME) AS CollectionDateTime,
        TRY_CAST(fle.ReceivedDateTime   AS DATETIME) AS ReceivedDateTime,
        TRY_CAST(fle.ResultedDateTime   AS DATETIME) AS ResultedDateTime,
        DATEDIFF(MINUTE, TRY_CAST(fle.OrderDateTime AS DATETIME), TRY_CAST(fle.ResultedDateTime AS DATETIME)) AS TotalTATMinutes,
        DATEDIFF(MINUTE, TRY_CAST(fle.OrderDateTime AS DATETIME), TRY_CAST(fle.CollectionDateTime AS DATETIME)) AS OrderToCollectionMinutes,
        DATEDIFF(MINUTE, TRY_CAST(fle.CollectionDateTime AS DATETIME), TRY_CAST(fle.ReceivedDateTime AS DATETIME)) AS CollectionToReceivedMinutes,
        DATEDIFF(MINUTE, TRY_CAST(fle.ReceivedDateTime AS DATETIME), TRY_CAST(fle.ResultedDateTime AS DATETIME)) AS ReceivedToResultedMinutes,
        CASE WHEN fle.ResultedDateTime IS NULL THEN 1 ELSE 0 END AS IsUnresulted,
        dd.Year,
        dd.Month,
        dd.DayOfWeek,
        DATEPART(HOUR, TRY_CAST(fle.OrderDateTime AS DATETIME)) AS OrderHour
    FROM wh.fact_lab_event fle
    JOIN wh.dim_date dd
        ON fle.DateKey = dd.DateKey
),

TATBucketPerTest AS (
    SELECT
        b.LabEventKey,
        CASE
            WHEN b.ResultedDateTime IS NULL THEN 'Unresulted'
            WHEN b.TotalTATMinutes <= 120   THEN '0-2h'
            WHEN b.TotalTATMinutes <= 240   THEN '2-4h'
            WHEN b.TotalTATMinutes <= 480   THEN '4-8h'
            WHEN b.TotalTATMinutes <= 1440  THEN '8-24h'
            ELSE '>24h'
        END AS TATBucket,
        CASE
            WHEN b.ResultedDateTime IS NULL THEN NULL
            WHEN b.TotalTATMinutes <= 120   THEN 0
            WHEN b.TotalTATMinutes <= 240   THEN 120
            WHEN b.TotalTATMinutes <= 480   THEN 240
            WHEN b.TotalTATMinutes <= 1440  THEN 480
            ELSE 1440
        END AS MinTATMinutes,
        CASE
            WHEN b.ResultedDateTime IS NULL THEN NULL
            WHEN b.TotalTATMinutes <= 120   THEN 120
            WHEN b.TotalTATMinutes <= 240   THEN 240
            WHEN b.TotalTATMinutes <= 480   THEN 480
            WHEN b.TotalTATMinutes <= 1440  THEN 1440
            ELSE 999999
        END AS MaxTATMinutes,
        CASE
            WHEN b.ResultedDateTime IS NULL THEN 0
            WHEN b.TotalTATMinutes <= 
                 CASE
                     WHEN b.TotalTATMinutes <= 120  THEN 120
                     WHEN b.TotalTATMinutes <= 240  THEN 240
                     WHEN b.TotalTATMinutes <= 480  THEN 480
                     WHEN b.TotalTATMinutes <= 1440 THEN 1440
                     ELSE 999999
                 END
            THEN 1 ELSE 0
        END AS WithinTAT
    FROM Base b
),

QCTrendAgg AS (
    SELECT
        qa.TestDurableKey,
        qa.DateKey,
        COUNT(*) AS QCEventCount,
        SUM(CASE WHEN qa.QCStatus = 'Fail' THEN 1 ELSE 0 END) AS QCFailCount,
        SUM(TRY_CAST(qa.DowntimeMinutes AS INT)) AS TotalDowntimeMinutes
    FROM wh.fact_analyzer_qc qa
    GROUP BY qa.TestDurableKey, qa.DateKey
),

QCTrendAggWithRolling AS (
    SELECT
        qa.TestDurableKey,
        qa.DateKey,
        qa.QCEventCount,
        qa.QCFailCount,
        qa.TotalDowntimeMinutes,
        AVG(CAST(qa.QCFailCount AS FLOAT)) OVER (
            PARTITION BY qa.TestDurableKey
            ORDER BY qa.DateKey
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS RollingQCFails7Day
    FROM QCTrendAgg qa
),

QCTrendPerTest AS (
    SELECT DISTINCT
        b.LabEventKey,
        qt.QCEventCount,
        qt.QCFailCount,
        qt.TotalDowntimeMinutes,
        qt.RollingQCFails7Day
    FROM Base b
    LEFT JOIN QCTrendAggWithRolling qt
        ON b.TestDurableKey = qt.TestDurableKey
       AND b.DateKey       = qt.DateKey
),

CapacityAgg AS (
    SELECT
        b2.TestDurableKey,
        b2.DateKey,
        b2.OrderHour,
        COUNT(*) AS TestsInHour,
        AVG(CAST(COUNT(*) AS FLOAT)) OVER (
            PARTITION BY b2.TestDurableKey
            ORDER BY b2.DateKey, b2.OrderHour
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS RollingTests3Hour
    FROM Base b2
    GROUP BY b2.TestDurableKey, b2.DateKey, b2.OrderHour
),

CapacityPerTest AS (
    SELECT DISTINCT
        b.LabEventKey,
        cap.TestsInHour,
        cap.RollingTests3Hour
    FROM Base b
    LEFT JOIN CapacityAgg cap
        ON b.TestDurableKey = cap.TestDurableKey
       AND b.DateKey       = cap.DateKey
       AND b.OrderHour     = cap.OrderHour
),

RollingTATPerTest AS (
    SELECT
        b.LabEventKey,
        AVG(CAST(b.TotalTATMinutes AS FLOAT)) OVER (
            PARTITION BY b.TestDurableKey
            ORDER BY b.DateKey
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS RollingAvgTAT7Day
    FROM Base b
)

SELECT
    b.LabEventKey,
    b.TestDurableKey,
    b.ClinicDurableKey,
    b.DateKey,
    b.OrderDateTime,
    b.CollectionDateTime,
    b.ReceivedDateTime,
    b.ResultedDateTime,
    b.TotalTATMinutes,
    b.OrderToCollectionMinutes,
    b.CollectionToReceivedMinutes,
    b.ReceivedToResultedMinutes,
    b.IsUnresulted,
    b.Year,
    b.Month,
    b.DayOfWeek,
    b.OrderHour,
    tat.TATBucket,
    tat.MinTATMinutes,
    tat.MaxTATMinutes,
    tat.WithinTAT,
    qt.QCEventCount,
    qt.QCFailCount,
    qt.TotalDowntimeMinutes,
    qt.RollingQCFails7Day,
    cap.TestsInHour,
    cap.RollingTests3Hour,
    rt.RollingAvgTAT7Day
FROM Base b
LEFT JOIN TATBucketPerTest tat
    ON b.LabEventKey = tat.LabEventKey
LEFT JOIN QCTrendPerTest qt
    ON b.LabEventKey = qt.LabEventKey
LEFT JOIN CapacityPerTest cap
    ON b.LabEventKey = cap.LabEventKey
LEFT JOIN RollingTATPerTest rt
    ON b.LabEventKey = rt.LabEventKey;
GO


/* ============================================================
   VIEW 3: Provider Behavior & Ordering Patterns
   ============================================================ */
CREATE OR ALTER VIEW vw.vw_ProviderOrderingPatterns AS
WITH Base AS (
    SELECT
        fle.LabEventKey,
        fle.ProviderDurableKey,
        fle.PatientDurableKey,
        fle.TestDurableKey,
        fle.DateKey,
        TRY_CAST(fle.OrderDateTime    AS DATETIME) AS OrderDateTime,
        TRY_CAST(fle.ResultedDateTime AS DATETIME) AS ResultedDateTime,
        fle.ResultFlag,
        dd.Year,
        dd.Month,
        dd.DayOfWeek
    FROM wh.fact_lab_event fle
    JOIN wh.dim_date dd
        ON fle.DateKey = dd.DateKey
),

OrdersPerPatient AS (
    SELECT
        ProviderDurableKey,
        PatientDurableKey,
        COUNT(*) AS OrderCount
    FROM Base
    GROUP BY ProviderDurableKey, PatientDurableKey
),

ProviderStats AS (
    SELECT
        ProviderDurableKey,
        AVG(OrderCount) AS AvgOrdersPerPatient,
        STDEV(OrderCount) AS StdDevOrdersPerPatient
    FROM OrdersPerPatient
    GROUP BY ProviderDurableKey
),

ProviderVariation AS (
    SELECT
        opp.ProviderDurableKey,
        opp.PatientDurableKey,
        opp.OrderCount,
        ps.AvgOrdersPerPatient,
        ps.StdDevOrdersPerPatient,
        CASE
            WHEN ps.StdDevOrdersPerPatient IS NULL OR ps.StdDevOrdersPerPatient = 0
                THEN 0
            ELSE (opp.OrderCount - ps.AvgOrdersPerPatient) / ps.StdDevOrdersPerPatient
        END AS OrderingZScore
    FROM OrdersPerPatient opp
    JOIN ProviderStats ps
        ON opp.ProviderDurableKey = ps.ProviderDurableKey
),

TestUtilization AS (
    SELECT
        ProviderDurableKey,
        TestDurableKey,
        COUNT(*) AS TestOrderCount,
        COUNT(DISTINCT PatientDurableKey) AS UniquePatients,
        COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT PatientDurableKey), 0) AS TestsPerPatient
    FROM Base
    GROUP BY ProviderDurableKey, TestDurableKey
),

WeeklyCritical AS (
    SELECT
        ProviderDurableKey,
        DATEPART(YEAR, OrderDateTime) AS Year,
        DATEPART(WEEK, OrderDateTime) AS WeekOfYear,
        COUNT(*) AS CriticalCount
    FROM Base
    WHERE ResultFlag = 'Critical'
    GROUP BY ProviderDurableKey,
             DATEPART(YEAR, OrderDateTime),
             DATEPART(WEEK, OrderDateTime)
),

MonthlyVolumeTAT AS (
    SELECT
        b.Year,
        b.Month,
        COUNT(*) AS TotalOrders,
        AVG(
            DATEDIFF(
                MINUTE,
                b.OrderDateTime,
                b.ResultedDateTime
            )
        ) AS AvgTATMinutes
    FROM Base b
    GROUP BY b.Year, b.Month
),

RollingSeasonality AS (
    SELECT
        Year,
        Month,
        TotalOrders,
        AvgTATMinutes,
        AVG(AvgTATMinutes) OVER (
            ORDER BY Year, Month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS RollingAvgTAT3Month
    FROM MonthlyVolumeTAT
)

SELECT
    b.LabEventKey,
    b.ProviderDurableKey,
    b.PatientDurableKey,
    b.TestDurableKey,
    b.DateKey,
    b.OrderDateTime,
    b.ResultedDateTime,
    b.ResultFlag,
    b.Year,
    b.Month,
    b.DayOfWeek,
    pv.OrderCount,
    pv.AvgOrdersPerPatient,
    pv.StdDevOrdersPerPatient,
    pv.OrderingZScore,
    tu.TestOrderCount,
    tu.UniquePatients,
    tu.TestsPerPatient,
    wc.Year AS CriticalYear,
    wc.WeekOfYear,
    wc.CriticalCount,
    rs.TotalOrders AS MonthlyTotalOrders,
    rs.AvgTATMinutes AS MonthlyAvgTATMinutes,
    rs.RollingAvgTAT3Month
FROM Base b
LEFT JOIN ProviderVariation pv
    ON b.ProviderDurableKey = pv.ProviderDurableKey
   AND b.PatientDurableKey = pv.PatientDurableKey
LEFT JOIN TestUtilization tu
    ON b.ProviderDurableKey = tu.ProviderDurableKey
   AND b.TestDurableKey = tu.TestDurableKey
LEFT JOIN WeeklyCritical wc
    ON b.ProviderDurableKey = wc.ProviderDurableKey
   AND b.Year = wc.Year
   AND DATEPART(WEEK, b.OrderDateTime) = wc.WeekOfYear
LEFT JOIN RollingSeasonality rs
    ON b.Year = rs.Year
   AND b.Month = rs.Month;
GO

import csv
import random
from datetime import datetime, timedelta

# ============================================================
# CONFIGURATION
# ============================================================
NUM_PATIENTS = 1000
NUM_PROVIDERS = 50
NUM_CLINICS = 10
NUM_TESTS = 20
NUM_SPECIMENS = 4
NUM_LAB_EVENTS = 35000

START_DATE = datetime(2024, 1, 1)
END_DATE = datetime(2024, 12, 31)

random.seed(42)

# ============================================================
# HELPERS
# ============================================================
def daterange(start, end):
    for n in range((end - start).days + 1):
        yield start + timedelta(days=n)

def write_sql_optimized_csv(filename, rows):
    if not rows:
        return
    with open(filename, 'w', newline='\n', encoding='utf-8') as f:
        writer = csv.DictWriter(
            f,
            fieldnames=list(rows[0].keys()),
            lineterminator='\n',
            quoting=csv.QUOTE_MINIMAL,
            quotechar='"'
        )
        writer.writeheader()
        writer.writerows(rows)

# ============================================================
# 1. DIM_DATE
# ============================================================
print("Generating dim_date.csv...")
date_rows = []
date_key_map = {}

for d in daterange(START_DATE, END_DATE):
    dk = int(d.strftime("%Y%m%d"))
    date_rows.append({
        'DateKey': str(dk),
        'Date': d.strftime('%Y-%m-%d'),
        'DayOfWeek': d.strftime('%A'),
        'Month': d.strftime('%B'),
        'Quarter': str((d.month - 1) // 3 + 1),
        'Year': str(d.year),
        'IsWeekend': '1' if d.weekday() >= 5 else '0',
        'IsHoliday': '0',
        'IsCurrent': '1',
        'RowEffectiveDate': '2024-01-01',
        'RowEndDate': '9999-12-31',
        'RowStatus': 'Active'
    })
    date_key_map[d.date()] = dk

write_sql_optimized_csv('dim_date.csv', date_rows)

# ============================================================
# 2. DIM_CLINIC
# ============================================================
print("Generating dim_clinic.csv...")
clinic_rows = []

for cid in range(1, NUM_CLINICS + 1):
    clinic_rows.append({
        'ClinicDurableKey': str(cid),
        'ClinicName': f'Clinic Site {cid}',
        'Region': random.choice(['North', 'South', 'East', 'West', 'Central']),
        'HasUrineCollection': random.choice(['0', '1']),
        'IsCurrent': '1',
        'RowEffectiveDate': '2024-01-01',
        'RowEndDate': '9999-12-31',
        'RowStatus': 'Active'
    })

write_sql_optimized_csv('dim_clinic.csv', clinic_rows)

# ============================================================
# 3. DIM_PATIENT
# ============================================================
print("Generating dim_patient.csv...")
patient_rows = []

for pid in range(1, NUM_PATIENTS + 1):
    age = random.randint(1, 90)
    age_group = 'Pediatric' if age < 18 else 'Adult' if age < 65 else 'Geriatric'
    patient_rows.append({
        'PatientDurableKey': str(pid),
        'PatientName': f'Patient {pid}',
        'Age': str(age),
        'AgeGroup': age_group,
        'Sex': random.choice(['M', 'F']),
        'InsuranceType': random.choice(['Commercial', 'Medicare', 'Medicaid', 'Self-Pay']),
        'IsCurrent': '1',
        'RowEffectiveDate': '2024-01-01',
        'RowEndDate': '9999-12-31',
        'RowStatus': 'Active'
    })

write_sql_optimized_csv('dim_patient.csv', patient_rows)

# ============================================================
# 4. DIM_PROVIDER
# ============================================================
print("Generating dim_provider.csv...")
provider_rows = []
specialties = ['Family Medicine', 'Pediatrics', 'Internal Medicine', 'Cardiology']

for pr in range(1, NUM_PROVIDERS + 1):
    provider_rows.append({
        'ProviderDurableKey': str(pr),
        'ProviderName': f'Provider {pr}',
        'Specialty': random.choice(specialties),
        'ProviderGroup': random.choice(['Group A', 'Group B', 'Group C']),
        'IsCurrent': '1',
        'RowEffectiveDate': '2024-01-01',
        'RowEndDate': '9999-12-31',
        'RowStatus': 'Active'
    })

write_sql_optimized_csv('dim_provider.csv', provider_rows)

# ============================================================
# 5. DIM_TEST
# ============================================================
print("Generating dim_test.csv...")
test_names = [
    'Potassium', 'LDL-C', 'HbA1c', 'Vitamin D', 'Lead (Pediatric)',
    'CBC', 'BMP', 'CMP', 'TSH', 'Free T4',
    'Urine Microalbumin', 'Urine Culture', 'CRP', 'ESR', 'Ferritin',
    'Iron', 'B12', 'Folate', 'Glucose', 'Lipase'
]

test_rows = []
for tid in range(1, NUM_TESTS + 1):
    test_rows.append({
        'TestDurableKey': str(tid),
        'TestName': test_names[tid - 1],
        'TestCategory': random.choice(['Chemistry', 'Hematology', 'Immunology', 'Microbiology']),
        'LOINCCode': f'LOINC-{tid:05d}',
        'ExpectedTATMinutes': str(random.choice([45, 60, 90, 120])),
        'IsCurrent': '1',
        'RowEffectiveDate': '2024-01-01',
        'RowEndDate': '9999-12-31',
        'RowStatus': 'Active'
    })

write_sql_optimized_csv('dim_test.csv', test_rows)

# ============================================================
# 6. DIM_SPECIMEN
# ============================================================
print("Generating dim_specimen.csv...")
methods = ['Venipuncture', 'Capillary', 'Urine Cup', 'Swab']

specimen_rows = []
for sid in range(1, NUM_SPECIMENS + 1):
    specimen_rows.append({
        'SpecimenDurableKey': str(sid),
        'SpecimenType': 'Blood' if sid <= 2 else 'Urine',
        'TubeType': 'Red Top' if sid == 1 else 'Lavender',
        'CollectionMethod': methods[sid - 1],
        'VolumeML': '5',
        'IsCurrent': '1',
        'RowEffectiveDate': '2024-01-01',
        'RowEndDate': '9999-12-31',
        'RowStatus': 'Active'
    })

write_sql_optimized_csv('dim_specimen.csv', specimen_rows)

# ============================================================
# 7. FACT_LAB_EVENT
# ============================================================
print("Generating fact_lab_event.csv...")
lab_rows = []

test_order_weights = [
    0.12, 0.05, 0.06, 0.05, 0.08,
    0.03, 0.04, 0.03, 0.03, 0.02,
    0.10, 0.04, 0.04, 0.08, 0.03,
    0.10, 0.02, 0.04, 0.12, 0.02
]

for i in range(1, NUM_LAB_EVENTS + 1):
    day = START_DATE + timedelta(days=random.randint(0, (END_DATE - START_DATE).days))
    date_key = date_key_map[day.date()]

    patient_id = random.randint(1, NUM_PATIENTS)
    provider_id = random.randint(1, NUM_PROVIDERS)
    clinic_id = random.randint(1, NUM_CLINICS)
    test_id = random.choices(range(1, NUM_TESTS + 1), weights=test_order_weights)[0]

    patient_age_group = patient_rows[patient_id - 1]['AgeGroup']

    if test_id in [13, 6]:
        specimen_key = 3
    elif test_id == 5:
        specimen_key = 2
    else:
        specimen_key = 2 if patient_age_group == "Pediatric" and random.random() < 0.60 else 1

    hour = random.randint(7, 15)
    minute = random.randint(10, 59)
    base_time = f"{day.strftime('%Y-%m-%d')} {hour:02d}:{minute:02d}:00"

    lab_rows.append({
        'LabEventKey': str(i),
        'PatientDurableKey': str(patient_id),
        'ProviderDurableKey': str(provider_id),
        'ClinicDurableKey': str(clinic_id),
        'TestDurableKey': str(test_id),
        'SpecimenDurableKey': str(specimen_key),
        'DateKey': str(date_key),
        'OrderDateTime': base_time,
        'CollectionDateTime': base_time,
        'ReceivedDateTime': base_time,
        'ResultedDateTime': base_time,
        'RejectionFlag': '0',
        'RejectionReason': 'None',
        'RedrawFlag': '0',
        'MissingFlag': '0',
        'ResultFlag': 'Normal',
        'ResultValue': f"{random.uniform(3.5, 5.2):.2f}",
        'Status': 'Completed'
    })

write_sql_optimized_csv('fact_lab_event.csv', lab_rows)

# ============================================================
# 8. FACT_ANALYZER_QC
# ============================================================
print("Generating fact_analyzer_qc.csv...")
qc_rows = []
analyzers = ['ANALYZER_CHEM_01', 'ANALYZER_HEMA_02', 'ANALYZER_IMMUNO_03']

qc_key = 1
for day in daterange(START_DATE, END_DATE):
    date_key = date_key_map[day.date()]

    for analyzer in analyzers:
        if "CHEM" in analyzer:
            associated_tests = [1, 2, 3, 11, 14, 15, 16, 19]
        elif "HEMA" in analyzer:
            associated_tests = [9, 19]
        else:
            associated_tests = [4, 7, 10, 12, 17, 18, 20]

        test_id = random.choice(associated_tests)

        qc_rows.append({
            'QCEventKey': str(qc_key),
            'AnalyzerID': analyzer,
            'TestDurableKey': str(test_id),
            'DateKey': str(date_key),
            'QCDateTime': f"{day.strftime('%Y-%m-%d')} {random.randint(6,18):02d}:00:00",
            'QCStatus': random.choice(['Pass', 'Fail']),
            'DowntimeMinutes': f"{random.uniform(0.5, 4.5):.2f}",
            'RowStatus': 'Active'
        })

        qc_key += 1

write_sql_optimized_csv('fact_analyzer_qc.csv', qc_rows)

print("\nProcessing Complete — CSVs match SQL staging tables exactly.")

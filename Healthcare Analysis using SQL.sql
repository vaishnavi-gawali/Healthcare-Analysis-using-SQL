--Demographic Analysis

--What is the demographic profile of the patient population, including age and gender distribution?
-- Pediatric: less than 18 years old
-- Adult: Between 18 to 64 years old
-- Senior: Over 65 years old

WITH demographic AS(
SELECT patient_id, gender,
	   CASE WHEN DATEDIFF(YEAR, date_of_birth, GETDATE())< 18 THEN 'Pediatric'
	        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 18 AND 64 THEN 'Adult'
			ELSE 'Senior' END AS 'age_group'
FROM [Healthcare_Analysis_Database].[dbo].Patients)
SELECT gender, age_group, COUNT(*) AS patient_count
FROM demographic
GROUP BY gender, age_group;


--Which diagnoses are most prevalent among patients and how do they vary across the different demographic groups, including gender and age? 
WITH demographic AS(
SELECT p.patient_id, p.gender, v.diagnosis,
	   CASE WHEN DATEDIFF(YEAR, date_of_birth, GETDATE())< 18 THEN 'Pediatric'
	        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 18 AND 64 THEN 'Adult'
			ELSE 'Senior' END AS 'age_group'
FROM [Healthcare_Analysis_Database].[dbo].Patients p
INNER JOIN [Healthcare_Analysis_Database].[dbo].[Outpatient Visits] v
ON p.patient_id = v.patient_id)
SELECT gender, age_group,COALESCE(diagnosis,'No Diagnosis') AS Diagnosis,  COUNT(*) AS patient_count
FROM demographic
GROUP BY gender, age_group, diagnosis

--What are the most common appointment times throughout the day, and how does the distribution of appointment times vary across different hours?
SELECT DATEPART (HOUR, appointment_time) AS appointment_hour,
	   COUNT(*) AS appointment_count
FROM [Healthcare_Analysis_Database].[dbo].Appointments
GROUP BY DATEPART (hour, appointment_time)
ORDER BY appointment_count DESC


--What are the most commonly ordered lab tests?

SELECT test_name,
       COUNT(*) AS test_count
FROM [Healthcare_Analysis_Database].[dbo].[Lab Results]
GROUP BY test_name
ORDER BY test_count DESC




--Typically, fasting blood sugar levels falls between 70-100 mg/dL. Our goal is to identify patients  whose lab results are outside this normal range to implement early intervention.

SELECT p.patient_id,
	   p.patient_name,
	   l.test_date,
	   l.test_name,
       l.result_value
FROM [Healthcare_Analysis_Database].[dbo].Patients AS p
INNER JOIN [Healthcare_Analysis_Database].[dbo].[Outpatient Visits] AS v
ON p.patient_id = v.patient_id
INNER JOIN [Healthcare_Analysis_Database].[dbo].[Lab Results] AS l
ON v.visit_id = l.visit_id
WHERE l.test_name = 'Fasting Blood Sugar'
AND (l.result_value < 70 OR l.result_value >100)



-- Assess how many patients are considered High, Medium, and Low Risk.

-- High Risk: patients who are smokers and have been diagnosed with either hypertension or diabetes.
-- Medium Risk: patients who are non-smokers and have been diagnosed with either hypertension or diabetes.
--Low Risk: patients who do not fall into the High or Medium Risk categories. This includes patients who are not smokers and do not have a diagnosis of hypertension or diabetes.



WITH patient_risk_category AS(
SELECT patient_id,
       CASE WHEN smoker_status = 'Y' AND diagnosis IN ('Hypertension','Diabetes') THEN 'High Risk'
	        WHEN smoker_status = 'N' AND diagnosis IN ('Hypertension','Diabetes') THEN 'Medium Risk'
		    ELSE 'Low Risk' END AS 'Risk_Category'
FROM [Healthcare_Analysis_Database].[dbo].[Outpatient Visits])
SELECT Risk_Category, COUNT(*) AS patient_count
FROM patient_risk_category
GROUP BY Risk_Category


--Find out information about patients who had multiple visits within 30 days of their previous medical visit

-- Identify those patients
-- Date of initial visit
-- Reason of the initial visit
-- Readmission date
-- Reason for readmission
-- Number of days between the initial visit and readmission
-- Readmission visit recorded must have happened after the initial visit 


	SELECT v1.patient_id, v1.visit_date AS initial_visit, v1.reason_for_visit AS reason_for_initial_visit,
		   v2.visit_date AS readmission_date, v2.reason_for_visit AS reason_for_readmission,
		   DATEDIFF(DAY, v1.visit_date, v2.visit_date) AS days_between_initial_and_readmission
	FROM [Healthcare_Analysis_database].[dbo].[Outpatient Visits] AS v1
	INNER JOIN [Healthcare_Analysis_database].[dbo].[Outpatient Visits] AS v2
	ON v1.patient_id = v2.patient_id
	WHERE DATEDIFF(DAY, v1.visit_date, v2.visit_date) <= 30
	AND v2.visit_date > v1.visit_date



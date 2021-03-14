import streamlit as st
import joblib
from pandas import DataFrame

load_model = joblib.load(filename='logit_model.pkl')
load_model

input_data = {
    'Age': 48,
    'DistanceFromHome': 22,
    'MonthlyIncome': 6500,
    'TotalWorkingYears': 2,
    'TrainingTimesLastYear': 3,
    'YearsAtCompany': 2,
    'YearsInCurrentRole': 1,
    'YearsWithCurrManager': 1,
    'Department': 'Sales',
    'EnvironmentSatisfaction': 'Very High',
    'JobInvolvement': 'High',
    'JobSatisfaction': 'High',
    'JobRole': 'Laboratory Technician',
    'OverTime': 'No',
    'WorkLifeBalance': 'Better'
}

df_input = DataFrame([input_data])

prediction = load_model.predict(df_input)[0]
print(prediction)

prediction_proba = load_model.predict_proba(df_input)[:, 1][0]
print(prediction_proba)

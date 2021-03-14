import streamlit as st
import joblib
from pandas import DataFrame
import pygal

RELATIVE_PATH = 'environment/prod/'

st.sidebar.title('Predicting Attrition Probability')
st.sidebar.header('Required Fields')

age = st.sidebar.slider('Age', 18, 70, 20)
distanceFromHome = st.sidebar.slider('DistanceFromHome', 0.0, 50.0, 0.5)
monthlyIncome = st.sidebar.slider('MonthlyIncome', 1200, 18000, 2500)
totalWorkingYears = st.sidebar.slider('TotalWorkingYears', 0, 35, 2)
trainingTimesLastYear = st.sidebar.slider('TrainingTimesLastYear', 0, 50, 1)
yearsAtCompany = st.sidebar.slider('YearsAtCompany', 0, 30, 1)
yearsInCurrentRole = st.sidebar.slider('YearsInCurrentRole', 0, 30, 1)
yearsWithCurrManager = st.sidebar.slider('YearsWithCurrManager', 0, 10, 1)

department = st.sidebar.selectbox('Department',
                                  ('Research & Development',
                                   'Sales',
                                   'Human Resources')
                                  )

environmentSatisfaction = st.sidebar.selectbox('EnvironmentSatisfaction',
                                               ('Very High',
                                                'High',
                                                'Medium',
                                                'Low'))

jobInvolvement = st.sidebar.selectbox('JobInvolvement',
                                      ('Very High',
                                       'High',
                                       'Medium',
                                       'Low'))

jobSatisfaction = st.sidebar.selectbox('JobSatisfaction',
                                       ('Very High',
                                        'High',
                                        'Medium',
                                        'Low'))

jobRole = st.sidebar.selectbox('JobRole',
                               ('Research Scientist',
                                'Laboratory Technician',
                                'Healthcare Representative',
                                'Manager',
                                'Sales Representative',
                                'Research Director',
                                'Human Resources'))

overTime = st.sidebar.selectbox('OverTime', ('Yes', 'No'))

workLifeBalance = st.sidebar.selectbox('WorkLifeBalance',
                                       ('Better',
                                        'Good',
                                        'Best',
                                        'Bad'))

load_model = joblib.load(RELATIVE_PATH+'logit_model.pkl')

input_data = {
    'Age': age,
    'DistanceFromHome': distanceFromHome,
    'MonthlyIncome': monthlyIncome,
    'TotalWorkingYears': totalWorkingYears,
    'TrainingTimesLastYear': trainingTimesLastYear,
    'YearsAtCompany': yearsAtCompany,
    'YearsInCurrentRole': yearsInCurrentRole,
    'YearsWithCurrManager': yearsWithCurrManager,
    'Department': department,
    'EnvironmentSatisfaction': environmentSatisfaction,
    'JobInvolvement': jobInvolvement,
    'JobSatisfaction': jobSatisfaction,
    'JobRole': jobRole,
    'OverTime': overTime,
    'WorkLifeBalance': workLifeBalance
}

df_input = DataFrame([input_data])

prediction = load_model.predict(df_input)[0]
print(prediction)

prediction_proba = load_model.predict_proba(df_input)[:, 1][0]
print(prediction_proba)

prob_yes = round(prediction_proba, 2)
prob_no = round(1-prediction_proba, 2)

legend_prob_yes = round(100*prob_yes, 2)
legend_prob_no = round(100*prob_no, 2)
prob_yes_chart = round(prob_yes*180, 2)
prob_no_chart = round(prob_no*180, 2)

pie_chart = pygal.Pie(half_pie=True)

pie_chart.title = 'Attrition Probability'

pie_chart.add('P(Yes):'+str(legend_prob_yes)+'%', prob_yes_chart)
pie_chart.add('P(No):'+str(legend_prob_no)+'%', prob_no_chart)

# save
pie_chart.render_to_png(RELATIVE_PATH+'chart_prob_attrition.png')

st.image(RELATIVE_PATH+'chart_prob_attrition.png', output_format='png',
         use_column_width=True, widht=2000,
         caption='P(> 0.5) = Yes')

st.subheader('More Information')

st.write("""
You can access more details about this project,
please visit the [repo on GitHub](https://github.com/ffgama/people_analytics).
""")

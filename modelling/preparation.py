from pandas import read_csv, DataFrame

data_people = read_csv('../eda/data/data_people_filtered.csv')
data_people.info()

# dataset com desbalanceamento de classes
data_people['Attrition'].value_counts(normalize=True)

# temp_data_people = data_people.copy()

# from_to_features = {
#     'Attrition':
#         {
#             'Yes': 1,
#             'No': 0
#         },
#     'Department':
#         {
#             'Research & Development':1,
#             'Sales': 2,
#             'Human Resources': 3
#         },
#     'EnvironmentSatisfaction':
#         {
#             'Low':1,
#             'Medium':2,
#             'High':3,
#             'Very High':4
#         },
#     'JobInvolvement':
#         {
#             'Low':1,
#             'Medium':2,
#             'High':3,
#             'Very High':4
#         },
#     'JobSatisfaction':
#         {
#             'Low':1,
#             'Medium':2,
#             'High':3,
#             'Very High':4
#         },
#     'JobRole':
#         {
#             'Sales Executive':1,
#             'Research Scientist':2,
#             'Laboratory Technician':3,
#             'Manufacturing Director':4,
#             'Healthcare Representative':5,
#             'Manager':6,
#             'Sales Representative':7,
#             'Research Director':8,
#             'Human Resources':9
#         },
#     'OverTime':
#         {
#             'Yes': 1,
#             'No': 2
#         },
#     'WorkLifeBalance':
#         {
#             'Bad':1,
#             'Good':2,
#             'Better':3,
#             'Best':4
#         }
# }

# columns_to_transforming = [
#     'Attrition','Department','EnvironmentSatisfaction',
#     'JobInvolvement','JobSatisfaction','JobRole',
#     'OverTime','WorkLifeBalance']

# for c in columns_to_transforming:
#     data_people[c] = data_people[c].map(from_to_features[c])

data_people.to_csv('../eda/data/data_people_prepared.csv', index_label=False)

from pandas import read_csv
from numpy import linspace, arange
from sklearn.model_selection import StratifiedShuffleSplit, RandomizedSearchCV
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.compose import make_column_transformer
from sklearn.pipeline import make_pipeline
import joblib
from sklearn.metrics import classification_report

data_people = read_csv('../eda/data/data_people_prepared.csv')

data_people['Attrition'] = data_people['Attrition'].map({'No': 0, 'Yes': 1})

X = data_people.drop('Attrition', axis=1)
y = data_people[['Attrition']].values.ravel()

split_definition = StratifiedShuffleSplit(n_splits=1,
                                          test_size=0.3, train_size=0.7,
                                          random_state=42)

for train_index, test_index in split_definition.split(X, y):
    # print("TRAIN:", train_index, "TEST:", test_index)
    X_train, X_test = X.iloc[train_index], X.iloc[test_index]
    y_train, y_test = y[train_index], y[test_index]
    
num_features = ['Age', 'DistanceFromHome', 'MonthlyIncome',
                'TotalWorkingYears', 'TrainingTimesLastYear',
                'YearsAtCompany', 'YearsInCurrentRole',
                'YearsWithCurrManager']

cat_features = ['Department', 'EnvironmentSatisfaction',
                'JobInvolvement', 'JobSatisfaction',
                'JobRole', 'OverTime', 'WorkLifeBalance']

preprocessing = make_column_transformer(
    (StandardScaler(), num_features),
    (OneHotEncoder(), cat_features)
)

pipe = make_pipeline(preprocessing, LogisticRegression())

grid_params = {
    # weights associated the target {class_label: weight}
    'logisticregression__class_weight': (
        [{0: x, 1: 1.0-x} for x in linspace(0.05, 0.95, 20)]
    ),
    # C = 1/lambda. C: regularization parameter and Lambda: penalty
    # controlling.
    'logisticregression__C': arange(5, 80, 5),
    # Max. interacations for the algorithm convergence
    'logisticregression__max_iter': arange(1000, 8000, 200)}

random_grid = RandomizedSearchCV(
    pipe,
    param_distributions=grid_params,
    # maximum number of iterations taken for the solvers to converge.
    n_iter=100,
    # evaluation metric
    scoring='balanced_accuracy',
    random_state=42,
    cv=5,
    verbose=2,
    n_jobs=-1
)

random_search = random_grid.fit(X_train, y_train)

best_params = random_search.best_params_
# best_score = random_search.best_score_
# print('\n=========')
# print("Best Score: {}".format(best_score))
# print("Best parameters : {}".format(best_params))
# print('=========')

pipe = make_pipeline(preprocessing, LogisticRegression(
     class_weight=best_params['logisticregression__class_weight'],
     C=best_params['logisticregression__C'],
     max_iter=best_params['logisticregression__max_iter']
))

model = pipe.fit(X_train, y_train)

# save the model to disk
joblib.dump(model, filename='logit_model.pkl')

y_pred = model.predict(X_test)

print(classification_report(y_test, y_pred))

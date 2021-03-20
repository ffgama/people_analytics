from pandas import read_csv
from numpy import linspace, arange
from sklearn.model_selection import StratifiedShuffleSplit, RandomizedSearchCV
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.compose import make_column_transformer
from sklearn.pipeline import make_pipeline
from sklearn.metrics import (classification_report,
                             precision_recall_curve,
                             plot_precision_recall_curve
                             )
import joblib

# Carregando o dataset apenas com as features que selecionamos
# na etapa exploratoria
data_people = read_csv('../eda/data/data_people_prepared.csv')
data_people.info()

data_people['Attrition'] = data_people['Attrition'].map({'No': 0, 'Yes': 1})

# Preparando os dados antes do split
X = data_people.drop('Attrition', axis=1)
y = data_people[['Attrition']].values.ravel()

# Definicao do criterio de split: a proporcao de desbalanceamento do target
# se mantem
split_definition = StratifiedShuffleSplit(n_splits=1,
                                          test_size=0.3, train_size=0.7,
                                          random_state=42)


# Aplicaco do split de treino e teste
for train_index, test_index in split_definition.split(X, y):
    X_train, X_test = X.iloc[train_index], X.iloc[test_index]
    y_train, y_test = y[train_index], y[test_index]

# features numericas
num_features = ['Age', 'DistanceFromHome', 'MonthlyIncome',
                'TotalWorkingYears', 'TrainingTimesLastYear',
                'YearsAtCompany', 'YearsInCurrentRole',
                'YearsWithCurrManager']
# features categoricas
cat_features = ['Department', 'EnvironmentSatisfaction',
                'JobInvolvement', 'JobSatisfaction',
                'JobRole', 'OverTime', 'WorkLifeBalance']

# Definicao do pipeleline de transformacao
preprocessing = make_column_transformer(
    (StandardScaler(), num_features),
    (OneHotEncoder(), cat_features)
)
# Pipeline do baseline model
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
    'logisticregression__max_iter': arange(1000, 8000, 200)
}

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
print('\n=========')
print("Best parameters : {}".format(random_search.best_params_))

best_params = random_search.best_params_

pipe = make_pipeline(preprocessing, LogisticRegression(
     class_weight=best_params['logisticregression__class_weight'],
     C=best_params['logisticregression__C'],
     max_iter=best_params['logisticregression__max_iter']
))

model = pipe.fit(X_train, y_train)

joblib.dump(model, filename='logit_model.pkl')

y_pred = model.predict(X_test)

# plot_precision_recall_curve(model,X_test,y_test)
print(classification_report(y_test, y_pred))

# extraindo as probabilidades de pertencer a uma classe
y_prob_pred = model.predict_proba(X_test)[:, 1]

data_test = data_people.iloc[X_test.index, ]
data_test['prediction'] = y_pred
data_test['prob_desligamento'] = y_prob_pred

data_test['Attrition'].value_counts()

# salvando nosso dataset
# data_test.to_csv('../eda/data/result_test_data.csv', index=False)

from pandas import read_csv
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import ( 
    classification_report, precision_recall_curve, 
    plot_precision_recall_curve
)
from pandas import get_dummies
from numpy import linspace, arange
from sklearn.model_selection import RandomizedSearchCV

# Carregando o dataset apenas com as features que selecionamos 
# na etapa exploratoria
data_people = read_csv('../eda/data/data_people_prepared.csv')
data_people.info()

data_people['Attrition'] = data_people['Attrition'].map({'No': 0, 'Yes': 1})

obj_columns = data_people.select_dtypes('object')
data_people_enc = get_dummies(data_people, columns=obj_columns.columns)

# Preparando os dados antes do split
X = data_people_enc.drop('Attrition', axis=1)
y = data_people[['Attrition']].values.ravel()

# Padronizando as features 
scaler = StandardScaler()
int_cols = X.select_dtypes('int64').columns
X.loc[:,int_cols] = scaler.fit_transform(X[int_cols])

# Definicao do split de treino: 70/30
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.3, random_state=42)

baseline = LogisticRegression()

random_grid = RandomizedSearchCV(
    baseline,
    param_distributions={
        # weights associated the target {class_label: weight}
        'class_weight': [{0: x, 1: 1.0-x} for x in linspace(0.05, 0.95, 20)],
        # C = 1/lambda. C: regularization parameter and Lambda: penalty controlling.
        'C': arange(5,80,5),
        # Max. interacations for the algorithm convergence
        'max_iter': arange(1000, 8000, 200)
    },
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

model = LogisticRegression(
    **random_search.best_params_
)

model.fit(X_train, y_train)
# Em ambiente de producao salvariamos todos os artefatos 
# necessarios: parametros escolhidos, features, pickle, etc.
# Ex. melhores parametros de tuning: dict_params = {'max_iter': 4000,
#'class_weight': {0: 0.2, 1: 0.8},
# 'C': 80}
    
y_pred = model.predict(X_test)

# plot_precision_recall_curve(model,X_test,y_test)
print(classification_report(y_test, y_pred))

# extraindo as probabilidades de pertencer a uma classe
y_prob_pred = model.predict_proba(X_test)[:,1]

X_test.loc[:,int_cols] = scaler.inverse_transform(X_test.loc[:,int_cols])

data_test = data_people.iloc[X_test.index,]
data_test['prediction'] = y_pred
data_test['prob_desligamento'] = y_prob_pred

# 61 colaboradores pediram desligamentos
data_test['Attrition'].value_counts()

# salvando nosso dataset
# data_test.to_csv('../eda/data/result_test_data.csv', index=False)
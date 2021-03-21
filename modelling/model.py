from pandas import read_csv, DataFrame
from numpy import linspace, arange
from sklearn.linear_model import LogisticRegression
from utils.general_functions import *
from choose_train_test_split import *
from pre_processing import *
from tuning_params import *
from train import *
from evaluation import *

FULL_PATH = '../eda/data/data_people_prepared.csv'

# Carregando o dataset apenas com as features que selecionamos
# na etapa exploratoria
data_people = open_data(FULL_PATH)

# Definicao do criterio de split: a proporcao de desbalanceamento do target
# se mantem
X_train, y_train, X_test, y_test = get_data_train_test(
    data_people, 'Attrition',
    test_size=0.3, random_state=42)

num_f = ['Age', 'DistanceFromHome', 'MonthlyIncome',
         'TotalWorkingYears', 'TrainingTimesLastYear',
         'YearsAtCompany', 'YearsInCurrentRole',
         'YearsWithCurrManager']
cat_f = ['Department', 'EnvironmentSatisfaction',
         'JobInvolvement', 'JobSatisfaction',
         'JobRole', 'OverTime', 'WorkLifeBalance']

preprocessing = pre_processing_data(num_features=num_f, cat_features=cat_f)

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

best_params = get_best_parameters(pipe, X_train, y_train, grid_params)

model = train_model(preprocessing, LogisticRegression(
    class_weight=best_params['logisticregression__class_weight'],
    C=best_params['logisticregression__C'],
    max_iter=best_params['logisticregression__max_iter']),
    X_train, y_train)

# obtendo a performance do nosso modelo
get_model_performance(model, X_test, y_test)

# salvando nosso dataset
save_full_dataset(model, data_people, X_test)

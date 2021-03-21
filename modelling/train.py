from sklearn.pipeline import make_pipeline
import joblib
from pandas import DataFrame
from numpy import array
from typing import Dict


def train_model(pre_processing, model, X_train: DataFrame, y_train: array):
    """Building and dump of the model

    Args:
        pre_processing ([Pipeline]): pipeline pre-processing step
        model ([Model]): passing the machine learning model to fit
        X_train ([type]): training data (features)
        y_train ([type]): training data (target)
        model_name ([str]): pickle name
    Returns:
        [Model]: trained model
    """
    pipe = make_pipeline(pre_processing,
                         model)
    model = pipe.fit(X_train, y_train)

    joblib.dump(model, filename='logit_model'+'.pkl')
    return model

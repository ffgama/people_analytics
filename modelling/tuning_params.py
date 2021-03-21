from sklearn.model_selection import RandomizedSearchCV
from typing import Dict
from pandas import DataFrame


def get_best_parameters(pipe, X_train: DataFrame,
                        y_train, grid_params: Dict) -> Dict:
    """As from the data training, search and evaluate to find the best \
        training parameters for the model.

    Args:
        pipe (Pipeline): pipeline containing all applied transformations
        X_train ([type]): training data (features)
        y_train ([type]): training data (target)

    Returns:
        [dict]: dictionary with best parameters for the model
    """
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
    return random_search.best_params_

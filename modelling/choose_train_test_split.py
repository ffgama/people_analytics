from pandas import read_csv, DataFrame
from sklearn.model_selection import StratifiedShuffleSplit


def get_data_train_test(dataset: DataFrame,
                        target_col: str, test_size: float,
                        random_state: int) -> DataFrame:
    """Split the data into train and test dataset keeping the proportions\
        of the target variable.

    Returns:
        [type]: a list containing all datasets that has been splitted
    """
    X = dataset.drop(target_col, axis=1)
    y = dataset[[target_col]].values.ravel()
    split_definition = StratifiedShuffleSplit(n_splits=1,
                                              test_size=0.3,
                                              random_state=random_state)
    for train_index, test_index in split_definition.split(X, y):
        X_train, X_test = X.iloc[train_index], X.iloc[test_index]
        y_train, y_test = y[train_index], y[test_index]
    print('- Shape do treino: {}'.format(X_train.shape))
    print('- Shape do teste: {}'.format(X_test.shape))
    return [X_train, y_train, X_test, y_test]

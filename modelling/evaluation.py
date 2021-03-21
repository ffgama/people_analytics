from pandas import DataFrame
from sklearn.metrics import classification_report
from numpy import array


def get_model_performance(model,
                          X_test: DataFrame, y_test: array) -> DataFrame:
    """Report the model results

    Args:
        model ([Model]): Trained model
        X_test (DataFrame): dataframe with testing data
    Returns:
        [DataFrame]: dataframe with the results
    """
    y_pred = model.predict(X_test)
    dict_results = classification_report(y_test, y_pred, output_dict=True)
    results_df = DataFrame(dict_results)
    rename_cols = {'0': 'No (Attrition)', '1': 'Yes (Attrition)'}
    results_df = results_df.rename(columns=rename_cols)
    return results_df


def save_full_dataset(model, dataset: DataFrame, X_test: DataFrame):
    y_binary_pred = model.predict(X_test)
    y_prob_pred = model.predict_proba(X_test)[:, 1]

    data_test = dataset.iloc[X_test.index, ]
    data_test.loc[:, 'binary_prediction'] = y_binary_pred
    data_test.loc[:, 'prob_prediction'] = y_prob_pred
    data_test.to_csv('../eda/data/1.csv', index=False)

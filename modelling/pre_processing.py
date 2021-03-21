from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.compose import make_column_transformer
from sklearn.pipeline import make_pipeline
from typing import List


def pre_processing_data(num_features: List,
                        cat_features: List):
    """Apply a set of transformations to the dataset.

    Args:
        num_features (List): pass a set of numeric columns
        cat_features (List): pass a set of categorical columns

    Returns:
        [ColumnTransformer]: set of definitions applied to the columns
    """
    column_transf = make_column_transformer(
        (StandardScaler(), num_features),
        (OneHotEncoder(), cat_features)
    )
    return column_transf

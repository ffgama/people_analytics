from pandas import read_csv, DataFrame
from typing import Dict


def open_data(path: str, separator=',') -> DataFrame:
    """Extract data from csv file

    Args:
        path (str): full path where file is
        separator (str, optional): [description]. Defaults to ','.

    Returns:
        DataFrame: dataset that has been extracted
    """
    dataset = read_csv(path, sep=separator)
    return dataset


def apply_target_transf(dataset: DataFrame,
                        target_name: str,
                        dict_cat: Dict[str, int]) -> DataFrame:
    """Convert categorical target to binary.

    Args:
        dataset (DataFrame): dataset whose transformation that will applied
        target_name (str): column name
        dict_cat (Dict[str, int]): dictionary that contains \
        {key (old value): value: (new value)}

    Returns:
        DataFrame: dataset with target variable transformed
    """
    dataset[target_name] = dataset[target_name].map(dict_cat)
    return dataset

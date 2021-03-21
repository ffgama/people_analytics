from pandas import read_csv, DataFrame, IndexSlice
from sklearn.metrics import (
    recall_score, precision_score,
    roc_auc_score, classification_report,
    confusion_matrix, plot_confusion_matrix
)
from sklearn.calibration import calibration_curve
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

data_test = read_csv('../eda/data/result_test_data.csv')

roc = round(roc_auc_score(data_test['Attrition'],
                          data_test['prediction']), 2)
recall = round(recall_score(data_test['Attrition'],
                            data_test['prediction']), 2)
precision = round(precision_score(data_test['Attrition'],
                                  data_test['prediction']), 2)

print('ROC:', roc)
# TP / (TP+FN)
print('Recall:', recall)
# TP / (TN+TP)
print('Precision:', precision)

# Confusion Matrix
cm = confusion_matrix(data_test['Attrition'],
                      data_test['prediction'],
                      labels=[0, 1])
cm

ax = plt.subplot()
sns.heatmap(cm, annot=True, ax=ax, fmt='g', cmap='Blues')

# Acertos do nosso modelo
# TP -> modelo previu que o colaborador se desligaria e ele de fato
# se desligou (43)
# TN -> modelo previu corretamente que o
# colaborador nao se desligaria e ele de fato nao se desligou (307)

# Erros do nosso modelo
# FP -> modelo previu que o colaborador se desligaria mas ele
# nao se desligou (73)
# FN -> modelo previu que o colaborador nao se desligaria
# mas na verdade ele se desligou (18)

df_res = DataFrame(
    classification_report(
        data_test['Attrition'],
        data_test['prediction'],
        output_dict=True)
    ).T

df_res.style.background_gradient(cmap='viridis',
                                 subset=IndexSlice['0':'1', :'f1-score'])

# TRADE-OFF (Recall e Precision)

# Cenario de alta probabilidade ou simplesmente (>0.5) de desligamento
# Aumento dos falsos positivos: aumento da probabilidade do modelo da certeza
# do modelo de que o colaborador ira se desligar embora uma boa parte deles
# nao se desligue.

# O efeito de um recall muito alto tem como consequencia de que o RH ao
# observar uma alta probabilidade de attrition, tera que propor
# acoes para grande parte de colaboradores
# que na verdade estao relativamente satisfeitos em permanecer na empresa.
data_test.query('prob_desligamento > 0.5')['Attrition'].value_counts()


# Scores de probabilidade
# A distribuicao dos scores de probabilidade aponta que nosso modelo
# tem feito um bom papel em discriminar essas classes. Mas ainda existe
# um overlapping perceptivel nas distribuicoes
query_template_not_attrition = (
    data_test.query('Attrition==0')['prob_desligamento'].values
)
query_template_attrition = (
    data_test.query('Attrition==1')['prob_desligamento'].values
)

sns.distplot(query_template_not_attrition,
             label='Not attrition', color='blue', hist=False)
sns.distplot(query_template_attrition,
             label='Attrition', color='red', hist=False)
plt.title('Distribuicao dos scores de probabilidade entre as classes',
          fontsize=13)
plt.legend(loc='upper right', fontsize='12')

# Conclusao em relacao a modelagem

# Apesar do modelo ter apresentado bom desempenho no recall, ainda
# existem algumas oportunidades de melhoria.

# Ainda assim, nesse momento estamos em um step de validacao junto
# ao usuario de negocio.
# Poderiamos decidir usar o modelo (ainda que em um ambiente de teste)
# para validacao.
# Que crenca temos?
# Se validassemos pelo uso do modelo com os dados de teste,
# qual o impacto que isso traria para o negocio?

# Impacto financeiro: colocando isso na balanca

# E evidente de que um desligamento do colaborador tende a trazer como
# consequencia outros problemas para a empresa tais como:
# gerenciar o clima do time, descontinuacao de trabalho,
# abertura de novo processo seletivo e assim por diante.

# Mas tambem uma forma de olharmos para o problema seria mensurando o impacto
# financeiro.

# Ambiente ficticio
# Sentamos com o RH e financeiro e identificamos que os custos
# de desligamento de um colaborador para a empresa
# pode ser calculado a partir da formula:
# salario anual * 100%, chamaremos de IIF (Indicador de impacto financeiro)
data_test['IIF_score'] = data_test['MonthlyIncome']*12*100/100

# contabilizando os custos
data_test['IIF_score'].sum().astype(int)
# Ou seja todos pedissem demissao o prejuizo total seria de mais de 35 milhoes!

# custos com desligamentos dos 61 colaboradores
# 3,8 milhoes
data_test.query('Attrition==1')['IIF_score'].sum()

# probabilidade acima > 0.5: precisamos direcionar acoes para engajar
# o colaborador
data_test.groupby(['Attrition', 'prediction'])['IIF_score'].mean().round(2)

# Se prestarmos toda acao necessaria para cada colaborador que tenha
# probabilidade acima de 50% de attrition entao poderiamos
# economizar ate 2,2 milhoes!

# Temos um total de 116 colaboradores nesse bolo (em torno de 26% do total)
data_test.query('prob_desligamento > 0.5').shape
data_test.query('prob_desligamento > 0.5 and Attrition==1')['IIF_score'].sum()

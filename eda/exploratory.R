rm(list=ls())

# imports
load(file = "eda/data/transf_people_data.RData")

source("eda/utils/general_functions.R")
source("eda/utils/general_plots.R")

# pkgs
pkgs = c("ggplot2","highcharter","dplyr","forcats","knitr","Hmisc","corrplot")
lapply(pkgs, function(pkg){ require(pkg, character.only = TRUE)})

# Attrition (target): medida que quantifica o desgaste de um funcionario na empresa, como consequencia pode aumentar as chances de se desligar da empresa.
# Alguns impactos para o negocio: 
# 1. Elevados custos com desligamentos
# 2. Comprometimento no clima e nas entregas do time
# 3. Processo de contratacao de novos colaboradores 

# Questionamentos iniciais: 
# 1) que fatores contribuem para o attrition?
# 2) com base nos dados que temos, sera que poderemos criar uma solucao preditiva para ajudar o time de RH a antecipar esses problemas e 
# propor iniciativas para minimizar o attrition?

# 1) Para responder o primeiro vamos seguir alguns passos: 
# a) Analise exploratoria para termos um overview das features do nosso dataset
# b) Estatisticas infereciais para compreender melhor o impacto dessas features no attrition

# 2) Os insights na primeira estapa servirao de apoio para modelagem preditiva. O que espero nessa etapa basicamente seria: 
# a) com base no historico da empresa quais sao as chances de um funcionario sair da empresa?

# Analise de dados
people_data = people_data_transf

features_description = list(
  "Age" = "Idade do colaborador",
  "Attrition" =  "Colaborador se desligou (SIM/NAO)",
  "BusinessTravel" = "Com que frequencia o colaborador tem viajado pela empresa?",
  "DailyRate" = "Taxa/dia salarial",
  "Department" = "Area do negocio",
  "DistanceFromHome" = "Distancia percorrida do trabalho para a casa",
  "Education" = "ID de educacao 1 a 5",
  "EducationField" = "Campo de educacional",
  "EmployeeCount" = "Constante com o total de colaboradores (1 por registro)",
  "EmployeeNumber" = "Id do colaborador",
  "EnvironmentSatisfaction" = "Satisfacao organizacional",
  "Gender" = "Genero",
  "HourlyRate" = "Taxa/hora salarial",
  "JobInvolvement" = "Envolvimento com o cargo",
  "JobLevel" = "Nivel do cargo (1 a 5)",
  "JobRole" = "Cargo",
  "JobSatisfaction" = "Satisfacao com o cargo",
  "MaritalStatus" = "Estado civil",
  "MonthlyIncome" = "Salario Mensal",
  "MonthlyRate" = "Taxa/mensal salarial",
  "NumCompaniesWorked" = "Numero de empresas que o colaborador ja trabalhou",
  "Over18" = "Acima de 18 anos?",
  "OverTime" = "Colaborador ja fez hora extra?",
  "PercentSalaryHike" = "Percentual de aumento de salario",
  "PerformanceRating" = "Taxa de performance (3 ou 4)",
  "RelationshipSatisfaction" = "Satisfacao com relacionamento",
  "StandardHours" = "Carga horaria (fixo 80hs)",
  "StockOptionLevel" = "Bonus",
  "TotalWorkingYears" = "Anos de experiencia profissional",
  "TrainingTimesLastYear" = "Horas gastas em treinamentos (ultimo ano)",
  "WorkLifeBalance" = "Horas de equilibro na vida profissional",
  "YearsAtCompany" = "Anos de empresa",
  "YearsInCurrentRole" = "Anos no cargo atual",
  "YearsSinceLastPromotion" = "Total (em  anos) desde a ultima promocao",
  "YearsWithCurrManager" = "Anos gastos com atual gerente"
)

# Temos um total de 35 colunas incluindo o target. Por isso atender o escopo da nossa analise, vamos filtrar algumas features.
people_data = people_data %>% 
  select(Age, BusinessTravel, Department, DistanceFromHome, Education, EducationField, EnvironmentSatisfaction,Gender, JobInvolvement, JobSatisfaction,
         PerformanceRating, JobLevel, JobRole, MaritalStatus, MonthlyIncome, NumCompaniesWorked, OverTime, PercentSalaryHike, RelationshipSatisfaction,
         StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear, WorkLifeBalance, YearsAtCompany, YearsInCurrentRole, YearsSinceLastPromotion,
         YearsWithCurrManager,
         Attrition) 

write.csv(people_data, file = "eda/data/data_people_full.csv", row.names = FALSE)

# ANALISE 
View(people_data)

# total de 1470 colaboradores
people_data %>% nrow()

# overview da distribuicao (variaveis numericas)
people_data %>%
  select_if(funs(!is.character(.))) %>%
  summary()

# 16% dos colaboradores sairam da empresa
people_data %>% 
  count(Attrition) %>%
  mutate(prop = round(n/sum(n),2)) %>% 
  arrange(prop) %>%
  kable(col.names = c("Desligamento","Total","Proporcao"))

# Podemos avaliar esses casos observando outras features do dataset

# Idade
# Em media o Attrition tem acontecido em colaboradores mais mais jovens. Mas a diferenca entre as medias eh bem sutil
people_data %>%
  plot_box_compare_groups(feature_num = "Age", 
                        feature_cat = "Attrition", 
                        title="Distribuicao das idades em relacao ao Attrition", 
                        xlab= "Desligamento?",
                        ylab = "Idade dos colaboradores")


# Antes da decisao de qual teste aplicar precisamos validar a hipotese de normalidade da distribuicao. 
# Vamos assumir como referencia um nivel de significancia de 5%
# H0: os dados sao normalmente distribuidos
# H1: os dados nao sao normalmente distribuidos
shapiro.test(people_data$Age)

# Podemos relizar um teste estatistico para identifcar se existe alguma diferenca estatistica entre as medias.
# H0: diferencas entre as medias = 0 
# H1: diferencas entre as medias != 0 

# O resultado do teste traz evidencias de nao normalidade na nossa distribuicao. Dessa forma um caminho adequado seria aplicar um teste nao-parametrico
# para identificar se existe alguma diferenca significativa entre as medias. 
# Os jovens tendem a se desligar mais das empresas, um fator que talvez possa ser considerado seria a dinamica do mercado.
run_ttest_sample(people_data, formula = Age ~ Attrition)


# Distancia do trabalho para casa
people_data %>%
  plot_box_compare_groups(feature_num = "DistanceFromHome", 
                          feature_cat = "Attrition", 
                          title="Distribuicao das distancias em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Distancia do trabalho para casa")

# Podemos tomar essa feature como importante porque o resultado do teste nos indica uma diferenca significativa entre as medias. 
# Nota-se que dos colaboradores que se desligaram normalmente moram mais longe do local de trabalho.
run_ttest_sample(people_data, formula = DistanceFromHome ~ Attrition)

# Salario mensal
people_data %>%
  plot_box_compare_groups(feature_num = "MonthlyIncome", 
                          feature_cat = "Attrition", 
                          title="Distribuicao dos salarios mensais dos colaboradores em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Salarios mensais")

run_ttest_sample(people_data, formula = MonthlyIncome ~ Attrition)
# É evidente de que colaboradores com salarios menores tem uma taxa maior de Attrition, talvez por conta do cargo ou falta de reconhecimento,
# planejamento de carreira adequados e afins.

# Total de empresas
people_data %>%
  plot_box_compare_groups(feature_num = "NumCompaniesWorked", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do historico do total de empresas que o colaborador trabalhou em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Total de empresas")

run_ttest_sample(people_data, formula = NumCompaniesWorked ~ Attrition)
# De fato, pelos resultados que tivemos claramente essa variavel é um componenente irrelevante para o Attrition.

# Percentual de aumento de salarios
people_data %>%
  plot_box_compare_groups(feature_num = "PercentSalaryHike", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do percentual de aumentos dos colaboradores em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Percentual de aumento")

run_ttest_sample(people_data, formula = PercentSalaryHike ~ Attrition)
# Nao ha diferenca significativa no Attrition entre colacoradores que tiveram um percentual maior de aumento e aqueles que tiveram um aumento mais 
# mais modesto

# Tempo de experiencia
people_data %>%
  plot_box_compare_groups(feature_num = "TotalWorkingYears", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do tempo de experiencia dos colaboradores em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Tempo de experiencia")

run_ttest_sample(people_data, formula = TotalWorkingYears ~ Attrition)
# Nao é de se surpreender que colaboradores com maior tempo de experiencia tendem a procurar estabilidade dentro da empresa. A feature idade
# que vimos acima tambem pode nos ajudar a entender porque colaboradores com menor tempo de experiencia tendem a trazer um impacto no Attrition.

# Tempo dedicado a treinamentos no ultimo ano
people_data %>%
  plot_box_compare_groups(feature_num = "TrainingTimesLastYear", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do tempo de treinamento em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Tempo de treinamento")

run_ttest_sample(people_data, formula = TrainingTimesLastYear ~ Attrition)
# As horas gastas de treinamento no ano anterior tambem impactam no Attrition.

# Tempo de empresa
people_data %>%
  plot_box_compare_groups(feature_num = "YearsAtCompany", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do tempo de casa dos colaboradores em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Anos de empresa")

run_ttest_sample(people_data, formula = YearsAtCompany ~ Attrition)
# Uma outra feature importante é o tempo de casa. Colaboradores que possuem menos tempo de empresa contribuem tem maiores chances de desgaste. 
# Talvez a resiliencia seja um fator que explique esse cenario.

# Anos de cargo
people_data %>%
  plot_box_compare_groups(feature_num = "YearsInCurrentRole", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do tempo de cargo colaboradores em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Anos de cargo")

run_ttest_sample(people_data, formula = YearsInCurrentRole ~ Attrition)
# Colaboradores com pouco tempo de cargo tambem trazem impacto ao Attrition. A falta de adaptacao/experiencia poderia ser um fator importante
# para aumentar as chances de desligamento.

# Anos desde a ultima promocao
people_data %>%
  plot_box_compare_groups(feature_num = "YearsSinceLastPromotion", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do tempo desde a ultima promocao em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Anos desde a ultima promocao")

run_ttest_sample(people_data, formula = YearsSinceLastPromotion ~ Attrition)
# O fato de ter sido promovido recentemente ou nao, parece nao interfeir no Attrition, podemos descartar essa feature.


# Experiencia com o atual Manager
people_data %>%
  plot_box_compare_groups(feature_num = "YearsWithCurrManager", 
                          feature_cat = "Attrition", 
                          title="Distribuicao do tempo de experiencia na funcao em relacao ao Attrition", 
                          xlab= "Desligamento?",
                          ylab = "Anos")

run_ttest_sample(people_data, formula = YearsWithCurrManager ~ Attrition)
# A adaptacao a lideranca e um fator que aumenta as chances de permanencia na empresa.

# Dentre essas variaveis, vamos buscar a correlacao as features
numeric_cols = c("Age","DistanceFromHome","MonthlyIncome","TotalWorkingYears",
                 "TrainingTimesLastYear","YearsAtCompany","YearsInCurrentRole","YearsWithCurrManager","Attrition")

data_corr_num = people_data %>%
  select(numeric_cols) %>%
  mutate(Attrition = if_else(Attrition == "Yes", 1, 0))

result = rcorr(as.matrix(data_corr_num), type="pearson")

# A matriz de correlacao traz alguns insights interessantes:
# 1. Temos indicativo de multicolinearidade entre as features: YearsInCurrentRole e YearsAtCompany.
# 2. Nenhuma das features em questao possuem uma forte relacao linear com a Attriton.
# 3. Maioria das features possuem correlacao linear negativa com Arttritom o que reforca nossas descobertas anteriores.
corrplot(result$r, 
         type="upper",
         order="hclust", 
         p.mat = result$P, 
         sig.level = 0.05, 
         insig = "blank")

# Vamos continuar nosso estudo agora varrendo outras features categoricas....

# Viagens pela empresa
people_data %>%
  group_by(BusinessTravel, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "BusinessTravel", y_axis = "n", 
                             title = "Quão frequentemente o colaborador viaja pela empresa?",
                             xlab = "", ylab = "Total de colaboradores",
                            group_name = "Attrition")

# Aqui nao conseguimos identificar algum padrao que pudesse indicar algum peso no Attrition, isto porque independente da frequencia de 
# viagens o numero de Attrition permaneceu estavel.

# Area de negocio
people_data %>%
  group_by(Department, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "Department", y_axis = "n", 
                             title = "Avaliando o numero de casos por area de negocio",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Quanto a area de negocio conseguimos encontrar um insight interessante: a area de venda apesar de ter um numero menor de 
# colaboradores alocados, apresenta um alto indice de Attrition semelhante a area de pesquisa e desenvolvimento 
# que possui mais que o dobro de colaboradores. Por isso, vamos recrutar essa feature para as etapas seguintes.

# Educacao: escolaridade
people_data %>%
  group_by(Education, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "Education", y_axis = "n", 
                             title = "Avaliando o numero de colaboradores por escolaridade",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# A empresa possui menos colaboradores doutores e o attrition é baixo. Por outro lado, a maioria dos colaboradores possuem bacharel e, nesse grupo, 
# o Attrition é maior. O padrao se repete para outros categorias o que indica que essa variavel isoladamente pode nao ser discriminativa. 
# Por isso, nesse primeiro momento nao pretendemos mante-la.

# Campo educacional
people_data %>%
  group_by(EducationField, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "EducationField", y_axis = "n", 
                             title = "Avaliando o numero de casos por campo educacional",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Tal como no caso da escolaridade, o campo educacional revelou-se nao ser uma feature em potencial tambem.

# Satisfacao organizacional
people_data %>%
  group_by(EnvironmentSatisfaction, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "EnvironmentSatisfaction", y_axis = "n", 
                             title = "Avaliando a satisfacao dos colaboradores",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Tudo ja indicava pelo potencial dessa feature e isso ficou comprovado atraves do grafico. A conclusao que podemos obter é que, proporcionalmente,
# colaboradores insatisfeitos tem maiores chances de pedirem desligamento.

# Genero
people_data %>%
  group_by(Gender, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "Gender", y_axis = "n", 
                             title = "Checando colaboradores pelo genero",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Esta parece ser uma feature que de fato, é meramente descritiva. Vamos seguir.

# Envolvimento com o cargo
people_data %>%
  group_by(JobInvolvement, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "JobInvolvement", y_axis = "n", 
                             title = "Checando o envolvimento dos colaboradores em relacao aos cargos",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Nota-se claramente que colaboradores com baixo envolvimento tem altas chances de pedirem desligamentos. Historicamente, 
# pelo menos metade dos colaboradores pediram desligamentos quando foram classificados com baixo nivel de envolvimento. 

# Satisfacao com o cargo
people_data %>%
  group_by(JobSatisfaction, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "JobSatisfaction", y_axis = "n", 
                             title = "Listando o total de colaboradores satisfeitos com seus cargos",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# A satisfacao com o cargo tambem é uma feature relevante, isto porque apesar da categoria de colaboradores insatisfeitos com o cargo ser menor o 
# o volume de colaboradores que se desligaram da empresa foi o segundo maior e, pensando em termos proporcionais esse grupo de colaboradores
# tiveram maior influencia no Attrition.

# Desempenho
people_data %>%
  group_by(PerformanceRating, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "PerformanceRating", y_axis = "n", 
                             title = "Quanto ao desempenho dos colaboradores",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Nao parece ser uma feature em potencial. Proporcionalmente ambos os grupos tem os mesmos impactos no Attrition.


# Cargo
people_data %>%
  group_by(JobRole, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "JobRole", y_axis = "n", 
                             title = "Quanto ao cargo dos colaboradores",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Dentre todos os cargos, representante de vendas tem um impacto significativo no Attrition. Essa feature combinada com outras features, pode 
# ser util.

# A satisfacao com o cargo tambem é uma feature relevante, isto porque apesar da categoria de colaboradores insatisfeitos com o cargo ser menor o 
# o volume de colaboradores que se desligaram da empresa foi o segundo maior e, pensando em termos proporcionais esse grupo de colaboradores
# tiveram maior influencia no Attrition.

# Estado civil
people_data %>%
  group_by(MaritalStatus, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "MaritalStatus", y_axis = "n", 
                             title = "Quanto ao estado civil dos colaboradores",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Aqui temos um ponto interessante. Colaboradores solteiros tendem trazer um impacto maior para o Attrition. Uma explicacao razoavel poderia ser, 
# que normalmente sao colaboradores mais jovens que tem uma liberdade maior para arriscar e buscar novos desafios na carreira.
# Ao incluir a idade media identificamos que, de fato, sao colaboradores mais jovens com idade media de 31 anos. 
# Poderemos estar incluindo redundancia se incluirmos essa features, mas nesse primeiro momento, nao estamos preocupados com isso. Lidaremos melhor
# com vies/variancia depois. 
people_data %>%
  group_by(MaritalStatus, Attrition) %>%
  summarise(n = n(), age_avg = mean(Age)) %>%
  kable(col.names = c("Estado civil","Attrition","Total","Media de idade"))


# Hora extra
people_data %>%
  group_by(OverTime, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "OverTime", y_axis = "n", 
                             title = "Avaliando pelo total de horas extras dos colaboradores",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Colaboradores com horas extras de fato, tendem a afetar o Attrition. Isso porque, dependendo da demanda e frequencia da horas extras, isso 
# pode criar um desgaste natural do colaborador e, como consequencia, aumentar as chances de desligamento.

# Equilibrio entre a vida pessoal e trabalho
people_data %>%
  group_by(WorkLifeBalance, Attrition) %>%
  summarise(n = n()) %>%
  plot_vertical_bar_by_group(x_axis = "WorkLifeBalance", y_axis = "n", 
                             title = "Quanto ao equilibrio entre a vida pessoal e o trabalho",
                             xlab = "", ylab = "Total de colaboradores",
                             group_name = "Attrition")

# Colaboradores que nao adotam um bom gerenciamento de tempo entre vida pessoal e profissional tendem a se desgastar com o tempo. Horas extras,
# pode entrar como um fator que interefere nessa feature.


# Cargo
# Vamos aplicar o teste do Chi-quadrado para independencia para identicar associacao entre as variaveis
contingency_matrix_tbl = get_contingency_table(people_data, "Attrition", "Department")

# H0: variaveis sao independentes, logo nao existe correlacao entre ambas (correlacao = 0)
# H1: existe dependencia entre as variaveis sao dependentes (correlacao != 0)
# Novamente consideraremos nivel de significancia: alpha = 5%
test_result = run_chitest_sample(contingency_matrix_tbl)

# Aqui temos o valor que fora observado na nossa amostra
# contingency_matrix_tbl
test_result$observed
# Aqui temos o valor esperado calculado a partir dos dados observados.
# e = ( sum(row)*sum(col) ) / total_geral
# Ex: Humam Resources = No
# (1233) * 63 / 1470 = 52.84
test_result$expected
# calculo dos residuos:
# r = ( observed - expected ) / sqrt(expected)
# (51 -  52.84286) / sqrt(52.84286) = -0.25
test_result$residuals

# Podemos utilizar o valor residual que obtivemos para estimar o impacto de cada categoria no score final do Chi-quadrado.
# Quando mais alto o valor absoluto maior a contribuicao para o score do Chi-quadrado. Vemos isso atraves da formula abaixo:
# X-squared: sum((all_residuals)^2) / sum(all_expected)

# podemos estimar as associacoes atraves dos residuos. Por exemplo, existe uma correlacao positiva de maginitude (2.37) entre o Cargo de vendas
# e o attrition.
plot_corr_categorical_raw_values(test_result)

# Uma metrica melhor de quantificacao de cada categoria no attrition, vamos sentar a contribuicao percentual, por exemplo:
#  Cargo de vendas tem um percentual um impacto maior para determinar a relacao de dependencia entre a feature Cargo e o Attrition.
plot_corr_categorical_impact_score(test_result)

# Vamos passear por outras variaveis categoricas...

# EnvironmentSatisfaction
contingency_matrix_tbl = get_contingency_table(people_data, "Attrition", "EnvironmentSatisfaction")
test_result = run_chitest_sample(contingency_matrix_tbl)
# Existe uma relacao positiva entre baixa satisfacao e Attrition
plot_corr_categorical_raw_values(test_result)
# Impacto significativo no desligamento quanto o colaborador esta insatisfeito com o clima. 
plot_corr_categorical_impact_score(test_result)

# JobInvolvement
contingency_matrix_tbl = get_contingency_table(people_data, "Attrition", "JobInvolvement")
test_result = run_chitest_sample(contingency_matrix_tbl)
# Baixo e medio envolvimento com cargo tem uma relacao positiva com o Attrition. Por outro lado existe tambem significativo no 
# Attrition quando o colaborador esta altamente envolvido no cargo, so que a associacao com o Attrition e negativa, ou seja, 
# quanto maior o envolvimento com o cargo, menor as chances do colaborador pedir desligamento.
plot_corr_categorical_raw_values(test_result)
# Novamente identificamos que o baixo envolvimento do colaborador tem um impacto significativo no Attrition
plot_corr_categorical_impact_score(test_result)

# JobSatisfaction
# Os extremos: Baixa satisfacao e satisfacao muito alta tem um peso determinante para o Attrition
contingency_matrix_tbl = get_contingency_table(people_data, "Attrition", "JobSatisfaction")
test_result = run_chitest_sample(contingency_matrix_tbl)
plot_corr_categorical_raw_values(test_result)
plot_corr_categorical_impact_score(test_result)

# JobRole
# Outra feature que poderemos considerar importante especialmente pela presenca do cargo de Representativa de vendas 
# que esta altamente associado com Attrition
contingency_matrix_tbl = get_contingency_table(people_data, "Attrition", "JobRole")
test_result = run_chitest_sample(contingency_matrix_tbl)
plot_corr_categorical_raw_values(test_result)
plot_corr_categorical_impact_score(test_result)

# OverTime
# Esta feature tambem e importante especialmente porque demonstrou-se altamente discriminativa. Especialmente porque temos relacoes inversas, a grosso
# modo: colaboradores que pediram desligamento ja fizeram horas extras, colaboradores que permaneceram na empresa nunca fizeram.
contingency_matrix_tbl = get_contingency_table(people_data, "Attrition", "OverTime")
test_result = run_chitest_sample(contingency_matrix_tbl)
plot_corr_categorical_raw_values(test_result)
plot_corr_categorical_impact_score(test_result)

# WorkLifeBalance
# O equilibrio entre vida e profissional tambem e um fator importante para decisao do colaborador de permanecer na empresa. Isso acontece, 
# especialmente entre os que **nao** possuem o devido equilibrio.
contingency_matrix_tbl = get_contingency_table(people_data, "Attrition", "WorkLifeBalance")
test_result = run_chitest_sample(contingency_matrix_tbl)
plot_corr_categorical_raw_values(test_result)
plot_corr_categorical_impact_score(test_result)

# Enfim, chegamos ao fim dessa etapa de selecao previa de features potenciais para o Attrition. Dessa maneira conseguimos responder o nosso 
# primeiro questionamento: "1) que fatores contribuem para o attrition?"

# Colaboradores que precisamos ficar atentos:

# 1) Age: colaboradores com ate 32 anos.
# 2) DistanceFromHome: colaboradores que moram mais distantes do trabalho.
# 3) MonthlyIncome: colaboradores que possuem uma remuneracao mais baixa.
# 4) TotalWorkingYears: colaboradores menos experientes.
# 5) TrainingTimesLastYear: colaboradores que investiram menos tempo em treinamentos no ultimo ano.
# 6) YearsAtCompany: colaboradores com menos tempo de empresa.
# 7) YearsInCurrentRole: colaboradores com baixa experiencia no cargo atual.
# 8) YearsWithCurrManager: colaboradores menos adaptados a lideranca atual.
# 9) Department: colaboradores do setor de vendas tem mais chances de Attrition.
# 10) EnvironmentSatisfaction: colaboradores insatisfeitos com o clima da empresa.
# 11) JobInvolvement: colaboradores com baixo nivel de envolvimento com o cargo que ocupam.
# 12) JobSatisfaction: colaboradores com baixa satisfacao em relacao ao cargo.
# 13) JobRole: colaboradores no cargo de representante de vendas.
# 14) OverTime: colaboradores que fazem hora extra.
# 15) WorkLifeBalance: colaboradores que nao adotam equilibrio entre vida pessoal e profissional.

# Inicialmente, tambem levantamos a pergunta: "2) com base nos dados que temos, sera que poderemos criar uma solucao preditiva 
# para ajudar o time de RH a antecipar esses problemas e propor iniciativas para minimizar o attrition?" 

# Atraves desas features que realizamos o estudo previo, podemos fazer uma primeira iteracao na construcao de um modelo preditivo. 
# Faremos isso nas etapas seguintes, vamos salvar uma copia do nosso dataset.
people_data = people_data %>%
  select(Age, DistanceFromHome, MonthlyIncome, TotalWorkingYears, TrainingTimesLastYear, YearsAtCompany, YearsInCurrentRole,
         YearsWithCurrManager, Department, EnvironmentSatisfaction, JobInvolvement, JobSatisfaction, JobRole, OverTime,
         WorkLifeBalance, Attrition)

write.csv(people_data, file = "eda/data/data_people_filtered.csv", row.names = FALSE)
run_ttest_sample = function(dataset, formula, alpha=0.05){
  
  result = dataset %>%
    t.test(formula, data = ., alternative = "two.sided", var.equal=FALSE)
  
  print(result)
  
  response = if_else(result$p.value <= alpha, 
                     "Temos indicios suficientes para rejeitar H0 e concluir que existem diferencas significativas entre as medias", 
                     "Nao temos evidencias suficientes para rejeitar H0")
  
  print(response)
  
}

run_chitest_sample = function(tbl_contingency, alpha=0.05){
  
  chi_test = chisq.test(tbl_contingency)

  result = if_else(chi_test$p.value <= alpha, 
                   "Existem evidencias suficientes para crermos em uma relacao de dependencia entre as variaveis", 
                   "Nao temos evidencias amostrais suficientes para rejeitarmos H0")
  print(result)
  
  return(chi_test)
  
}


get_contingency_table = function(dataset, feature, feature_target){
  
  count_tbl = table(dataset[[feature]], dataset[[feature_target]])
  tbl_contingency = as.matrix(count_tbl)
  
  return(tbl_contingency)
}

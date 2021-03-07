plot_box_compare_groups = function(dataset, feature_num, feature_cat, title, xlab, ylab){
  
  hcboxplot( 
    x = dataset[[feature_num]],
    var = dataset[[feature_cat]],
  ) %>%
    hc_title(text = title) %>%
    hc_xAxis(title = list(text = xlab)) %>%
    hc_yAxis(title = list(text = ylab)) %>%
    hc_chart(type = "column")
  
}

plot_vertical_bar_by_group = function(dataset, x_axis, y_axis, title, xlab, ylab, group_name){
  
  dataset %>%
    hchart('column', hcaes(x = .data[[x_axis]], y = .data[[y_axis]], group = .data[[group_name]])) %>%
    hc_colors(c("#0073C2FF", "#EFC000FF"))  %>%
    hc_title(text = title) %>%
    hc_xAxis(title = list(text = xlab)) %>%
    hc_yAxis(title = list(text = ylab)) %>%
    hc_chart(type = "column")
}

plot_corr_categorical_raw_values = function(dataset){
  
    corrplot(dataset[['residuals']], is.cor = FALSE, 
             addCoef.col = "white", cl.cex = .6,
             cl.ratio = 0.5,cl.pos = "b",
             tl.col="#31435d", method = "color")
}

plot_corr_categorical_impact_score = function(dataset){
  
  impact_index = 100*dataset[['residuals']]^2/dataset[['statistic']]
  
  corrplot(impact_index, is.cor = FALSE, 
           addCoef.col = "white", cl.cex = .6,
           cl.ratio = 0.5,cl.pos = "b",
           tl.col="#31435d", method = "color")
  
}



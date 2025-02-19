# People Analytics Case
<hr>

### What are the reasons that  influence  attrition ?

## Structure

1. docs: attachment documents
2. eda: ETL for data analysis + scripts of EDA and methods (utilities) for the support EDA.
3. modelling: previous data preparation + building and evaluation of the model.
4. environment: preparing models for the testing and production environment.

<hr>

```
docs/
	data_dictionary.csv
	
environment/
	|-- qa/
	|-- prod/

eda/
	|-- data/
	|-- etl/
	|-- utils/
	exploration.R

modelling/
	evaluation.py
    	model.py
    	preparation.py

```

<hr>

## Docker compose

 - **RStudio**: use to exploratory analysis. Official image can be accessed [here](https://hub.docker.com/r/rocker/rstudio/dockerfile)

 To run to local mode with all necessary packages. You can download Dockerfile and docker-compose.yaml. 

 Open terminal and type `docker-compose up`. Open terminal and type `docker-compose up -d`.

## Application

You can access and interact with our humble application through the link: https://prediction-attrition-app.herokuapp.com/

:rocket:

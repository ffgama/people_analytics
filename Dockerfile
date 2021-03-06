FROM rocker/rstudio:3.6

RUN apt-get update && apt-get -y install \
  libv8-dev \
  libxml2-dev \
  libcurl4-openssl-dev \
  libssl-dev

# R packages
RUN R -e "install.packages('ggplot2',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('data.table',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('lubridate',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('stringr',dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('V8',dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('DT',dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('dplyr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('devtools',dependencies=TRUE, repos='http://cran.rstudio.com/')"
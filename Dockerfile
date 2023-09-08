FROM rocker/docker
RUN R -e "install.packages(\"tidyverse\")"
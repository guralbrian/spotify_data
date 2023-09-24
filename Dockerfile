FROM rocker/tidyverse

# Install required R packages
RUN R -e "install.packages("pals")"
RUN R -e "install.packages("patchwork")"
RUN R -e "install.packages("lubridate")"
RUN R -e "install.packages("RColorBrewer")"
RUN R -e "install.packages("ggridges")"
RUN R -e "install.packages("viridis")"
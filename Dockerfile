FROM rocker/tidyverse

# Update package list and install man-db
## This is to see the manual of bash commands while in the Rstudio container
RUN apt update && apt install -y man-db && rm -rf /var/lib/apt/lists/*
## Unminimize the system
RUN yes | unminimize

# Need to have X11 to visualize plots
RUN apt-get install -y --no-install-recommends libxt6

# Install required R packages
# Quotes for package names need to be preceeded by \ 
RUN R -e "install.packages(\"pals\")"
RUN R -e "install.packages(\"patchwork\")"
RUN R -e "install.packages(\"lubridate\")"
RUN R -e "install.packages(\"RColorBrewer\")"
RUN R -e "install.packages(\"ggridges\")"
RUN R -e "install.packages(\"viridis\")"
RUN R -e "install.packages(\"rjson\")"
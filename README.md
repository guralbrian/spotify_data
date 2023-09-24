# Spotify Listening Analysis in R

Written by [Brian Gural](https://www.linkedin.com/in/brian-gural-09bb60128/) \
README last updated on September 6th 2023

## Project Goals

This project is focused on a comprehensive analysis of personal listening habits using Spotify data. Utilizing R and various statistical and data visualization techniques, the project aims to provide insights into trends, preferences, and temporal patterns related to music listening. The ultimate goal is to provide a straighforward method of analyzing one's own Spotify data. 

Spotify users [can go here](https://www.spotify.com/us/account/privacy/) to request their own data. 


## Getting Started 

This analysis pipeline is intented to be containerized via Docker. Once completed, one will be able to follow the directions below to set up a Docker container, then run Snakemake within the container.

### Docker

To run the code, build the Docker image and then start an RStudio server:

docker build -t spotify_analysis . 

docker run -d -p 8787:8787 -e PASSWORD=yourpasswordhere -v $(pwd):/home/rstudio spotify_analysis

Open your web browser and go to http://localhost:8787.

Username: rstudio
Password: your_password

Note: The `docker run` line uses the argument `-v $(pwd):/home/rstudio` to mount the current working directory to the docker container, then make the relative path to it (within the container) `/home/rstudio`
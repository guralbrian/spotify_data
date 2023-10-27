# Spotify Listening Analysis in R

Written by [Brian Gural](https://www.linkedin.com/in/brian-gural-09bb60128/) \
README last updated on September 24th 2023

## Project Goals

This project is focused on a comprehensive analysis of personal listening habits using Spotify data. Utilizing R and various statistical and data visualization techniques, the project aims to provide insights into trends, preferences, and temporal patterns related to music listening. The ultimate goal is to provide a straighforward method of analyzing one's own Spotify data. 

Spotify users [can go here](https://www.spotify.com/us/account/privacy/) to request their own data. 


## Example Plots

![Plot 1](https://github.com/guralbrian/spotify_data/blob/main/results/readme/images/brian_tartists_09242023.png?raw=true)

![Plot 2](https://github.com/guralbrian/spotify_data/blob/main/results/readme/images/brian_summary_09242023.png?raw=true)


## Getting Started 

This analysis pipeline is intented to be containerized via Docker. Follow the directions below to carry out the pipeline on your own computer*

*assumes that you have cloned this repo and have docker functioning

### Docker

To run the code, build the Docker image and then start an RStudio server:

`docker build -t spotify_analysis .`

`docker run  --name=spotify -d -p 8787:8787 -e PASSWORD=pw -v $(pwd):/home/rstudio spotify_analysis`

If you'd like to run the code in an interactive session:
Open your web browser and go to http://localhost:8787.

Username: rstudio
Password: pw

Otherwise, use make to run the scripts for the skeleton analysis:

- Enter an the docker session with `docker exec -it spotify /bin/bash`
- Navigate to our project directory with `cd home/rstudio`
- Run scripts with `make`

Two plots should appear in the `results/skeleton` directory

To kill the docker container, find the container ID with `docker ps -a`, then use the container ID in `docker kill "container ID"`.


Note: The `docker run` line uses the argument `-v $(pwd):/home/rstudio` to mount the current working directory to the docker container, then make the relative path to it (within the container) `/home/rstudio`
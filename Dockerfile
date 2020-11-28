FROM rocker/shiny-verse:latest

RUN install2.r --error \
    ggplot2 \
    densratio \
    parallel \
    reshape \
    pcg \ 
    gridExtra \
    shiny \
    tools \
    shinythemes \
    shinyalert \
    shinyjs \
    shinycssloaders

# copy the app to the image
COPY *.Rproj /srv/shiny-server/
COPY *.R /srv/shiny-server/
COPY Data /srv/shiny-server/Data
COPY www /srv/shiny-server/www
COPY Rscripts /srv/shiny-server/Rscripts

# select port
EXPOSE 3838

# allow permission
RUN sudo chown -R shiny:shiny /srv/shiny-server
RUN sudo chown -R shiny:shiny /srv/shiny-server/Rscripts

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

# run app
CMD ["/usr/bin/shiny-server.sh"]

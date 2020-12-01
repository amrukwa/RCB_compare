FROM rocker/shiny-verse:4.0.3

RUN apt-get update

COPY  ./packrat/packrat.lock ./packrat/init.R /srv/shiny-server/packrat/

RUN install2.r packrat

# copy the app to the image
# .Rprofile
COPY *.Rproj /srv/shiny-server/
COPY *.Rprofile /srv/shiny-server/
COPY *.R /srv/shiny-server/
COPY Data /srv/shiny-server/Data
COPY www /srv/shiny-server/www
COPY Rscripts /srv/shiny-server/Rscripts

# select port
EXPOSE 3838

# allow permission
RUN sudo chown -R shiny:shiny /srv/shiny-server
RUN sudo chown -R shiny:shiny /srv/shiny-server/Rscripts

RUN R -e 'packrat::restore(project="/srv/shiny-server", restart = FALSE);'

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

# run app
CMD ["/usr/bin/shiny-server.sh"]

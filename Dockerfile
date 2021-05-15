FROM rocker/shiny:4.0.3 as builder
COPY  ./packrat/packrat.lock ./packrat/init.R packrat/
RUN install2.r packrat
RUN R -e 'packrat::restore(restart = FALSE);'

FROM rocker/shiny:4.0.3
# copy the app to the image
COPY *.Rproj /srv/shiny-server/
COPY *.Rprofile /srv/shiny-server/
COPY *.R /srv/shiny-server/
COPY Data /srv/shiny-server/Data
COPY www /srv/shiny-server/www
COPY Rscripts /srv/shiny-server/Rscripts
COPY --from=builder packrat /srv/shiny-server/packrat

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

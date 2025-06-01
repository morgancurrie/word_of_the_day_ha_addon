ARG BUILD_FROM
FROM $BUILD_FROM

# Install requirements for add-on
RUN \
  apk add --no-cache \
    ruby

# Copy data for add-on
COPY words.csv /
COPY update_ha_sensor.rb /
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
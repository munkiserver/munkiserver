FROM nginx:1.9.1

COPY nginx.conf /etc/nginx/nginx.conf
COPY sites-enabled /etc/nginx/sites-enabled
RUN rm /etc/nginx/conf.d/default.conf
EXPOSE 80

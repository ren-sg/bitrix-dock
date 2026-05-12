ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

COPY ./conf.d/nginx.conf /etc/nginx/
COPY ./conf.d/upstream.conf /etc/nginx/conf.d/
COPY ./conf.d/default.conf /etc/nginx/conf.d/
COPY ./conf.d/push.conf /etc/nginx/conf.d/
# COPY ./conf.d/ssl.conf /etc/nginx/conf.d/

RUN usermod -u 1000 www-data

CMD ["nginx"]

EXPOSE 80 443

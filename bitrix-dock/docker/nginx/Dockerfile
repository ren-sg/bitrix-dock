ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

COPY ./conf.d/nginx.conf /etc/nginx/
COPY ./conf.d/upstream.conf /etc/nginx/conf.d/
COPY ./conf.d/default.conf /etc/nginx/conf.d/
RUN mkdir -p /etc/nginx/inc
COPY ./conf.d/push.conf /etc/nginx/inc/
# COPY ./conf.d/ssl.conf /etc/nginx/conf.d/

RUN apk add --no-cache shadow && \
    (getent group www-data || addgroup -g 1000 -S www-data) && \
    (getent passwd www-data || adduser -u 1000 -D -S -G www-data www-data) && \
    usermod -u 1000 www-data && \
    groupmod -g 1000 www-data

CMD ["nginx"]

EXPOSE 80 443

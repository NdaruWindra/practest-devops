FROM alpine:3.17.0


RUN apk update && \
    apk add nginx


COPY practest.html /usr/share/nginx/html/practest.html


RUN chown -R nginx:nginx /usr/share/nginx/html


RUN mkdir -p /run/nginx

RUN rm -rf /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

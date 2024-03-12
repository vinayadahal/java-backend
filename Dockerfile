FROM alpine:latest
WORKDIR /backend
RUN apk add nodejs npm
RUN npm install -g nodemon 
COPY backend /backend/
RUN ["npm","install"]
CMD ["nodemon","server"]
EXPOSE 8080

FROM node:18-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Set environment variables for React build
ENV REACT_APP_STUDENT_API_URL=/api/students
ENV REACT_APP_COURSE_API_URL=/api/courses
ENV REACT_APP_AUTH_API_URL=/api/auth
ENV REACT_APP_USER_API_URL=/api/users

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Create uploads directory and ensure it has proper permissions
RUN mkdir -p uploads && chmod 777 uploads

EXPOSE 3001

CMD ["npm", "start"]
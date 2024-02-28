# Use an official Node.js runtime as a parent image
FROM node:20 as builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and yarn.lock to the working directory
COPY package.json yarn.lock ./

# Install dependencies using Yarn
RUN yarn install

# Copy the rest of the application code
COPY . .

# Build the Vue.js application
RUN yarn build

# Use an official Nginx runtime as a parent image
FROM nginx:alpine

# Copy the built Vue.js app from the builder stage to the nginx public directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]

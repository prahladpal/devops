# Use Node.js as the base image
FROM node:18

# Set the working directory inside the container
WORKDIR /app

# Copy application files into the container
COPY index.html server.js package.json /app/

# Install dependencies
RUN npm install express

# Expose port 3000
EXPOSE 3000

# Run the application
CMD ["node", "server.js"]

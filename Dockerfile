# Use an official Python base image
FROM python:3.9-slim

# Set working directory in container
WORKDIR /app 

# Copy current directory contents into container
COPY . .

# Install dependencies
RUN pip install --no-cache-dir flask

# Expose the port the app runs on
EXPOSE 5000

# Command to run the
CMD ["python", "app.py"]

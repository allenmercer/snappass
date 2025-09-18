# Use the official Python slim image as the base, matching the official repo
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application source code
COPY . .

# Expose the port the app runs on (Snappass default is 5000)
EXPOSE 5000

# The command to run the application using gunicorn, a production-ready web server
CMD ["gunicorn", "-b", "0.0.0.0:5000", "snappass:app"]
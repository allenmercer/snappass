# Use the official Python slim image as the base
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
# This file will come from the cloned Snappass repo
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install the gunicorn web server for production use
RUN pip install --no-cache-dir gunicorn

# Copy the rest of the application source code
# The pipeline will have already placed our custom templates and styles into this source
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# The command to run the application using gunicorn, pointing to the correct entrypoint
CMD ["gunicorn", "-b", "0.0.0.0:5000", "snappass.main:app"]
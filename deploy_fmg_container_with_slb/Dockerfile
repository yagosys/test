# Base Image
FROM fortinet/fortimanager:7.0.7

# Copy nc binary from host to the Docker image
COPY nc /bin/nc

# Ensure nc is executable
RUN chmod +x /bin/nc


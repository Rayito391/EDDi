# Use the official PostgreSQL image
FROM postgres:16

# Set environment variables
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=TecDeCuliacann

COPY db/schema.sql /docker-entrypoint-initdb.d/schema.sql

# Expose the PostgreSQL port
EXPOSE 5432

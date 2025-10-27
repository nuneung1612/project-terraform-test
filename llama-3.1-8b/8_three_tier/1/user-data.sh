#!/bin/bash

echo "Setting up database connection..."
mysql -h ${RDS_HOST} -P 3306 -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE mydb;"
mysql -h ${RDS_HOST} -P 3306 -u ${DB_USERNAME} -p${DB_PASSWORD} -e "USE mydb;"
mysql -h ${RDS_HOST} -P 3306 -u ${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(255));"

echo "Database setup complete."

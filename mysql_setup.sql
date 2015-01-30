/* Create the Database */
CREATE DATABASE mediawiki;

/* Set up grants for the Database */
GRANT ALL PRIVILEGES ON mediawiki.* TO 'admin'@'localhost' IDENTIFIED BY 'admin';

/* Remove the Test Database */
DROP DATABASE test;

/* Flush PRIVILEGES */
FLUSH PRIVILEGES;

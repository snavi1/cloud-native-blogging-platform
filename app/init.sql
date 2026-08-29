CREATE DATABASE IF NOT EXISTS blogdb;

CREATE USER IF NOT EXISTS 'bloguser'@'%' IDENTIFIED BY 'blogpass';

GRANT ALL PRIVILEGES ON blogdb.* TO 'bloguser'@'%';

USE blogdb;

CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL
);

INSERT INTO posts (title, content)
SELECT 'Welcome to Cloud-Native Blogging',
       'This application was deployed using Terraform, Ansible and Jenkins.'
WHERE NOT EXISTS (
    SELECT 1 FROM posts WHERE title = 'Welcome to Cloud-Native Blogging'
);

FLUSH PRIVILEGES;

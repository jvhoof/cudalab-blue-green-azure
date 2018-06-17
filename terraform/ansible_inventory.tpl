[sql]
${sql_hosts}

[${env}:children]
sql

[web]
${web_hosts}

[${env}:children]
web

[green:vars]
DB_NAME=demo
DB_USER=demo
DB_PASSWORD=${db_password}
DB_HOST=${sql_host}
[sql]
${sql_hosts}

[${env}:children]
sql

[web]
${web_hosts}

[${env}:children]
web
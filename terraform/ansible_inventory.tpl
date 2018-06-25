[sql]
${sql_hosts}

[web]
${web_hosts}

[${env}:children]
web
sql

[${env}:vars]
DB_NAME=demo
DB_USER=demo
DB_PASSWORD=${db_password}
DB_HOST=${sql_host}

[waf]
${waf_hosts}

[waf-${env}:children]
waf

[waf-${env}:vars]
WAF_PASSWORD=${waf_password}

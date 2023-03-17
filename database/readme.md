In order for this to work (to have a private IP), I had to run gcloud services enable servicenetworking.googleapis.com --project=griggsco-dev-380214

In order to log in as an IAM user:

gcloud auth login
export MYSQL_PWD=`gcloud sql generate-login-token`
mysql -h 10.182.0.3 -ujgriggs-admin --ssl-ca=.ssh/server-ca.pem --ssl-cert=.ssh/client-cert.pem --ssl-key=.ssh/client-key.pem

The .pem files are outputs from google_sql_ssl_cert.client_cert

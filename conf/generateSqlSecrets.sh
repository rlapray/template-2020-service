#!/bin/sh
ENVIRONMENT=$1
cat  << EOF
        {name: "sql.cluster.url", valueFrom: "arn:aws:ssm:$REGION:$ACCOUNT_ID:parameter/$ENVIRONMENT.$SERVICE_NAME.sql.cluster.url"},
        {name: "sql.database", valueFrom: "arn:aws:ssm:$REGION:$ACCOUNT_ID:parameter/$ENVIRONMENT.$SERVICE_NAME.sql.database"},
        {name: "sql.user", valueFrom: "arn:aws:ssm:$REGION:$ACCOUNT_ID:parameter/$ENVIRONMENT.$SERVICE_NAME.sql.user"},
        {name: "sql.password", valueFrom: "arn:aws:ssm:$REGION:$ACCOUNT_ID:parameter/$ENVIRONMENT.$SERVICE_NAME.sql.password"},
EOF
#!/bin/sh
#define parameters which are passed in.

ENVIRONMENT=$1

HEALTHCHECK_INTERVAL=5
HEALTHCHECK_TIMEOUT=2
HEALTHCHECK_RETRIES=8
HEALTHCHECK_START_PERIOD=10

#Configuration for environment
if [ $ENVIRONMENT = "staging" ]
then
  CPU=256
  MEMORY=512
else
  CPU=512
  MEMORY=1024
fi

if [ $SQL_ENABLED = "true" ]
then
  conf/generateSqlSecrets.sh $ENVIRONMENT > conf/sqlSecretsBlock
  SQL_BLOCK=`cat conf/sqlSecretsBlock`
fi



#define the template.
cat  << EOF
{
  "family": "$ENVIRONMENT-$SERVICE_NAME",
  "networkMode": "awsvpc",
  "taskRoleArn": "arn:aws:iam::$ACCOUNT_ID:role/$ENVIRONMENT-ecs_task_execution_role",
  "executionRoleArn": "arn:aws:iam::$ACCOUNT_ID:role/$ENVIRONMENT-ecs_task_execution_role",
  "cpu": "$CPU",
  "memory": "$MEMORY",
  "requiresCompatibilities": [
        "FARGATE"
  ],
  "tags": [
    {"key": "Environment", "value": "$ENVIRONMENT"},
    {"key": "Service", "value": "$SERVICE_NAME"}
  ],
  "containerDefinitions": [
    {
      "name": "web",
      "image": "<IMAGE1_NAME>",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "essential": true,
      "dependsOn": [{
        "containerName": "envoy",
        "condition": "HEALTHY"
      }],
      "networkMode": "awsvpc",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/aws/ecs/taskDefinition/$ENVIRONMENT/$SERVICE_NAME",
          "awslogs-region": "$REGION",
          "awslogs-stream-prefix": "$SERVICE_NAME"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost/healthcheck || exit 1"
        ],
        "interval": $HEALTHCHECK_INTERVAL,
        "timeout": $HEALTHCHECK_TIMEOUT,
        "retries": $HEALTHCHECK_RETRIES,
        "startPeriod": $HEALTHCHECK_START_PERIOD
      },
      "secrets": [
$SQL_BLOCK
      ]
    },
    {
      "name": "envoy",
      "image": "840364872350.dkr.ecr.eu-west-1.amazonaws.com/aws-appmesh-envoy:v1.12.2.1-prod",
      "user": "1337",
      "essential": true,
      "ulimits": [
        {
          "name": "nofile",
          "hardLimit": 15000,
          "softLimit": 15000
        }
      ],
      "portMappings": [
        {
          "containerPort": 9901,
          "hostPort": 9901,
          "protocol": "tcp"
        },
        {
          "containerPort": 15000,
          "hostPort": 15000,
          "protocol": "tcp"
        },
        {
          "containerPort": 15001,
          "hostPort": 15001,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "APPMESH_VIRTUAL_NODE_NAME",
          "value": "mesh/$ENVIRONMENT/virtualNode/$SERVICE_NAME"
        },
        {
          "name": "ENVOY_LOG_LEVEL",
          "value": "debug"
        },
        {
          "name": "ENABLE_ENVOY_STATS_TAGS",
          "value": "1"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/aws/ecs/taskDefinition/$ENVIRONMENT/$SERVICE_NAME/envoy",
          "awslogs-region": "$REGION",
          "awslogs-stream-prefix": "proxy"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
        ],
        "interval": 5,
        "timeout": 2,
        "retries": 3
      }
    }
  ],
  "proxyConfiguration": {
        "type": "APPMESH",
        "containerName": "envoy",
        "properties": [
            {"name": "AppPorts", "value": "80"},
            {"name": "EgressIgnoredIPs", "value": "169.254.170.2,169.254.169.254"},
            {"name": "EgressIgnoredPorts", "value": "5432"},
            {"name": "IgnoredUID", "value": "1337"},
            {"name": "ProxyEgressPort", "value": "15001"},
            {"name": "ProxyIngressPort", "value": "15000"},
        ]
    }
}
EOF
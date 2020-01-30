#!/bin/sh
#define parameters which are passed in.

#define the template.
cat  << EOF
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: "web"
          ContainerPort: 80
        PlatformVersion: "LATEST"
EOF
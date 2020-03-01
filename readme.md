# template-2020-service

## Intro

This project is a dependency for https://github.com/rlapray/template-2020-infrastructure.

This is a java service managed by the previous project.

2 branches, for 2 services with no difference but their names.

*WARNING* => it's dirty for now

## What's inside ?

- Taskdef generation with input to configure healthcheck and CPU + MEMORY
- Pull sql secrets safely from AWS System Parameter Store
- Provision codebuild metadata
- AppSpec generation
- Endpoint to test envoy and AppMesh features
- Endpoint to see what's in env (dangerous in production)
- Endpoint to see container metadata
- Endpoint to see container stats
- Endpoint to see task metadata
- Endpoint to see tasks stats
- Endpoint to test db features


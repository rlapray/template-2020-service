#!/bin/sh
#define parameters which are passed in.

#define the template.
cat  << EOF
codebuild {
  arn: "$CODEBUILD_BUILD_ARN"
  id: "$CODEBUILD_BUILD_ID"
  image: "$CODEBUILD_BUILD_IMAGE"
  number: "$CODEBUILD_BUILD_NUMBER"
  succeeding: "$CODEBUILD_BUILD_SUCCEEDING"
  initiator: "$CODEBUILD_INITIATOR"
  logPath: "$CODEBUILD_LOG_PATH"
  resolvedSourceVersion: "$CODEBUILD_RESOLVED_SOURCE_VERSION"
  source {
    repoUrl: "$CODEBUILD_SOURCE_REPO_URL"
    version: "$CODEBUILD_SOURCE_VERSION",
    directory: "$CODEBUILD_SRC_DIR"
  }
  startTime: "$CODEBUILD_START_TIME"
  webhook {
    actorAccountId: "$CODEBUILD_WEBHOOK_ACTOR_ACCOUNT_ID",
    baseRef: "$CODEBUILD_WEBHOOK_BASE_REF"
    event: "$CODEBUILD_WEBHOOK_EVENT"
    previousCommit: "$CODEBUILD_WEBHOOK_PREV_COMMIT"
    headRef: "$CODEBUILD_WEBHOOK_HEAD_REF"
    trigger: "$CODEBUILD_WEBHOOK_TRIGGER"
  }
}

EOF


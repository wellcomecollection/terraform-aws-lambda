# terraform-aws-lambda

[![Build status](https://badge.buildkite.com/6aef8c173ae3cbd347a36143a053c3735a0f852c85259c6f79.svg)](https://buildkite.com/wellcomecollection/terraform-module-terraform-aws-lambda)

A Terraform module for creating AWS Lambdas at Wellcome Collection

**Features:**
- Log routing/retention/permissions configured for you
- An error alarm when `error_alarm_topic_arn` is set, tagged with its Backplane Component (`alarm_component`), repository (`alarm_repository`) and severity (`alarm_severity`, default `medium`)

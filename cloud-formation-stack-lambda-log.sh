#!/bin/sh

if ! command -v aws &> /dev/null; then
    echo "AWS CLIがインストールされてないです"
    exit 1
fi

if ! command -v fzf &> /dev/null; then
    echo "fzfがインストールされてないです"
    exit 1
fi

# Stackの選択
stacks=$(aws cloudformation list-stacks --query "StackSummaries[?StackStatus=='CREATE_COMPLETE' || StackStatus=='UPDATE_COMPLETE'].[StackName]" --output text)
if [ -z "$stacks" ]; then
    echo "Stackがありませんでした"
    exit 0
fi
stack_name=$(echo "$stacks" | fzf --preview "aws cloudformation describe-stack-resources --stack-name {} --query 'StackResources[].[ResourceType, LogicalResourceId]' --output table")

# Lambda関数の選択
lambda_resources=$(aws cloudformation describe-stack-resources --stack-name "$stack_name" --query "StackResources[?ResourceType=='AWS::Lambda::Function'].[PhysicalResourceId]" --output text)
if [ -z "$lambda_resources" ]; then
    echo "Lambda関数がありませんでした"
    exit 0
fi
selected_lambda=$(echo "$lambda_resources" | fzf --preview "aws logs tail /aws/lambda/{} --format short --since 5m") # 直近5分のログを表示

# ログをtailする
aws logs tail "/aws/lambda/$selected_lambda" --format short --follow

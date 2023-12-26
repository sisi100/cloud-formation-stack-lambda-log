#!/bin/sh

if ! command -v aws &> /dev/null; then
    echo "AWS CLIがインストールされてないです"
    exit 1
fi

if ! command -v fzf &> /dev/null; then
    echo "fzfがインストールされてないです"
    exit 1
fi

if command -v aws-vault; then
    # aws-vaultがインストールされている場合は、aws-vaultでProfileを選択して変数を設定する
    profiles=$(aws-vault list --profiles)
    profile=$(echo "$profiles" | fzf)
    export $(aws-vault exec "$profile" -- env | grep AWS_ | grep -v AWS_VAULT)
fi

# Stackの選択
stacks=$(aws cloudformation list-stacks --query "StackSummaries[?StackStatus=='CREATE_COMPLETE' || StackStatus=='UPDATE_COMPLETE'].[StackName]" --output text)
if [ -z "$stacks" ]; then
    echo "Stackがありませんでした"
    exit 0
fi
stack_name=$(echo "$stacks" | fzf --preview "aws cloudformation describe-stack-resources --stack-name {} --query 'StackResources[].[ResourceType, LogicalResourceId]' --output table")

# Lambda関数の選択
lambda_resources=$(aws cloudformation describe-stack-resources --stack-name "$stack_name" --query "StackResources[?ResourceType=='AWS::Lambda::Function'].[LogicalResourceId, PhysicalResourceId]" --output text)
if [ -z "$lambda_resources" ]; then
    echo "Lambda関数がありませんでした"
    exit 0
fi
selected_lambda=$(echo "$lambda_resources" | fzf --preview "aws logs tail /aws/lambda/{2} --format short --since 5m") # 直近5分のログを表示

# ログをtailする
physical_resource_id=$(echo "$selected_lambda" | awk '{print $2}')
aws logs tail "/aws/lambda/$physical_resource_id" --format short --follow

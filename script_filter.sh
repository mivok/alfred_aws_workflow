#!/bin/bash

file_age() {
    echo $(( $(date +%s) - $(stat -f %m "$1") ))
}

cache_fail() {
    echo '{"items": [
        {
            "title": "Failed to get instance list",
            "subtitle": "'"${1//[\"$'\r\n']/}"'"
        }
    ]}'
    exit 1
}

refresh_cache_now() {
    # This captures stderr into a variable and then fails if the command
    # didn't return 0. Note the normally incorrect order of '2>&1'.
    mkdir -p "$alfred_workflow_cache"
    local STDERR
    STDERR=$(aws ec2 describe-instances 2>&1 >"$CACHE_FILE") || \
        cache_fail "$STDERR"
}

refresh_cache_if_needed() {
    [[
        ! -f "$CACHE_FILE" ||
        ! -s "$CACHE_FILE" ||
        $(file_age "$CACHE_FILE") -gt $CACHE_EXPIRY
    ]] && refresh_cache_now
}

verify_dependencies() {
    if ! which -s aws jq; then
        echo '{"items": [
            {
                "title": "Required commands not installed",
                "subtitle": "You need to install the aws cli and jq"
            }
        ]}'
        exit 1
    fi
}

get_profile() {
    PROFILE_FILE="$alfred_workflow_data/current_aws_profile"
    export AWS_PROFILE
    if [[ -f "$PROFILE_FILE" ]]; then
        AWS_PROFILE=$(<"$PROFILE_FILE")
    else
        AWS_PROFILE="default"
    fi
}

get_region() {
    REGION_FILE="$alfred_workflow_data/current_aws_region"
    export AWS_DEFAULT_REGION
    if [[ -f "$REGION_FILE" ]]; then
        AWS_DEFAULT_REGION=$(<"$REGION_FILE")
    else
        AWS_DEFAULT_REGION="us-east-1"
    fi
}

query_instances() {
    ./query.jq --arg query "$1" "$CACHE_FILE"
}

## Main

# For testing the script directly on the command line
[[ -z $alfred_workflow_cache ]] && alfred_workflow_cache="."
[[ -z $alfred_workflow_data ]] && alfred_workflow_data="."
[[ -z $CACHE_EXPIRY ]] && CACHE_EXPIRY=3600

verify_dependencies
get_profile
get_region
CACHE_FILE="$alfred_workflow_cache/${AWS_PROFILE}_${AWS_DEFAULT_REGION}.json"
refresh_cache_if_needed
query_instances "$1"

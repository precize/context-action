#!/bin/bash

while true
do
   echo "Checking if there are existing workflows to complete..."
   sleep 20
   running=$(gh run list --status='in_progress' --json headSha,databaseId --jq '.[] | select((.headSha == "'$GITHUB_SHA'") and .databaseId != '$GITHUB_RUN_ID')')
   if [ -z "$running" ]; then
	break
   fi
done

wget -q -O - https://precize-terraform-context.s3.amazonaws.com/precize-context.tgz | tar -xvz -C /tmp

changedDirs=$(git log -m -1 --name-only --pretty="format:" $GITHUB_SHA | sed '/^[[:space:]]*$/d' | xargs dirname | sort -u)
# Convert to array
dirArr=($changedDirs)

for dir in "${dirArr[@]}"
do
   /tmp/precize-context tag -d $dir --tag-groups git --skip-tags git_org,git_modifiers,git_last_modified_by,git_last_modified_at --parsers Terraform --tag-prefix precize_ --tag-local-modules false
done

git config --global user.name 'Precize'
git config --global user.email 'noreply@precize.ai'
git commit -am "Resource tags updated for Terraform configurations by Precize"
git push
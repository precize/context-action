#!/bin/bash

while true
do
   echo "Checking if there are existing workflows to complete..."
   running=$(gh run list --status='in_progress' --json headSha,databaseId --jq '.[] | select((.headSha == "'$GITHUB_SHA'") and .databaseId != "'$GITHUB_RUN_ID'")')
   echo "Running: $running"

   if [ -z "$running" ]; then
    echo "Here"
	break
   fi
   sleep 5
done

wget -q -O - https://github.com/bridgecrewio/yor/releases/download/0.1.183/yor_0.1.183_linux_amd64.tar.gz | tar -xvz -C /tmp
/tmp/yor tag -d . --tag-groups git --skip-tags git_file,git_org,git_modifiers,git_last_modified_by,git_last_modified_at --parsers Terraform --tag-prefix precize_ --tag-local-modules false

git config --global user.name 'Precize'
git config --global user.email 'noreply@precize.ai'
git commit -am "Resource tags updated for Terraform configurations by Precize"
git push
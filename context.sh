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

wget -q -O - https://github.com/bridgecrewio/yor/releases/download/0.1.183/yor_0.1.183_linux_amd64.tar.gz | tar -xvz -C /tmp

gitlogFiles=$(git log -m -1 --name-only --pretty="format:" $GITHUB_SHA | sed '/^[[:space:]]*$/d')
read -a changedFiles <<< $gitlogFiles
for file in "${changedFiles[@]}"
do
   dir=${file%/*}
   /tmp/yor tag -d $dir --tag-groups git --skip-tags git_org,git_modifiers,git_last_modified_by,git_last_modified_at --parsers Terraform --tag-prefix precize_ --tag-local-modules false
done

git config --global user.name 'Precize'
git config --global user.email 'noreply@precize.ai'
git commit -am "Resource tags updated for Terraform configurations by Precize"
git push
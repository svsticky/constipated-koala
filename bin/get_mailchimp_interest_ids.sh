#!/bin/bash

while read line; do                                         # Read .env file
    if [[ $line =~ ^MAILCHIMP_TOKEN= ]] ; then              # If line starts with "MAILCHIMP_TOKEN="
        token=$(echo $line | cut -d'=' -f2)                 # Save the part after '='
    fi
done <../.env

if [ -z "$token" ] ; then                                   # If no token was found
    echo "No MAILCHIMP_TOKEN found in root .env file!" 1>&2 # Throw an error
    exit 1                                                  # And exit the script
else
    echo "MAILCHIMP_TOKEN found: $token"
fi

echo 
echo "Interest IDs:"
echo 

# Get lists with curl, use jq to find the list id
listid=`curl -sS "https://us5.api.mailchimp.com/3.0/lists" --user "yeet:$token" | jq -r '.lists[2].id'` # When running this script i had to use idx 2
# Get the interest categories with curl, use jq to find the category id
catid=`curl -sS "https://us5.api.mailchimp.com/3.0/lists/{$listid}/interest-categories" --user "yeet:$token" | jq -r '.categories[0].id'`
# Get the interests with curl, use jq to find their names and IDs
curl -sS "https://us5.api.mailchimp.com/3.0/lists/{$listid}/interest-categories/{$catid}/interests" --user "yeet:$token" | jq -r '.interests[] | .name, .id'
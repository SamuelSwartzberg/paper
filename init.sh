#!bin/bash
POSTS=(posts/*.md)
echo "<!-- This is the generated index.html. Any edits here will be overwritten! -->" > index.html #add a warning to the generated index.html
cat _index.html >> index.html # add the content of the master index.html file to the generated one

for (( i = 0; i < ${#POSTS[@]}; i++ )); do
  HEADER=$(head -n 3 ${POSTS[i]}) # Get the first three lines, which are header lines
  IFS=$'\n'
  read -rd '' -a headerLineArray <<<"$HEADER"  # Split them into an array
  postTemplate=$(cat post-item-template.html) # get the html post template
  cat markdown-template.html > "${POSTS[i]%.md}temp.html"
  for (( j = 0; j < ${#headerLineArray[@]}; j++ )); do
    key=$(echo ${headerLineArray[j]} | cut -d "|" -f1)
    value=$(echo ${headerLineArray[j]} | cut -d "|" -f2)
    postTemplate=${postTemplate/"{$key}"/"$value"} # Replace the {key} instances in postTemplate by their values, filling the template
    sed -i'.original' -e "s|{$key}|${value}|" "${POSTS[i]%.md}temp.html"
  done
  postTemplate=${postTemplate/"{url}"/"${POSTS[i]%.md}.html"} # Replace the {key} instances in postTemplate by their values, filling the template
  tail -n +4 "${POSTS[i]}" > tempMDpost.md
  markdown tempMDpost.md --template "${POSTS[i]%.md}temp.html" > "${POSTS[i]%.md}.html" #create the article html files
  # head -n 36 "${POSTS[i]%.md}.html" | tail -n 3
  perl -pi -e 's| &lt;([^&]*?)&gt; |<\1>|g' "${POSTS[i]%.md}.html"
  # head -n 36 "${POSTS[i]%.md}.html" | tail -n 3
  echo $postTemplate > tempPostItem.html # create a temporary post item
  sed -i'.original' '/INSERT HERE-->/r tempPostItem.html' index.html # add the contents of the post item to the generated index.html
done
rm *.original
rm posts/*.original
rm temp*
rm posts/*temp.*

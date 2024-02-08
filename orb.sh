#!/bin/bash

orbfile="./Orbfile"

remove_if_exist() {
    local file="$1"
    if [ -f "$file" ] || [ -d "$file" ]; then 
        rm -rf "$file"
    else
        :
    fi
}

# Check if the script is called with "init" command as the first parameter
if [ "$#" -eq 2 ] && [ "$1" = "init" ]; then
    if [ -z "$2" ]; then
        echo "Creating a new directory in the current location..."
        mkdir new_directory
    else
        echo "Creating a new directory in the specified location: $2"
        mkdir "$2"
touch "$2"/Orbfile
cat << EOF > "$2"/Orbfile
# Orbfile config here
EOF

mkdir "$2"/content
mkdir "$2"/content/posts

cat <<EOF > "$2"/content/posts/helloworld.txt
title: Hello, world!
date: dd-mm-yyyy

= Hello, world!
EOF

cat <<EOF > "$2"/content/about.txt
= about
EOF
    fi
# Check if the script is called with "build" command as the first parameter
elif [ "$#" -eq 1 ] && [ "$1" = "build" ]; then
    echo "Building..."
    echo "Checking for previous build..."
    
read -p "Removing previous build. Do you want to continue? (y/n): " choice

# Check the user's choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "Continuing..."
    # Add your actions here
elif [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
    echo "Exiting..."
    exit 0
else
    echo "Invalid choice. Please enter 'y' to continue or 'n' to exit."
    exit 1
fi
    rm -rf dist
    mkdir dist
    mkdir dist/content
    cp -r content/* dist/content
    source $orbfile
     
touch dist/index.html

cat <<EOF > dist/index.html
<html>
<head>
<title>"$PAGE_TITLE"</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<TT>
<P># "$PAGE_TAGLINE"</P>
<P></P>
<A HREF='content/about.txt'>About</A>
<P></P>
EOF

get_date_and_title() {
    local file="$1"
    local date=$(sed -n '1s/date: \(.*\)/\1/p' "$file")
    local title=$(sed -n '2s/title: \(.*\)/\1/p' "$file")
    echo "$date" "$title"
}

for file in content/posts/*; do
    if [[ -f $file ]]; then
        info=$(get_date_and_title "$file")
        date=$(echo "$info" | cut -d ' ' -f 1)
        title=$(echo "$info" | cut -d ' ' -f 2-)

        echo "<LI> $date <A HREF='$file'>$title</A></LI>"
    fi
done | sort -r -k2 >> dist/index.html

cat << EOF >> dist/index.html
<P></P>
<CENTER>"$PAGE_FOOTER"</CENTER>
</TT>
</body>
</html>
EOF

# Print usage message for other cases
else
    echo "Usage:"
    echo "To create a directory in the current location: $0 init"
    echo "To create a directory in a specific location: $0 init <directory_location>"
    echo "To build: $0 build"
    exit 1
fi

if [ "$#" -eq 1 ] && [ "$1" = "serve" ]; then
    echo "Serving on http://localhost:8000"
    python3 -m http.server --directory "./dist" 
else
    echo "Usage:"
    echo "To create a directory in the current location: $0 init"
    echo "To create a directory in a specific location: $0 init <directory_location>"
    echo "To build: $0 build"
    exit 1
fi

exit 0

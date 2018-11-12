#!/bin/bash

# Make sure you created your configuration templates as .json files and stored them in TEMPLATE_FOLDER. Run "bash mustask.sh" and watch out for OUTPUT_FOLDER being created with skill variants that will be ready for instant deployment via Skill Management API (SMAPI).

TEMPLATE_FOLDER="templates";
OUTPUT_FOLDER="_dist";

for templateFile in $TEMPLATE_FOLDER/*.json; do \
    templateFilePath=${templateFile%.*}; \
    templateFileName=$(basename "$templateFilePath"); \
    resourcePath="$TEMPLATE_FOLDER/$templateFileName/"; \
    outputPath="$OUTPUT_FOLDER/$templateFileName"; \
    
    # create skill directory
    mkdir -p "$outputPath"; \
    
    # copy all files to skill directory excluding template directory and this shell script
    rsync -aq . "$outputPath" --ignore-errors --delete --include ".ask" --exclude "*$OUTPUT_FOLDER*" --exclude "$TEMPLATE_FOLDER" --exclude "$0" --exclude ".*"; \
     
    # go through all non-binary files in the root directory
    for sourceFile in $(find . -type f -not -path "*$TEMPLATE_FOLDER*" -not -path "*$OUTPUT_FOLDER*" -not -path "*.git*" -not -name "*$0" | xargs file | grep ".*: .* text" | sed "s;\(.*\): .* text.*;\1;") ; do \
        echo "Reading from: $sourceFile"; \
        output="./$outputPath/${sourceFile#./}"; \
        # use mustache to resolve template files
        mustache $templateFile $sourceFile > $output; \
        echo "Done writing: $output"; \
        echo "--------------------------------------------"; \
    done; \

    # copy all skill resources
    [ -d "$resourcePath" ] && rsync -av "$resourcePath" --ignore-errors --exclude ".*" "$outputPath"; \
   
    cd "$outputPath"; \

    for command in "$@"; do \
        eval "$command"; \
    done; \

    cd "../../"; \
done;

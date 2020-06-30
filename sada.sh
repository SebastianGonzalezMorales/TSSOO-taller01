#!/bin/bash

# La variable $# es equiv a argc.
if [ $# != 1 ]; then
    echo "Uso: $0 <directorio busqueda>"
    exit
fi

searchDir=$1


summaryFiles=$(find $searchDir -name "summary-0*.txt")

 for i in ${summaryFiles[*]};
        do
                evacTimeVisitorsIG3=(`cat $i | cut -d ':' -f 3,4,8\
                        >> evacTime.txt;`)
        done


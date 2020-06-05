#!/bin/bash

# La variable $# es equiv a argc.
if [ $# != 1 ]; then
    echo "Uso: $0 <directorio busqueda>"
    exit
fi

searchDir=$1

#Verificar que searchDir es un elemente existente.
if [ ! -e $searchDir ]; then
        echo "$1 no existe"
        exit
fi

#Verificar que searchDir es un directorio
if [ ! -d $searchDir ]; then
   echo "Directorio $1 no existe"
   exit
fi

printf "Directorio busqueda: %s\n" $1

#Buscar archivos summary-NNN.txt
summaryFiles=$(find $searchDir -name "summary-0*.txt")

#Crear un archivo que contenga los valores de la columna 8(evacTime)
#de los archivos summary-NNN.txt
for i in ${summaryFiles[*]};
do
        printf ">> %s\n" $i
        evacTimeResidents=(`cat $i | tail -n+2 | cut -d ':' -f 8 \
                >> evacTimeResidents.txt;`)

done

#Calcular el promedio total, el minimo y el máximo de los todos los residentes.
evacTimeResidents=$(cat evacTimeResidents.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
					                                        if($1>max){max=$1};\
                                                            total+=$1; count+=1;\
                                                            } \
                                                            END { print"alls:Promedio:" total/count":","min:" min,"max:" max}')

rm evacTimeResidents.txt

echo $evacTimeResidents >> evacuation.txt

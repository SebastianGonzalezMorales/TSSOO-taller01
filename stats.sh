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


#Crear un archivo con el nombre evacTime.txt que contenga los valores de la columna 8(evacTime)
#de los archivos summary-NNN.txt
for i in ${summaryFiles[*]};
do
        evacTimeAll=(`cat $i | tail -n+2 | cut -d ':' -f 8 \
                >> evacTimeAll.txt;`)

done

#Calcular el promedio total, el minimo y el máximo de los todos las personas de las simulaciones.
evacTimeAll=$(cat evacTimeAll.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};\
                                                            total+=$1; count+=1;\
                                                            } \
                                                            END { print"alls:Promedio:" total/count":","min:" min,"max:" max}')

echo $evacTimeAll >> evacuation.txt

#Crear un archivo con el nombre evacTimeResidents.txt que contenga los valores de la columna 8(evacTime) de los archivos summary-NNN.txt, que sean residentes.
#Es residente si en la columna model su valor es 0.

for i in ${summaryFiles[*]};
do
        evacTimeResidents=(`cat $i | tail -n+2 | cut -d ':' -f 3,8 | grep -n "0:" | cut -d ':' -f 3 \
                >> evacTimeResidents.txt;`)

done

#Calcular el promedio total, el minimo y el máximo de los todos los residentes.
evacTimeResidents=$(cat evacTimeResidents.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};\
                                                            total+=$1; count+=1;\
                                                            } \
                                                            END { print"Residents:Promedio:" total/count":","min:" min,"max:" max}')

echo $evacTimeResidents >> evacuation.txt


#Crear un archivo con el nombre evacTimeVisitorsI.txt que contenga los valores de la columna 8(evacTime) de los archivos summary-NNN.txt, que sean visitanteI.
#Es visitanteI si en la columna model su valor es 1.

for i in ${summaryFiles[*]};
do
        evacTimeVisitorsI=(`cat $i | tail -n+2 | cut -d ':' -f 3,8 | grep -n "1:" | cut -d ':' -f 3 \
                >> evacTimeVisitorsI.txt;`)
done

evacTimeVisitorsI=$(cat evacTimeVisitorsI.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                                                                 if($1>max){max=$1};\
                                                                                                 total+=$1; count+=1;\
                                                                                           } \
                                                                                               END { print "visitorsI:Promedio:"total/count ":" min ":" max}')
echo $evacTimeVisitorsI >> evacuation.txt


#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los archivo summary-NNN.txt, que sean residentesG-0.
#Es residente-G0 si en la columna model su valor es 0 y la columna groupAge su valor es 0.


for i in ${summaryFiles[*]};
do
        evacTimeResidentsGO=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:0" | cut -d ':' -f 4 \
                >> evacTimeResidentsG0.txt;`)

done


evacTimeResidentsG0=$(cat evacTimeResidentsG0.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};\
                                                            total+=$1; count+=1;\
                                                            } \
                                                            END { print"residents-G0:Promedio:" total/count":","min:" min,"max:" max}')
echo $evacTimeResidentsG0 >> evacuation.txt

#Crear un archivo con el nombre evacTimeResidentsG1.txt que contenga los valores de la columna 8(evacTime) de los archivos summary-NNN.txt, que sean residentesG-1.
#Es residente-G1 si en la columna model su valor es 0 y la columna groupAge su valor es 1.

for i in ${summaryFiles[*]};
do
        evacTimeResidentsG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:1" | cut -d ':' -f 4 \
                >> evacTimeResidentsG1.txt;`)

done


evacTimeResidentsG1=$(cat evacTimeResidentsG1.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};\
                                                            total+=$1; count+=1;\
                                                            } \
                                                            END { print"residents-G1:Promedio:" total/count":","min:" min,"max:" max}')

echo $evacTimeResidentsG1 >> evacuation.txt

#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los archivos summary-NNN.txt, que sean residentesG-2.
#Es residente-G1 si en la columna model su valor es 0 y la columna groupAge su valor es 2.

for i in ${summaryFiles[*]};
do
        evacTimeResidentsG2=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:2" | cut -d ':' -f 4 \
                >> evacTimeResidentsG2.txt;`)

done


evacTimeResidentsG2=$(cat evacTimeResidentsG2.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};\
                                                            total+=$1; count+=1;\
                                                            } \
                                                            END { print"residents-G2:Promedio:" total/count":","min:" min,"max:" max}')

echo $evacTimeResidentsG2 >> evacuation.txt

for i in ${summaryFiles[*]};
do
        evacTimeResidentsG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:3" | cut -d ':' -f 4 \
                >> evacTimeResidentsG3.txt;`)

done


evacTimeResidentsG3=$(cat evacTimeResidentsG3.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};\
                                                            total+=$1; count+=1;\
                                                            } \
                                                            END { print"residents-G3:Promedio:" total/count":","min:" min,"max:" max}')
echo $evacTimeResidentsG3 >> evacuation.txt


#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los archivos summary-NNN.txt, que sean residentesG-1.
#Es visitanteI-G0 si en la columna model su valor es 1 y la columna groupAge su valor es 0.


for i in ${summaryFiles[*]};
do
        evacTimeVisitorsIG0=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:0" | cut -d ':' -f 4 \
                >> evacTimeVisitorsIG0.txt;`)
done

evacTimeVisitorsIG0=$(cat evacTimeVisitorsIG0.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                                                                 if($1>max){max=$1};\
                                                                                                 total+=$1; count+=1;\
                                                                                           } \
                                                                                          END { print "visitorsI-G0:Promedio:" total/count":","min:" min,"max:" max}')
echo $evacTimeVisitorsIG0 >> evacuation.txt


#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los archivo summary-NNN.txt, que sean visitanteIs-G1.
#Es visitanteI-G1 si en la columna model su valor es 1 y la columna groupAge su valor es 1.

for i in ${summaryFiles[*]};
do
        evacTimeVisitorsIG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:1" | cut -d ':' -f 4 \
                >> evacTimeVisitorsIG1.txt;`)
done

evacTimeVisitorsIG1=$(cat evacTimeVisitorsIG1.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                                                                 if($1>max){max=$1};\
                                                                                                 total+=$1; count+=1;\
                                                                                           } \
                                                                                           END { print "visitorsI-G1:Promedio:"total/count":","min:" min,"max:" max}')
echo $evacTimeVisitorsIG1 >> evacuation.txt

#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los archivos summary-NNN.txt, que sean visitanteG-2.
#Es visitanteI-G2 si en la columna model su valor es 1 y la columna groupAge su valor es 2.

for i in ${summaryFiles[*]};
do
        evacTimeVisitorsIG2=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:2" | cut -d ':' -f 4 \
                >> evacTimeVisitorsIG2.txt;`)
done

evacTimeVisitorsIG2=$(cat evacTimeVisitorsIG2.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                                                                 if($1>max){max=$1};\
                                                                                                 total+=$1; count+=1;\
                                                                                           } \
                                                                                            END { print "visitorsI-G2:Promedio:"total/count":","min:" min,"max:" max}')
echo $evacTimeVisitorsIG2 >> evacuation.txt


#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los archivos summary-NNN.txt, que sean residentesG-3.
#Es visitanteI-3 si en la columna model su valor es 1 y la columna groupAge su valor es 3.

for i in ${summaryFiles[*]};
do
        evacTimeVisitorsIG3=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:3" | cut -d ':' -f 4 \
                >> evacTimeVisitorsIG3.txt;`)
done

evacTimeVisitorsIG3=$(cat evacTimeVisitorsIG3.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                                                                 if($1>max){max=$1};\
                                                                                                 total+=$1; count+=1;\
                                                                                           } \
                                                                                           END { print "visitorsI-G3:Promedio:"total/count ":","min:" min,"max:" max}')
echo $evacTimeVisitorsIG3 >> evacuation.txt


rm evacTimeVisitorsIG3.txt
rm evacTimeVisitorsIG2.txt
rm evacTimeVisitorsIG1.txt
rm evacTimeVisitorsIG0.txt
rm evacTimeVisitorsI.txt
rm evacTimeResidentsG3.txt
rm evacTimeResidentsG2.txt
rm evacTimeResidentsG1.txt
rm evacTimeResidentsG0.txt
rm evacTimeResidents.txt
rm evacTimeAll.txt



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

#
#Problema1
#

problema1(){
	executionSummaryFiles=$(find $searchDir -name "executionSummary-0*.txt")


	# Crear un archivo llamado en donde esten las columnas 6,7,8(timeExecMakeAgents,timeExecCal,timeExecSim)
	# de todas las simulaciones para luego calcular el tiempo de simulación total
	echo "tsimTotal:promedio:min:max" >> metrics.txt

	for i in ${executionSummaryFiles[*]};
	do
		columnas=(`cat $i | tail -n+2 | cut -d ':' -f 6,7,8\
       			 >> columnas.txt ;`)
   		 sumaDeColumnas=$(cat columnas.txt | awk -F ':' 'BEGIN{sum=0}{sum=$1+$2+$3;}END{print sum}'>>sumaDeColumnas.txt;)
	done

 	 operaciones1=$(cat sumaDeColumnas.txt |  awk 'BEGIN{ min=2**63-1; max=0}\
        	         {if($1<min){min=$1};if($1>max){max=$1};total+=$1; count+=1;}\
                	  END {printf("%d:%d:%d:%d", total, total/count, min, max)}')

	echo $operaciones1 >> metrics.txt

	#Crear un archivo llamado maxmemory en donde este la columna 9(maxMemory) de todas las simulaciones
	# para luego sacar las estadisticas.

	echo "memUsed:promedio:min:max" >> metrics.txt
	for i in ${executionSummaryFiles[*]};
	do
   		 columnasMaxMemory=(`cat $i | tail -n+2 | cut -d ':' -f 9\
   			 >> maxMemory.txt;`)
	done

	operaciones2=$(cat maxMemory.txt | awk 'BEGIN{ min=2**63-1; max=0}\
             		 {if($1<min){min=$1};if($1>max){max=$1};total+=$1; count+=1;}\
        	      	 END {printf("%d:%d:%d:%d", total, total/count, min, max)}')

	echo $operaciones2 >> metrics.txt

	rm columnas.txt sumaDeColumnas.txt  maxMemory.txt
}

#
#Problema2
#

problema2(){
	#Buscar archivos summary-NNN.txt
	summaryFiles=$(find $searchDir -name "summary-0*.txt")

	#Crear un archivo con el nombre evacTime.txt que contenga los valores de la columna 8(evacTime)
	#de los archivos summary-NNN.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeAll=(`cat $i | tail -n+2 | cut -d ':' -f 8 \
                	>> evacTimeAll.txt;`)

	done

	echo "alls:promedio:min:max" >> evacuation.txt
	#Calcular el promedio total, el minimo y el máximo de los todos las personas de las simulaciones.
	evacTimeAll=$(cat evacTimeAll.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                         if($1>max){max=$1};total+=$1; count+=1;} \
                                         END { printf("%d:%d:%d:%d", total, total/count, min, max)}')

	echo $evacTimeAll >> evacuation.txt

	#Crear un archivo con el nombre evacTimeResidents.txt que contenga los valores de la columna 8(evacTime)
	# de los archivos summary-NNN.txt, que sean residentes. Es residente si en la columna model su valor es 0.

	for i in ${summaryFiles[*]};
	do
        	evacTimeResidents=(`cat $i | tail -n+2 | cut -d ':' -f 3,8 | grep -n "0:" | cut -d ':' -f 3 \
                	>> evacTimeResidents.txt;`)
	done

	echo "residents:promedio:min:max" >> evacuation.txt
	#Calcular el promedio total, el minimo y el máximo de los todos los residentes.
	evacTimeResidents=$(cat evacTimeResidents.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                      if($1>max){max=$1};total+=$1; count+=1;} \
                                                      END { printf("%d:%d:%d:%d", total, total/count, min, max)}')

	echo $evacTimeResidents >> evacuation.txt


	#Crear un archivo con el nombre evacTimeVisitorsI.txt que contenga los valores de la columna 8(evacTime)
	#de los archivos summary-NNN.txt, que sean visitanteI. Es visitanteI si en la columna model su valor es 1.

	for i in ${summaryFiles[*]};
	do
        	evacTimeVisitorsI=(`cat $i | tail -n+2 | cut -d ':' -f 3,8 | grep -n "1:" | cut -d ':' -f 3 \
                	>> evacTimeVisitorsI.txt;`)
	done

	echo "visitorsI:promedio:min:max" >> evacuation.txt
	evacTimeVisitorsI=$(cat evacTimeVisitorsI.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                      if($1>max){max=$1};total+=$1; count+=1;} \
                                                      END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
	echo $evacTimeVisitorsI >> evacuation.txt


	#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los
	#archivo summary-NNN.txt, que sean residentesG-0. Es residente-G0 si en la columna model su valor es 0
	#y la columna groupAge su valor es 0.

	echo "residents-G0:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeResidentsGO=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:0" | cut -d ':' -f 4 \
                	>> evacTimeResidentsG0.txt;`)
	done

	evacTimeResidentsG0=$(cat evacTimeResidentsG0.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};total+=$1; count+=1;} \
                                                            END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
	echo $evacTimeResidentsG0 >> evacuation.txt

	#Crear un archivo con el nombre evacTimeResidentsG1.txt que contenga los valores de la columna 8(evacTime)
	#de los archivos summary-NNN.txt, que sean residentesG-1. Es residente-G1 si en la columna model su valor es 0
	# y la columna groupAge su valor es 1.

	echo "residents-G1:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeResidentsG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:1" | cut -d ':' -f 4 \
                	>> evacTimeResidentsG1.txt;`)
	done

	evacTimeResidentsG1=$(cat evacTimeResidentsG1.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};total+=$1; count+=1;} \
                                                            END { printf("%d:%d:%d:%d", total,  total/count, min, max)}')

	echo $evacTimeResidentsG1 >> evacuation.txt

	#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime)
	# de los archivos summary-NNN.txt, que sean residentesG-2. Es residente-G1 si en la columna model su valor es 0
	# y la columna groupAge su valor es 2.

	echo "residents-G2:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeResidentsG2=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:2" | cut -d ':' -f 4 \
                	>> evacTimeResidentsG2.txt;`)
	done

	evacTimeResidentsG2=$(cat evacTimeResidentsG2.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};total+=$1; count+=1;} \
                                                            END { printf("%d:%d:%d:%d", total, total/count, min, max)}')

	echo $evacTimeResidentsG2 >> evacuation.txt

	echo "residents-G1:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeResidentsG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "0:3" | cut -d ':' -f 4 \
                	>> evacTimeResidentsG3.txt;`)
	done

	evacTimeResidentsG3=$(cat evacTimeResidentsG3.txt | awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                            if($1>max){max=$1};total+=$1; count+=1;} \
                                                            END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
	echo $evacTimeResidentsG3 >> evacuation.txt


	#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime)
	#de los archivos summary-NNN.txt, que sean residentesG-1. Es visitanteI-G0 si en la columna model su valor es
	#1 y la columna groupAge su valor es 0.

	echo "visitorsI-G0:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeVisitorsIG0=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:0" | cut -d ':' -f 4 \
                	>> evacTimeVisitorsIG0.txt;`)
	done

	evacTimeVisitorsIG0=$(cat evacTimeVisitorsIG0.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                              if($1>max){max=$1};total+=$1; count+=1;} \
                                                              END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
	echo $evacTimeVisitorsIG0 >> evacuation.txt


	#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime)
	#de los archivo summary-NNN.txt, que sean visitanteIs-G1. Es visitanteI-G1 si en la columna model su valor es 1
	# y la columna groupAge su valor es 1.

	echo "visitorsI-G1:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeVisitorsIG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:1" | cut -d ':' -f 4 \
                	>> evacTimeVisitorsIG1.txt;`)
	done

	evacTimeVisitorsIG1=$(cat evacTimeVisitorsIG1.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                             if($1>max){max=$1};total+=$1; count+=1;} \
                                                             END { printf("%d:%d:%d:%d", total, total/count , min,  max)}')
	echo $evacTimeVisitorsIG1 >> evacuation.txt

	#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los
	#archivos summary-NNN.txt, que sean visitanteG-2. Es visitanteI-G2 si en la columna model su valor es 1 y la columna
	#groupAge su valor es 2.

	echo "visitorsI-G2:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeVisitorsIG2=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:2" | cut -d ':' -f 4 \
                	>> evacTimeVisitorsIG2.txt;`)
	done

	evacTimeVisitorsIG2=$(cat evacTimeVisitorsIG2.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                             if($1>max){max=$1};total+=$1; count+=1;} \
                                                             END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
	echo $evacTimeVisitorsIG2 >> evacuation.txt

	#Crear un archivo con el nombre evacTimeResidentsG0.txt que contenga los valores de la columna 8(evacTime) de los
	#archivos summary-NNN.txt, que sean residentesG-3. Es visitanteI-3 si en la columna model su valor es 1 y la columna
	#groupAge su valor es 3.

	echo "visitorsI-G3:promedio:min:max" >> evacuation.txt
	for i in ${summaryFiles[*]};
	do
        	evacTimeVisitorsIG3=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep -n "1:3" | cut -d ':' -f 4 \
                	>> evacTimeVisitorsIG3.txt;`)
	done

	evacTimeVisitorsIG3=$(cat evacTimeVisitorsIG3.txt |  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                                             if($1>max){max=$1};total+=$1; count+=1;} \
                                                             END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
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

}

#
#Problema3
#

OUTFILE="usePhone-stats.txt"

problema3(){
	usePhoneFiles=$(find $searchDir -name "usePhone-0*.txt")


        #idea: crear un archivo en donde las columna i-ésima representen la cantidad de personas
        #      que utilizan el teléfono en el instante t=10i.
        #      Luego, procesar cada columna para calcular las estadísticas solicitadas

        tmpFile="fracaso.txt"
        > $tmpFile

        for i in ${usePhoneFiles[*]};
        do
               # printf "> %s\n" $i
                tiempos=(`cat $i | tail -n+3 | cut -d ':' -f 3`)
                for i in ${tiempos[*]};
                do
                        printf "%d:" $i >> $tmpFile
                done
                printf "\n" >> $tmpFile
        done

        #Determinar el total de columnas a procesar
                #Sacar la primera linea                 : head -1 $tmpFile
                #eliminar el último caracter    : sed 's/.$//'
                #cambiar todos los ':' por '\n' : tr ':' '\n'
                #contar las líneas                              : wc -l

        totalFields=$(head -1 $tmpFile | sed 's/.$//' | tr ':' '\n'| wc -l)

        > $OUTFILE

        # el archivo tiene una linea de cabecera, que comienza con '#'
        printf "timestamp:promedio:min:max\n" >> $OUTFILE
                for i in $(seq 1 $totalFields); do

                out=$(cat $tmpFile | cut -d ':' -f $i |\
                        awk 'BEGIN{ min=2**63-1; max=0}\
                                {if($1<min){min=$1};if($1>max){max=$1};total+=$1; count+=1;}\
                                END {print total/count":"max":"min}')
                printf "$i:$out\n" >> $OUTFILE
        done

        rm $tmpFile

}

problema1
problema2
problema3

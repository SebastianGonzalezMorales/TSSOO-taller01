#!/bin/bash

# Uso SCRIPT
#
usoScript(){
	echo -e "Uso: ./stats.sh -d <directorio datos> [-h]\n      -d: directorio donde están los datos a procesar.\n      -h: muestra este mensaje y termina."
	exit
}

# MAIN
#
while getopts "d:h" opt; do
  case ${opt} in
    d )
		searchDir=$OPTARG
      ;;
    h )
		usoScript
      ;;
    \? )
		usoScript
      ;;
  esac
done

#La variable $# es equiv a argc. Verifica que hayan dos argumentos
if [ $# != 2 ]; then
    usoScript
    exit
fi

#Verifica si longitud del STRING es cero
if [ -z $searchDir ]; then
	usoScript
fi

#Verificar que searchDir es un directorio
if [ ! -d $searchDir ]; then
        echo "$searchDir no es un directorio"
        exit
fi


printf "Directorio busqueda: %s\n" $searchDir

#PARTE 1: Determinar estadisticas para métricas de desempeño computacional
#	  Salida: archivo metrics.txt con la siguiente estructura:
#				tsimTotal:promedio:min:max
#				memUsed:promedio:min:max
#
OUTFILE1="metrics.txt"
parte1(){
	#Buscando archivos executionSumary-NNN.txt de todas las simulaciones.
	executionSummaryFiles=$(find $searchDir -name "executionSummary-0*.txt")

	tmpFile1="columnas.txt"
	tmpFile2="sumaDeColumnas.txt"
	tmpFile3="maxMemory.txt"

	# Escribiendo encabezado en el archivo metrics.txt.
	echo "tsimTotal:promedio:min:max" >> $OUTFILE1
	for i in ${executionSummaryFiles[*]};
	do
		printf "Obteniendo datos de: > %s\n" $i

		# Idea: Crear un archivo temporal en donde esten las columnas 6,7,8
		#       (timeExecMakeAgents,timeExecCal,timeExecSim) de todas las simulaciones
		#       para luego calcular el tiempo de simulación total.

		# Concatena datos.                                               : cat $i..
                # output comenzando desde la línea dos.   	                 : tail -n+2.
                # Delimita por campos donde haya ":" en cada linea del archivo   :  cut -d ':' -f 6,7,8.
                # salida se redirecciona a un archivo temporal.
		columnas=(`cat $i | tail -n+2 | cut -d ':' -f 6,7,8\
       			 >> $tmpFile1 ;`)
   		 sumaDeColumnas=$(cat $tmpFile1 | awk -F ':' 'BEGIN{sum=0}{sum=$1+$2+$3;}END{print sum}'\
			>> $tmpFile2;)

		# Crear un archivo temporal en donde este la columna 9(maxMemory) de todas las simulaciones
		# para luego calcular estadisticas.

		columnasMaxMemory=(`cat $i | tail -n+2 | cut -d ':' -f 9\
                         >> $tmpFile3;`)
	done

	# Calcular estadísticas del tiempo de simulacion total y redireccionando su salida al archivo metrics.txt.
 	 operaciones1=$(cat $tmpFile2 |  awk 'BEGIN{ min=2**63-1; max=0}\
        	         		{if($1<min){min=$1};if($1>max){max=$1};total+=$1; count+=1;}\
                	  		END {printf("%d:%d:%d:%d", total, total/count, min, max)}')
	echo $operaciones1 >> $OUTFILE1


	# Escibir encabezado en el archivo metrics.txt.
	echo "memUsed:promedio:min:max" >> $OUTFILE1
	# Calcular estadísticas de la memoria utilizada por el simulador y redireccionando su salida al archivo metrics.txt.
	operaciones2=$(cat $tmpFile3 | awk 'BEGIN{ min=2**63-1; max=0}\
             				 {if($1<min){min=$1};if($1>max){max=$1};total+=$1; count+=1;}\
        	      			 END {printf("%d:%d:%d:%d", total, total/count, min, max)}')
	echo $operaciones2 >> $OUTFILE1

	rm $tmpFile1 $tmpFile2 $tmpFile3
}

#PARTE 2: Determinar estadisticas para tiempo de evacuacion.
#         Salida: archivo evacuation.txt con la siguiente estructura:
#                       alls:promedio:min:max
#			residents:promedio:min:max
#			visitorsI:promedio:min:max
#			residents-G0:promedio:min:max
#			residents-G1:promedio:min:max
#			residents-G2:promedio:min:max
#			residents-G3:promedio:min:max
#			visitorsI-G0:promedio:min:max
#			visitorsI-G1:promedio:min:max
#			visitorsI-G2:promedio:min:max
#			visitorsI-G3:promedio:min:max
#
OUTFILE2="evacuation.txt"
parte2(){
	# Buscar archivos summary-NNN.txt de todas las simulaciones.
	summaryFiles=$(find $searchDir -name "summary-0*.txt")

	tmpFile4="evacTimeAll.txt"
	tmpFile5="evacTimeResidents.txt"
	tmpFile6="evacTimeVisitorsI.txt"
	tmpFile7="evacTimeResidentsG0.txt"
	tmpFile8="evacTimeResidentsG1.txt"
	tmpFile9="evacTimeResidentsG2.txt"
	tmpFile10="evacTimeResidentsG3.txt"
	tmpFile11="evacTimeVisitorsIG0.txt"
	tmpFile12="evacTimeVisitorsIG1.txt"
	tmpFile13="evacTimeVisitorsIG2.txt"
	tmpFile14="evacTimeVisitorsIG3.txt"
	for i in ${summaryFiles[*]};
	do
		printf "Obteniendo datos de: > %s\n" $i

		# Crear archivos temporales que contengan los valores de las columna que se requiere para
		# luego realizar estadísticas.

		# Concatena datos.				       		 : cat $i..
		# output comenzando la salida desde la línea dos.		 : tail -n+2.
		# Delimita por campos donde haya ":" en cada linea del archivo 	 :  cut -d ':' -f 8.
		# en este caso -f 8 por la columna evacTime.
		# salida se redirecciona a un archivo temporal.
		evacTimeAll=(`cat $i | tail -n+2 | cut -d ':' -f 8 \
                	>> $tmpFile4;`)

		#Idea: seleccionar campos  model, groupAge, y evacTime, luego con buscar patrón para cada caso.
		#	"0" = residentes.
		#	"1" = visitantes.
		#	"0,0" = residentes de grupo etario G0 (0-14).
		#	"0,1" = residentes de grupo etario G1 (15-29.
		#	"0,2" = residentes de grupo etario G2 (30-64).
		#	"0,3" = residentes de grupo etario G3 (65 o mas).
		#	"1,0" = visitantes de grupo etario G0 (0-14).
		#	"1,1" = visitantes de grupo etario G1 (15-29.
		#	"1,2" = visitantes de grupo etario G2 (30-64).
		#	"1,3" = visitantes de grupo etario G3 (65 o mas).
		#
		# Delimita por campos donde haya ":" en cada linea del archivo   :  cut -d ':' -f 3,8.
		# en este caso -f 3,8 para la columna model y evacTime.
		# Busca patrones en el archivo, en este caso "0:"		 :  grep "0:".

		evacTimeResidents=(`cat $i | tail -n+2 | cut -d ':' -f 3,8 | grep "0:" | cut -d ':' -f 2 \
                	>> $tmpFile5;`)
		evacTimeVisitorsI=(`cat $i | tail -n+2 | cut -d ':' -f 3,8 | grep "1:" | cut -d ':' -f 2 \
                	>> $tmpFile6;`)
		evacTimeResidentsGO=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "0:0" | cut -d ':' -f 3 \
                	>> $tmpFile7;`)
		evacTimeResidentsG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "0:1" | cut -d ':' -f 3 \
                	>> $tmpFile8;`)
		evacTimeResidentsG2=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "0:2" | cut -d ':' -f 3 \
                	>> $tmpFile9;`)
		evacTimeResidentsG3=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "0:3" | cut -d ':' -f 3 \
                	>> $tmpFile10;`)
		evacTimeVisitorsIG0=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "1:0" | cut -d ':' -f 3 \
                	>> $tmpFile11;`)
		evacTimeVisitorsIG1=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "1:1" | cut -d ':' -f 3 \
                	>> $tmpFile12;`)
		evacTimeVisitorsIG2=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "1:2" | cut -d ':' -f 3 \
                	>> $tmpFile13;`)
		evacTimeVisitorsIG3=(`cat $i | tail -n+2 | cut -d ':' -f 3,4,8 | grep "1:3" | cut -d ':' -f 3 \
                	>> $tmpFile14;`)
	done

	# Escribr encabezado en el archivo evacuation.txt.
	echo "alls:promedio:min:max" >> $OUTFILE2
	# Calcular estadísticas de todos las personas de las simulaciones y redireccionar su salida al archivo evacuation.txt.
	evacTimeAll=$(cat $tmpFile4 |\
			   awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                  if($1>max){max=$1};total+=$1; count+=1;} \
                                  END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeAll >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "residents:promedio:min:max" >> $OUTFILE2
	# Calcular estadísticas de los todos los residentes y redireccionar su salida al archivo evacuation.txt.
	evacTimeResidents=$(cat $tmpFile5 |\
				 awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                        if($1>max){max=$1};total+=$1; count+=1;} \
                                         END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeResidents >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "visitorsI:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de visitantes Tipo I y redireccionar su salida al archivo evacuation.txt.
	evacTimeVisitorsI=$(cat $tmpFile6 |\
				 awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                        if($1>max){max=$1};total+=$1; count+=1;} \
                                        END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeVisitorsI >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "residents-G0:promedio:min:max" >> $OUTFILE2
	# Calcular estadísticas de residentes G0 y redireccionar su salida al archivo evacuation.txt.
	evacTimeResidentsG0=$(cat $tmpFile7 |\
				 awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                        if($1>max){max=$1};total+=$1; count+=1;} \
                                        END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeResidentsG0 >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "residents-G1:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de residentes G1 y redireccionar su salida al archivo evacuation.txt.
	evacTimeResidentsG1=$(cat $tmpFile8 |\
				 awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                        if($1>max){max=$1};total+=$1; count+=1;} \
                                        END { printf("%d:%d:%d:%d", total,  total/count, min, max)}')
		echo $evacTimeResidentsG1 >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "residents-G2:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de residentes G2 y redireccionar su salida al archivo evacuation.txt.
	evacTimeResidentsG2=$(cat $tmpFile9 |\
				 awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                         if($1>max){max=$1};total+=$1; count+=1;} \
                                         END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeResidentsG2 >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "residents-G3:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de residentes G3 y redireccionar su salida al archivo evacuation.txt.
	evacTimeResidentsG3=$(cat $tmpFile10 |\
				 awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                        if($1>max){max=$1};total+=$1; count+=1;} \
                                        END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeResidentsG3 >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "visitorsI-G0:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de visitantes G0 y redireccionar su salida al archivo evacuation.txt.
	evacTimeVisitorsIG0=$(cat $tmpFile11 |\
				  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                         if($1>max){max=$1};total+=$1; count+=1;} \
                                         END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeVisitorsIG0 >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "visitorsI-G1:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de visitantes G1 y redireccionar su salida al archivo evacuation.txt.
	evacTimeVisitorsIG1=$(cat $tmpFile12 |\
				  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                         if($1>max){max=$1};total+=$1; count+=1;} \
                                         END { printf("%d:%d:%d:%d", total, total/count , min,  max)}')
		echo $evacTimeVisitorsIG1 >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "visitorsI-G2:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de visitantes G2 y redireccionar su salida al archivo evacuation.txt.
	evacTimeVisitorsIG2=$(cat $tmpFile13 |\
				  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                          if($1>max){max=$1};total+=$1; count+=1;} \
                                          END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeVisitorsIG2 >> $OUTFILE2

	# Escribir encabezado en el archivo evacuation.txt.
	echo "visitorsI-G3:promedio:min:max" >> $OUTFILE2
	#Calcular estadísticas de visitantes G3 y redireccionar su salida al archivo evacuation.txt.
	evacTimeVisitorsIG3=$(cat $tmpFile14 |\
				  awk 'BEGIN{ min=2**63-1; max=0}{ if($1<min){min=$1};\
                                    	  if($1>max){max=$1};total+=$1; count+=1;} \
                                          END { printf("%d:%d:%d:%d", total, total/count, min, max)}')
		echo $evacTimeVisitorsIG3 >> $OUTFILE2

	#Eliminando archivos temporales
	rm $tmpFile4 $tmpFile5 $tmpFile6 $tmpFile7 $tmpFile8 $tmpFile9 $tmpFile10 $tmpFile11 $tmpFile12 $tmpFile13 $tmpFile14

}

#PARTE 3: Determinar estadisticas del uso de teléfonos móviles basado en ejemplo del profesor.
#         Salida: archivo usePhone-stats.txt con la siguiente estructura:
#			timestamp:promedio:min:max
#
#
OUTFILE3="usePhone-stats.txt"
parte3(){
	usePhoneFiles=$(find $searchDir -name "usePhone-0*.txt")

	# Crear un archivo en donde las columna i-ésima representen la cantidad de personas
        # que utilizan el teléfono en el instante t=10i.
        # Luego, procesar cada columna para calcular las estadísticas solicitadas

        tmpFile15="usoDeTelefono"
        > $tmpFile15

        for i in ${usePhoneFiles[*]};
        do
                printf "Obteniendo datos de: > %s\n" $i
                tiempos=(`cat $i | tail -n+3 | cut -d ':' -f 3`)
                for i in ${tiempos[*]};
                do
                        printf "%d:" $i >> $tmpFile15
                done

                printf "\n" >> $tmpFile15
        done

        #Determinar el total de columnas a procesar
                #Sacar la primera linea                 : head -1 $tmpFile
                #eliminar el último caracter    : sed 's/.$//'
                #cambiar todos los ':' por '\n' : tr ':' '\n'
                #contar las líneas                              : wc -l

        totalFields=$(head -1 $tmpFile15 | sed 's/.$//' | tr ':' '\n'| wc -l)

        > $OUTFILE3

        printf "timestamp:promedio:min:max\n" >> $OUTFILE3
                for i in $(seq 1 $totalFields); do
		out=$(cat $tmpFile15 | cut -d ':' -f $i |\
			 awk 'BEGIN{ min=2**63-1; max=0}\
				  {if($1<min){min=$1};if($1>max){max=$1};total+=$1; count+=1;}\
                           	   END {print total/count":"max":"min}')
                printf "$i:$out\n" >> $OUTFILE3
        done

	rm $tmpFile15

}

parte1
parte2
parte3


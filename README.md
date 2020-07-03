**Autor:** Sebastián González Morales

**Correo institucional:** Sebastian.gonzalez@alumnos.uv.cl

**Diseño de la solución**

La búsqueda y lectura de datos serán tres **executionSummary-NNN.txt**, **summary-NNN.txt** y **usephone-NNN.TXT**, para la primera se requiere calcular el tiempo total de la simulación este tiempo esta definido como execMakeAgents + timeExecCal + timeExecSim. Esto se realizara mediante un arreglo y la información obtenida será redireccionada a un archivo temporal,  para luego ser procesada y obtener el tiempo total de simulación, este tiempo será redireccionado a otro archivo temporal para luego realizar las estadísticas solicitadas, luego de eso la salida será redireccionada al archivo metrics.txt, luego para la memoria utilizada por el simulador se requiere la columna maxMemory de todas las simulaciones, mediante un arreglo se obtiene el valor y se redirecciona a un archivo temporal, luego de obtener ese valor para todas las simulaciones, se procesa ese archivo para obtener el promedio, máximo y mínimo y luego eso se redirecciona al archivo metrics.txt.

Para el segundo se requiere algo similar de lo realizado en el primero, se necesita obtener el valor de la columna evacTime de todas las simulaciones, pero aquí se tiene un par de condiciones ya que se tiene que diferenciar el grupo de personas, por ejemplo el residente-G0 del residente-G1, para hacer esto al recorrer el archivo se obtendrá solo lo que se requiere, en este caso es la columna 3,4,8, es decir model, groupAge, y evacTime, para obtener cada uno de los datos solicitados se recorrera el archivo y luego se crearan archivos temporales, para ser procesados y obtener el promedio, el mínimo y el máximo luego estos resultados serán redireccionados a un archivo llamado evacuation.txt. 

Para el tercero, se hará lo mismo que en el uno y dos, lo que se necesita es el valor de la columna usePhone, por lo tanto, estos valores serán seleccionados y luego redireccionados a un archivo temporal, en este archivo temporal, en cada fila estarán los datos de cada simulación, por ejemplo en la fila 1 estarán todos los valores de la columna usePhone del archivo usePhone-000.txt, y así sucesivamente, después se contaran el número de líneas que tiene cada simulación, estas deberían ser 360, ya que en la línea 360 esta el ultimo instante de tiempo registrado en la simulación, así a través de un ciclo se ira calculando el promedio, min y max de cada instante de tiempo de todas las simulaciones,  luego la salida se irán redireccionado a un archivo llamado usePhone-stats.txt junto al instante de tiempo. 

Cabe señalar que cuando se lee cada archivo se elimina la línea de cabecera tanto para la primera, segunda, y tercera, ya que esa línea no es necesaria para realizar las estadisticas. También luego de obtener las estadísticas en los archivos metrics.txt, evacuation.txt y usePhone-stats.txt, los archivos temporales creados serán eliminados. 

**Funciones**

**usosScript()**: Mustra al usuario la forma correcta de ejecutar el script.

**parte1()**: Determinar estadisticas para métricas de desempeño computacional. 
    	  	Salida: archivo metrics.txt con la siguiente estructura: 
					
					
		    						tsimTotal:promedio:min:max
				    				memUsed:promedio:min:max
									
**parte2()** : Determinar estadisticas para tiempo de evacuacion.
        	 Salida: archivo evacuation.txt con la siguiente estructura: <br>
							
								alls:promedio:min:max 
								residents:promedio:min:max 
								visitorsI:promedio:min:max
								residents-G0:promedio:min:max
								residents-G1:promedio:min:max
    							residents-G2:promedio:min:max
								residents-G3:promedio:min:max
								visitorsI-G0:promedio:min:max
								visitorsI-G1:promedio:min:max
								visitorsI-G2:promedio:min:max
								visitorsI-G3:promedio:min:max
								
**parte3()** : Determinar estadisticas del uso de teléfonos móviles basado en ejemplo del profesor.
           Salida: archivo usePhone-stats.txt con la siguiente estructura: 
					 
        					     		 timestamp:promedio:min:max




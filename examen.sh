#!/bin/sh

#Examen


entero() { #función para la comprobación de números
	if [ -z $1 ]; #compruebo si la variable esta vacia
	then 
		error=0
		clear
	else 
		nodigitos=$(echo $1 | sed s/[0-9]//g)
		if [ -n "$nodigitos" ]; # si esta vacio son solo números y si no tendrá letras y tengo que pedir de nuevo la variable
		then
			error=0
		else
			error=1
		fi
	fi
}
anyadirtique() { #función para añadir tiques
	#Calculo el nombre del tique
	dia=$(date | cut -d' ' -f3)
	hora=$(date | cut -d' ' -f4 | cut -d: -f1)
	minuto=$(date | cut -d' ' -f4 | cut -d: -f2)
	segundo=$(date | cut -d' ' -f4 | cut -d: -f3)
	#Creo el nombre del tique
	nombre="tique$Numerotique"
	diatique="de$dia$hora$minuto$segundo"
	nombretique="$nombre$diatique"
	fintique=0
	#Pido los datos
	while [ $fintique != FIN ]; 
	do
		read -p "Dime el producto: " producto
		error=0
		while [ $error -eq 0 ]; do
			read -p "Dime la cantidad: " cantidad
			entero $cantidad
		done
		error=0
		while [ $error -eq 0 ]; do
			read -p "Dime el precio unitario: " precio
			entero $precio
		done
		#Calculamos el subtotal
		subtotal=$((precio*cantidad))
		#Añadimos la línea al fichero
		echo "$producto:$cantidad:$precio:$subtotal">>$carpetatiques/$nombretique
		read -p "Si no quieres añadir otro producto teclea FIN, si lo quieres añadir presiona cualquier tecla: " fintique
		if [ -z $fintique ]; #Si la variable fintique esta vacia le pongo cero para que siga en el while
		then
			fintique=0
		fi
	done
	#Aumentamos el numero de tique para el siguiente tique
	Numerotique=$((Numerotique+1))
	}

mostrartique() { #función para mostrar tiques
	j=1
	clear
	for i in $(ls $carpetatiques) #Listar los archivos que hay en la carpeta
	do
		echo "$j) $i"  #la variable j la utilizo para numerar los archivos listados
		j=$((j+1))	
	done
	read -p "Dime el número de tique que quieres listar: " numero
	k=1
	for i in $(ls $carpetatiques)
	do
		#Imprimo el tique seleccionado
		Totaltique=0
		
		if [ $numero -eq $k ]; #compruebo que el fichero que recorrón en el for sea el mimsmo número que he introducido en la variable numero
		then
			printf "Producto \t\t Cantidad \t Precio \t Total\n"
			for j in $(cat $carpetatiques/$i)
			do
				producto=$(echo $j | cut -d':' -f1) #leo del archivo el producto
				cantidad=$(echo $j | cut -d':' -f2) #leo del archivo la cantidad
				precio=$(echo $j | cut -d':' -f3) #leo del archivo el precio
				totalproducto=$(echo $j | cut -d':' -f4) #leo del archivo el total de cada producto
				Totaltique=$((Totaltique+totalproducto)) #Voy calculando el total del tique
				printf "$producto \t\t\t $cantidad \t\t $precio \t\t $totalproducto \n"
			done
			printf "TOTAL \t\t\t\t\t\t\t $Totaltique\n"
		fi
		k=$((k+1))
	done
	sleep 10
	clear	
}

sumartique() { #función para sumar tiques	
	read -p "Dime el día o intervalo de días (separado por -) que quieres sumar: " dia
	Sumatiques=0 #inicializo las variables que luego mostraré para la suma de los tiques y para el número de tiques
	Numerotiques=0
	#Recorro todos los tiques
	for i in $(ls $carpetatiques)
	do
		#Saco el día de cada tique
		diatique=$(echo $i | cut -c9,10)
		if [ $dia -eq $diatique ]; #Compruebo si es igual al día pedido
			then
			for j in $(cat $carpetatiques/$i) #saco los datos
			do
				totalproducto=$(echo $j | cut -d':' -f4) #Y calculo los totales
				Sumatiques=$((Sumatiques+totalproducto))
			done
			Numerotiques=$((Numerotiques+1)) #calculo cuantos tiques hay
		fi
	done
	#Muestro en pantalla los datos
	echo "El $dia se vendieron $Numerotiques tiques por un total de $Sumatiques"
	sleep 10
	clear
}

#Comprobamos si esta creada la carpeta de tiques
carpetatiques=$HOME/tiques
creada=$(find / -wholename $carpetatiques 2>errores.txt)
if [ -z $creada ];
	then
	mkdir $carpetatiques
fi
#Miramos cuantos ficheros hay en la carpeta tiques para numerar los tikets
Numerotique=$(ls -l $carpetatiques | wc | tr -s ' ' |cut -d' ' -f2)
salir=0
#Mostramos el menú
while [ $salir -eq 0 ]; do
	echo "1) Añadir tique."
	echo "2) Mostrar tique."
	echo "3) Sumar tiques entre días."
	echo "x) Salir."
	read -p "Elige la opción que desees: " opcion
	case $opcion in
		1)
			anyadirtique
		;;
		2)
			mostrartique
		;;
		3)
			sumartique
		;;
		x)
			salir=1
		;;
		*)
			echo "Opción no valida"
			sleep 2
			clear
	esac
	
done
	
rm -r errores.txt

error=0

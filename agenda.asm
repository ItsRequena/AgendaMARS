# Definicion del tipo estructurado
#	TYPE Contacto = RECORD
#		Nombre: ARRAY[0..28]
#		TLF: INTEGER;
#		Dir: ARRAY[0..20]
		.data
# Reserva de memoria #
contacto:	.space 1200 # 60 bytes * 20 contactos
nombre:		.space 29
		.align 3
tlf:		.space 4
direccion:	.space 21
		.align 3

tira1:		.asciiz	"¿Que operación desea realizar?\nConsultar = 0\nInsertar = 1\n"
tira2:		.asciiz "Opcion incorrecta!\n"
tira3:		.asciiz "Introduce el nombre: "
tira4:		.asciiz "Introduce el telefono: "
tira5:		.asciiz "Introduce la direccion: "
tira6:		.asciiz "Agenda vacia!\n"
tira7:		.asciiz "Introduce el numero del contacto: "
tira8:		.asciiz "No hay ningun contacto con ese indice!\n"
tira9:		.asciiz "Agenda llena!\n"
tiraNombre:	.asciiz "Nombre: "
tiraTlf:	.asciiz "Telefono: "
tiraDireccion:	.asciiz "\nDireccion: "
		.text
# Imprimir menu inicial
inicio:		li $v0,4
		la $a0,tira1
		syscall
# Pedir entero por pantalla
		li $v0,5
		syscall
		
		la $t0,contacto		# Ponemos un puntero al inicio de los contactos
		li $t6,1		
		beqz $v0,consultar	# Comprobamos si el valor introducido es 0
		beq $v0,$t6,insertar	# Comprobamos si el valor introducido es 1
# Imprimir mensaje de opcion incorrecta
		li $v0,4
		la $a0,tira2
		syscall
		j inicio
# OPCION DE CONSULTAR
consultar:	
# Imprimir mensaje de pedir indice
		li $v0,4
		la $a0,tira7
		syscall
# Pedir indice por pantalla
		li $v0,5
		syscall
		move $a0,$v0		# Cargamos el indice introducido al argumento $a0
		add $t1,$s1,-1		# Restamos 1 al contador de la agenda porque en este punto se encuentra adelantado 1 posicion
		ble $a0,$t1,cont	# Comprobamos si ese existe un contacto con ese indice
# Imprimir mensaje de error(no existe contacto con ese indice)
		li $v0,4
		la $a0,tira8
		syscall
		j inicio
cont:		jal consult
		j inicio
# OPCION DE INSERTAR	
insertar:	blt $s1,20,cont1	# Comprobamos que si ya existen 20 contactos
# Imprimir mensaje de error(agenda llena)
		li $v0,4
		la $a0,tira9		
		syscall
		j inicio
cont1:		
# Imprimir mensaje pidiendo el nombre
		li $v0,4
		la $a0,tira3
		syscall
# Pedir cadena de caracteres(nombre) por pantalla
		li $v0,8
		la $a0,nombre
		li $a1,30
		syscall
# Imprimir mensaje pidiendo el telefono			
		li $v0,4
		la $a0,tira4
		syscall
# Pedir entero(telefono) por pantalla
		li $v0,5
		syscall
		sw $v0,tlf
# Imprimir mensaje pidiendo la direccion	
		li $v0,4
		la $a0,tira5
		syscall
# Pedir cadena de caracteres(direccion) por pantalla
		li $v0,8
		la $a0,direccion
		li $a1,22
		syscall
		la $a0,nombre		# Cargamos la direccion del nombre en $a0
		la $a2,tlf		# Cargamos la direccion del telefono en $a1
		lw $a2,0($a2)
		la $a1,direccion	# Cargamos la direccion de la direccion en $a1
		jal insert
		addi $s1,$s1,1     	# contador_agenda:=contador_agenda+1
# Borramos el nombre almacenado(evitando que el siguiente nombre se sobrescriba sobre el anterior)
		li $t4,0
		li $t5,28
volver:		sb $zero,0($a0)
		addi $a0,$a0,1
		addi $t4,$t4,1
		blt $t4,$t5,volver
# Borramos la direccion actual(evitando que la siguiente direccion se sobrescriba sobre la anterior)	
		li $t4,0
		li $t5,20
volver1:	sb $zero,0($a1)
		addi $a1,$a1,1
		addi $t4,$t4,1
		blt $t4,$t5,volver1
		j inicio
# Fin de programa
		li $v0,10
		syscall
		
###################################
# Subrutina que consulta los datos de un contacto
# Parametros: $a0 indice
##################################
consult:	move $t1,$a0
		bgtz  $s1,sig		# Comprobamos si el contador_agenda=0
# Imprimir mensaje de agenda vacia
		li $v0,4
		la $a0,tira6
		syscall
		j end
sig:		mul $t2,$t1,60		# Despalzamiento: indice*tamaño contacto(60)
		add $t2,$t0,$t2		# Dirección base del contacto: $t0+$t2
# Imprimir por pantalla tiraNombre
		li $v0,4
		la $a0,tiraNombre
		syscall
# Mostrar por pantalla el NOMBRE		
		li $t5,28		# tope=28
		li $t6,0		# i=0
		b cuerpo
incr:		addi $t6,$t6,1		# i:=i+1
		addi $t2,$t2,1		# Avanzamos 1 caracter del contacto
cuerpo:		li $v0,11
		lb $a0,0($t2)
		syscall					
		blt $t6,$t5,incr	# Comprobamos si i<tope para continuar con el bucle 
# Imprimir por pantalla tiraTlf
		li $v0,4
		la $a0,tiraTlf
		syscall
# Mostrar por pantalla el TELEFONO
		li $v0,1
		lw $a0,4($t2)		# Cargamos el telefono con un desplazamiento de 4 posiciones porque el puntero se encuentra en la posicion 28 del contacto debido al bucle anterior
		syscall
# Imprimir por pantalla tiraDireccion
		li $v0,4
		la $a0,tiraDireccion
		syscall
# Mostrar por pantalla la DIRECCION
		addi $t2,$t2,8		# Avanzamos el puntero del contacto 8 posiciones para que este alineado a la direccion
		li $t5,20		# tope=20
		li $t6,0		# i=0
		b cuerpo1
incr1:		addi $t6,$t6,1		# i:=i+1
		addi $t2,$t2,1		# Avanzamos 1 caracter del contacto
cuerpo1:	li $v0,11
		lb $a0,0($t2)
		syscall	
		blt $t6,$t5,incr1	# Comprobamos si i<tope para continuar con el bucle 
end:		jr $ra
###################################
# Subrutina que inserta un elemento nuevo en la agenda
# Parametros: $a0 Nombre, $a1 Dirección, $a2 tlf 
###################################
insert:		move $t1,$a0		# Carga del parametro nombre en $t1
		move $t2,$a1		# Carga del parametro direccion en $t2
		move $t3,$a2		# Carga del parametro telefono en $t3
		la $t0,contacto
		mul $t7,$s1,60		# Despalzamiento: contador_agenda*tamaño_contacto(60)
		add $t7,$t0,$t7		# Dirección base del contacto: $t0+$t7
# Insertar el NOMBRE	
		li $t5,28		# tope=28
		li $t6,0		# i=0
		b body
inc:		addi $t6,$t6,1		# i:=i+1
		addi $t1,$t1,1		# Avanzamos 1 caracter del NOMBRE
		addi $t7,$t7,1		# Avanzamos 1 posicion el contacto
body:		lb $t4,0($t1)		# Cargamos el byte del nombre en el registro $t4							
		sb $t4,0($t7)		# Almacenamos en el contacto el byte del caracter del nombre								
cond:		blt $t6,$t5,inc		# Comprobamos si i<tope para continuar con el bucle 
# Insertar el TELEFONO	
		sw $t3,4($t7)		# Guardamos con un desplazamiento de 4 posiciones porque el puntero se encuentra en la posicion 28 del contacto debido al bucle anterior
# Insertar la DIRECCION
		addi $t7,$t7,8		# Avanzamos 8 posicionez el puntero del contacto debido a que este se encuentra en la 28,situandonos en la posicion 36 del contacto
		li $t5,20		# tope=20
		li $t6,0		# i=0
		b body1
inc1:		addi $t6,$t6,1		# i:=i+1
		addi $t2,$t2,1		# Avanzamos caracteres de la DIRECCION
		addi $t7,$t7,1		# Avanzamos 1 posicion del contacto	
body1:		lb $t4,0($t2)		# Cargamos el byte de la direccion en el registro $t4
		sb $t4,0($t7)		# Almacenamos en el contacto el byte del caracter de la direccion
cond1:		blt $t6,$t5,inc1	# Comprobamos si i<tope para continuar con el bucle 
		jr $ra
		
		
		

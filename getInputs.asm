# (Função)
# getInputs: Recebe os inputs de entrada.
# Parâmetros: nenhum.
# Retorno:
# 	$s0: Endereço da string da base de origem.
# 	$s1: Tamanho de $s0.
# 	$s2: Endereço da string do número a ser convertido.
# 	$s3: Tamanho de $s2.
# 	$s4: Endereço da string da base de destino.
# 	$s5: Tamanho de $s4.
getInputs:

	# Salva a referência da main na pilha.
	addu $sp, $sp, -4
	sw $ra, ($sp)		

	# Exibe a mensagem de título na tela.
	li $v0, 4
    la $a0, mensagemTitulo
    syscall
    
    # Exibe a mensagem de opções na tela.
	li $v0, 4
    la $a0, mensagemOpcoes
    syscall
    
    # Requere a entrada da base de origem.
	li $v0, 4
    la $a0, requerirBaseInput
    syscall
    
    # Lê o caractere da base de entrada.
    # $s0 = String pointer.
    # $s1 = String length.
    li $v0, 8
    li $a1, 10
	syscall

	# Checa a validade da string de entrada.
	jal checkBaseInput
    
    # Pega o endereço da string (a0) e o tamanho (a1).
    move $s0, $a0		# Mover o endereço de a0 para s0.
    move $s1, $a1		# Mover o endereço de a1 para s1.
    
    # Requere o número a ser convertido.
	li $v0, 4
    la $a0, entradaNumero
    syscall
    
    # Lê o número de entrada.
    # $s2 = String pointer.
    # $s3 = String length.
    li $v0, 8
    lw $a1, MAX_BINARY_DIGITS
    syscall

	# Checa a validade da string de entrada.
	la $t2, ($a0)	   # Carrega o endereço da string do número antes do checkZero.
	jal checkZeroInput # Primeiro verifica se todos os caracteres dados são zero.
	jal checkNumberInput

    move $s2, $a0		# Mover o endereço de a0 para s2.
    move $s3, $a1		# Mover o endereço de a1 para s3.

	# Requere a entrada da base de destino.
	li $v0, 4
    la $a0, mensagemOpcoes
    syscall
    
    li $v0, 4
    la $a0, requerirBaseOutput
    syscall

    # Lê o caractere da base de saída.
    # $s4 = String pointer.
    # $s5 = String length.
    li $v0, 8
    li $a1, 10
    syscall

	# Checa a validade da string de entrada.
	jal checkBaseInput

    move $s4, $a0		# Mover o endereço de a0 para s4.
    move $s5, $a1		# Mover o endereço de a1 para s5.

	lw $ra, ($sp) 		# Recupera o endereço de retorno da main.
    	
    jr $ra

checkZeroInput:
    	
	li $t1, 10			# 10 = '\n'
	lb $t3, ($t2)		# Carrega o byte atual da string do número.
	beq $t1, $t3, Exit_ZERO

	# Se não for igual a zero, continua a verificação.
	li $t1, '0'
	bne $t3, $t1, return_SUCCESS
	
	addu $t2, $t2, 1	# Incrementa o ponteiro da string.
	
	j checkZeroInput
	
# (Subrotina de getInput)
# Checa se o número informado de entrada é compatível com a base escolhida.
checkNumberInput:

	# t0: Base dada de entrada.
	# t1: Registrador temporário para comparação.
	# t2: Endereço da string do número de entrada.
	lb $t0, ($s0)		# Carrega a base proposta de entrada.
	la $t2, ($a0)		# Carrega o endereço da string do número.

	# Verifica se a base de origem é binária.
	li	$t1, 'B'
	beq $t0, $t1, checkBinary

	li	$t1, 'b'
	beq $t0, $t1, checkBinary
	
	# Verifica se a base de origem é decimal.
	li	$t1, 'D'
	beq $t0, $t1, checkDecimal

	li	$t1, 'd'
	beq $t0, $t1, checkDecimal
	
	# Verifica se a base de origem é hexadecimal.
	li $t9, 0

	li	$t1, 'H'
	beq $t0, $t1, checkHexadecimal

	li	$t1, 'h'
	beq $t0, $t1, checkHexadecimal

# Confere se todos os dígitos estão entre 0 e 1.
checkBinary:
	
	li $t1, 10			# 10 = '\n'
	lb $t3, ($t2)		# Carrega o byte atual da string do número.
	beq	$t1, $t3, return_SUCCESS

	# Se menor que 0, indicar falha.
	li $t1, '0'
	blt $t3, $t1, Exit_FAILED
	
	# Se maior que 1, indicar falha.
	li $t1, '1'
	bgt $t3, $t1, Exit_FAILED
	
	addu $t2, $t2, 1	# Incrementa o ponteiro da string.
	j checkBinary

# Confere se todos os dígitos estão entre 0 e 9.
checkDecimal:

	li $t1, 10			# 10 = '\n'
	lb $t3, ($t2)		# Carrega o byte atual da string do número.
	beq	$t1, $t3, return_SUCCESS

	# Se menor que 0, indicar falha.
	li $t1, '0'
	blt $t3, $t1, Exit_FAILED
	
	# Se maior que 9, indicar falha.
	li $t1, '9'
	bgt $t3, $t1, Exit_FAILED
	
	addu $t2, $t2, 1	# Incrementa o ponteiro da string.
	
	j checkDecimal
		
# Confere se todos os dígitos estão entre 0 e 9 ou A e F.
checkHexadecimal:
	
	li $t1, 10	
	lb $t3, ($t2)
	beq	$t1, $t3, return_SUCCESS

	# Se menor que 0, indicar falha.
	li $t1, '0'
	blt $t3, $t1, Exit_FAILED
	
	# Se maior que 9, checar se é letra.
	li $t1, '9'
	bgt $t3, $t1, checkHexadecimal_secondCheck

	# Se chegar nesse bloco, o dígito está entre 0 e 9
	addu $t2, $t2, 1
	
	j checkHexadecimal


checkHexadecimal_secondCheck:
	
	# Se menor que 'A', indicar falha.
	li $t1, 'A'
	blt $t3, $t1, Exit_FAILED

	# Se maior que 'F', indicar falha.
	li $t1, 'F'
	bgt $t3, $t1, Exit_FAILED

	# Se chegar nesse bloco, o dígito está entre A e F
	addu $t2, $t2, 1
	addu $t9, $t9, 1			# Contador do tamanho da string que contem o numero em hexadecimal
	bgt $t9, 8, Exit_FAILED		# Se o numero em hexadecimal tiver mais que 8 digitos é invalido
	
	j checkHexadecimal

# (Subrotina de getInput)
# Checa se a base informada de entrada é compatível com as opções e a formatação proposta.
# Sendo $a0 a base.
checkBaseInput:

	lb $t0, ($a0)

	# Verifica se a base de origem é binario.
	li	$t1, 'B'
	beq $t0, $t1, checkStringInput

	li	$t1, 'b'
	beq $t0, $t1, checkStringInput
	
	# Verifica se a base de origem é decimal.
	li	$t1, 'D'
	beq $t0, $t1, checkStringInput

	li	$t1, 'd'
	beq $t0, $t1, checkStringInput
	
	# Verifica se a base de origem é hexadecimal.
	li	$t1, 'H'
	beq $t0, $t1, checkStringInput

	li	$t1, 'h'
	beq $t0, $t1, checkStringInput

	j Exit_FAILED

# Checa se a formatação está como o esperado.
checkStringInput:
	
	lb $t0, 1 ($a0)		# Pega 1 byte após o primeiro byte da string.
	li $t1, 10  		# 10 = '\n'.
	beq $t0, $t1, return_SUCCESS

	j Exit_FAILED

return_SUCCESS:

	jr $ra

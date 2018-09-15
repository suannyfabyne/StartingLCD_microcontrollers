;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2014                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                             LCD                                 *
;*                  SUANNY FABYNE DA SILVA VIEIRA                  *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		DADO		;ARMAZENA O DADO PARA A EEPROM
		NUMERONOME
		BITTESTE
		CONTBITTESTE
		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZAÇÃO DA EEPROM, DE ACORDO COM A DESCRIÇÃO NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDEREÇO ZERO DA EEPROM, DADOS EM ORDEM ALEATÓRIA
	ORG 0x2100 ;tinha usado pra gravar 'meu nome na eemprom, mas desisti
	DE	0X53,0X75,0X61,0X6E,0X6E,0X79

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*    gp4 mandará os dados pro display, gp5 será responsavel pelo enable, e gp0 pelo clock*
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÁ ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE DADO (DADO) NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUPÇÕES
	BANK0				;POSICIONA PARA BANK 0
	RETURN

ESCREVEDADO  ;ROTINA PARA ESCREVER PARTE DOS DADOS DA INICIALIZAÇÃO, REFERENTE A 101100 (BACKLIGHT, RS, DB4, DB5, DB6, DB7, NESTA ORDEM
	BCF GPIO, GP4 ;db7
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK
	BCF GPIO, GP4 ;db6
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK
	BSF GPIO, GP4 ;db5
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK
	BSF GPIO, GP4 ;db4
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK
	BCF GPIO, GP4 ;RS
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK
	BSF GPIO, GP4 ;BACKLIGHT
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK
	BSF GPIO, GP0	;CLOCK ;DOIS CLOCKS A MAIS, PARA DESLOCAR O DADO NO REG DE DESLOCAMENTO E COLOCA-LO NA POSIÇAO CERTA
	BCF GPIO, GP0	;CLOCK
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK	
	BSF GPIO, GP5	;enable
	BCF GPIO, GP5	;enable
	;CORPO DA ROTINA

	RETURN
	
DELAYUS ;rotina de delay

	BTFSS INTCON, T0IF
	GOTO DELAYUS
	RETURN

BITWRITE
	MOVLW .6 ;modo dinamico de ler os bits da tabela do fluxograma. Le os 6 bits da variavel posta em BITTESTE (BACKLIGHT, RS, DB4, DB5, DB6, DB7)
	MOVWF CONTBITTESTE
BITTEST
	BTFSS BITTESTE, 0 ;BITTESTE (BACKLIGHT, RS, DB4, DB5, DB6, DB7)
	GOTO LIMPAGP4 ;caso o bit menos significativo de bitteste for 1, seta o gp4, se nao, limpa
	BSF GPIO, GP4
VOLTOULIMPAGP4
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK
	RRF BITTESTE
	DECFSZ CONTBITTESTE
	GOTO BITTEST
	BSF GPIO, GP0	;CLOCK ;DOIS CLOCKS A MAIS, PARA DESLOCAR O DADO NO REG DE DESLOCAMENTO E COLOCA-LO NA POSIÇAO CERTA
	BCF GPIO, GP0	;CLOCK
	BSF GPIO, GP0	;CLOCK
	BCF GPIO, GP0	;CLOCK	
	BSF GPIO, GP5	;enable
	BCF GPIO, GP5	;enable
	BCF INTCON, T0IF
	MOVLW .255
	MOVWF TMR0
	CALL DELAYUS
	RETURN

LIMPAGP4
	BCF GPIO, GP4
	GOTO VOLTOULIMPAGP4
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000110'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW .0
	MOVWF NUMERONOME
	BCF INTCON, T0IF
	MOVLW .116
	MOVWF TMR0
INICIALIZAR ;começa a inicialização do display
	BTFSS INTCON, T0IF
	GOTO INICIALIZAR
	CALL ESCREVEDADO ;chama a rotina para mandar dados pro display
	BCF INTCON, T0IF
	MOVLW .216
	MOVWF TMR0
ESPERAR4.1
	BTFSS INTCON, T0IF
	GOTO ESPERAR4.1 ;delay de 4.1ms
	CALL ESCREVEDADO ;ESCREVEU
	BCF INTCON, T0IF
	MOVLW .255
	MOVWF TMR0
	CALL DELAYUS ;delay de 10ms
	CALL ESCREVEDADO ;ESCREVEU
	BCF INTCON, T0IF
	MOVLW .255
	MOVWF TMR0
	CALL DELAYUS
	
	MOVLW B'100100';escreve os dados da tabela em bitteste, para ser manipulada na rotina BITWRITE
	MOVWF BITTESTE ;(BACKLIGHT, RS, DB4, DB5, DB6, DB7)
	CALL BITWRITE
	MOVLW B'100100';
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'100001';
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'100000';
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'101111';
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'100000';
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'101000';
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'100000';
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'100110';
	MOVWF BITTESTE
	CALL BITWRITE
	
	BCF INTCON, T0IF ;delay para dar tempo de mandar as letras corretamentes, sem exclusão
	MOVLW .150
	MOVWF TMR0
	CALL DELAYUS
	
	MOVLW B'111010'; S manda os bits correspondente a letra S (1010) + RS(1) + BACKLIGHT (1). do menos significativo para o mais
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'111100'; S ;segue mesmo estilo para o resto dos caracteres  letra S (1100) + RS(1) + BACKLIGHT (1) 
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'111110'; U
	MOVWF BITTESTE
	CALL BITWRITE
	MOVLW B'111010'; U
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'110110'; A
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'111000'; A
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'110110'; N
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'110111'; N
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'110110'; N
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'110111'; N
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'111110'; Y
	MOVWF BITTESTE
	CALL BITWRITE	
	MOVLW B'111001'; Y
	MOVWF BITTESTE
	CALL BITWRITE

FIM
	GOTO FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END

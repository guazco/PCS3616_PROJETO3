; -------------------------------------------------------------------
; Ambiente de Execucao
; -------------------------------------------------------------------

;0x000  -- Funcoes do ambiente de execucao
@	/0000 ; origem absoluta

MAIN			JP  /0000

FINAL   		HM  FINAL

; -------------------------------------------------------------------
; Subrotina: MNEM2OP
; Converte um mnemonico em opcode
;
; -------------------------------------------------------------------

TABELA 		K /4A50 ; JP 
        	K /4A5A ; JZ 
        	K /4A4E ; JN 
        	K /4C56 ; LV 
        	K /4144 ; AD 
        	K /5342 ; SB 
        	K /4D4C ; ML 
        	K /4456 ; DV 
        	K /4C44 ; LD 
        	K /4D4D ; MM 
        	K /5343 ; SC 
        	K /5253 ; RS 
        	K /484D ; HM 
        	K /4744 ; GD 
        	K /5044 ; PD 
        	K /4F53 ; OS 
	
NUM 		K /0000 ; 0 
        	K /0001 ; 1 
        	K /0002 ; 2 
        	K /0003 ; 3 
        	K /0004 ; 4 
        	K /0005 ; 5 
        	K /0006 ; 6 
        	K /0007 ; 7 
        	K /0008 ; 8 
        	K /0009 ; 9 
        	K /000A ; A 
        	K /000B ; B 
        	K /000C ; C 
        	K /000D ; D 
        	K /000E ; E 
        	K /000F ; F 
PTAB 		K TABELA 
PNUM 		K NUM 
INITAB 		K TABELA 
ININUM 		K NUM 
;	
SC 			MNEM2OP ; chama SUB-ROTINA MNEM2OP 
; 
MNEM2OP 	K /0000 
LOOPMN 		LD PTAB 
        	AD LOAD 
        	MM VALMN 
        	VALMN K /0000 
        	SB MNEM 
        	JZ FIMMN 
        	LD PTAB 
        	AD DOIS 
        	MM PTAB 
        	JP LOOPMN 
FIMMN   	LD PTAB 
        	SB INITAB 
        	AD ININUM 
        	AD LOAD 
        	MM INSTMN 
INSTMN  	K /0000 
        	MM OPCODE 
        	LD INITAB 
        	MM PTAB 
        	RS MNEM2OP 
;

; -------------------------------------------------------------------
; Subrotina: LEITURA
; Faz a leitura de uma word - mesma funcao do Get Data
;
; -------------------------------------------------------------------
LEITURA   	K   /0000
          	LD  /300
          	AD  GDINST
          	MM  LER
LER       	K   /0000
;          	PD  /100 ; linha para debug
          	RS  LEITURA

; -------------------------------------------------------------------
; Subrotina: ATOHEX
; Converte uma word em ascii para um hexadecimal.
;
; Exemplo: ATOHEX("AB") = 0010 (i.e., 16 em decimal)
; -------------------------------------------------------------------
ATOHEX    	K   /0000
          	MM  CH_IN_A ; GUARDA EM CH_IN_A 
          	GD /300
          	MM  CH_IN_B ; GUARDA EM CH_IN_B
          	SC  CHTOI 
          	MM  VAR
          	RS  ATOHEX

; -------------------------------------------------------------------
; Subrotina: CHTOI
; Converte uma word em hexa para um número inteiro.
;
; Exemplo: CHTOI("0010") = 0010 (i.e., 16 em decimal)
; -------------------------------------------------------------------

; Parâmetros
CH_ANS          $       /0001        ; Variável para guardar resultado
CH_IN_A         $       /0001        ; 2 bytes mais significativos (em ASCII)
CH_IN_B         $       /0001        ; 2 bytes menos signicativos (em ASCII)

  ;; Corpo da subrotina
CHTOI           $       /0001
  ;; Zera CH_ANS
                LD      ZERO
                MM      CH_ANS
  ;; Unpack primeira palavra
                LD      CH_IN_A
                MM      WORD
                SC      UNPACK
  ;; Processa primeira palavra
  ;; Processa primeiro byte
                LD      UNP_B1
                SC      IS_HEX
                JN      CH_RET
                SB      CH_0
                ML      EIGHT
                MM      CH_ANS
  ;; Processa segundo byte
                LD      UNP_B2
                SC      IS_HEX
                JN      CH_RET
                SB      CH_0
                ML      FOUR
                AD      CH_ANS
                MM      CH_ANS
  ;; Unpack segunda palavra
                LD      CH_IN_B
                MM      WORD
                SC      UNPACK
  ;; Processa segunda palavra
  ;; Processa primeiro byte
                LD      UNP_B1
                SC      IS_HEX
                JN      CH_RET
                SB      CH_0
                ML      TWO
                AD      CH_ANS
                MM      CH_ANS
  ;; Processa segundo byte
                LD      UNP_B2
                SC      IS_HEX
                JN      CH_RET
                SB      CH_0
                AD      CH_ANS
  ;; Valor da resposta está no acumulador!
CH_RET          RS      CHTOI

; -------------------------------------------------------------------
; Subrotina: UNPACK
; Extrai os bytes de uma word contida no acumulador, colocando-os
; em dois endereços da memória.
;
; Exemplo: dada a word XYZT no acumulador, ao final da execução,
; UNP_B1="00XY" e UNP_B2="00ZT".
; -------------------------------------------------------------------

; Parâmetros
WORD            $       /0001       ; Word de entrada
UNP_B1          $       /0001       ; Byte mais significativo
UNP_B2          $       /0001       ; Byte menos significativo

; Constantes
SHIFT		    K       /0100
CH_0		    K       /0030
CH_F		    K       /0046
X_INI		    K       /003A
X_END	        K       /0041
X_DIFF	        K       /0007
ONE		    	K       /0001
MINUS_1	        K       /FFFF
ZERO		    K       /0000
EIGHT		    K       /1000
FOUR		    K       /0100
TWO		    	K       /0010

; Corpo da subrotina
UNPACK          $	    /0001
                MM	    WORD	    ; Carrega word. Primeiramente faremos unpack de B2
                ML	    SHIFT       ; Desloca os bytes para remover 2 primeiros hex
                SC	    RSHIFT2	    ; Desloca os bytes menos significativos pro seu lugar
                MM	    UNP_B2	    ; Salva resultado
                LD	    WORD	    ;
                SC	    RSHIFT2	    ;
                MM	    UNP_B1	    ;
               	RS	    UNPACK	    ; Retorna

; -------------------------------------------------------------------
; Subrotina: READ
; Faz a leitura das linhas do codigo compilado
;
; -------------------------------------------------------------------

READ		    JP	/0000			; endereco de retorno
		        GD	/300	        ; le primeira word
		        MM	DATA		; guarda a word em DATA
		        SB	EOF		; checa se eh EOF
                        JZ	FIM	        ; se for, vai para o fim
		        SC	CHECAROTULO	; se nao, checa rotulo
		        GD	/0000		; ADICIONAR VERIFICACAO DE ERRO
		        SC	CHECAINSTR	; chama subrotina para checar instrucao
		        SC	CHECAVAL	; chama subrotina para checar valor
		        LD	IC		; carrega o instruction counter
		        AD	DOIS            ; soma dois para para a proxima instrucao
		        MM	IC 		; salva ic
		        LD	STP		; 
		        AD	MOVEM           ;
		        MM	MVIC            ;
		        LD	IC              ;
MVIC		        K	/0000                   ;
FIM		        HM	FIM             ; 
		
; -------------------------------------------------------------------
; Subrotina: CHECAROTULO
; Faz a analise do rotulo associado a uma linha de instrucao
;
; -------------------------------------------------------------------
CHECAROTULO 	JP	/0000           ; endereco de retorno
			    LD	STP             ; carrega stp
			    AD	MOVEM           ; adiciona comando de salvamento
			    MM	MVTOM           ; grava na linha mvto
			    LD	DATA            ; carrega rotulo
MVTOM		    K	/0000           ; salva na pilha
			    LD	STP             ; carrega ponteiro da pilha
			    SB	DOIS            ; subtrai dois e vai para proxima posicao
			    MM	STP             ; salva no ponteiro
    	        RS	CHECAROTULO     ; retorna da subrotina
                
; -------------------------------------------------------------------
; Subrotina: CHECAINST
; Faz a analise da instrucao associada a uma linha do codigo
;
; -------------------------------------------------------------------
CHECAINST		JP	/0000           ; endereco de retorno
			    GD	/300            ; le instrucao
			    MM	WORD            ; converte de ascii para mnemonico
			    SC	UNPACK          
			    LD	UNP_B1          
                ML	L1SHIFT         
                AD	UNP_B2              
                MM	MNEM            ; salva o mnemonico
			    SC	MNEM2OP         ; converte mnemonico para opcode
			    LD	OPCODE          ; corrige o opcode para transformar em instrucao
			    ML	L3SHIFT
			    MM	OPER            ; instrucao originada no opcode
			    LD	STP             
			    AD	MOVEM
			    MM	MVTOM
			    LD	OP
MVTOM		    K	/0000           ; guarda operacao na pilha
			    LD	STP             ; sobe o stackpointer em um endereco
			    SB	DOIS
			    MM	STP
    	        RS	CHECAINST;

; -------------------------------------------------------------------
; Subrotina: CHECAVAL
; Faz a analise do valor associado a uma linha de instrucao
;
;ROTULObbINSTRUCAOb/VALOR		modelo 1 de linha de instrucao
;ROTULObbINSTRUCAObbROTULO2	    modelo 2 de linha de instrucao 
; -------------------------------------------------------------------

BET			    K	/0000   ; variavel que armazena o valor lido
DIGF			K	/0000   ;
PTH			    K	STP     ; pointer que serve para varrer a tabela em busca do rótulo

CHECAVAL		JP	/0000
			    GD	/300	; le proximos dois bytes
			    MM	BET     ; salva eles no bet    
                SB	ROT     ; subtrai do padrao esperado para rotulos     
                JZ	RC	    ; pula para rc se o padrao for o de rotulo
                LD	BET     ; se nao for recarrega o que foi lido
                SB	ESP	    ; subtrai do padrao esperado para valores
                JZ	VC      ; pula para vc se o padrao for o de valores
                JP	ERROVAL	; pula para erro caso nenhuma condicao seja satisfeira

VC			    GD	/300	; le 2 bytes
			    SC	ATOHEX  ; usa funcao para gerar versao do valor em hexa
			    MM	DIGF    ; salva esse valor em digf
			    LD	STP     ; carrega apontador da pilha
			    AD	MOVEM   ; adiciona comando de salvamento na memoria
			    MM	MVTOM1  ; salva na linha mvtom1
			    LD	DIGF    ; carrega digf
MVTOM1		    K	/0000   ; usa comando de salvamento na memoria
			    JP	END     ; pula para o fim
		
RC			    GD	/300    ; le 2 bytes
			    MM	BET     ; salva em bet
LOOP		    LD	PTH     ; carrega o ponteiro de stp
			    AD 	LOAD    ; adiciona comando de carregamento da memoria
			    MM	TABR    ; guarda na linha tabr
TABR		    K	/0000   ; le o que esta guardado naquela posicao
			    SB	BET     ; subtrai o rotulo
			    JZ	ESC     ; se o rótulo for igual pula para escrita (ESC)
                            LD	PTH     ; carrega o ponteiro de stp
                            AD	DOIS    ; adiciona dois para ir para o próximo endereço
                            MM	PTH     ; atualiza ponteiro
                            JP	LOOP	; volta para o comeco do loop
ESC			    LD	STP     ; carrega stack pointer 
			    AD	MOVEM   ; adiciona comando de salvamento
			    MM	MVTOM2  ; salva na linha mvtom2
			    LD	PTH     ; carrega ponteiro auxiliar 
			    SB	SEIS    ; subtrai 6 desse ponteiro
MVTOM2		    K	/0000   ; salva esse endereco na pilha
END			    LD	STP     ; carrega o stack pointer
			    SB	DOIS    ; subtrai dois
			    MM	STP     ; salva no stp

;===================================================================================





@	/02FF
;0x2FF -- Início da área de código @ /02FF



@	/08FF
;0x8FF -- Início da área estática @ /08FF

;Parâmetros:
;MontePointer → MTP
;StackPointer → STP
;InstructionPointer → ICP

; ** PONTEIROS **
STP		        K	/0FFF   ; stack pointer
MTP		        K	/09FF   ; monte pointer

; ** EXCECOES **
ERROVAL	        LD	ERVAL   ; erro no valor
		        OS	/0EE
EV1		        HM	EV1	

ERROEOF	        LD	EREOF   ; erro por falta de fim de arquivo
		        OS	/0EE    
EV2		        HM	EV2

; ** CONSTANTES **
UM 		        K 	/0001 ; constante 1
DOIS		    K	/0002 ; constante 2
SEIS		    K	/0006 ; constante 6
ASCCTE	        K	/0031 ; constante corrige letras
EOF		        K	/2320 ; # + ESPACO
ROT		        K	/2020 ; ascii para espaço espaço
ESP		        K	/202F ; ascii para espaço barra

L3SHIFT	        K	/1000 ; jogar numero 3 casas para a esquerda   
L1SHIFT	        K	/0010 ; jogar numero 1 casa para a esquerda

ERVAL		    K	/0001 ; A SETAR 
EREOF		    K	/0002 ; A SETAR

; ** VARIAVEIS **
IC		        K	/0000   ; instruction counter
VAR		        K	/0000   ; variavel da conversao de ascii para hex
DATA		    K	/0000   
OPER		    K	/0000	
OPCODE          K   /000E 
MNEM            K   /0000 

; ** INSTRUCOES **

LOAD		    K	/8000   ; instrucao de carregamento do conteudo de um endereco
MOVEM	        K	/9000   ; instrucao de salvamento em um endereco

@	/09FF
;0x9FF -- Início do monte @ /09FF


MEMÓRIA LIVRE


;0xFFF -- Início da pilha @ /0FFF


===================================================================================

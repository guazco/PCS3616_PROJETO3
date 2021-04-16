; Versao do codigo em C--
;
; int a;
; int b;
; int c;
; int d;
;
; c = a + b;
; d = a * b;
;
; if c > d;
; print c 
; if d > c;
; print d
;
& /0100
JP		MAIN

A 		K	/0000
		K	/0000
AP  	K	A

B 		K	/0000
		K	/0000
BP  	K	B

C 		K	/0000
		K	/0000
CP  	K	C

D 		K	/0000
		K	/0000
DP  	K	D


MAIN 	

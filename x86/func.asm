;=====================================================================
; ECOAR - example Intel x86 assembly program
;
; Author:      Zbigniew Szymanski
; Date:        2016-03-16
; Description: Function converts first character to an 'w'.
;              int func(char *a);
;
;=====================================================================

section	.text
global  func

func:
	push	ebp
	mov	ebp, esp
	mov	eax, DWORD [ebp+8]	;address of *a to eax
	mov	BYTE [eax], 'w'		;a[0]='w'
	mov	eax, 0			;return 0
	pop	ebp
	ret

;============================================
; THE STACK
;============================================
;
; larger addresses
; 
;  |                               |
;  | ...                           |
;  ---------------------------------
;  | function parameter - char *a  | EBP+8
;  ---------------------------------
;  | return address                | EBP+4
;  ---------------------------------
;  | saved ebp                     | EBP, ESP
;  ---------------------------------
;  | ... here local variables      | EBP-x
;  |     when needed               |
;
; \/                              \/
; \/ the stack grows in this      \/
; \/ direction                    \/
;
; lower addresses
;
;
;============================================

; ============================================================================
;
; Jakub Tomkiewicz
; Index: 300183
;
; x86-32 Project No. 21 Adding Text
;
; ============================================================================

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
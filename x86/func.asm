; ========================================
;
; Jakub Tomkiewicz
; Index: 300183
;
; x86-32 Project No. 21 Adding Text
;
; ========================================

; func(image *numbersImg, image *srcImg, int startX, int startY, int numberX)

section	.text
global func

func:
	push ebp
	mov	ebp, esp

; create pointers & place them in proper place
setupPointers: 

	mov eax, 0
	mov [esp + 16], eax ; i = 0

; for (int i = 0; i < 8; i++)
loopI:

	mov eax, 8
	cmp [esp + 16], eax ; i == 8
	je afterLoopI

	mov eax, 0 
	mov [esp + 20], eax ; j = 0

; for (int j = 0; j < 24; j++)
loopJ:

	mov eax, 24
	cmp [esp + 20], eax ; j == 24
	je afterLoopJ

	mov eax, [esi] ; eax = *pNumbers
	mov [edi], eax ; *pSrc = eax

	mov eax, 4
	add esi, eax ; pNumbers++
	add edi, eax ; pSrc++

	mov eax, 1
	add [esp + 20], eax ;j++
	jmp loopJ

; when loopJ finishes, increment pScr and pNumbers
afterLoopJ:

	mov eax, 936 ; 960 - 24 (so line width - 3 * 8)
	add esi, eax ; pNumbers += 936
	add edi, eax ; pSrc += 936

	mov eax, 1
	add [esp + 16], eax ;j++
	jmp loopI

; when loopI finishes, exit
afterLoopI:
	pop	ebp
	ret
; ========================================
;
; Jakub Tomkiewicz
; Index: 300183
;
; x86-32 Project No. 21 Adding Text
;
; ========================================

; func(image *numbersImg, image *srcImg, unsigned int startX, unsigned int startY, unsigned int numberX)

section	.text
global func

func:
	push ebp
	mov	ebp, esp
	push ebx
	push edi
	push esi

	sub esp, 8 ; place for i and j (loop variables)

	; numbersImg pointer
	mov eax, [ebp + 8] ; address of numbersImg struct
	mov esi, [eax + 16] ; *img

	mov eax, 3
	mov ebx, [ebp + 24] ; numberX
	imul eax, ebx ; numberX * 3
	add esi, eax ; pNumbers += (numberX * 3)

	; scrImg pointer
	mov eax, [ebp + 12] ; address of srcImg struct
	mov edi, [eax + 16] ; *img

	mov eax, 960 ; srcImg -> lineSize
	mov ebx, [ebp + 20] ; startY
	imul eax, ebx ; startY * srcImg -> lineSize
	add edi, eax ; pSrc += (startY * srcImg -> lineSize)

	mov eax, 3
	mov ebx, [ebp + 16] ; startX
	imul eax, ebx ; startX * 3
	add edi, eax ; pSrc += (startX * 3)

	mov eax, 0
	mov [esp + 0], eax ; i = 0

; for (int i = 0; i < 8; i++)
loopI:
	mov eax, 8
	cmp [esp + 0], eax ; i == 8
	je afterLoopI

	mov eax, 0 
	mov [esp + 4], eax ; j = 0

; for (int j = 0; j < 24; j++)
loopJ:
	mov eax, 24
	cmp [esp + 4], eax ; j == 24
	je afterLoopJ

	mov eax, [esi] ; eax = *pNumbers
	mov [edi], eax ; *pSrc = eax

	mov eax, 1
	add esi, eax ; pNumbers++
	add edi, eax ; pSrc++

	mov eax, 1
	add [esp + 4], eax ; j++
	jmp loopJ

; when loopJ finishes, increment pScr and pNumbers
afterLoopJ:
	mov eax, 936 ; 960 - 24 (so line width - 3 * 8)
	add esi, eax ; pNumbers += 936
	add edi, eax ; pSrc += 936

	mov eax, 1
	add [esp + 0], eax ; i++
	jmp loopI

; when loopI finishes, exit
afterLoopI:
	pop esi ; recover registers
	pop edi
	pop ebx
	mov esp, ebp ; deallocate local variables
	pop	ebp ; restore base pointer value
	ret
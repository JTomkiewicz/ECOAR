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

	; numbersImg pointer
	mov eax, [ebp + 8] ; address of numbersImg struct
	mov esi, [eax + 16] ; *img

	mov eax, [ebp + 24] ; numberX
	lea eax, [2*eax + eax] ; numberX * 3
	add esi, eax ; pNumbers += (numberX * 3)

	; scrImg pointer
	mov eax, [ebp + 12] ; address of srcImg struct
	mov edi, [eax + 16] ; *img

	mov eax, [eax + 12] ; srcImg -> lineSize
	mov edx, eax ; keep lineSize for later, it will be usefull in loop
	mov ebx, [ebp + 20] ; startY
	imul eax, ebx ; startY * srcImg -> lineSize
	add edi, eax ; pSrc += (startY * srcImg -> lineSize)

	mov eax, [ebp + 16] ; startX
	lea eax, [2*eax + eax] ; startX * 3
	add edi, eax ; pSrc += (startX * 3)

	sub edx, 24 ; lineSize - 3 * 8

	mov eax, 7
	mov ebx, eax ; i = 7

; for (int i = 7; i >= 0; i--)
loopI:
	mov eax, 23 
	mov ecx, eax ; j = 23

; for (int j = 23; j >= 0; j--)
loopJ:
	mov eax, [esi] ; eax = *pNumbers
	mov [edi], eax ; *pSrc = eax

	mov eax, 1
	add esi, eax ; pNumbers++
	add edi, eax ; pSrc++

	mov eax, 0
	cmp ecx, eax ; j == 0
	je afterLoopJ

	mov eax, 1
	sub ecx, eax ; j--
	jmp loopJ

; when loopJ finishes, increment pScr and pNumbers
afterLoopJ:
	add esi, edx ; pNumbers += 936
	add edi, edx ; pSrc += 936

	mov eax, 0
	cmp ebx, eax ; i == 0
	je afterLoopI

	mov eax, 1
	sub ebx, eax ; i--
	jmp loopI

; when loopI finishes, exit
afterLoopI:
	pop esi ; recover registers
	pop edi
	pop ebx
	mov esp, ebp ; deallocate local variables
	pop	ebp ; restore base pointer value
	ret
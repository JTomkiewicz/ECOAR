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
global  func

func:
	push	ebp
	mov	ebp, esp

; copy number from numbersImg at location [numberX, 0]
mov eax, [ebp + 8] ; eax is address of the struct numbersImg 

; paste copied number into srcImg at location [startX, startY]
mov eax, [ebp + 12] ; eax is address of the struct srcImg

mov eax, [ebp + 16] ; eax is address of the int startX
mov eax, [ebp + 20] ; eax is address of the int startY
mov eax, [ebp + 24] ; eax is address of the int numbersX

exit:
	pop	ebp
	ret
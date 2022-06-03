#autor: Imenko Prezimić INDEX ra1234-2018

.section .data
ispis1:     .ascii "Unseite logicki izraz: \0"
ispis2:     .ascii "Rezultat: \0"
greska1:    .ascii "Greska kod operanda.\n\0"
greska2:    .ascii "Greska kod operacije.\n\0"
newlin:     .ascii "\n\0"

string1: .fill 101, 1, 42

niz_brojeva: .fill 20, 4, 0
niz_operacija: .fill 20, 1, 0

broj_brojeva: .long 0
broj_operacija: .long 0

rezultat: .fill 20, 1, 48
operacija_dodata: .long 0
greska: .long 0

.section .text
.globl main

.macro ispisi_string str
	movl $4, %eax
	movl $1, %ebx
	movl $\str, %ecx
	movl $0, %edx
1:
	cmpb $0, (%ecx)
	je 2f
	
	incl %ecx
	incl %edx
	jmp 1b
2:
	movl $\str, %ecx
	int $0x80
.endm

.macro unesi_string str, int
	movl $3, %eax
	movl $0, %ebx
	movl $\str, %ecx
	movl $\int, %edx
	int $0x80
	
	decl %eax
	movb $0, \str(, %eax, 1)
.endm

main:
	ispisi_string ispis1
	unesi_string string1, 101

	pushl $string1
	call ubaci_u_niz
	addl $4, %esp
	
	cmpl $1, greska
	je ispisi_gresku_1
	
	cmpl $2, greska
	je ispisi_gresku_2

	movl $0, %esi
	movl $0, %edi

	movl niz_brojeva(, %esi, 4), %eax	# prvi_broj

petlja:
	cmpl $0, broj_brojeva
	je uspesno_ispisi_rezultat

	incl %esi
	movl niz_brojeva(, %esi, 4), %ebx	# drugi broj
	decl %esi

	movb niz_operacija(, %edi, 1), %cl	# operacija
	
	cmpb $'&', %cl
	je andovanje
	
	cmpb $'^', %cl
	je xorovanje
	
	cmpb $'|', %cl
	je orovanje

	jmp ispisi_gresku_1
	
andovanje:
	andl %ebx, %eax	# ebx glavni broj
	
	incl %esi
	incl %edi
	decl broj_brojeva
	jmp petlja

xorovanje:
	xorl %ebx, %eax
	
	incl %esi
	incl %edi
	decl broj_brojeva
	jmp petlja

orovanje:
	orl %ebx, %eax
	
	incl %esi
	incl %edi
	decl broj_brojeva
	jmp petlja

uspesno_ispisi_rezultat:
	pushl %eax
	ispisi_string ispis2
	popl %eax
	
	pushl %eax
	call konvertuj_u_string
	addl $4, %esp
	
	movl $0, %ebx
	jmp zavrsi

ispisi_gresku_1:
	ispisi_string greska1
	movl $1, %ebx
	jmp zavrsi
	
ispisi_gresku_2:
	ispisi_string greska2
	movl $1, %ebx
	jmp zavrsi

zavrsi:
	movl $1, %eax
	int $0x80


#######################
konvertuj_u_string:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi
	
	
	movl 8(%ebp), %eax	# broj
	movl $rezultat, %esi
	
	movl $8, %ebx
	movl $0, %ecx
petlja_pp2:
	cmpl $0, %eax
	je okreni_pre_pp2
	
	movl $0, %edx
	divl %ebx
	
	addb $48, %dl
	movb %dl, (%esi)
	
	incl %esi
	jmp petlja_pp2

okreni_pre_pp2:
	movb $0, (%esi)
	decl %esi
	
	movl $rezultat, %edi

okreni_pp2:
	cmpl %esi, %edi
	jae zavrsi_pp2
	
	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	jmp okreni_pp2

zavrsi_pp2:
	ispisi_string rezultat

	popl %edi
	popl %esi
	movl %ebp, %esp
	popl %ebp
	
	ret


#######################
ubaci_u_niz:
	pushl %ebp
	movl %esp, %ebp
	
	subl $4, %esp
	
	pushl %esi
	pushl %edi
	pushl %ebx
	
	movl 8(%ebp), %esi	# adresa

	movl $0, %eax
	movl $10, %ebx
	movl $0, %ecx
	
	movl $0, %edi
	movl $0, %edx
	pushl %edx

	movl $1, operacija_dodata

petlja_pre_pp1:
	cmpb $'&', (%esi)
	je operacija_je_pp1
	
	cmpb $'|', (%esi)
	je operacija_je_pp1
	
	cmpb $'^', (%esi)
	je operacija_je_pp1
	
	cmpb $' ', (%esi)
	jne ubaci_element_u_niz_pp1_pre

	incl %esi
	
	jmp petlja_pre_pp1
	
operacija_je_pp1:
	incl operacija_dodata
	movb (%esi), %al
	popl %edx
	movb %al, niz_operacija(, %edx, 1)
	
	incl %edx
	pushl %edx
	incl %esi
	jmp petlja_pre_pp1
	
ubaci_element_u_niz_pp1_pre:
	movl $0, %eax
	movl $10, %ebx
	movl $0, %ecx
	
petlja_pp1:
	cmpb $' ', (%esi)
	je ubaci_element_u_niz_pp1
	
	cmpb $0, (%esi)
	je ubaci_zadnji_element_u_niz_pp1
	
	cmpb $'0', (%esi)
	je proveri_heksadecimalni_pp1
	
	cmpb $'0', (%esi)
	jl greska_pp1_1
	
	cmpb $'9', (%esi)
	jg greska_pp1_1
	
	movb (%esi), %cl
	subb $48, %cl
	
	mulb %bl
	jc greska_pp1_1
	
	addb %cl, %al
	jc greska_pp1_1
	
preskoci_element_pp1:
	incl %esi
	jmp petlja_pp1

proveri_heksadecimalni_pp1:
	incl %esi
	
	cmpb $'x', (%esi)
	je jeste_heksadecimalni_pp1
	
	cmpb $'X', (%esi)
	je jeste_heksadecimalni_pp1
	
	cmpb $' ', (%esi)
	je ubaci_nulu_u_niz_pp1

jeste_heksadecimalni_pp1:
	movl $0, %eax
	movl $16, %ebx
	movl $0, %ecx
	
	incl %esi
	
heksadecimalna_konverzija_pp1:
	cmpb $' ', (%esi)
	je ubaci_element_u_niz_pp1
	
	cmpb $0, (%esi)
	je ubaci_zadnji_element_u_niz_pp1
	
	cmpb $'0', (%esi)
	jl greska_pp1_1
	
	cmpb $'f', (%esi)
	jg greska_pp1_1
	
	movb (%esi), %cl
	subb $48, %cl
	
	cmpb $9, %cl
	jg treba_oduzeti_39_heks_pp1
	
	mulb %bl
	jc greska_pp1_1
	
	addb %cl, %al
	jc greska_pp1_1
	
	incl %esi
	jmp heksadecimalna_konverzija_pp1
	
treba_oduzeti_39_heks_pp1:
	subb $39, %cl
	
	cmpb $0, %cl
	jl dodaj_do_velikog_slova
	
	mull %ebx
	addl %ecx, %eax
	
	incl %esi
	jmp heksadecimalna_konverzija_pp1

dodaj_do_velikog_slova:
	addb $32, %cl
	
	mull %ebx
	addl %ecx, %eax
	
	incl %esi
	jmp heksadecimalna_konverzija_pp1

ubaci_nulu_u_niz_pp1:
	movl $0, %eax

ubaci_element_u_niz_pp1:
	cmpl $1, operacija_dodata
	jne greska_pp1_2

	movl $0, operacija_dodata

	movl %eax, niz_brojeva(, %edi, 4)
	incl %edi
	incl %esi
	
	movl $0, %eax
	movl $10, %ebx
	movl $0, %ecx
	jmp petlja_pre_pp1
	
ubaci_zadnji_element_u_niz_pp1:
	movl %eax, niz_brojeva(, %edi, 4)
	
	movl %edi, broj_operacija
	jmp zavrsi_pp1

greska_pp1_1:
	movl $1, greska
	
	popl %edx
	popl %ebx
	popl %edi
	popl %esi
	addl $4, %esp
	
	movl %ebp, %esp
	popl %ebp
	ret
	
greska_pp1_2:
	movl $2, greska
	
	popl %edx
	popl %ebx
	popl %edi
	popl %esi
	addl $4, %esp
	
	movl %ebp, %esp
	popl %ebp
	ret

zavrsi_pp1:
	popl %edx
	movl %edx, broj_operacija
	movl %edi, broj_brojeva
	popl %ebx
	
	popl %edi
	popl %esi
	addl $4, %esp
	
	movl %ebp, %esp
	popl %ebp
	
	ret

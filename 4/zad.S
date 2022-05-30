# autor: Imenko Prezimić INDEX in12-2018
# fajlovi: zad.S

# Ako vaše rešenje sadrži dodatne fajlove, stavite njihove nazive u liniju fajlovi
# Na primer, ako imate i potprogram u pp.S, iza fajlovi treba da stoji: zad.S pp.S

.section .data
in_max = 12
msg1:   .ascii "Unesite pocetni clan: \0"
msg2:   .ascii "Unesite gornju granicu: \0"
msg3:   .ascii "Suma geometrijske progresije je: \0"
sum: 	.fill in_max,1,0
lb:	.fill in_max,1,0
ub:  	.fill in_max,1,0
error: 	.long 0
errop:  .ascii "Nedozvoljena vrednost ulaza!\n\0"
erroflw:.ascii "Prekoracenje opsega!\n\0"

pocetni: .fill 12, 1, 42
gornja: .fill 12, 1, 42

string: .fill 12, 1, 0

greska: .byte 0

.section .text
.globl main

.macro ispisi_string str
	movl $4,%eax
	movl $1,%ebx
	movl $\str,%ecx
	movl $0,%edx
1:  	cmpb $0,(%ecx)
    	je 2f
    	incl %ecx
    	incl %edx
    	jmp 1b
2:  	movl $\str,%ecx
    	int $0x80
.endm

main:
	ispisi_string msg1	# ispisi msg1

	movl $3, %eax		# unesi str
	movl $0, %ebx
	movl $pocetni, %ecx
	movl $in_max, %edx
	int $0x80

	ispisi_string msg2	# ispisi msg2
	
	movl $3, %eax		# unesi str2
	movl $0, %ebx
	movl $gornja, %ecx
	movl $in_max, %edx
	int $0x80

	movl $10, %ebx
	movl $0, %eax
	movl $0, %ecx
	movl $pocetni, %esi
	
konverzija_1:
	cmpb $0, (%esi)
	je upisi_prvi_broj
	
	cmpb $'*', (%esi)
	je upisi_prvi_broj
	
	cmpb $'\n', (%esi)
	je upisi_prvi_broj
	
	cmpb $'0', (%esi)
	jl greska_1
	
	cmpb $'9', (%esi)
	jg greska_1
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jo greska_2
	addl %ecx, %eax
	jo greska_2
	incl %esi
	jmp konverzija_1
	
upisi_prvi_broj:
	movl %eax, lb
	
	movl $10, %ebx
	movl $0, %eax
	movl $0, %ecx
	movl $gornja, %esi
	
konverzija_2:
	cmpb $0, (%esi)
	je upisi_drugi_broj
	
	cmpb $'*', (%esi)
	je upisi_drugi_broj
	
	cmpb $'\n', (%esi)
	je upisi_drugi_broj
	
	cmpb $'0', (%esi)
	jl greska_1
	
	cmpb $'9', (%esi)
	jg greska_1
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jo greska_2
	
	addl %ecx, %eax
	jo greska_2
	
	incl %esi
	jmp konverzija_2
	
upisi_drugi_broj:
	movl %eax, ub
	
	movl lb, %eax
	movl $2, %ebx
	
glavna_petlja:
	cmpl %eax, ub
	je konvertuj_u_string_pre
	
	addl %eax, sum
	jo greska_2
	
	mull %ebx
	jo greska_2
	
	jmp glavna_petlja
	
konvertuj_u_string_pre:
	addl %eax, sum
	
	movl sum, %eax
	movl $string, %esi
	movl $10, %ebx
	
konvertuj_u_string:
	cmpl $0, %eax
	je obrni_ispis_pre
	
	movl $0, %edx
	divl %ebx
	
	movb %dl, (%esi)
	addb $48, (%esi)
	
	incl %esi
	
	jmp konvertuj_u_string

obrni_ispis_pre:
	movl $string, %edi
	
	movb $0, (%esi)
	decl %esi
	
obrni_ispis:
	cmpl %esi, %edi
	jae ispisi_rezultat
	
	movb (%esi), %al
	movb (%edi), %ah
	
	movb %ah, (%esi)
	movb %al, (%edi)
	
	incl %edi
	decl %esi
	jmp obrni_ispis
	
ispisi_rezultat:
	ispisi_string msg3
	ispisi_string string
	jmp kraj

greska_1:
	ispisi_string errop
	movb $1, greska
	jmp kraj

greska_2:
	ispisi_string erroflw
	movb $2, greska
	jmp kraj

kraj:
	movl $0, %eax
	movb greska, %al
	movl $1, %ebx
	int $0x80

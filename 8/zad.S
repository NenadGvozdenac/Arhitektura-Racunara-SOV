#autor: Imenko Prezimić INDEX ra1234-2018
.section .data
ispis1:     .ascii "Unesite do 10 dekadnih brojeva (niz1): \0"
ispis2:     .ascii "Unesite do 10 dekadnih brojeva (niz2): \0"
ispis3:     .ascii "Transformisan drugi niz: \0"
greska1:    .ascii "Greska1 \0"
greska2:    .ascii "Greska2\n\0"
newlin:     .ascii "\n\0"

razmak:     .ascii " \0"

ispis_krajnji:	.fill 50, 1, 42

niz1_str:	.fill 151, 1, 42
niz2_str:	.fill 151, 1, 42

niz1_i:	.fill 20, 4, 0
niz2_i:	.fill 20, 4, 0

broj_elemenata: .long 0

greska:	.long 0

.section .text
.global main
.globl proveri_validnost
.globl izvedi_elemente

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
	unesi_string niz1_str, 151

	ispisi_string ispis2
	unesi_string niz2_str, 151

	pushl $niz1_str	# push adresu ispis1
	call proveri_validnost
	addl $4, %esp
	
	cmpl $1, greska
	je ispisi_gresku_1
	
	pushl $niz2_str
	call proveri_validnost
	addl $4, %esp
	
	cmpl $1, greska
	je ispisi_gresku_1

	pushl $niz1_str
	pushl $niz1_i
	call izvedi_elemente	
	addl $8, %esp
	
	cmpl $1, greska
	je ispisi_gresku_1
	
	pushl $niz2_str
	pushl $niz2_i
	call izvedi_elemente	
	addl $8, %esp

	cmpl $1, greska
	je ispisi_gresku_1
	
	decl broj_elemenata

	movl broj_elemenata, %eax
		
proveri_velicine_prvog_niza:
	cmpl $0, niz1_i(, %eax, 4)
	jl ispisi_gresku_2
	
	cmpl $20, niz1_i(, %eax, 4)
	jg ispisi_gresku_2
	
	cmpl $0, %eax
	je glavna_petlja_jos_pre
	
	decl %eax
	jmp proveri_velicine_prvog_niza

glavna_petlja_jos_pre:	
	movl $0, %esi

glavna_petlja_pre:
	cmpl %esi, broj_elemenata
	jl zavrsi_program_pre

	movl niz1_i(, %esi, 4), %eax
	
glavna_petlja:
	movl $5, %ebx
	
	movl $0, %edx
	divl %ebx
	
	movl $1, %ecx	# maska 00000000000000001
	
glavna_petlja_u_petlji:
	cmpl $1, %edx
	je teraj_dalje_pre
	
	shll $1, %ecx
	addl $1, %ecx
	
	decl %edx
	jmp glavna_petlja_u_petlji

teraj_dalje_pre:
	movl niz1_i(, %esi, 4), %eax
	
teraj_dalje:
	cmpl $0, %eax
	je okreni_broj
	
	shll $1, %ecx
	decl %eax
	jmp teraj_dalje

okreni_broj:
	orl %ecx, niz2_i(, %esi, 4)
	
	incl %esi
	jmp glavna_petlja_pre

zavrsi_program_pre:
	ispisi_string ispis3
	
	pushl $niz2_i
	call konvertuj_iz_decimalnog_u_string
	addl $4, %esp

	jmp uspesno_zavrsen_program

ispisi_gresku_1:
	ispisi_string greska1
	movl $1, %ebx
	jmp kraj

ispisi_gresku_2:
	ispisi_string greska2
	movl $2, %ebx
	jmp kraj
	
uspesno_zavrsen_program:
	movl $0, %ebx
	jmp kraj

kraj:
	movl $1, %eax
	int $0x80
	
	
	
	
	
	
	
proveri_validnost:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	
	movl 8(%ebp), %esi	# adresa pocetnog
	
petlja_pp1:
	cmpb $0, (%esi)
	je greska_1_pp1
	
	cmpb $' ', (%esi)
	je preskoci_element
	
	cmpb $'0', (%esi)
	jl greska_1_pp1
	
	cmpb $'9', (%esi)
	jg greska_1_pp1
	
	jmp zavrsi_pp1
	
preskoci_element:
	incl %esi
	jmp petlja_pp1
	
greska_1_pp1:
	movl $1, greska
	jmp zavrsi_pp1

zavrsi_pp1:
	popl %esi
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
	
	
	

	
izvedi_elemente:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi
	
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	movl 8(%ebp), %edi	# pocetna adresa niza brojeva
	movl 12(%ebp), %esi	# pocetna adresa stringa
	
	movl $0, %edx
	pushl %edx
	
petlja_pp2_pre:
	movl $10, %ebx
	movl $0, %ecx
	movl $0, %eax
	
petlja_pp2_pre_malo_posle:
	cmpb $0, (%esi)
	je zavrsi_program_pp2_pre

	cmpb $'0', (%esi)
	jl povecaj_esi
	
	cmpb $'9', (%esi)
	jg povecaj_esi
	
	jmp petlja_pp2
	
povecaj_esi:
	incl %esi
	jmp petlja_pp2_pre_malo_posle
	
petlja_pp2:
	cmpb $0, (%esi)
	je zavrsi_dodavanje_elemenata_pp2
	
	cmpb $' ', (%esi)
	je dodaj_novi_element_pp2
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jc greska_pp2
	addl %ecx, %eax
	jc greska_pp2
	
	incl %esi
	jmp petlja_pp2
	
dodaj_novi_element_pp2:
	popl %edx
	movl %eax, (%edi, %edx, 4)
	incl %edx
	pushl %edx
	
	incl %esi
	jmp petlja_pp2_pre
	
zavrsi_dodavanje_elemenata_pp2:
	popl %edx
	movl %eax, (%edi, %edx, 4)
	incl %edx

	movl %edx, broj_elemenata

	jmp zavrsi_program_pp2

greska_pp2:
	movl $1, greska

zavrsi_program_pp2_pre:
	popl %edx
	
	movl %edx, broj_elemenata
zavrsi_program_pp2:
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	
	popl %edi
	popl %esi
	movl %esp, %ebp
	popl %ebp
	
	ret	
	
	
	
	
	
	
	
	
konvertuj_iz_decimalnog_u_string:
	pushl %ebp
	movl %esp, %ebp
	
	movl $0, %ecx

petlja_pre_pp3:
	cmpl %ecx, broj_elemenata
	jl zavrsi_pp3

	movl $10, %ebx
	movl $ispis_krajnji, %esi	# adresa niza
	
	movl niz2_i(, %ecx, 4), %eax
		
petlja_pp3:
	cmpl $0, %eax
	je okretanje_pre_pp3
	
	movl $0, %edx
	divl %ebx
	
	movb %dl, (%esi)
	addb $48, (%esi)
	
	incl %esi
	jmp petlja_pp3	

okretanje_pre_pp3:
	movb $0, (%esi)
	decl %esi
	
	movl $ispis_krajnji, %edi
	
okretanje_pp3:
	cmpl %esi, %edi
	jg sledeca_iteracija_pp3
	
	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	jmp okretanje_pp3
	
sledeca_iteracija_pp3:
	incl %ecx
	
	pushl %ecx
	ispisi_string ispis_krajnji
	ispisi_string razmak
	popl %ecx
	
	jmp petlja_pre_pp3
	
zavrsi_pp3:
	movl %ebp, %esp
	popl %ebp
	
	ret

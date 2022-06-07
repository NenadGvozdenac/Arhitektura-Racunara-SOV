
.section .data
poruka1: .ascii "Unesite sve uglove:\0"
poruka1_len = . - poruka1
poruka2: .ascii "Navedeni uglovi jesu uglovi trougla.\n\0"
poruka2_len = . - poruka2
poruka3: .ascii "Navedeni uglovi nisu uglovi trougla.\n\0"
poruka3_len = . - poruka3
poruka4: .ascii "Navedeni uglovi jesu uglovi cetvorougla.\n\0"
poruka4_len = . - poruka4
poruka5: .ascii "Navedeni uglovi nisu uglovi cetvorougla.\n\0"
poruka5_len = . - poruka5

greska1: .ascii "Greska: Prazan unos.\n\0"
greska1_len = . - greska1
greska2: .ascii "Greska: Maksimalan unos prekoracen.\n\0"
greska2_len = . - greska2
greska3: .ascii "Greska: Konverzija nije uspesna.\n\0"
greska3_len = . - greska3
greska4: .ascii "Greska: Nije unet adekvatan broj uglova.\n\0"
greska4_len = . - greska4

string_unos: .fill 31, 1, 42

greska: .long 0
niz: .fill 5, 4, 0
broj_elemenata: .long 0

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
	ispisi_string poruka1
	unesi_string string_unos, 31
	
	cmpl $30, %eax	# eax ? 30
	jge prekoracenje_unosa

	movl $string_unos, %esi

	cmpb $0, (%esi)
	je prazan_string_greska

	pushl $string_unos
	call upisi_uglove_u_niz
	addl $4, %esp

	cmpl $3, greska
	je problem_pri_konverziji_greska

	cmpl $4, broj_elemenata
	jg elementi_greska

	cmpl $3, broj_elemenata
	jl elementi_greska
	
	movl $0, %esi
	movl $0, %ecx	# SUMA
	
	cmpl $3, broj_elemenata
	je proveri_trougao
	
	cmpl $4, broj_elemenata
	je proveri_cetvorougao

proveri_trougao:
	cmpl %esi, broj_elemenata
	je da_li_je_trougao
	
	addl niz(, %esi, 4), %ecx	# SUMA
	incl %esi
	jmp proveri_trougao

da_li_je_trougao:
	cmpl $180, %ecx
	je jeste_trougao
	
	ispisi_string poruka3
	jmp kraj

jeste_trougao:
	ispisi_string poruka2
	jmp kraj	
	
	
proveri_cetvorougao:
	cmpl %esi, broj_elemenata
	je da_li_je_cetvorougao
	
	addl niz(, %esi, 4), %ecx	# SUMA
	incl %esi
	jmp proveri_cetvorougao

da_li_je_cetvorougao:
	cmpl $360, %ecx
	je jeste_cetvorougao
	
	ispisi_string poruka5
	jmp kraj

jeste_cetvorougao:
	ispisi_string poruka4
	jmp kraj	

elementi_greska:
	ispisi_string greska4
	jmp kraj

prekoracenje_unosa:
	ispisi_string greska2
	jmp kraj

prazan_string_greska:
	ispisi_string greska1
	jmp kraj

problem_pri_konverziji_greska:
	ispisi_string greska3
	jmp kraj

kraj:
	movl $0, %ebx
	movl $1, %eax
	int $0x80
	
	
	
	
################################################	
upisi_uglove_u_niz:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %ebx
	pushl %esi
	pushl %edi
	
	movl 8(%ebp), %esi	# adresa stringa
	
	movl $0, %edi
	
dodji_do_prvog_elementa_pp1:
	cmpb $' ', (%esi)
	jne petlja_pre_pp1
	
	incl %esi
	jmp dodji_do_prvog_elementa_pp1
	
petlja_pre_pp1:
	movl $8, %ebx
	movl $0, %ecx
	movl $0, %edx
	movl $0, %eax
	
petlja_pp1:
	cmpb $' ', (%esi)
	je ubaci_element_pp1
	
	cmpb $0, (%esi)
	je ubaci_poslednji_element_pp1
	
	cmpb $'0', (%esi)
	jl prekoracenje_pp1
	
	cmpb $'7', (%esi)
	jg prekoracenje_pp1
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jc prekoracenje_pp1
	
	addl %ecx, %eax
	jc prekoracenje_pp1
	
	incl %esi
	jmp petlja_pp1

ubaci_element_pp1:
	movl %eax, niz(, %edi, 4)
	incl %edi
	incl %esi
	jmp petlja_pre_pp1
	
ubaci_poslednji_element_pp1:
	movl %eax, niz(, %edi, 4)
	incl %edi
	
	movl %edi, broj_elemenata
	jmp zavrsi_program_pp1
	
prekoracenje_pp1:
	movl $3, greska
	jmp zavrsi_program_pp1

zavrsi_program_pp1:
	popl %edi
	popl %esi
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	
	ret

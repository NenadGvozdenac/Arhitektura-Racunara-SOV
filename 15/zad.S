# autor: Imenko Prezimić INDEX ra1234-2017
# fajlovi: zad.S

# Ako vaše rešenje sadrži dodatne fajlove, stavite njihove nazive u liniju sa komentarom fajlovi
# Na primer, ako imate i potprogram u pp.S, deo iza "fajlovi" treba da izgleda: zad.S pp.S

.section .data
	poruka: .ascii "Unesite niz brojeva:\0"
	poruka_zbir: .ascii "Zbir kvadrata niza je (Bez najmanjeg broja):\0"
	newline: .ascii "\n\n\0"
	
	poruka_prekoracenje: .ascii "Greska! Doslo je do prekoracenja!\0"
	poruka_los_broj: .ascii "Greska! Uneta cifra nije pozitivan broj u decimalnom sistemu!\0"

	greska: .long 0
	string_unos: .fill 1001, 1, 42
	
	niz_len = 100
	niz: .fill niz_len,4,0

	najmanji_element: .long 0
	broj_elemenata: .long 0
	najmanji_el_index: .long 0

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

.section .text
.globl main

main:
	ispisi_string poruka
	unesi_string string_unos, 1001
	
	pushl $string_unos
	call proveri_string
	addl $4, %esp
	
	cmpl $50, greska
	je greska_los_broj

	pushl $string_unos
	call ubaci_elemente_u_niz
	addl $4, %esp

	cmpl $100, greska
	je greska_prekoracenje
	
	movl $0, %edi
	
	movl niz(, %edi, 4), %eax
	movl %eax, najmanji_element	# prvi element
	
	movl %edi, najmanji_el_index
	
	incl %edi
	
odredi_najmanji_element:
	cmpl %edi, broj_elemenata
	je odredi_sumu_kvadrata_pre

	movl niz(, %edi, 4), %eax
	
	cmpl %eax, najmanji_element	# n ? trenutni
	jg promeni_najmanji

	incl %edi
	jmp odredi_najmanji_element

promeni_najmanji:
	movl %edi, najmanji_el_index
	movl %eax, najmanji_element
	
	incl %edi
	jmp odredi_najmanji_element

odredi_sumu_kvadrata_pre:
	movl $0, %edi
	movl $0, %ecx	 # SUMA
	
	movl najmanji_element, %ebx

odredi_sumu_kvadrata:
	cmpl %edi, broj_elemenata
	je ispisi_sumu_kvadrata
	
	cmpl niz(, %edi, 4), %ebx
	je preskoci_element

	movl niz(, %edi, 4), %eax	# trenutni element
	
	mull %eax
	jc greska_prekoracenje
	
	addl %eax, %ecx

preskoci_element:
	incl %edi
	jmp odredi_sumu_kvadrata
	
ispisi_sumu_kvadrata:
	pushl %ecx
	ispisi_string poruka_zbir
	popl %ecx
	
	pushl %ecx	# SUMA
	call konvertuj_u_string
	addl $4, %esp
	
	movl $0, %ebx
	jmp kraj

greska_prekoracenje:
	ispisi_string poruka_prekoracenje
	movl $100, %ebx
	jmp kraj

greska_los_broj:
	ispisi_string poruka_los_broj
	movl $50, %ebx
	jmp kraj

kraj:
	movl $1, %eax
	int $0x80
	
	
	
	
	
	
	
########################
proveri_string:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %esi
	pushl %edi
	pushl %ebx
	
	movl 8(%ebp), %esi	# adresa

petlja_pp1:
	cmpb $0, (%esi)
	je zavrsi_pp1
	
	cmpb $' ', (%esi)
	je preskoci_element_pp1
	
	cmpb $'0', (%esi)
	jl greska_pp1
	
	cmpb $'9', (%esi)
	jg greska_pp1
	
preskoci_element_pp1:
	incl %esi
	jmp petlja_pp1
	
greska_pp1:
	movl $50, greska
	jmp zavrsi_pp1

zavrsi_pp1:
	popl %ebx
	popl %edi
	popl %esi
	
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
########################	
ubaci_elemente_u_niz:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %ebx
	pushl %esi
	pushl %edi
	
	movl 8(%ebp), %esi	# adresa elementa
	
	movl $0, %edi
	
petlja_pre_pre_pp2:
	movl $10, %ebx
	movl $0, %eax
	movl $0, %ecx
	movl $0, %edx
	
petlja_pre_pp2:
	cmpb $0, (%esi)
	je zavrsi_pp2

	cmpb $'	', (%esi)
	je zavrsi_pp2

	cmpb $' ', (%esi)
	jne petlja_pp2
	
	incl %esi
	jmp petlja_pre_pp2
	
petlja_pp2:
	cmpb $' ', (%esi)
	je ubaci_element_pp2
	
	cmpb $0, (%esi)
	je ubaci_poslednji_element_pp2
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jc prekoracenje_pp2
	
	addl %ecx, %eax
	jc prekoracenje_pp2
	
	incl %esi
	jmp petlja_pp2

ubaci_element_pp2:
	movl %eax, niz(, %edi, 4)
	incl %edi
	incl %esi
	jmp petlja_pre_pre_pp2
	
ubaci_poslednji_element_pp2:
	movl %eax, niz(, %edi, 4)
	incl %edi
	jmp zavrsi_pp2
	
prekoracenje_pp2:
	movl $100, greska
	jmp zavrsi_pp2	

zavrsi_pp2:
	movl %edi, broj_elemenata

	popl %edi
	popl %esi
	popl %ebx
	
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
########################
konvertuj_u_string:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %esi
	pushl %edi
	pushl %ebx
	
	movl 8(%ebp), %eax	# ELEMENT
	movl $string_unos, %esi

	cmpl $0, %eax
	je upisi_nulu_pp3

	movl $10, %ebx

petlja_pp3:
	cmpl $0, %eax
	je okreci_pre_pp3
		
	movl $0, %edx
	divl %ebx
	
	movb %dl, (%esi)
	addb $48, (%esi)
	
	incl %esi
	jmp petlja_pp3
	
okreci_pre_pp3:
	movb $0, (%esi)
	decl %esi

	movl $string_unos, %edi
	
okreci_pp3:
	cmpl %esi, %edi
	jae zavrsi_pp3

	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	
	jmp okreci_pp3
	
upisi_nulu_pp3:
	movb $'0', (%esi)
	movb $0, 1(%esi)
	jmp zavrsi_pp3
	
zavrsi_pp3:
	ispisi_string string_unos

	popl %ebx
	popl %edi
	popl %esi
	
	movl %ebp, %esp
	popl %ebp
	
	ret

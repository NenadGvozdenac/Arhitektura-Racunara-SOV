# autor: Imenko Prezimić INDEX ra1234-2016
# fajlovi: zad.S

# Ako vaše rešenje sadrži dodatne fajlove, stavite njihove nazive u liniju fajlovi
# Na primer, ako imate i potprogram u pp.S, iza fajlovi treba da stoji: zad.S pp.S

# 13:20 - 14:07

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

.section .data
porukaTekst: .ascii "Unesite tekst: \0"
porukaKarakter: .ascii "Unesite karakter: \0"
porukaPozicije: .ascii "Unesite pozicije: \0"
porukaRezultat: .ascii "Rezultujuci tekst: \0"
porukaGreska: .ascii "\nGreska: \0"

poruka: .fill 101, 1, 42	# tekst
karakter: .fill 2, 1, 42	# karakter
pozicije: .fill 101, 1, 42

niz: .fill 15, 4, 0

greska: .long 0
string_temp: .fill 50, 1, 42

broj_elemenata: .long 0
duzina_prvog_stringa: .long 0

.section .text
.globl main

main:
	ispisi_string porukaTekst
	unesi_string poruka, 101
	movl %eax, duzina_prvog_stringa
	
	ispisi_string porukaKarakter
	unesi_string karakter, 2

	ispisi_string porukaPozicije
	unesi_string pozicije, 101

	movl $poruka, %esi
	cmpb $0, (%esi)
	je ispisi_gresku_1
	
	movl $karakter, %esi
	cmpb $0, (%esi)
	je ispisi_gresku_1
	
	movl $pozicije, %esi
	cmpb $0, (%esi)
	je ispisi_gresku_1

	pushl $pozicije
	call konvertuj_u_niz
	addl $4, %esp

	cmpl $3, greska
	je ispisi_gresku_3
	
	cmpl $2, greska
	je ispisi_gresku_2
	
	movl $0, %esi
	
petlja:
	cmpl %esi, broj_elemenata
	je ispisi_novi_string
	
	movl duzina_prvog_stringa, %edi
	
	cmpl %edi, niz(, %esi, 4)
	jge ispisi_gresku_3
	
	movl $0, %edi
	movb karakter(, %edi, 1), %cl	# karakter za upis
	
	movl niz(, %esi, 4), %edi		# pozicija za upis
	
	movb %cl, poruka(, %edi, 1)
	
	incl %esi
	jmp petlja
	
ispisi_novi_string:
	ispisi_string porukaRezultat
	ispisi_string poruka
	
	ispisi_string porukaGreska
	movl $0, %eax
	
	pushl %eax
	call konvertuj_element_u_string
	addl $4, %esp
	
	movl $0, %ebx
	jmp kraj

ispisi_gresku_1:
	ispisi_string porukaGreska
	movl $1, %eax
	
	pushl %eax
	call konvertuj_element_u_string
	addl $4, %esp
	
	movl $0, %ebx
	jmp kraj

ispisi_gresku_2:
	ispisi_string porukaGreska
	movl $2, %eax
	
	pushl %eax
	call konvertuj_element_u_string
	addl $4, %esp
	
	movl $0, %ebx
	jmp kraj

ispisi_gresku_3:
	ispisi_string porukaGreska
	movl $3, %eax
	
	pushl %eax
	call konvertuj_element_u_string
	addl $4, %esp
	
	movl $0, %ebx
	jmp kraj

kraj:
	movl $1, %eax
	int $0x80
	
	
	
	
	
	
	
########################
konvertuj_u_niz:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi
	
	movl 8(%ebp), %esi	# adresa niza

	movl $0, %edi

petlja_pre_pp1:
	movl $10, %ebx
	movl $0, %eax
	movl $0, %ecx
	movl $0, %edx
	
petlja_pp1:
	cmpb $' ', (%esi)
	je ubaci_element_pp1
	
	cmpb $0, (%esi)
	je ubaci_poslednji_element_pp1
	
	cmpb $'0', (%esi)
	jl greska_pp1
	
	cmpb $'9', (%esi)
	jg greska_pp1
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jc prekoracenje_pp1
	
	addl %ecx, %eax
	jc prekoracenje_pp1
	
	incl %esi
	jmp petlja_pp1

ubaci_element_pp1:
	cmpb $0, 1(%esi)
	je greska_pp1

	movl %eax, niz(, %edi, 4)
	incl %edi
	incl %esi
	
	jmp petlja_pre_pp1
	
ubaci_poslednji_element_pp1:
	movl %eax, niz(, %edi, 4)
	
	movl %edi, broj_elemenata
	incl broj_elemenata
	
	jmp zavrsi_pp1
	
prekoracenje_pp1:
	movl $3, greska
	jmp zavrsi_pp1

greska_pp1:
	movl $2, greska
	jmp zavrsi_pp1

zavrsi_pp1:
	popl %edi
	popl %esi
	
	movl %ebp, %esp
	popl %ebp
	
	ret	
	
########################
konvertuj_element_u_string:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi
	pushl %ebx
	
	movl 8(%ebp), %eax	# element
	
	movl $string_temp, %esi
	
	movl $10, %ebx
	movl $0, %ecx
	movl $0, %edx
	
	cmpl $0, %eax
	je nula_element_pp2
	
petlja_pp2:
	cmpl $0, %eax
	je okreci_pre_pp2
	
	movl $0, %edx
	divl %ebx
	
	movb %dl, (%esi)
	addb $48, (%esi)
	
	incl %esi
	jmp petlja_pp2

okreci_pre_pp2:
	movb $0, (%esi)
	decl %esi
	
	movl $string_temp, %edi

okreci_pp2:
	cmpl %esi, %edi
	jae zavrsi_pp2
	
	movb (%esi), %al
	movb (%edi), %ah
	movb (%esi), %ah
	movb (%edi), %al
	
	incl %edi
	decl %esi
	jmp okreci_pp2

nula_element_pp2:
	movb $'0', (%esi)
	movb $0, 1(%esi)
	jmp zavrsi_pp2

zavrsi_pp2:
	ispisi_string string_temp

	popl %ebx
	popl %edi
	popl %esi
	movl %ebp, %esp
	popl %ebp
	
	ret

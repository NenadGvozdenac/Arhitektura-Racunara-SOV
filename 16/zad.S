# autor: Imenko Prezimić INDEX ra1234-2017
# fajlovi: zad.S

# Ako vaše rešenje sadrži dodatne fajlove, stavite njihove nazive u liniju sa komentarom fajlovi
# Na primer, ako imate i potprogram u pp.S, deo iza "fajlovi" treba da izgleda: zad.S pp.S

.section .data

unesite: .ascii "Ulazni string je: \0"
unesite_len = .-unesite
najucestalija: .ascii "Najucestalija slova su: \0"
najucestalija_len = .-najucestalija
greska: .ascii "GRESKA Nema slova u ulaznom stringu.\0"
greska_len = .-greska

string_unos: .fill 61, 1, 42
niz_slova_za_unos: .fill 30, 1, 42
maksimum_slova_za_ponavljanje: .long 0

broj: .long 0

string: .ascii " \0"

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
	ispisi_string unesite
	unesi_string string_unos, 61
	
	movl $string_unos, %esi
	cmpb $0, (%esi)
	je greska_1
	
	pushl $string_unos
	call proveri_da_li_ima_slova
	addl $4, %esp
	
	cmpl $100, %eax
	je greska_1
	
	pushl $string_unos
	call pretvori_u_mala_slova
	addl $4, %esp
	
	pushl $string_unos
	call pronadji_najvece_ponavljanje_slova
	addl $4, %esp
	
	ispisi_string najucestalija

idk_anymore:
	movl $string_unos, %esi
	
petlja_jos_pre_pre_pre:
	cmpb $0, (%esi)
	je kraj
	
	cmpb $' ', (%esi)
	jne da_li_je_slovo 
	
preskoci:
	incl %esi
	jmp petlja_jos_pre_pre_pre
	
da_li_je_slovo:
	cmpb $'a', (%esi)
	jl preskoci
	
	cmpb $'z', (%esi)
	jg preskoci
	
	jmp petlja_jos_pre_pre
	
petlja_jos_pre_pre:
	movl maksimum_slova_za_ponavljanje, %edi	# BROJAC TRENUTNI
	movl $string_unos, %esi

petlja_jos_pre:
	cmpb $0, (%esi)
	je petlja_pre
	
	incl %esi
	jmp petlja_jos_pre

petlja_pre:
	decl %esi

petlja:
	cmpb $0, (%esi)
	je kraj
	
	cmpb $'a', (%esi)
	jl listaj_dalje
	
	cmpb $'z', (%esi)
	jg listaj_dalje
	
	jmp proveri_trenutno_slovo

listaj_dalje:	
	decl %esi
	jmp petlja

proveri_trenutno_slovo:
	movb (%esi), %al	# TRENUTNO SLOVO, PROVERI NEMOJ BIT DEBIL
	
	movb $' ', (%esi)
	decl %edi
	
proveri_petlja:
	cmpb (%esi), %al
	je smanji_brojac_trenutni
	
	cmpl $string_unos, %esi
	je idk_anymore

	decl %esi
	jmp proveri_petlja
	
smanji_brojac_trenutni:
	decl %edi
	
	movb $' ', (%esi)
	
	cmpl $0, %edi
	je ispisi_element
	
	decl %esi

	jmp proveri_petlja
		
ispisi_element:
	movl $0, %edi
	movb %al, string(, %edi, 1)

	incl broj

	ispisi_string string
	
	jmp petlja_jos_pre_pre

greska_1:
	ispisi_string greska
	movl $100, broj
	jmp kraj

kraj:
	movl broj, %ebx
	movl $1, %eax
	int $0x80









#############################
pretvori_u_mala_slova:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %esi
	
	movl 8(%ebp), %esi	# adresa stringa

petlja_pp1:
	cmpb $0, (%esi)
	je zavrsi_pp1
	
	cmpb $'A', (%esi)
	jl preskoci_element_pp1
	
	cmpb $'Z', (%esi)
	jg preskoci_element_pp1
	
	addb $32, (%esi)

preskoci_element_pp1:	
	incl %esi
	jmp petlja_pp1
	
zavrsi_pp1:
	popl %esi
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
#############################	
pronadji_najvece_ponavljanje_slova:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %esi
	
	movl 8(%ebp), %esi	# adresa nasega dragoga stringa a
	movb $'a', %al	# A 

	movl $0, %edi

petlja_pre_pp2:
	cmpb $'z', %al
	jg zavrsi_pp2

petlja_pp2:
	cmpb $0, (%esi)
	je predji_na_sledece_slovo_pp2
	
	cmpb %al, (%esi)
	je povecaj_brojac_temp_pp2
	
	incl %esi
	jmp petlja_pp2
	
predji_na_sledece_slovo_pp2:
	incb %al
	movl 8(%ebp), %esi
	
	cmpl maksimum_slova_za_ponavljanje, %edi
	jg postavi_novi_najveci_broj_ponavljanja_stringa_pp2
	
	movl $0, %edi
	jmp petlja_pre_pp2	

postavi_novi_najveci_broj_ponavljanja_stringa_pp2:
	movl %edi, maksimum_slova_za_ponavljanje
	
	movl $0, %edi
	jmp petlja_pre_pp2	

povecaj_brojac_temp_pp2:
	incl %esi
	incl %edi
	jmp petlja_pp2
	
zavrsi_pp2:
	popl %esi
	
	movl %ebp, %esp
	popl %ebp
	
	ret
	

proveri_da_li_ima_slova:
	pushl %ebp
	movl %esp, %ebp
	
	movl 8(%ebp), %esi	# ADRESA

	movl $100, %eax

petlja_pp3:
	cmpb $0, (%esi)
	je zavrsi_pp3

	cmpb $'a', (%esi)
	jl preskoci_pp3
	
	cmpb $'z', (%esi)
	jg preskoci_pp3
	
	movl $0, %eax

preskoci_pp3:
	incl %esi
	jmp zavrsi_pp3

zavrsi_pp3:
	movl %ebp, %esp
	popl %ebp
	
	ret


# unos 1
# Unesite brojeve: 2 4 5 7  10 15 15  54
# Najveci broj: 54

# unos 2
# Unesite brojeve:     2 3  15
# Najveci broj: 15

# unos 3
# Unesite brojeve: 0
# Najveci broj: 0

# prazan string -> povratna 1
# prekoracenje -> povratna 2
# pogresan karakter -> povratna 3

.section .data
str1: .ascii "Unesite brojeve: \0"
str1_len = . - str1
str2: .ascii "Najveci broj: \0"
str2_len = . - str2
str3: .ascii "Greska!\0"
str3_len = . - str3

str_unos_max = 51
str_unos: .fill str_unos_max, 1, 42

str_n: .ascii "\n\n\0"

brojac_brojeva: .long 0

niz: .fill 25, 4, 0
najveci_element: .long 0

str_temp: .fill 51, 1, 42

.section .text
.globl main

main:
	movl $4, %eax
	movl $1, %ebx
	movl $str1, %ecx
	movl $str1_len, %edx
	int $0x80
	
	movl $3, %eax
	movl $0, %ebx
	movl $str_unos, %ecx
	movl $str_unos_max, %edx
	int $0x80

	decl %eax
	movb $0, str_unos(, %eax, 1)

	movl $str_unos, %esi
	
	cmpb $0, (%esi)
	je greska_1
	
	movl $0, %edi	# brojac niza

petlja_dodji_do_broja:
	cmpb $0, (%esi)
	je radi_operaciju	

	cmpb $' ', (%esi)
	jne konvertuj_broj_pre
	
	incl %esi
	jmp petlja_dodji_do_broja

konvertuj_broj_pre:
	movl $0, %eax
	movl $10, %ebx
	movl $0, %ecx
	movl $0, %edx
	
konvertuj_broj:
	cmpb $' ', (%esi)
	je ubaci_element_u_niz
	
	cmpb $0, (%esi)
	je ubaci_poslednji_element_u_niz
	
	movb (%esi), %cl
	subb $'0', %cl
	
	cmpb $0, %cl
	jl greska_3
	cmpb $9, %cl
	ja greska_3
	
	mull %ebx
	jc greska_2
	addl %ecx, %eax
	jc greska_2
	
	incl %esi
	jmp konvertuj_broj
	
ubaci_element_u_niz:
	movl %eax, niz(, %edi, 4)
	incl %edi
	
	incl brojac_brojeva
	
	incl %esi
	jmp petlja_dodji_do_broja
	
ubaci_poslednji_element_u_niz:
	movl %eax, niz(, %edi, 4)
	incl %edi
	
	incl brojac_brojeva
	
	jmp radi_operaciju
	
radi_operaciju:
	cmpl $0, brojac_brojeva
	je greska_1

	movl $0, %edi
	movl niz(, %edi, 4), %eax	# pocetni najveci
	
	incl %edi
	
	movl $0, %esi

radi_operaciju_petlja:
	cmpl $25, %esi
	je ispisi_najveci_element

	cmpl niz(, %edi, 4), %eax	# drugi ? prvim elementom
	jl postavi_novi_veci
	
	incl %edi
	incl %esi
	jmp radi_operaciju_petlja

postavi_novi_veci:
	movl niz(, %edi, 4), %eax
	incl %edi
	incl %esi
	
	jmp radi_operaciju_petlja
	
ispisi_najveci_element:
	movl %eax, najveci_element
	
	movl $4, %eax
	movl $1, %ebx
	movl $str2, %ecx
	movl $str2_len, %edx
	int $0x80
	
	movl najveci_element, %eax
	movl $10, %ebx
	movl $0, %edx
	
	movl $str_temp, %esi

	cmpl $0, %eax
	je ispisi_nulu

ispisi_element:
	cmpl $0, %eax
	je okreci_pre
	
	movl $0, %edx
	divl %ebx
	
	movb %dl, (%esi)
	addb $'0', (%esi)
	
	incl %esi
	jmp ispisi_element

okreci_pre:
	movb $0, (%esi)
	decl %esi
	
	movl $str_temp, %edi
	
	movl %esi, %edx
	subl %edi, %edx	# DUZINA

okreci:
	cmpl %esi, %edi
	jae ispisi
	
	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	
	jmp okreci

ispisi:
	movl $4, %eax
	movl $1, %ebx
	movl $str_temp, %ecx
	
	incl %edx
	
	int $0x80
	
	movl $0, %ebx
	jmp kraj

ispisi_nulu:
	movb $'0', (%esi)	# POMERAMO NULU U STRING
	
	movl $4, %eax
	movl $1, %ebx
	movl $str_temp, %ecx
	movl $1, %edx
	
	int $0x80
	
	movl $0, %ebx
	jmp kraj	

greska_1:
	movl $4, %eax
	movl $1, %ebx
	movl $str3, %ecx
	movl $str3_len, %edx
	int $0x80
	
	movl $1, %ebx
	jmp kraj

greska_2:
	movl $4, %eax
	movl $1, %ebx
	movl $str3, %ecx
	movl $str3_len, %edx
	int $0x80
	
	movl $2, %ebx
	jmp kraj

greska_3:
	movl $4, %eax
	movl $1, %ebx
	movl $str3, %ecx
	movl $str3_len, %edx
	int $0x80
	
	movl $3, %ebx
	jmp kraj

kraj:
	movl $4, %eax
	movl $1, %ebx
	movl $str_n, %ecx
	movl $2, %edx
	int $0x80

	movl $1, %eax
	int $0x80

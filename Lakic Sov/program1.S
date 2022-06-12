.section .data

str1: .ascii "Unesite donju granicu: \0"
str1_len = . - str1
str2: .ascii "Unesite gornju granicu: \0"
str2_len = . - str2
str3: .ascii "Suma aritmeticke progresije je: \0"
str3_len = . - str3

str_greska_1: .ascii "Nedozvoljena vrednost ulaza!\0"
str_greska_1_len = . - str_greska_1

str_greska_2: .ascii "Prekoracenje opsega!\0"
str_greska_2_len = . - str_greska_2

string_unos_1: .fill 15, 1, 42
string_unos_2: .fill 15, 1, 42

broj_1: .long 0
broj_2: .long 0
suma: .long 0

string_ispis: .fill 15, 1, 42

.section .text
.globl main

main:
	movl $4, %eax		# ispis prve poruke
	movl $1, %ebx
	movl $str1, %ecx
	movl $str1_len, %edx
	int $0x80

	movl $3, %eax		# unos prvog stringa
	movl $0, %ebx
	movl $string_unos_1, %ecx
	movl $15, %edx
	int $0x80

	movl $string_unos_1, %esi

	decl %eax			# brisanje \n 
	movb $0, (%esi, %eax, 1)
	
	movl $4, %eax		# ispis prve poruke
	movl $1, %ebx
	movl $str2, %ecx
	movl $str2_len, %edx
	int $0x80

	movl $3, %eax		# unos prvog stringa
	movl $0, %ebx
	movl $string_unos_2, %ecx
	movl $15, %edx
	int $0x80

	movl $string_unos_2, %esi

	decl %eax			# brisanje \n 
	movb $0, (%esi, %eax, 1)

	movl $0, %eax
	movl $0, %ecx
	movl $0, %edx
	
	movl $string_unos_1, %esi
	movl $10, %ebx

petlja_1:
	cmpb $0, (%esi)
	je upisi_prvi_broj
	
	movb (%esi), %cl	# '1'
	subb $'0', %cl		# '1' - '0' === 49 - 48 = 1
		
	cmpb $0, %cl
	jl greska_1
	
	cmpb $9, %cl
	jg greska_1	# >
		
	mull %ebx
	jc greska_2
	
	addl %ecx, %eax
	jc greska_2
	
	incl %esi
	jmp petlja_1

upisi_prvi_broj:
	movl %eax, broj_1
	
	movl $0, %eax
	movl $0, %ecx
	movl $0, %edx
	
	movl $string_unos_2, %esi
	movl $10, %ebx	

petlja_2:
	cmpb $0, (%esi)
	je upisi_drugi_broj
	
	movb (%esi), %cl	# '1'
	subb $'0', %cl		# '1' - '0' === 49 - 48 = 1
		
	cmpb $0, %cl
	jl greska_1
	
	cmpb $9, %cl
	jg greska_1	# >	
		
	mull %ebx
	jc greska_2
	
	addl %ecx, %eax
	jc greska_2
	
	incl %esi
	jmp petlja_2

upisi_drugi_broj:
	movl %eax, broj_2

	movl broj_1, %eax	# donja granica
	movl $0, %ecx	# suma
	
	incl broj_2
glavna_petlja:
	cmpl %eax, broj_2
	je upisi_sumu
	
	addl %eax, %ecx
	incl %eax
	
	jmp glavna_petlja
	
upisi_sumu:
	movl %ecx, suma
	
	movl $4, %eax
	movl $1, %ebx
	movl $str3, %ecx
	movl $str3_len, %edx
	int $0x80
	
	movl suma, %eax
	movl $10, %ebx
	movl $0, %ecx
	movl $0, %edx

	movl $string_ispis, %esi

petlja_ispis:
	cmpl $0, %eax
	je obrni_pre
	
	movl $0, %edx
	divl %ebx		# 15 / 10 -> dl -> 5  -> 5 + '0' -> '5'
	
	addb $'0', %dl
	movb %dl, (%esi)
	
	incl %esi
	jmp petlja_ispis

obrni_pre:
	movb $0, (%esi)
	decl %esi
	
	movl %esi, %edi	# pocetna adresa stringa
	movl %edi, %ecx	# 8129478923
	
	subl $string_ispis, %ecx	# 8129478923 - 8129478920 = 3	duzina stringa da se zapamti
	incl %ecx

	movl $string_ispis, %edi

obrni:
	cmpl %esi, %edi
	jae ispisi_string
	
	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	jmp obrni

ispisi_string:
	movl $4, %eax
	movl $1, %ebx
	movl %ecx, %edx	# DUZINA
	movl $string_ispis, %ecx
	int $0x80
	
	movl $0, %ebx
	
	jmp kraj

greska_1:
	movl $4, %eax
	movl $1, %ebx
	movl $str_greska_1, %ecx
	movl $str_greska_1_len, %edx
	int $0x80
	
	movl $1, %ebx
	
	jmp kraj

greska_2:
	movl $4, %eax
	movl $1, %ebx
	movl $str_greska_2, %ecx
	movl $str_greska_2_len, %edx
	int $0x80

	movl $2, %ebx
	jmp kraj

kraj:
	movl $1, %eax
	int $0x80

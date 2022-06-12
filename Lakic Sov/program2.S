# unesi dva broja, A i B. Kao rezultat trebas ispisati njihov proizvod. Maks 15 karaktera. OKTALNI BROJEVI
# interakcija:
# Unesite A: -5
# Unesite B: -1
# Proizvod: 5		# DECIMALNI ISPIS PROIZVODA
# (Povratna vrednost 0)

# Prekoracenje opsega: ispisi greska, vrati povratnu vrednost 1
# Karakter ne valja: ispisi greska, vrati povratnu vrednost 2

.section .data

poruka1: .ascii "Unesite A: \0"
poruka1_len = . - poruka1
poruka2: .ascii "Unesite B: \0"
poruka2_len = . - poruka2
poruka3: .ascii "Proizvod: \0"
poruka3_len = . - poruka3

string_unos_1: .fill 16, 1, 42
string_unos_2: .fill 16, 1, 42

str_ispis: .fill 16, 1, 42

err: .ascii "Greska!\0"
err_len = . - err

A: .long 0
B: .long 0
R: .long 0

negativan_je: .long 0

.section .text
.globl main

main:
	movl $4, %eax
	movl $1, %ebx
	movl $poruka1, %ecx
	movl $poruka1_len, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	movl $string_unos_1, %ecx
	movl $16, %edx
	int $0x80

	decl %eax
	movb $0, string_unos_1(, %eax, 1)

	movl $4, %eax
	movl $1, %ebx
	movl $poruka2, %ecx
	movl $poruka2_len, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	movl $string_unos_2, %ecx
	movl $16, %edx
	int $0x80

	decl %eax
	movb $0, string_unos_2(, %eax, 1)
	
	movl $string_unos_1, %esi
	movl $1, %edi
	
	cmpb $'-', (%esi)
	jne proveren_znak

	movl $-1, %edi
	incl %esi

proveren_znak:
	movl $0, %eax
	movl $8, %ebx
	movl $0, %ecx
	movl $0, %edx

petlja_1:
	cmpb $0, (%esi)
	je upisi_prvi_broj
	
	movb (%esi), %cl
	subb $'0', %cl
	
	cmpb $0, %cl
	jl greska_2
	
	cmpb $7, %cl
	jg greska_2
	
	mull %ebx
	jo greska_1
	addl %ecx, %eax
	jo greska_1
	
	incl %esi
	jmp petlja_1

upisi_prvi_broj:
	imull %edi
	movl %eax, A	# PRVI BROJ KONVERTOVAN
	
	# DRUGI BROJ
	movl $string_unos_2, %esi
	movl $1, %edi
	
	cmpb $'-', (%esi)
	jne proveren_znak_2

	movl $-1, %edi
	incl %esi

proveren_znak_2:
	movl $0, %eax
	movl $8, %ebx
	movl $0, %ecx
	movl $0, %edx

petlja_2:
	cmpb $0, (%esi)
	je upisi_drugi_broj
	
	movb (%esi), %cl
	subb $'0', %cl
	
	cmpb $0, %cl
	jl greska_2
	
	cmpb $7, %cl
	jg greska_2
	
	mull %ebx
	jo greska_1
	addl %ecx, %eax
	jo greska_1
	
	incl %esi
	jmp petlja_2

upisi_drugi_broj:
	imull %edi
	movl %eax, B	# PRVI BROJ KONVERTOVAN

	movl A, %eax
	movl B, %ebx
	
	imull %ebx	# EAX * EBX -> EAX
	
	movl %eax, R

	movl $4, %eax
	movl $1, %ebx
	movl $poruka3, %ecx
	movl $poruka3_len, %edx
	int $0x80
	
	movl R, %eax
	movl $str_ispis, %esi
	
	cmpl $0, %eax
	jnl petlja_3_ranije
	
	imull $-1, %eax
	movl $1, negativan_je
	movb $'-', (%esi)
	incl %esi
	
petlja_3_ranije:
	movl $10, %ebx
	movl $0, %edx

petlja_3:
	cmpl $0, %eax
	je okreci_pre
	
	movl $0, %edx
	divl %ebx
	
	addb $'0', %dl
	movb %dl, (%esi)
	
	incl %esi
	jmp petlja_3

okreci_pre:
	movb $0, (%esi)
	decl %esi
	
	cmpl $1, negativan_je
	jne nesto
	
	movl $str_ispis, %edi
	incl %edi
	jmp odredi_duzinu

nesto:
	movl $str_ispis, %edi
	jmp odredi_duzinu

odredi_duzinu:
	movl %esi, %edx
	subl %edi, %edx	# ODUZIMANJE
	
	incl %edx

okreci:
	cmpl %esi, %edi
	jae ispisi_krajnji_string
	
	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	jmp okreci

ispisi_krajnji_string:
	movl $4, %eax
	movl $1, %ebx
	movl $str_ispis, %ecx
	
	cmpl $1, negativan_je
	je povecaj_edx_za_jedan
	
	int $0x80
	
	movl $0, %ebx
	jmp kraj

povecaj_edx_za_jedan:
	incl %edx
	int $0x80

	movl $0, %ebx
	jmp kraj

greska_1:
	movl $4, %eax
	movl $1, %ebx
	movl $err, %ecx
	movl $err_len, %edx
	int $0x80
	
	movl $1, %ebx
	jmp kraj
	
greska_2:
	movl $4, %eax
	movl $1, %ebx
	movl $err, %ecx
	movl $err_len, %edx
	int $0x80
	
	movl $2, %ebx
	jmp kraj

kraj:
	movl $1, %eax
	int $0x80

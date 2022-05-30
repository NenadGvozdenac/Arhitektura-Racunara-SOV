# autor: Imenko Prezimić INDEX ra1234-2017
# fajlovi: zad.S

# Poredjenje aritmeticke sredine parnih i neparnih brojeva

.section .data

poruka1: .ascii "Unesite niz: \0"
poruka2: .ascii "Rezultat greske je: \0"
poruka3: .ascii "Prekoracenje! \n\0"
poruka4: .ascii "Neodgovarajuci operand! \n\0"
poruka5: .ascii "Veca je aritmeticka sredina parnih brojeva! \n\0"
poruka6: .ascii "Veca je aritmeticka sredina neparnih brojeva! \n\0"
poruka7: .ascii "Iste su aritmeticke sredine parnih i neparnih brojeva! \n\0"

max_unos = 51
unos: .fill max_unos, 1, 0

niz: .fill 20, 4, 0
string: .fill 15, 1, 0

parni_sum: .long 0
neparni_sum: .long 0

parni_n: .long 0
neparni_n: .long 0

.section .text
.globl main

.macro ispisi_string str
	movl $4, %eax
	movl $1, %ebx
	movl $\str, %ecx
	movl $0, %edx
1:	cmpb $0, (%ecx)
	je 2f
	incl %edx
	incl %ecx
	jmp 1b
	
2:	incl %edx
	movl $\str, %ecx
	int $0x80
.endm
	
main:
	ispisi_string poruka1

	movl $3, %eax	# unos stringa
	movl $0, %ebx
	movl $unos, %ecx
	movl $max_unos, %edx
	int $0x80

	decl %eax	# trimovanje sa kraja
	movb $0, unos(, %eax, 1)

	movl $0, %esi

	pushl $unos
	call proveri_slova
	addl $4, %esp

	cmpl $1, %eax
	je greska_1

	movl $unos, %esi
	movl $0, %edi	# brojac elemenata

pre_petlje:
	movl $10, %ebx
	movl $0, %ecx
	movl $0, %edx
	movl $0, %eax

petlja:
	cmpb $0, (%esi)
	je zavrsi_ubacivanje

	cmpb $' ', (%esi)
	je ubaci_element_u_niz
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jc greska_2
	
	addl %ecx, %eax
	jc greska_2
	
	incl %esi
	jmp petlja
	
ubaci_element_u_niz:
	movl %eax, niz(, %edi, 4)
	incl %edi
	incl %esi
	jmp pre_petlje
	
zavrsi_ubacivanje:
	movl %eax, niz(, %edi, 4)
	incl %edi	# brojac elemenata
	incl %esi
	
	movl $0, %esi
	movl $2, %ebx
	movl $0, %ecx
	
	decl %edi
	
glavna_petlja:
	cmpl %esi, %edi
	jb poredi_sredine

	movl $0, %edx
	
	movl niz(, %esi, 4), %eax
	divl %ebx
	
	cmpl $0, %edx
	je paran
	jne neparan
	
paran:
	mull %ebx
	addl %eax, parni_sum
	incl %esi
	
	incl parni_n
	jmp glavna_petlja

neparan:
	pushl %edx
	mull %ebx
	popl %edx
	
	addl %edx, %eax
	addl %eax, neparni_sum
	
	incl %esi
	incl neparni_n
	jmp glavna_petlja

poredi_sredine:
	movl parni_n, %ebx
	movl parni_sum, %eax
	movl $0, %edx
	
	divl %ebx
	movl %eax, parni_sum
	
	movl neparni_n, %ebx
	movl neparni_sum, %eax
	movl $0, %edx
	
	divl %ebx
	movl %eax, neparni_sum
	
	cmpl parni_sum, %eax	# eax ? parni_sum
	jl neparni_veci
	jg parni_veci
	je jednake
	
parni_veci:
	ispisi_string poruka6
	ispisi_string poruka2

	movl $0, %eax
	pushl %eax
	call konvertuj_u_string
	addl $4, %esp
	
	ispisi_string string
	
	jmp kraj

neparni_veci:
	ispisi_string poruka5
	ispisi_string poruka2

	movl $0, %eax
	pushl %eax
	call konvertuj_u_string
	addl $4, %esp
	
	ispisi_string string
	
	jmp kraj

jednake:
	ispisi_string poruka7
	ispisi_string poruka2

	movl $0, %eax
	pushl %eax
	call konvertuj_u_string
	addl $4, %esp
	
	ispisi_string string
	
	jmp kraj

greska_1:				# PREKORACENJE
	ispisi_string poruka4
	ispisi_string poruka2
	
	movl $2, %eax
	pushl %eax
	call konvertuj_u_string
	addl $4, %esp
	
	ispisi_string string
	
	jmp kraj
	
greska_2:				# POGRESAN UNOS
	ispisi_string poruka3
	ispisi_string poruka2
	
	movl $1, %eax
	pushl %eax
	call konvertuj_u_string
	addl $4, %esp
	
	ispisi_string string
	
	jmp kraj

kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
	
	

	# int proveri_slova(char*)	
proveri_slova:
	pushl %ebp
	movl %esp, %ebp
	
	movl 8(%ebp), %eax
	
petlja_pp:
	cmpb $0, (%eax)
	je uspesno_pp
	
	cmpb $' ', (%eax)
	je preskoci_pp
	
	cmpb $'0', (%eax)
	jl greska_pp
	
	cmpb $'9', (%eax)
	jg greska_pp

preskoci_pp:	
	incl %eax
	jmp petlja_pp

greska_pp:
	movl $1, %eax
	jmp kraj_pp
	
uspesno_pp:
	movl $0, %eax
	jmp kraj_pp

kraj_pp:
	movl %ebp, %esp
	popl %ebp
	
	ret



	# int konvertuj_u_string(int)
konvertuj_u_string:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi

	movl 8(%ebp), %eax
	
	movl $10, %ebx

	movl $string, %esi

	cmpl $0, %eax
	je ispisi_nulu_pp2

petlja_pp2:
	cmpl $0, %eax
	je uspesno_pp2
	
	movl $0, %edx
	divl %ebx
	
	addb $48, %dl
	movb %dl, (%esi)

	incl %esi
	jmp petlja_pp2
	
uspesno_pp2:
	movb $0, (%esi)
	decl %esi
	
	movl $string, %edi
	
okreni_pp2:
	cmpl %esi, %edi
	jae zavrsi_pp2
	
	movb (%esi), %ah
	movb (%edi), %al
	movb %ah, (%edi)
	movb %al, (%esi)
	
	incl %edi
	decl %esi
	jmp okreni_pp2

ispisi_nulu_pp2:
	addb $48, %al
	movb %al, (%esi)
	
	incl %esi
	movb $0, (%esi)
	decl %esi

zavrsi_pp2:
	popl %edi
	popl %esi
	movl %ebp, %esp
	popl %ebp
	
	ret

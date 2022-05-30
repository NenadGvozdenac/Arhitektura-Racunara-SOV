.section .data

inMessage: .ascii "Ulazna sekvenca: \0"
outMessage: .ascii "Izlazna sekvenca: \0"
errMessage: .ascii "Greska!\0"

string_max = 101
string_unos1: .fill string_max,1,0
izlaz: .fill string_max,1,0

string_ispis1: .fill string_max, 1, 0
stringidk: .ascii " "

niz:	.fill 20, 4, 0

greska: .long 0

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

.macro isprazni_string str
	movl $0, %eax
	movl $\str, %esi
1:	
	cmpl %esi, string_max	
	je 2f
	
	movb $0, (%esi)
	incl %esi
	jmp 1b
	
2:
.endm

main:
	ispisi_string inMessage
	
	movl $3, %eax	# unos pocetnog stringa
	movl $0, %ebx
	movl $string_unos1, %ecx
	movl $string_max, %edx
	int $0x80

	pushl $string_unos1
	call proveri_slova
	addl $4, %esp
	
	cmpl $1, greska
	je greska_1
	
	pushl $string_unos1
	call proveri_brojeve
	addl $4, %esp
	
	cmpl $2, greska
	je greska_2
	
	movl $string_unos1, %esi
	
	movl $0, %edi
	
petlja_do_pocetka:
	cmpb $'\n', (%esi)
	je zavrsi_ubacivanje
	
	cmpb $0, (%esi)
	je zavrsi_ubacivanje

	cmpb $' ', (%esi)
	jne pretvori_broj_pre
	
	incl %esi
	jmp petlja_do_pocetka

pretvori_broj_pre:
	movl $10, %ebx
	movl $0, %eax
	movl $0, %ecx
	
pretvori_broj:
	cmpb $' ', (%esi)
	je ubaci_u_niz
	
	cmpb $'\n', (%esi)
	je ubaci_u_niz
	
	cmpb $0, (%esi)
	je ubaci_u_niz
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jc greska_1
	addl %ecx, %eax
	jc greska_1
	incl %esi
	jmp pretvori_broj

ubaci_u_niz:
	movl %eax, niz(, %edi, 4)
	
	incl %edi
	incl %esi
	
	jmp petlja_do_pocetka

zavrsi_ubacivanje:
	movl $0, %esi
	
	ispisi_string outMessage
	
	movl niz(, %esi, 4), %ebx	# najveci
	
	pushl %ebx
	call ispisi_broj
	addl $4, %esp

	incl %esi
	
	movl niz(, %esi, 4), %ebx	# drugi element

	movl $0, %ecx
	movl $0, %edx	# upisivanje, 0 - da, 1 - ne
	
glavna_petlja:
	cmpl %ecx, %esi
	je sledeci_element

	cmpl niz(, %ecx, 4), %ebx
	jl nije_veci
	
	incl %ecx
	jmp glavna_petlja
	
nije_veci:
	incl %esi
	movl niz(, %esi, 4), %ebx
	movl $0, %ecx
	jmp glavna_petlja
	
sledeci_element:
	pushl %ebx
	call ispisi_broj
	addl $4, %esp
	
	incl %esi
	cmpl %edi, %esi
	je zavrsi_ispisivanje
	movl niz(, %esi, 4), %ebx
	
	movl $0, %ecx
	jmp glavna_petlja
	
zavrsi_ispisivanje:
	movl $1, %eax
	jmp kraj
	
greska_1:
	ispisi_string errMessage
	movl $1, %ebx
	jmp kraj

greska_2:
	ispisi_string errMessage
	movl $2, %ebx
	jmp kraj

uspesno:
	movl $0, %ebx
	jmp kraj

kraj:
	movl $1, %eax
	int $0x80
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# void proveri_slova(char*)
proveri_slova:
	pushl %ebp
	movl %esp, %ebp
	
	movl 8(%ebp), %eax	# adresa
	
petlja_pp_2:
	cmpb $0, (%eax)
	je uspesno_popuj_pp_2
	
	cmpb $'\n', (%eax)
	je uspesno_popuj_pp_2
	
	cmpb $' ', (%eax)
	je povecaj_brojac_pp_2
	
	cmpb $'0', (%eax)
	jl greska_pp_2
	
	cmpb $'9', (%eax)
	jg greska_pp_2
	
povecaj_brojac_pp_2:
	incl %eax
	jmp petlja_pp_2
	
uspesno_popuj_pp_2:
	movl $0, %eax
	jmp zavrsi_pp_2
	
greska_pp_2:
	movl $1, %eax
	jmp zavrsi_pp_2
	
zavrsi_pp_2:
	movl %eax, greska
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
	# void proveri_brojeve(char*)
proveri_brojeve:
	pushl %ebp
	movl %esp, %ebp
	
	movl 8(%ebp), %eax
	movl $2, greska
petlja_pp:
	cmpb $0, (%eax)
	je kraj_pp
	
	cmpb $'\n', (%eax)
	je kraj_pp
	
	cmpb $'0', (%eax)
	jl preskoci_pp
	
	cmpb $'9', (%eax)
	jg preskoci_pp
	
	movl $0, greska
	
	jmp kraj_pp
	
preskoci_pp:
	incl %eax
	jmp petlja_pp
	
kraj_pp:
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
	# void ispisi_broj(int broj)
ispisi_broj:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi
	
	movl 8(%ebp), %eax	# broj
	movl $string_ispis1, %esi	# adresa stringa
	
	movl $10, %ebx
	
	cmpl $0, %eax
	je ispisi_nulu_pp_3
	jmp petlja_pp_3
	
ispisi_nulu_pp_3:
	addb $'0', %al
	movb %al, (%esi)
	jmp zavrsi_pp_3
	
petlja_pp_3:
	cmpl $0, %eax
	je okreni_string_pre
	
	movl $0, %edx
	divl %ebx
	
	addb $48, %dl
	movb %dl, (%esi)
	
	incl %esi
	jmp petlja_pp_3
	
okreni_string_pre:
	movb $0, (%esi)
	decl %esi
	movl $string_ispis1, %edi
	
okreni_string:
	cmpl %esi, %edi
	jae zavrsi_pp_3

	movb (%esi), %ah
	movb (%edi), %al
	movb %al, (%esi)
	movb %ah, (%edi)
	
	incl %edi
	decl %esi
	jmp okreni_string
	
zavrsi_pp_3:
	ispisi_string string_ispis1
	ispisi_string stringidk
	
	movl $0, %eax
	
	popl %edi
	popl %esi
	movl %ebp, %esp
	popl %ebp
	
	retSS

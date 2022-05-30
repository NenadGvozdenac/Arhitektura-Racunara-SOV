#autor: Imenko Prezimić INDEX ra1234-2018

.section .data
poruka1:        .ascii "Unesite broj naredbi: \0"
poruka2:        .ascii "Unesite naredbe (naredba po liniji):\n\0"
poruka3:        .ascii "Doslo je do greske u izvrsavanju programa!\n\0"
poruka4:        .ascii "Vrednost u registru R1 nakon operacija: \0"

string_unos_max = 6
string_unos:	.fill string_unos_max, 1, 42
string_max = 51
string: 	.fill 51, 1, 42

broj_naredbi:	.byte 0
registar:	.long 0

broj:		.long 0
greska:	.byte 0

string_rez:	.fill 15, 1, 0

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

main:
	ispisi_string poruka1	
	
	movl $3, %eax	# unos poruka1
	movl $0, %ebx
	movl $string_unos, %ecx
	movl $string_unos_max, %edx
	int $0x80
	
	decl %eax
	movb $0, string_unos(, %eax, 1)
	
	pushl $string_unos
	call konvertuj_decimalni_broj
	addl $4, %esp

	cmpl $5, broj_naredbi
	jg greska_pri_unosu

	ispisi_string poruka2

petlja:
	cmpb $0, broj_naredbi
	je zavrsi_program
	
	movl $3, %eax
	movl $0, %ebx
	movl $string, %ecx
	movl $string_max, %edx
	int $0x80
	
	decl %eax
	movb $0, string(, %eax, 1)
	
	pushl $string
	call izvrsi_operaciju
	addl $4, %esp
	
	cmpb $1, greska
	je greska_pri_prekoracenju
	
	decb broj_naredbi
	jmp petlja
	

zavrsi_program:
	ispisi_string poruka4
	movl registar, %eax
	pushl %eax
	call konvertuj_decimalni_broj_u_string
	addl $4, %esp
	movl $0, %ebx
	jmp kraj

greska_pri_prekoracenju:
	ispisi_string poruka3
	movl $3, %ebx
	jmp kraj

greska_pri_unosu:
	ispisi_string poruka3
	movl $4, %ebx
	jmp kraj

kraj:
	movl $1, %eax
	int $0x80
	
	
konvertuj_decimalni_broj_u_string:
	pushl %ebp
	movl %esp, %ebp

	movl 8(%ebp), %eax	# vrednost broja
	
	movl $10, %ebx
	movl $0, %ecx
	movl $0, %edx
	
	movl $string_rez, %esi	# adresa stringa
		
petlja_pp3:
	cmpl $0, %eax
	je okreni_pre_pp3
	
	movl $0, %edx
	divl %ebx
	
	movb %dl, (%esi)
	addb $48, (%esi)
	
	incl %esi
	jmp petlja_pp3
	
okreni_pre_pp3:
	movl $string_rez, %edi
	
	movb $0, (%esi)
	decl %esi
	
okreni_pp3:
	cmpl %esi, %edi
	jae kraj_pp3
	
	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	
	jmp okreni_pp3
	
kraj_pp3:
	ispisi_string string_rez
	
	movl %ebp, %esp
	popl %ebp
	
	ret	





	
	
	

izvrsi_operaciju:
	pushl %ebp
	movl %esp, %ebp
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	pushl %esi
	pushl %edi
	
	movl 8(%ebp), %esi	# string
		
	movl $16, %ebx
	movl $0, %eax
	movl $0, %ecx
	
petlja_pp2:
	cmpb $'x', (%esi)
	je konvertuj_dalje_pre_pp2
	
	incl %esi
	jmp petlja_pp2

konvertuj_dalje_pre_pp2:
	incl %esi
	
konvertuj_dalje_pp2:
	cmpb $',', (%esi)
	je zavrsi_konverziju_pp2
	
	movb (%esi), %cl
	subb $48, %cl
	
	cmpb $'A', (%esi)
	jge oduzmi_jos_7_pp2
	
vrati_se_pp2:
	mull %ebx
	jc greska_prekoracenje_pp2
	
	addl %ecx, %eax
	jc greska_prekoracenje_pp2
	
	incl %esi
	jmp konvertuj_dalje_pp2
	
oduzmi_jos_7_pp2:
	subb $7, %cl
	jmp vrati_se_pp2
	
greska_prekoracenje_pp2:
	movb $1, greska
	jmp zavrsi_pp2
	
zavrsi_konverziju_pp2:
	movl %eax, broj
	movl 8(%ebp), %esi	# pocetak stringa
	
	cmpb $'A', (%esi)
	je saberi_pp2
	
	cmpb $'S', (%esi)
	je oduzmi_pp2
	
	cmpb $'M', (%esi)
	je pomnozi_pp2
	
saberi_pp2:
	movl broj, %eax
	addl %eax, registar
	
	jmp zavrsi_pp2
	
oduzmi_pp2:
	movl broj, %eax
	subl %eax, registar
	
	jmp zavrsi_pp2
	
pomnozi_pp2:
	movl registar, %eax
	mull broj
	
	movl %eax, registar
	
	jmp zavrsi_pp2
	
zavrsi_pp2:
	popl %edi
	popl %esi
	
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
	
	
	
	
	
	
	
konvertuj_decimalni_broj:
	pushl %ebp
	movl %esp, %ebp
	pushl %ebx
	pushl %esi
	pushl %edx
	
	movl 8(%ebp), %esi	# string
	
	movl $0, %eax
	movl $10, %ebx
	movl $0, %ecx
	movl $0, %edx	
	
petlja_pp1:
	cmpb $0, (%esi)
	je uspesno_pp1
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	addl %ecx, %eax
	
	incl %esi
	jmp petlja_pp1
	
uspesno_pp1:
	movb %al, broj_naredbi
	jmp kraj_pp1
	
kraj_pp1:
	popl %edx
	popl %esi
	popl %ebx
	movl %esp, %ebp
	popl %ebp
	
	ret

#autor: Imenko Prezimić INDEX ra1234-2018
.section .data
ispis1:     .ascii "Unesite do 10 brojeva: \0"
ispis2:     .ascii "Transformisan  niz: \0"
greska1:    .ascii "Greska1 \0"
greska2:    .ascii "Greska2\n\0"
newlin:     .ascii "\n\0"

string_niza: .fill 151, 1, 42
string_temp: .fill 20, 1, 42

razmak: .ascii " \0"

niz:	.fill 20, 4, 0
rez:	.fill 20, 4, 0
element: .long 0
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

.macro upisi_string str, int
	movl $3, %eax
	movl $0, %ebx
	movl $\str, %ecx
	movl $\int, %edx
	int $0x80
	
	decl %eax
	movb $0, \str(, %eax, 1)
.endm

.macro isprazni_string str
	movl $\str, %esi
1:
	cmpb $42, (%esi)
	je 2f
	
	movb $42, (%esi)
	incl %esi
	jmp 1b
2:
.endm

main:
	ispisi_string ispis1
	upisi_string string_niza, 151
	
	movl $string_niza, %esi
	cmpb $0, (%esi)
	je prazan_string

	pushl $string_niza
	call normalizuj_niz
	addl $4, %esp
	
	movl $0, %esi
	movl $1, %edi
	
	movl element, %edx

petlja:
	decl element
	cmpl $0, element
	je kraj 
	
	movl niz(, %esi, 4), %eax
	addl niz(, %edi, 4), %eax
	jc prekoracenje_2
	
	movl %eax, niz(, %edi, 4)
	
	incl %esi
	incl %edi
	jmp petlja

prazan_string:
	ispisi_string greska1
	movl $1, %ebx
	jmp zavrsi_program

kraj:
	pushl %edx
	ispisi_string ispis2
	popl %edx
	
	movl $0, %eax

kraj_petlja:
	cmpl %eax, %edx
	je zavrsi_program_pre
	
	movl niz(, %eax, 4), %ebx
	
	pushl %ebx
	call ispisi_element
	addl $4, %esp
	
	incl %eax
	jmp kraj_petlja

prekoracenje:
	jmp prazan_string
	
prekoracenje_2:
	ispisi_string greska2
	movl $2, %ebx
	jmp zavrsi_program

zavrsi_program_pre:
	movl $0, %ebx
zavrsi_program:
	movl $1, %eax
	int $0x80



##################################
ispisi_element:
	pushl %ebp
	movl %esp, %ebp
	pushl %edi
	pushl %esi
	pushl %ebx
	pushl %eax
	pushl %edx
		
	movl 8(%ebp), %eax
	movl $string_temp, %esi
	
	movl $10, %ebx
	
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
	movb $0, (%esi)
	decl %esi
	
	movl $string_temp, %edi

okreni_pp3:
	cmpl %esi, %edi
	jae zavrsi_pp3
	
	movb (%esi), %al
	movb (%edi), %ah
	movb %al, (%edi)
	movb %ah, (%esi)

	incl %edi
	decl %esi
	
	jmp okreni_pp3

zavrsi_pp3:
	ispisi_string razmak
	ispisi_string string_temp

	popl %edx
	popl %eax
	popl %ebx
	popl %esi
	popl %edi
	movl %ebp, %esp
	popl %ebp
	ret



##################################
normalizuj_niz:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi
	pushl %ebx
	
	movl 8(%ebp), %esi	# adresa
	
	movl $0, %eax
	movl $0, %ebx
	movl $0, %edx

dodji_do_elementa:
	cmpb $' ', (%esi)
	jne dodaj_element_pp1
	
	incl %esi
	jmp dodji_do_elementa

dodaj_element_pp1:
	cmpb $0, (%esi)
	je dodaj_element_krajnji

	cmpb $' ', (%esi)
	je dodaj_element

	cmpb $'0', (%esi)
	jl preskoci_element
	
	cmpb $'z', (%esi)
	jg preskoci_element

	cmpb $'9', (%esi)
	jle dopisi_broj
	
	cmpb $'a', (%esi)
	jl preskoci_element
	
	movb (%esi), %cl	# ELEMENT
	movl $0, %ebx

petlja_2_pp1:
	cmpb $42, string_temp(, %ebx, 1)
	je dopisi_element
	
	cmpb %cl, string_temp(, %ebx, 1)
	je preskoci_element
	
	incl %ebx
	jmp petlja_2_pp1

dopisi_element:
	movb %cl, string_temp(, %ebx, 1)
	incl %esi
	jmp dodaj_element_pp1

preskoci_element:
	incl %esi
	jmp dodaj_element_pp1

dopisi_broj:
	movl $0, %ebx
	movb (%esi), %cl

dopisi_broj_pp2:
	cmpb $42, string_temp(, %ebx, 1)
	je dopisi_element
	
	incl %ebx
	jmp dopisi_broj_pp2

dodaj_element:
	movl $0, %ebx
dodaj_element_petlja:
	cmpb $42, string_temp(, %ebx, 1)
	je zavrsi_dodavanje_elementa
	
	incl %ebx
	jmp dodaj_element_petlja

zavrsi_dodavanje_elementa:
	movb $0, string_temp(, %ebx, 1)
	
	pushl $string_temp
	call dodaj_u_niz
	addl $4, %esp
	
	pushl %esi
	isprazni_string string_temp
	popl %esi
	jmp dodji_do_elementa

dodaj_element_krajnji:
	cmpb $42, string_temp(, %ebx, 1)
	je dodaj_element_krajnji_zavrs
	
	incl %ebx
	jmp dodaj_element_krajnji

dodaj_element_krajnji_zavrs:
	movb $0, string_temp(, %ebx, 1)
	
	pushl $string_temp
	call dodaj_u_niz
	addl $4, %esp
	
	jmp idi_dalje

idi_dalje:
	popl %ebx
	popl %edi
	popl %esi
	movl %ebp, %esp
	popl %ebp
	ret
	
	
	
	
	
	
	
	
	
	
###########################
dodaj_u_niz:
	pushl %ebp
	movl %esp, %ebp
	pushl %ebx
	pushl %esi
	
	movl 8(%ebp), %esi	# adresa niza
	movl $0, %eax
	movl $0, %ecx
	movl $0, %edx
	
	movl $36, %ebx
petlja_pp2:
	cmpb $0, (%esi)
	je zavrsi_dodavanje
	
	movb (%esi), %cl
	subb $48, %cl
	
	cmpb $10, %cl
	jg dovedi_do_slova
	
	mull %ebx
	jc prekoracenje
	addl %ecx, %eax
	jc prekoracenje
	
	incl %esi
	jmp petlja_pp2

dovedi_do_slova:
	subb $39, %cl
	
	mull %ebx
	jc prekoracenje
	addl %ecx, %eax
	jc prekoracenje
	
	incl %esi
	jmp petlja_pp2

zavrsi_dodavanje:
	movl element, %ebx
	movl %eax, niz(, %ebx, 4)
	incl %ebx
	movl %ebx, element

kraj_pp2:
	popl %esi
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret

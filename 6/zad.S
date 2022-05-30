# autor: Imenko Prezimić INDEX ra1234-2018
# fajlovi: zad.S

.section .data
  unesi_tekst: .ascii "Unesite tekst: \0"
  unesi_kod: .ascii "Unesite kod: \0"
  unesi_bazu: .ascii "Unesite bazu: \0"
  sifrovano_poruka: .ascii "Sifrovan tekst: \0"
  resenje_poruka: .ascii "Broj sifrovanih karaktera je: \0"
  
  ent: .ascii "\n\0"
  
  tekst:	.fill 51, 1, 42
  kod:		.fill 6, 1, 42
  baza:	.fill 6, 1, 42
  
  baza_i:	.long 0
  kod_i:	.long 0
  
  greska:	.byte 0
  
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
	ispisi_string unesi_tekst
	unesi_string tekst, 51

	ispisi_string unesi_bazu
	unesi_string baza, 6
	
	pushl $baza
	pushl $baza_i
	call dekodiraj_broj
	addl $8, %esp
	
	cmpb $1, greska
	je pogresan_karakter_ili_prekoracenje
	
	ispisi_string unesi_kod
	unesi_string kod, 6
	
	pushl $kod
	pushl $kod_i
	call dekodiraj_broj
	addl $8, %esp

	cmpb $1, greska
	je pogresan_karakter_ili_prekoracenje

	movl $tekst, %esi	# pocetna adresa stringa
	
	movl $0, %ecx	# brojac
	
	movl $26, %ebx
	movl kod_i, %eax
	
	movl $0, %edx
	divl %ebx
	movl %edx, kod_i

kodiranje_stringa:
	cmpb $0, (%esi)
	je zavrsi_program
	
	cmpb $'a', (%esi)
	jl preskoci_element
	
	cmpb $'z', (%esi)
	jg preskoci_element
	
	movl kod_i, %edx
	addb %dl, (%esi)
	
	cmpb $'z', (%esi)
	jg smanji_za_26
	
	incl %ecx	# brojac
	
	incl %esi
	jmp kodiranje_stringa
	
preskoci_element:
	incl %esi
	jmp kodiranje_stringa
	
smanji_za_26:
	subb $26, (%esi)
	incl %ecx
	incl %esi
	jmp kodiranje_stringa
	
zavrsi_program:
	
	pushl %ecx
	ispisi_string sifrovano_poruka
	ispisi_string tekst
	ispisi_string ent

	ispisi_string resenje_poruka
	popl %ecx
	
	pushl %ecx
	pushl baza_i
	pushl $baza
	call kodiraj_u_string
	addl $12, %esp
	
	ispisi_string baza

uspesan_program:
	movl $0, %ebx
	jmp kraj

pogresan_karakter_ili_prekoracenje:
	movl $2, %ebx
	jmp kraj
	
kraj:
	movl $1, %eax
	int $0x80








	# dekodiraj_broj(int*, char*)
dekodiraj_broj:
	pushl %ebp
	movl %esp, %ebp
	pushl %eax
	pushl %esi
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	movl 12(%ebp), %esi	# char*
	
	movl $0, %eax
	movl $10, %ebx
	movl $0, %ecx
	
petlja_pp1:
	cmpb $0, (%esi)
	je zavrsi_pp1
	
	movb (%esi), %cl
	subb $48, %cl
	
	mull %ebx
	jc ogranicenje_pp1
	addl %ecx, %eax
	jc ogranicenje_pp1
	
	incl %esi
	jmp petlja_pp1
	
ogranicenje_pp1:
	movb $1, greska
	jmp kraj_pp1
	
zavrsi_pp1:
	movl 8(%ebp), %edx
	movl %eax, (%edx)
	jmp kraj_pp1
	
kraj_pp1:
	popl %edx
	popl %ecx
	popl %ebx
	popl %esi
	popl %eax
	movl %ebp, %esp
	popl %ebp
	
	ret
	
	
kodiraj_u_string:
	pushl %ebp
	movl %esp, %ebp
	pushl %ebx
	
	movl 16(%ebp), %eax	# broj za konverziju
	movl 12(%ebp), %ebx	# broj baza
	movl 8(%ebp), %esi	# char* baza
	
	movl $0, %edx

petlja_pp2:
	cmpl $0, %eax
	je okreni_pre_pp2
	
	movl $0, %edx
	divl %ebx
	
	movb %dl, (%esi)
	addb $48, (%esi)
	
	incl %esi
	jmp petlja_pp2
	
okreni_pre_pp2:
	movb $0, (%esi)
	decl %esi
	
	movl 8(%ebp), %edi

okreni_pp2:
	cmpl %esi, %edi
	jae zavrsi_pp2
	
	movb (%esi), %al
	movb (%edi), %ah
	
	movb %al, (%edi)
	movb %ah, (%esi)
	
	incl %edi
	decl %esi
	
	jmp okreni_pp2

zavrsi_pp2:
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	
	ret

data segment
msg db 0dh,0ah,"1-Addition '+'",0dh,0ah,"2-Multiplication",0dh,0ah,"3-Soustraction",0dh,0ah,"4-Division",0dh,0ah,"$"
msg2 db "Entrer le 1er nombre : $"
msg3 db 0dh,0ah,"Enter le 2eme nombre : $" 
msg4 db 0dh,0ah,"Erreur ",0dh,0ah,"$"
msg5 db 0dh,0ah,"Resultat : $"
msg6 db 0dh,0ah,"Fin: press any key..",0dh,0ah,"$" 
saut db 0dh,0ah,"$"
retour db 0dh,"$"
plus db " + $"
moins db " - $"
fois db " x $"
par db " / $"
egale db " = $"
data ends

stack segment
    dw   128  dup(0)
ends

code segment
    assume cs:code,ds:data,ss:stack 
        
start:

    mov ax,data
    mov ds,ax
    
    mov ax,stack
    mov ss,ax
    
    mov ah,9
    mov dx,offset msg2
    int 21h 
    
    mov cx,0;   Obligatoir avant chaque lecture
    call InputNo 
    
    push dx;    empiler le nombre lu (a)
    
    mov ah,9
    mov dx,offset msg3
    int 21h  
    
    mov cx,0;   avant chaque lecture
    call InputNo 
    push dx;    empiler le nombre lu (b)
    
    mov ah,9
    mov dx,offset msg
    int 21h
     
    mov ah,1
    int 21h
        
    cmp al,2Bh;     addition
    je Addition
    
    cmp al,2dh
    je Soustraction 
    
    cmp al,78h
    je Multiplication
    ;
    ;
erreur:
    mov ah,9
    mov dx, offset msg4
    int 21h
    jmp start

Addition:
    push ax;    Sauvegarder la contexte
    push bx
    push cx
    push dx
    push bp
    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp    
    mov bx,[bp+10]; bx=b
    mov dx,[bp+12]; dx=a
    
    add dx,bx
    jo erreur;  En cas d'overflow
    push dx;    Sauvegarder le resultat
 

    
    mov dx,[bp+12] ;    Afficher a
    call AfficherNo
    
    mov ah,9
    mov dx, offset plus;    Afficher +
    int 21h
    
    mov dx,[bp+10] 
    call AfficherNo;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    

    
    pop dx ;    Recuperer a+b

    call AfficherNo; Afficher le resultat
    
    pop bp ;    Restaurer le contexte
    pop dx
    pop cx
    pop bx
    pop ax
    jmp exit
    
Soustraction:
    push ax;    Sauvegarder la contexte
    push bx
    push cx
    push dx
    push bp
    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp    
    mov bx,[bp+10]; bx=b
    mov dx,[bp+12]; dx=a 
      
    
    SUB dx,bx
    jo erreur;  En cas d'overflow
    push dx;    Sauvegarder le resultat
 

    
    mov dx,[bp+12] ;    Afficher a
    call AfficherNo
    
    mov ah,9
    mov dx, offset moins;    Afficher -
    int 21h
    
    mov dx,[bp+10] 
    call AfficherNo;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    

    
    pop dx ;    Recuperer a+b

    call AfficherNo; Afficher le resultat
    
    pop bp ;    Restaurer le contexte
    pop dx
    pop cx
    pop bx
    pop ax
    jmp exit

Multiplication:
    push ax;    Sauvegarder la contexte
    push bx
    push cx
    push dx
    push bp
    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp    
    mov bx,[bp+10]; bx=b
    mov ax,[bp+12]; dx=a 
      
    
    mul bx
    jo erreur;  En cas d'overflow
    push ax;    Sauvegarder le resultat
 

    
    mov dx,[bp+12] ;    Afficher a
    call AfficherNo
    
    mov ah,9
    mov dx, offset fois;    Afficher -
    int 21h
    
    mov dx,[bp+10] 
    call AfficherNo;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    

    
    pop dx ;    Recuperer a+b

    call AfficherNo; Afficher le resultat
    
    pop bp ;    Restaurer le contexte
    pop dx
    pop cx
    pop bx
    pop ax
    jmp exit
    

exit:
    mov dx,offset msg6
    mov ah,9
    int 21h 
    
    mov ah,0
    int 16h
    
    mov ah,4ch
    int 21h
        
InputNo proc
    mov ah,01
    int 21h
    
    mov dx,0
    mov bx,1;       initialiser bx avant de former le nombre 
    cmp al,0dh;     enter key
    je FormNo
    
    ;                 0<=al<=9
    cmp al,30h; 30h code asci 0
    jb erreur
    cmp al,39h; 39h code asci 9
    ja erreur
    
    sub ax,30h;     convertire en chiffre
    mov ah,0;       pour push la valeur lu correctement
    push ax
    inc cx;         le nombre de chiffres du nombre lu
    jmp InputNo
    ret
InputNo ENDP
    
FormNo proc
    pop ax
    push dx;    sauvegarder dx (modifier par mul)
    mul bx;     mettre la chiffre au bon rang
    jo erreur
    pop dx;     restaurer dx
    add dx,ax
    jo erreur;  valeur entrer par l'utilisateur superieur a 7FFFh
    mov ax,bx;  enregister bx dans ax pour la multiplication apres
    mov bx,10
    push dx
    mul bx;     pour avancer au rang suivant (ax=bx*10)
    pop dx
    mov bx,ax;  recuperer le nouveau bx
    dec cx;     decrementer le compteur de chiffre du nombre
    cmp cx,0;   si le nombre de chiffre restant est superieur a 0 on refait l'operation
    ja FormNo
    ret ;       sinon return
FormNo ENDP


View proc
    push ax
    push bx
    push cx
    push dx 
    
 finSauvgarde:
            mov ax,dx
            mov dx,0
            div cx
            call ViewNo
            mov bx,dx
            mov dx,0
            mov ax,cx
            mov cx,10
            div cx
            mov dx,bx
            mov cx,ax
            cmp ax,0  
            jne finSauvgarde 
    pop dx
    pop cx
    pop bx 
    pop ax

    ret
    
View ENDP


AfficherNo proc 

    clc
    rol dx,1
    ror dx,1
    jnc UnChiffre
    neg dx

    push ax
    push dx    
    mov ah,2
    mov dx,"-"
    int 21h
    pop dx
    pop ax 
    
UnChiffre:
    cmp dx,10
    jae DeuxChiffres
    mov cx,1
    jmp fin
DeuxChiffres:
    cmp dx,100
    jae TroisChiffres
    mov cx,10
    jmp fin
TroisChiffres:
    cmp dx,1000
    jae QuatreChiffres
    mov cx,100
    jmp fin 
QuatreChiffres:  
    cmp dx,10000
    jae CinqeChiffres
    mov cx,1000
    jmp fin
     
CinqeChiffres:
    mov cx,10000
    
fin:

    call View  
    ret
      
ViewNo proc
    push ax
    push dx
    mov dx,ax
    add dl,30h
    mov ah,2
    int 21h
    pop dx
    pop ax
    ret;?? 
ViewNo ENDP
    
code ENDS

    
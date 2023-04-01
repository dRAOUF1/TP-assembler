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
    call InputNo10 
    
    push dx;    empiler le nombre lu (a)
    
    mov ah,9
    mov dx,offset msg3
    int 21h  
    
    mov cx,0;   avant chaque lecture
    call InputNo10 
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
    
    cmp al,2Fh
    je Division

erreur:
    mov ah,9
    mov dx, offset msg4
    int 21h
    jmp start

Addition:

    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp    
    mov bx,[bp]; bx=b
    mov dx,[bp+2]; dx=a
    
    add dx,bx
    jo erreur;  En cas d'overflow
    push dx;    Sauvegarder le resultat
 

Addition10:    
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo10
    
    mov ah,9
    mov dx, offset plus;    Afficher +
    int 21h
    
    mov dx,[bp] 
    call AfficherNo10;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer a+b

    call AfficherNo10; Afficher le resultat
    

    jmp exit 
    

;Addition2:    
;    mov dx,[bp+2] ;    Afficher a
;    call AfficherNo2
;    
;    mov ah,9
;    mov dx, offset plus;    Afficher +
;    int 21h
;    
;    mov dx,[bp] 
;    call AfficherNo2;    Afficher b 
;        
;    mov ah,9
;    mov dx, offset egale;   Afficher =
;    int 21h 
;    
;    pop dx ;    Recuperer a+b
;
;    call AfficherNo2; Afficher le resultat
;    
;
;    jmp exit
    
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
    call AfficherNo10
    
    mov ah,9
    mov dx, offset moins;    Afficher -
    int 21h
    
    mov dx,[bp+10] 
    call AfficherNo10;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    

    
    pop dx ;    Recuperer a-b

    call AfficherNo10; Afficher le resultat
    
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
   
    push ax;    Sauvegarder le resultat  
    push dx
 

    
    mov dx,[bp+12] ;    Afficher a
    call AfficherNo10
    
    mov ah,9
    mov dx, offset fois;    Afficher x
    int 21h
    
    mov dx,[bp+10] 
    call AfficherNo10;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer la 1ere partie de axb       
    pop ax
    cmp dx,0
    je Partie2

    call view32_10; Afficher le resultat 
    
 Partie2:       
    mov dx,ax ;    Recuperer la 2eme partie de axb

    call AfficherNo10; Afficher le resultat
    
    pop bp ;    Restaurer le contexte
    pop dx
    pop cx
    pop bx
    pop ax
    jmp exit

Division:
    push ax;    Sauvegarder la contexte
    push bx
    push cx
    push dx
    push bp
    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp  
    xor dx,dx  
    mov bx,[bp+10]; bx=b
    mov ax,[bp+12]; dx=a 
    
    div bx
    jo erreur
    push ax   
    
    mov dx,[bp+12] ;    Afficher a
    call AfficherNo10
    
    mov ah,9
    mov dx, offset par;    Afficher /
    int 21h
    
    mov dx,[bp+10] 
    call AfficherNo10;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer  a/b       
    call AfficherNo10 
    
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
        
InputNo10 proc
    mov ah,01
    int 21h
    
    mov dx,0
    mov bx,1;       initialiser bx avant de former le nombre 
    cmp al,0dh;     enter key
    je FormNo10
    
    ;                 0<=al<=9
    cmp al,30h; 30h code asci 0
    jb erreur
    cmp al,39h; 39h code asci 9
    ja erreur
    
    sub ax,30h;     convertire en chiffre
    mov ah,0;       pour push la valeur lu correctement
    push ax
    inc cx;         le nombre de chiffres du nombre lu 
    
    jmp InputNo10
    ret  
    
InputNo10 ENDP
    
FormNo10 proc
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
    ja FormNo10
    
    ret ;       sinon return  
    
FormNo10 ENDP


View10 proc
    push ax
    push bx
    push cx
    push dx 
    
    finSauvgarde:
                mov ax,dx
                mov dx,0
                div cx
                call ViewNo10
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
    
View10 ENDP


AfficherNo10 proc 

    clc
    rol dx,1
    ror dx,1
    jnc AvantBoucle10
    neg dx

    push ax
    push bx
    push dx    
    mov ah,2
    mov dx,"-"
    int 21h
    pop dx 
    pop bx
    pop ax 
    
    AvantBoucle10: 
        push ax
        push bx
        mov ax,10  ;ax=10
        mov bx,ax  ;bx=10  
    Boucle10:
        cmp dx,ax
        jb fin     ;si dx<ax alors on arriver a un rang en plus  
        cmp ax,10000
        je fin5chiffres
        push dx     
        mul bx     ;sinon rang suivant 
        pop dx 
        jo fin
        jmp Boucle10
   
    fin:    
        push dx  
                xor dx,dx
        div bx     ;recuperer le vrai rang (rang en plus / 10)
        pop dx 
    fin5chiffres:
        mov cx,ax 
        pop bx     ; restaurer bx et ax
        pop ax
        call View10 
         
    ret  
    
AfficherNo10 ENDP
      
ViewNo10 proc 
    
    push ax
    push dx
    mov dx,ax
    add dl,30h
    mov ah,2
    int 21h
    pop dx
    pop ax
    
    ret   
    
ViewNo10 ENDP 


view32_10 proc
    
    push ax
    push bx
    push cx
    push dx
    
    mov bx,10 ;Constante 10 stockee dans BX
    push bx ;bx est constant donc on peut l'utiliser comme marqueur pour sortir de la boucle            
    
    diviser: 
        mov cx,ax ;Stocke temporairement le partie bassse dans CX
        mov ax,dx ;Stocke temporairement le partie bassse dans AX
        
        xor dx,dx ;DX=0 pour la division DX:AX / BX
        div bx ; AX est le quotient haut, le reste est utilise dans la prochaine division
        xchg ax,cx ;Deplace le quotient de la partie haute dans CX et la partie basse(quotient) dans AX 
        div bx ; AX est le quotient bas, le reste est dans DX=[0,9]
        push dx ;Sauvegarde le reste 
        mov dx,cx ;Deplacer le quotient de la partie haute dans DX
        or cx,ax ;=0 uniquement si cx=0 et ax=0 (quotient de la partie haute et celui de la partie basse =0)
        jnz diviser ;Si !=0 boucler
        pop dx ;Recuperer l'unite
    
    afficher: 
        add dl,30h ;Transforme en caractere [0,9] -> ["0","9"]
        mov ah,02h ;Afficher
        int 21h 
        pop dx ;Recupere le prochain rang
        cmp dx,bx ;SI dx=10 alors on est arrive a la fin (le bx empiler au debut)
        jb afficher 
             
    
    pop dx
    pop cx
    pop bx
    pop ax 
    
    ret  
    
view32_10 ENDP
    
code ENDS

    
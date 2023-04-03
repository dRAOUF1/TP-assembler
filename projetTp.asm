
data segment

; "messageIntro", contient le nom des developpeurs de la calculatrice.
messageIntro DB "Calculatrice developpee par Touzene Abderraouf & Abed Abdeldjalil", 0Dh, 0Ah,0Dh, 0Ah, '$'

;"Menu", affiche un menu a l'utilisateur et l'invite a choisir une operation : addition, soustraction, multiplication ou division.
Menu db 0dh,0ah," Veuillez choisir l'operation a effectuer : ",0dh,0ah,"'+' pour l'addition ",0dh,0ah,"'-' pour la soustraction ",0dh,0ah,"'*' pour la multiplication",0dh,0ah,"'/' pour la division.",0dh,0ah,"$"

;"Num1" et "Num2", demandent a l'utilisateur d'entrer les deux nombres sur lesquels il souhaite effectuer l'operation selectionnee.
Num1 db "Entrer le 1er nombre : $"
Num2 db 0dh,0ah,"Enter le 2eme nombre : $" 

;"baseMsg", demandent a l'utilisateur d'entrer la base de l'opeartion
baseMsg DB "Entrez la base de l'operation :",0dh,0ah,"1-decimal",0dh,0ah,"2-binaire",0dh,0ah,"3-hexadecimal",0dh,0ah,"$"
base DB 4 DUP('$')

;"Erreurmsg", est utilisee pour afficher un message d'erreur si quelque chose se passe mal pendant le calcul.
ErreurInputMsg db 0dh,0ah,"Erreur:",0dh,0ah," Le nombre/chiffre entree est incorrect",0dh,0ah,"$"

ErreurDiv0Msg db 0dh,0ah,"Erreur:",0dh,0ah,"Division par 0 impossible ",0dh,0ah,"$"
                                                                                   
ErreurOverFlowMsg db 0dh,0ah,"Erreur:",0dh,0ah,"OVERFLOW",0dh,0ah,"$"                                                                                   
;"Finmsg", indique la fin du programme et invite l'utilisateur a appuyer sur n'importe quelle touche pour sortir.
Finmsg db 0dh,0ah,"Fin: press any key..",0dh,0ah,"$" 

;"saut et retour", cree une rupture de ligne a des fins de mise en forme.
saut db 0dh,0ah,"$"
retour db 0dh,"$"

;les operations
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
    
    
    ; Affichage du message d'introduction
    MOV AH, 9
    LEA DX, messageIntro
    INT 21h 
debut:
    ; Affichage du message de la base d'operation
    MOV AH, 9
    LEA DX, baseMsg
    INT 21h
    
    ; Lecture de la base
    MOV AH, 1 ; lecture d'un seul charactere
    INT 21h
    push ax
     
    mov ah,9
    mov dx, offset saut
    int 21h
     
    ; Traitement en fonction de la base choisie
     
    pop cx  
    cmp cl, "1"
    je Input10
    CMP cl, '2'
    JE Input2
    CMP cl, '3'
    JE Input16
    JMP ErreurInput ; jump to error if the input is invalid
    
    
    

Input10:
    ; Affichage du premier message  
    mov ah,9
    mov dx,offset Num1
    int 21h
    
    push cx
    mov cx,0;   Obligatoir avant chaque lecture
    call InputNo10 
    
    push dx;    empiler le nombre lu (a)
    
    mov ah,9
    mov dx,offset Num2
    int 21h  
    
    push cx
    mov cx,0;   avant chaque lecture
    call InputNo10 
    pop cx
    push dx;    empiler le nombre lu (b) 
      
    jmp Operation
    
Input2:
    ; Affichage du premier message  
    mov ah,9
    mov dx,offset Num1
    int 21h
     
    push cx
    mov cx,0;   Obligatoir avant chaque lecture
    call InputNo2  
    pop cx
    
    push dx;    empiler le nombre lu (a)
    
    mov ah,9
    mov dx,offset Num2
    int 21h  
    
    push cx
    mov cx,0;   avant chaque lecture
    call InputNo2
    pop cx 
    push dx;    empiler le nombre lu (b)  
     
    jmp Operation

Input16: 
        ; Affichage du premier message  
    mov ah,9
    mov dx,offset Num1
    int 21h 
    
    push cx
    mov cx,0;   Obligatoir avant chaque lecture
    call InputNo16
    pop cx
    push dx;    empiler le nombre lu (a)
    
    mov ah,9
    mov dx,offset Num2
    int 21h  
    
    push cx
    mov cx,0;   avant chaque lecture
    call InputNo16  
    pop cx
    push dx;    empiler le nombre lu (b) 
    
Operation:    
    mov ah,9
    mov dx,offset Menu
    int 21h
     
    mov ah,1
    int 21h 
        
    cmp al,2Bh  ;addition
    je Addition
    
    cmp al,2dh
    je Soustraction ;Soustraction
    
    cmp al,2Ah       
    je Multiplication ;Multiplication 
    
    cmp al,2Fh
    je Division ;Division   
    
    
    ;Gestion d'erreur
ErreurInput:
    mov dx, offset ErreurInputMsg
    mov ah,9
    int 21h
    jmp debut

ErreurOverflow:
    mov dx, offset ErreurOverFlowMsg
    mov ah,9
    int 21h
    jmp debut 

ErreurDiv0:
    mov dx, offset ErreurDiv0Msg
    mov ah,9
    int 21h
    jmp debut

Addition:

    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp    
    mov bx,[bp]; bx=b
    mov dx,[bp+2]; dx=a
    
    add dx,bx
    jo ErreurOverFlow;  En cas d'overflow
    push dx;    Sauvegarder le resultat 
    
    cmp cl,"2"
    je Addition2
    cmp cl,"3"
    je Addition16


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
    

Addition2:    
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo2
    
    mov ah,9
    mov dx, offset plus;    Afficher +
    int 21h
    
    mov dx,[bp] 
    call AfficherNo2;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer a+b

    call AfficherNo2; Afficher le resultat
    

    jmp exit 

Addition16:    
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo16
    
    mov ah,9
    mov dx, offset plus;    Afficher +
    int 21h
    
    mov dx,[bp] 
    call AfficherNo16;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer a+b

    call AfficherNo16; Afficher le resultat
    

    jmp exit
    
Soustraction:

    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp    
    mov bx,[bp]; bx=b
    mov dx,[bp+2]; dx=a 
      
    
    SUB dx,bx
    jo ErreurOverFlow;  En cas d'overflow
    push dx;    Sauvegarder le resultat 
    
    cmp cl,"2"
    je Soustraction2
    cmp cl,"3"
    je Soustraction16
    
Soustraction10:
    
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo10
    
    mov ah,9
    mov dx, offset moins;    Afficher -
    int 21h
    
    mov dx,[bp] 
    call AfficherNo10;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    

    
    pop dx ;    Recuperer a-b

    call AfficherNo10; Afficher le resultat
    jmp exit
    
Soustraction2:
        
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo2
    
    mov ah,9
    mov dx, offset moins;    Afficher -
    int 21h
    
    mov dx,[bp] 
    call AfficherNo2;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    

    
    pop dx ;    Recuperer a-b

    call AfficherNo2; Afficher le resultat

    jmp exit  
    
Soustraction16:
        
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo16
    
    mov ah,9
    mov dx, offset moins;    Afficher -
    int 21h
    
    mov dx,[bp] 
    call AfficherNo16;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    

    
    pop dx ;    Recuperer a-b

    call AfficherNo16; Afficher le resultat

    jmp exit

Multiplication:
    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp    
    mov bx,[bp]; bx=b
    mov ax,[bp+2]; dx=a 
      
    
    mul bx
   
    push ax;    Sauvegarder le resultat  
    push dx 
    
    cmp cl,"2"
    je Multiplication2
    cmp cl,"3"
    je Multiplication16

Multiplication10:
    
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo10
    
    mov ah,9
    mov dx, offset fois;    Afficher x
    int 21h
    
    mov dx,[bp] 
    call AfficherNo10;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer la 1ere partie de axb       
    pop ax ;    Recuperer la 2eme partie de axb 


    call view32_10; Afficher le resultat 
    jmp exit


Multiplication2:
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo2
    
    mov ah,9
    mov dx, offset fois;    Afficher x
    int 21h
    
    mov dx,[bp] 
    call AfficherNo2;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer la 1ere partie de axb       
    pop ax
    

    call view32_2; Afficher le resultat 
    jmp exit 

Multiplication16:
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo16
    
    mov ah,9
    mov dx, offset fois;    Afficher x
    int 21h
    
    mov dx,[bp] 
    call AfficherNo16;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer la 1ere partie de axb       
    pop ax
    

    call view32_16; Afficher le resultat 
    jmp exit

Division:

    
    mov ah,9
    mov dx, offset retour
    int 21h  

    mov bp,sp  
    xor dx,dx  
    mov bx,[bp]; bx=b 
    
    cmp bx,0
    je ErreurDiv0 
    mov ax,[bp+2]; dx=a 
    
    div bx
    push ax 
    
    cmp cl,"2"
    je Division2
    cmp cl,"3"
    je Division16

Division10:  
    
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo10
    
    mov ah,9
    mov dx, offset par;    Afficher /
    int 21h
    
    mov dx,[bp] 
    call AfficherNo10;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer  a/b       
    call AfficherNo10 
   
    jmp exit  

Division2:
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo2
    
    mov ah,9
    mov dx, offset par;    Afficher /
    int 21h
    
    mov dx,[bp] 
    call AfficherNo2;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer  a/b       
    call AfficherNo2 
   
    jmp exit 
    
Division16:
    mov dx,[bp+2] ;    Afficher a
    call AfficherNo16
    
    mov ah,9
    mov dx, offset par;    Afficher /
    int 21h
    
    mov dx,[bp] 
    call AfficherNo16;    Afficher b 
        
    mov ah,9
    mov dx, offset egale;   Afficher =
    int 21h 
    
    pop dx ;    Recuperer  a/b       
    call AfficherNo16 
   
    jmp exit              

exit:
    mov dx,offset Finmsg
    mov ah,9
    int 21h 
    
    mov ah,0
    int 16h
    
    mov ah,4ch
    int 21h 
    
   
    
    ;Debut des procedure
        
InputNo10 proc
    mov ah,01
    int 21h
    
    mov dx,0
    mov bx,1;       initialiser bx avant de former le nombre 
    cmp al,0dh;     enter key
    je FormNo10
    
    ;                 0<=al<=9
    cmp al,30h; 30h code asci 0
    jb ErreurInput
    cmp al,39h; 39h code asci 9
    ja ErreurInput
    
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
    jo ErreurOverFlow
    pop dx;     restaurer dx 
    
    add dx,ax
    jo ErreurOverFlow;  valeur entrer par l'utilisateur superieur a 7FFFh  
    
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
      
ViewNo proc 
    
    push ax
    push dx
    mov dx,ax
    cmp dx,9
    ja  ViewNo16
    add dl,30h
    jmp FinView
    ViewNo16:
        add dl,37h
    FinView:
        mov ah,2
        int 21h
        pop dx
        pop ax    
    ret   
    
ViewNo ENDP 


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
        mov ax,dx
        call ViewNo
        pop dx ;Recupere le prochain rang
        cmp dx,bx ;SI dx=10 alors on est arrive a la fin (le bx empiler au debut)
        jb afficher 
             
    
    pop dx
    pop cx
    pop bx
    pop ax 

    ret  
    
view32_10 ENDP  



InputNo2 proc
    mov ah,01
    int 21h
    
    mov dx,0
    mov bx,1;       initialiser bx avant de former le nombre 
    cmp al,0dh;     enter key
    je FormNo2
    
    ;                 0<=al<=9
    cmp al,30h; 30h code asci 0
    jb ErreurInput
    cmp al,31h; 39h code asci 9
    ja ErreurInput
    
    sub ax,30h;     convertire en chiffre
    mov ah,0;       pour push la valeur lu correctement
    push ax
    inc cx;         le nombre de chiffres du nombre lu 
    
    jmp InputNo2
    ret  
    
InputNo2 ENDP 

FormNo2 proc
    pop ax       
    
    push dx;    sauvegarder dx (modifier par mul)
    mul bx;     mettre la chiffre au bon rang
    jo ErreurOverFlow
    pop dx;     restaurer dx 
    
    add dx,ax
    jo ErreurOverFlow;  valeur entrer par l'utilisateur superieur a 7FFFh  
    
    mov ax,bx;  enregister bx dans ax pour la multiplication apres
    mov bx,2
    push dx
    mul bx;     pour avancer au rang suivant (ax=bx*10)
    pop dx
    mov bx,ax;  recuperer le nouveau bx 
    
    dec cx;     decrementer le compteur de chiffre du nombre
    cmp cx,0;   si le nombre de chiffre restant est superieur a 0 on refait l'operation
    ja FormNo2
    
    ret ;       sinon return  
    
FormNo2 ENDP

AfficherNo2 proc 
    
    clc
    rol dx,1
    ror dx,1
    jnc AvantBoucle2
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

    AvantBoucle2: 
        push ax
        push bx
        mov ax,2  ;ax=2
        mov bx,ax  ;bx=2  
    Boucle2:
        cmp dx,ax
        jb fin2     ;si dx<ax alors on arriver a un rang en plus  
        cmp ax,4000h
        je finBcpchiffres
        push dx     
        mul bx     ;sinon rang suivant 
        pop dx
        jmp Boucle2
   
    fin2:    
        push dx  
                xor dx,dx
        div bx     ;recuperer le vrai rang (rang en plus / 10)
        pop dx 
    finBcpchiffres:
        mov cx,ax 
        pop bx     ; restaurer bx et ax
        pop ax
        call View2 
         
    ret  
    
AfficherNo2 ENDP 

View2 proc
    push ax
    push bx
    push cx
    push dx 
    
    finSauvgarde2:
                mov ax,dx
                mov dx,0
                div cx
                call ViewNo
                mov bx,dx
                mov dx,0
                mov ax,cx
                mov cx,2
                div cx
                mov dx,bx
                mov cx,ax
                cmp ax,0  
                jne finSauvgarde2 
    pop dx
    pop cx
    pop bx 
    pop ax

    ret
    
View2 ENDP 

view32_2 proc
    
    push ax
    push bx
    push cx
    push dx
    
    mov bx,2 ;Constante 10 stockee dans BX
    push bx ;bx est constant donc on peut l'utiliser comme marqueur pour sortir de la boucle            
    
    diviser2: 
        mov cx,ax ;Stocke temporairement le partie bassse dans CX
        mov ax,dx ;Stocke temporairement le partie bassse dans AX
        
        xor dx,dx ;DX=0 pour la division DX:AX / BX
        div bx ; AX est le quotient haut, le reste est utilise dans la prochaine division
        xchg ax,cx ;Deplace le quotient de la partie haute dans CX et la partie basse(quotient) dans AX 
        div bx ; AX est le quotient bas, le reste est dans DX=[0,9]
        push dx ;Sauvegarde le reste 
        mov dx,cx ;Deplacer le quotient de la partie haute dans DX
        or cx,ax ;=0 uniquement si cx=0 et ax=0 (quotient de la partie haute et celui de la partie basse =0)
        jnz diviser2 ;Si !=0 boucler
        pop dx ;Recuperer l'unite
    
    afficher2: 
        mov ax,dx
        call ViewNo 
        pop dx ;Recupere le prochain rang
        cmp dx,bx ;SI dx=10 alors on est arrive a la fin (le bx empiler au debut)
        jb afficher2 
             
    
    pop dx
    pop cx
    pop bx
    pop ax 
    
    ret  
    
view32_2 ENDP  


InputNo16 proc
    mov ah,01
    int 21h
    
    mov dx,0
    mov bx,1;       initialiser bx avant de former le nombre 
    cmp al,0dh;     enter key
    je FormNo16
    
    ;                 0<=al<=9
    cmp al,30h; 30h code asci 0
    jb ErreurInput
    cmp al,39h
    jbe ErreurInput
    cmp al,41h; 39h code asci 9
    jb ErreurInput
    cmp al,46h
    ja ErreurInput 
    
    sub ax,37h
    jmp FinConvertion
    
    Decimale:
        sub ax,30h;     convertire en chiffre        
    FinConvertion:
        mov ah,0;       pour push la valeur lu correctement
        push ax
        inc cx;         le nombre de chiffres du nombre lu 
        
        jmp InputNo16
    ret  
    
InputNo16 ENDP  

FormNo16 proc
    pop ax       
    
    push dx;    sauvegarder dx (modifier par mul)
    mul bx;     mettre la chiffre au bon rang
    jo ErreurOverFlow
    pop dx;     restaurer dx 
    
    add dx,ax
    jo ErreurOverFlow;  valeur entrer par l'utilisateur superieur a 7FFFh  
    
    mov ax,bx;  enregister bx dans ax pour la multiplication apres
    mov bx,16
    push dx
    mul bx;     pour avancer au rang suivant (ax=bx*10)
    pop dx
    mov bx,ax;  recuperer le nouveau bx 
    
    dec cx;     decrementer le compteur de chiffre du nombre
    cmp cx,0;   si le nombre de chiffre restant est superieur a 0 on refait l'operation
    ja FormNo16
    
    ret ;       sinon return  
    
FormNo16 ENDP

AfficherNo16 proc 
    
    clc
    rol dx,1
    ror dx,1
    jnc AvantBoucle16
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

    AvantBoucle16: 
        push ax
        push bx
        mov ax,16  ;ax=16
        mov bx,ax  ;bx=16 
    Boucle16:
        cmp dx,ax
        jb fin16     ;si dx<ax alors on arriver a un rang en plus  
        cmp ax,1000h
        je fin4chiffres
        push dx     
        mul bx     ;sinon rang suivant 
        pop dx
        jmp Boucle16
   
    fin16:    
        push dx  
                xor dx,dx
        div bx     ;recuperer le vrai rang (rang en plus / 10)
        pop dx 
    fin4chiffres:
        mov cx,ax 
        pop bx     ; restaurer bx et ax
        pop ax
        call View16 
         
    ret  
    
AfficherNo16 ENDP 

View16 proc
    push ax
    push bx
    push cx
    push dx 
    
    finSauvgarde16:
                mov ax,dx
                mov dx,0
                div cx
                call ViewNo
                mov bx,dx
                mov dx,0
                mov ax,cx
                mov cx,16
                div cx
                mov dx,bx
                mov cx,ax
                cmp ax,0  
                jne finSauvgarde16 
    pop dx
    pop cx
    pop bx 
    pop ax

    ret
    
View16 ENDP  

view32_16 proc
    
    push ax
    push bx
    push cx
    push dx
    
    mov bx,10h ;Constante 10 stockee dans BX
    push bx ;bx est constant donc on peut l'utiliser comme marqueur pour sortir de la boucle            
    
    diviser16: 
        mov cx,ax ;Stocke temporairement le partie bassse dans CX
        mov ax,dx ;Stocke temporairement le partie bassse dans AX
        
        xor dx,dx ;DX=0 pour la division DX:AX / BX
        div bx ; AX est le quotient haut, le reste est utilise dans la prochaine division
        xchg ax,cx ;Deplace le quotient de la partie haute dans CX et la partie basse(quotient) dans AX 
        div bx ; AX est le quotient bas, le reste est dans DX=[0,9]
        push dx ;Sauvegarde le reste 
        mov dx,cx ;Deplacer le quotient de la partie haute dans DX
        or cx,ax ;=0 uniquement si cx=0 et ax=0 (quotient de la partie haute et celui de la partie basse =0)
        jnz diviser16 ;Si !=0 boucler
        pop dx ;Recuperer l'unite
    
    afficher16: 
        mov ax,dx
        call ViewNo 
        pop dx ;Recupere le prochain rang
        cmp dx,bx ;SI dx=10 alors on est arrive a la fin (le bx empiler au debut)
        jb afficher16 
             
    
    pop dx
    pop cx
    pop bx
    pop ax 
    
    ret  
    
view32_16 ENDP  
   
code ENDS

    
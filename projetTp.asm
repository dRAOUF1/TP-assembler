
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
    LEA DX, messageIntro
    call AfficherChaine 
debut:
    ; Affichage du message de la base d'operation
    LEA DX, baseMsg
    call AfficherChaine 
    
    ; Lecture de la base
    call LireChar ; lecture d'un seul charactere
    mov ah,0
    push ax
     
    mov dx, offset saut
    call AfficherChaine 
     
    ; Traitement en fonction de la base choisie

    pop si  
    cmp si, "1"
    je Input10
    CMP si, '2'
    JE Input2
    CMP si, '3'
    JE Input16
    JMP ErreurInput ; jump to error if the input is invalid
    
    Input10:
        mov si,10
        jmp Input
    Input2:
        mov si,2
        jmp Input
    Input16:
        mov si,10h

    

Input: 
    
    ; Affichage du premier message  
  
    mov dx,offset Num1
    call AfficherChaine
    
    
    mov cx,0;   Obligatoir avant chaque lecture
    call InputNo 
    
    push dx;    empiler le nombre lu (a)
    
    mov dx,offset Num2
    call AfficherChaine   
    
    mov cx,0;   avant chaque lecture
    call InputNo 

    push dx;    empiler le nombre lu (b) 
      


Operation:    

    mov dx,offset Menu
    call AfficherChaine 
     
    call LireChar 
        
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

    
    mov dx, offset retour
    call AfficherChaine  

    mov bp,sp    
    mov bx,[bp]; bx=b
    mov dx,[bp+2]; dx=a
    
    add dx,bx
    jo ErreurOverFlow;  En cas d'overflow
    push dx;    Sauvegarder le resultat 
    

    mov dx ,0   
    mov ax,[bp+2] ;    Afficher a
    call view32
    
    mov dx, offset plus;    Afficher +
    call AfficherChaine 
    
    mov dx,0
    mov ax,[bp] 
    call view32;    Afficher b 
        
    mov dx, offset egale;   Afficher =
    call AfficherChaine  
    
    pop ax ;    Recuperer a+b  
    mov dx,0

    call view32; Afficher le resultat
    

    jmp exit 
    
Soustraction:

    mov dx, offset retour
    call AfficherChaine   

    mov bp,sp    
    mov bx,[bp]; bx=b
    mov dx,[bp+2]; dx=a 
      
    
    SUB dx,bx
    jo ErreurOverFlow;  En cas d'overflow
    push dx;    Sauvegarder le resultat 
    


    mov ax,[bp+2] ;    Afficher a  
    mov dx,0
    call view32
    
    mov dx, offset moins;    Afficher -
    call AfficherChaine 
    
    mov ax,[bp]
    mov dx,0 
    call view32;    Afficher b 
        

    mov dx, offset egale;   Afficher =
    call AfficherChaine  
    

    
    pop ax ;    Recuperer a-b
    mov dx,0
    call view32; Afficher le resultat
    jmp exit
    


Multiplication:
    
    mov dx, offset retour
    call AfficherChaine   

    mov bp,sp    
    mov bx,[bp]; bx=b
    mov ax,[bp+2]; dx=a 
      
    
    mul bx
   
    push ax;    Sauvegarder le resultat  
    push dx 
    
    mov dx,0
    mov ax,[bp+2] ;    Afficher a
    call view32
    
    mov dx, offset fois;    Afficher x
    call AfficherChaine 
    
    mov dx,0
    mov ax,[bp] 
    call view32;    Afficher b 
        
    mov dx, offset egale;   Afficher =
    call AfficherChaine  
    
    pop dx ;    Recuperer la 1ere partie de axb       
    pop ax ;    Recuperer la 2eme partie de axb 


    call view32; Afficher le resultat 
    jmp exit


Division:

    mov dx, offset retour
    call AfficherChaine   

    mov bp,sp  
    xor dx,dx  
    mov bx,[bp]; bx=b 
    
    cmp bx,0
    je ErreurDiv0 
    mov ax,[bp+2]; dx=a 
    
    div bx
    push ax 
      
    
    mov dx,0
    mov ax,[bp+2] ;    Afficher a
    call view32
    
    mov dx, offset par;    Afficher /
    call AfficherChaine 
    
    mov dx,0
    mov ax,[bp] 
    call view32;    Afficher b 
        
    mov dx, offset egale;   Afficher =
    call AfficherChaine  
    
    pop ax ;    Recuperer  a/b 
    mov dx,0      
    call view32 
   
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
    
AfficherChaine proc
    push ax
    mov ah,9
    int 21h
    pop ax
    ret
AfficherChaine endp

LireChar proc
    mov ah,1
    int 21h
    ret
LireChar endp 
        
InputNo proc
    mov ah,01
    int 21h
    
    mov dx,0
    mov bx,1;       initialiser bx avant de former le nombre 
    cmp al,0dh;     enter key
    je FormNo 
     
    ;Dans toute les bases 0<=al<='F'
    cmp al,30h; 30h code asci 0
    jb ErreurInput
    cmp al,46h; 46h code asci de F
    ja ErreurInput
     
    ;Trouver la bonne base
    cmp si,10
    je Decimale
    cmp si,2
    je Bin 
    
    ;HEXA

    cmp al,39h
    jbe Decimale
    cmp al,41h; 39h code asci 9
    jb ErreurInput
 
    
    sub ax,37h
    jmp FinConvertion
    
    ;DEC
    ;                 0<=al<=9 
    Decimale:
        cmp al,30h; 30h code asci 0
        jb ErreurInput
        cmp al,39h; 39h code asci 9
        ja ErreurInput  
        sub ax,30h;     convertire en chiffre
        jmp FinConvertion 
    
    ;BIN 
    Bin:
        cmp al,30h
        jb ErreurInput
        cmp al, 31h
        ja ErreurInput
    
        sub ax,30h;     convertire en chiffre
    
    FinConvertion:
        mov ah,0;       pour push la valeur lu correctement
        push ax
        inc cx;         le nombre de chiffres du nombre lu 
        
        jmp InputNo
         
    FormNo:
        pop ax       
        
        push dx;    sauvegarder dx (modifier par mul)
        mul bx;     mettre la chiffre au bon rang
        jo ErreurOverFlow
        pop dx;     restaurer dx 
        
        add dx,ax
        jo ErreurOverFlow;  valeur entrer par l'utilisateur superieur a 7FFFh  
        
        mov ax,bx;  enregister bx dans ax pour la multiplication apres
        mov bx,si
        push dx
        mul bx;     pour avancer au rang suivant (ax=bx*10)
        pop dx
        mov bx,ax;  recuperer le nouveau bx 
        
        dec cx;     decrementer le compteur de chiffre du nombre
        cmp cx,0;   si le nombre de chiffre restant est superieur a 0 on refait l'operation
        ja FormNo 
    
    ret
    
InputNo ENDP
    
      
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


view32 proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx,si ;Constante 10 stockee dans BX
    push bx ;bx est constant donc on peut l'utiliser comme marqueur pour sortir de la boucle            
    
    ;Verfier si le nombre est negatif
    clc
    rol ax,1
    ror ax,1
    jnc diviser
    neg ax 
    
    push dx
    push ax
    mov ah,2
    mov dx,"-"
    int 21h
    pop ax
    pop dx
    
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
    
view32 ENDP  

code ENDS

    

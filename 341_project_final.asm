; =========================================================
; ENHANCED SCHOOL MANAGEMENT SYSTEM
; 8086 Assembly (Emu8086)
; Fixed logic, proper procedures, input validation
; =========================================================

.MODEL SMALL
.STACK 100h

; ===================== DATA =====================
.DATA

menu DB 0Dh,0Ah,"===== SCHOOL MANAGEMENT SYSTEM =====",0Dh,0Ah
     DB "1. Mark Student Attendance",0Dh,0Ah
     DB "2. View Attendance",0Dh,0Ah
     DB "3. Enter Student Grade",0Dh,0Ah
     DB "4. View Student Grade",0Dh,0Ah
     DB "5. Add Book to Library",0Dh,0Ah
     DB "6. View Book Inventory",0Dh,0Ah
     DB "7. Set Teacher Salary",0Dh,0Ah
     DB "8. View Teacher Salary",0Dh,0Ah
     DB "9. Add School Expense",0Dh,0Ah
     DB "0. Exit",0Dh,0Ah
     DB "Choose Option: $"

msgID       DB 0Dh,0Ah,"Enter ID (01-99): $"
msgBookID   DB 0Dh,0Ah,"Enter Book ID (01-10): $"
msgGrade    DB 0Dh,0Ah,"Enter Grade (0-100): $"
msgQty      DB 0Dh,0Ah,"Enter Quantity: $"
msgSalary   DB 0Dh,0Ah,"Enter Salary (4 digits, e.g., 5000): $"
msgExpense  DB 0Dh,0Ah,"Enter Expense Amount: $"
msgDone     DB 0Dh,0Ah,"Operation Successful!",0Dh,0Ah,"$"
msgExit     DB 0Dh,0Ah,"Program Terminated.",0Dh,0Ah,"$"
msgPresent  DB 0Dh,0Ah,"Status: Present",0Dh,0Ah,"$"
msgAbsent   DB 0Dh,0Ah,"Status: Absent",0Dh,0Ah,"$"
msgNoData   DB 0Dh,0Ah,"No data found!",0Dh,0Ah,"$"
msgInvalid  DB 0Dh,0Ah,"Invalid ID!",0Dh,0Ah,"$"
msgGradeIs  DB 0Dh,0Ah,"Grade: $"
msgQtyIs    DB 0Dh,0Ah,"Quantity: $"
msgSalIs    DB 0Dh,0Ah,"Salary: $"
msgExpAdded DB 0Dh,0Ah,"Expense added! New Total: $"

newline DB 0Dh,0Ah,"$"

; Arrays
ATTENDANCE  DB 100 DUP(0)       ; 0=Absent, 1=Present
GRADES      DB 100 DUP(0)       ; Store grades 0-100

BOOK_ID     DB 10 DUP(0)        ; Book IDs
BOOK_QTY    DB 10 DUP(0)        ; Book quantities
BOOK_CNT    DB 0                ; Number of books

TEACHER_SALARY DW 100 DUP(0)   ; Teacher salaries (0-99)
EXPENSE        DW 50 DUP(0)    ; School expenses
EXP_CNT        DB 0             ; Expense count
TOTAL_EXPENSE  DW 0             ; Running total of expenses

; ===================== CODE =====================
.CODE

; ---------- PRINT MACRO ----------
PRINT MACRO msg
    push ax
    push dx
    lea dx, msg
    mov ah, 09h
    int 21h
    pop dx
    pop ax
ENDM

; ---------- INPUT 2 DIGIT NUMBER (00-99) ----------
INPUT_2DIGIT PROC
    push bx
    push cx
    push dx
    
    mov ah, 01h
    int 21h
    sub al, '0'
    
    cmp al, 9
    ja INPUT_ERR
    
    mov bl, al
    mov al, 10
    mul bl
    mov cx, ax
    
    mov ah, 01h
    int 21h
    sub al, '0'
    
    cmp al, 9
    ja INPUT_ERR
    
    mov ah, 0
    add ax, cx
    
    pop dx
    pop cx
    pop bx
    ret

INPUT_ERR:
    mov ax, 0FFFFh
    pop dx
    pop cx
    pop bx
    ret
INPUT_2DIGIT ENDP

; ---------- INPUT 4 DIGIT NUMBER (0-9999) ----------
INPUT_4DIGIT PROC
    push bx
    push cx
    push dx
    
    mov ax, 0
    mov cx, 4

INPUT_4_LOOP:
    mov bx, 10
    mul bx
    mov dx, ax
    
    mov ah, 01h
    int 21h
    sub al, '0'
    
    cmp al, 9
    ja INPUT_4_ERR
    
    mov ah, 0
    add ax, dx
    
    loop INPUT_4_LOOP
    
    pop dx
    pop cx
    pop bx
    ret

INPUT_4_ERR:
    mov ax, 0FFFFh
    pop dx
    pop cx
    pop bx
    ret
INPUT_4DIGIT ENDP

; ---------- PRINT NUMBER (AX) ----------
PRINT_NUM PROC
    push ax
    push bx
    push cx
    push dx
    
    cmp ax, 0
    jne PRINT_NUM_START
    
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp PRINT_NUM_END
    
PRINT_NUM_START:
    mov cx, 0
    mov bx, 10
    
DIVIDE_LOOP:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne DIVIDE_LOOP
    
PRINT_LOOP:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop PRINT_LOOP
    
PRINT_NUM_END:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PRINT_NUM ENDP

; ===================== MAIN =====================
MAIN PROC
    mov ax, @data
    mov ds, ax

MAIN_MENU:
    PRINT menu
    mov ah, 01h
    int 21h
    
    cmp al, '0'
    je EXIT_PROG
    cmp al, '1'
    je MARK_ATT
    cmp al, '2'
    je VIEW_ATT
    cmp al, '3'
    je ENTER_GRADE
    cmp al, '4'
    je VIEW_GRADE
    cmp al, '5'
    je ADD_BOOK
    cmp al, '6'
    je VIEW_BOOKS
    cmp al, '7'
    je SET_SALARY
    cmp al, '8'
    je VIEW_SALARY
    cmp al, '9'
    je ADD_EXPENSE

    jmp MAIN_MENU

; ===================== MARK ATTENDANCE =====================
MARK_ATT:
    PRINT msgID
    call INPUT_2DIGIT
    
    cmp ax, 99
    ja ATT_INVALID
    
    mov si, ax
    mov ATTENDANCE[si], 1
    
    PRINT msgDone
    jmp MAIN_MENU

ATT_INVALID:
    PRINT msgInvalid
    jmp MAIN_MENU

; ===================== VIEW ATTENDANCE =====================
VIEW_ATT:
    PRINT msgID
    call INPUT_2DIGIT
    
    cmp ax, 99
    ja ATT_INVALID
    
    mov si, ax
    mov al, ATTENDANCE[si]
    
    cmp al, 1
    je ATT_PRESENT
    
    PRINT msgAbsent
    jmp MAIN_MENU

ATT_PRESENT:
    PRINT msgPresent
    jmp MAIN_MENU

; ===================== ENTER GRADE =====================
ENTER_GRADE:
    PRINT msgID
    call INPUT_2DIGIT
    
    cmp ax, 99
    ja GRADE_INVALID
    
    mov si, ax
    
    PRINT msgGrade
    call INPUT_2DIGIT
    
    cmp ax, 100
    ja GRADE_INVALID
    
    mov GRADES[si], al
    
    PRINT msgDone
    jmp MAIN_MENU

GRADE_INVALID:
    PRINT msgInvalid
    jmp MAIN_MENU

; ===================== VIEW GRADE =====================
VIEW_GRADE:
    PRINT msgID
    call INPUT_2DIGIT
    
    cmp ax, 99
    ja GRADE_INVALID
    
    mov si, ax
    mov al, GRADES[si]
    
    cmp al, 0
    je NO_GRADE
    
    PRINT msgGradeIs
    mov ah, 0
    call PRINT_NUM
    PRINT newline
    
    jmp MAIN_MENU

NO_GRADE:
    PRINT msgNoData
    jmp MAIN_MENU

; ===================== ADD BOOK =====================
ADD_BOOK:
    mov al, BOOK_CNT
    cmp al, 10
    jae BOOK_FULL
    
    PRINT msgBookID
    call INPUT_2DIGIT
    
    cmp ax, 10
    ja BOOK_INVALID
    
    mov bl, al
    
    PRINT msgQty
    call INPUT_2DIGIT
    
    mov bh, al
    
    mov al, BOOK_CNT
    mov ah, 0
    mov si, ax
    
    mov BOOK_ID[si], bl
    mov BOOK_QTY[si], bh
    inc BOOK_CNT
    
    PRINT msgDone
    jmp MAIN_MENU

BOOK_FULL:
BOOK_INVALID:
    PRINT msgInvalid
    jmp MAIN_MENU

; ===================== VIEW BOOKS =====================
VIEW_BOOKS:
    mov al, BOOK_CNT
    cmp al, 0
    je NO_BOOKS
    
    mov ah, 0
    mov cx, ax
    mov si, 0

VIEW_LOOP:
    PRINT newline
    mov dl, 'I'
    mov ah, 02h
    int 21h
    mov dl, 'D'
    int 21h
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    
    mov al, BOOK_ID[si]
    mov ah, 0
    call PRINT_NUM
    
    PRINT msgQtyIs
    mov al, BOOK_QTY[si]
    mov ah, 0
    call PRINT_NUM
    PRINT newline
    
    inc si
    loop VIEW_LOOP
    
    jmp MAIN_MENU

NO_BOOKS:
    PRINT msgNoData
    jmp MAIN_MENU

; ===================== SET SALARY =====================
SET_SALARY:
    PRINT msgID
    call INPUT_2DIGIT
    
    cmp ax, 99
    ja SAL_INVALID
    
    mov bx, ax
    shl bx, 1
    mov si, bx
    
    PRINT msgSalary
    call INPUT_4DIGIT
    
    cmp ax, 0FFFFh
    je SAL_INVALID
    
    mov TEACHER_SALARY[si], ax
    
    PRINT msgDone
    jmp MAIN_MENU

SAL_INVALID:
    PRINT msgInvalid
    jmp MAIN_MENU

; ===================== VIEW SALARY =====================
VIEW_SALARY:
    PRINT msgID
    call INPUT_2DIGIT
    
    cmp ax, 99
    ja SAL_INVALID
    
    mov bx, ax
    shl bx, 1
    mov si, bx
    
    mov ax, TEACHER_SALARY[si]
    
    cmp ax, 0
    je NO_SAL
    
    PRINT msgSalIs
    call PRINT_NUM
    PRINT newline
    
    jmp MAIN_MENU

NO_SAL:
    PRINT msgNoData
    jmp MAIN_MENU

; ===================== ADD EXPENSE =====================
ADD_EXPENSE:
    mov al, EXP_CNT
    cmp al, 50
    jae EXP_FULL
    
    PRINT msgExpense
    call INPUT_4DIGIT
    
    cmp ax, 0FFFFh
    je EXP_INVALID
    
    mov bl, EXP_CNT
    mov bh, 0
    shl bx, 1
    mov si, bx
    
    mov EXPENSE[si], ax
    inc EXP_CNT
    
    ; Update total expense
    add TOTAL_EXPENSE, ax
    
    PRINT msgExpAdded
    mov ax, TOTAL_EXPENSE
    call PRINT_NUM
    PRINT newline
    
    jmp MAIN_MENU

EXP_FULL:
EXP_INVALID:
    PRINT msgInvalid
    jmp MAIN_MENU

; ===================== EXIT =====================
EXIT_PROG:
    PRINT msgExit
    mov ah, 4Ch
    int 21h

MAIN ENDP
END MAIN
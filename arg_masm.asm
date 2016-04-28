; Derleme (Assemble) ve Link icin
;
;ml /coff /c /Fl arg_masm.asm
;link /subsystem:console arg_masm.obj
;
;.586                    ; islemci tipi
.model flat, stdcall    ; bellek modeli ve cagri tipi

include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

BUFFER_SIZE    equ    32768 ; Dosya giris/cikis icin tampon boyu
tab    equ    9             ; Tab karakter kodu

FILE_ATTRIBUTE_NORMAL   equ 80h ; normal dosya ozellikleri

OPEN_EXISTING   equ 3           ; var olan dosya
GENERIC_READ    equ 80000000h   ; okuma modu

CREATE_ALWAYS   equ 2           ; yeni yaratilacak dosya
GENERIC_WRITE   equ 40000000h   ; yazma modu

INVALID_HANDLE_VALUE    equ -1  ; dosya yaratilamadi, donus degeri

STD_OUTPUT_HANDLE   equ -11     ; standart cikis tutmaci

.data               ; boyutu bilinen veri tanimlamalari
CmdLinePtr dd  0

SrcFileNamePtr dd 0 ; kaynak dosya adina gosterici
DstFileNamePtr dd 0 ; hedef dosya adina gosterici

SrcFileHandle dd 0  ; kaynak dosya tutmaci
DstFileHandle dd 0  ; hedef dosya tutmaci

BytesRead    dd 0   ; okunan byte sayisi, donus degeri
BytesWritten dd 0   ; yazilan byte sayisi

BadSourceMsg  db "Kaynak dosya acilamadi",13,10
BadSourceMsgLen equ $ - BadSourceMsg

BadDestMsg    db "Hedef dosya acilamadi",13,10
BadDestMsgLen equ $ - BadDestMsg

.data?              ; boyutu bilinmeyen veri tanimlamalari
TempBuffer  db BUFFER_SIZE dup(?)
CmdLineTmp  db 1024 dup(?)

public  start
.code               ; kod kismi
start:

INVOKE  GetCommandLineA     ; M[CmdLinePtr] <- Komut satirinin tumu 
mov     [CmdLinePtr], eax

mov     esi, [CmdLinePtr]   ; islemler sirasinda CmdLineTmp ile calis
mov     edi, offset CmdLineTmp

call    ScanBlanks              ; bosluklari atla
call    ScanArg                 ; program adini (argv[0]) atla
call    ScanBlanks              ; bosluklari atla
mov     [SrcFileNamePtr], edi   ; M[SrcFileNamePtr] <- giris dosya adi 
call    ScanArg                 ; giris dosya adini atla
call    ScanBlanks              ; bosluklari atla
mov     [DstFileNamePtr], edi   ; M[DstFileNamePtr] <- cikis dosya adi
call    ScanArg                 ; cikis dosya adini atla

INVOKE  CreateFileA, [SrcFileNamePtr], GENERIC_READ, 0, 0,
                     OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
cmp     eax, INVALID_HANDLE_VALUE
je      BadSrc
mov     [SrcFileHandle], eax    ; M[SrcFileHandle] <- giris dosya tutmaci

INVOKE  CreateFileA, [DstFileNamePtr], GENERIC_WRITE, 0, 0,
                     CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
cmp     eax, INVALID_HANDLE_VALUE
je      BadDst
mov     [DstFileHandle], eax    ; M[DstFileHandle] <- cikis dosya tutmaci

CopyLoop:
; giris dosyasindan oku
INVOKE  ReadFile, [SrcFileHandle], offset TempBuffer,
                  BUFFER_SIZE, offset BytesRead, 0
cmp     [BytesRead], 0          ; dosya sonu ise
je      EndCopy                 ; kopyalamayi bitir
; cikis dosyasina yaz
INVOKE  WriteFile, [DstFileHandle], offset TempBuffer,
                   [BytesRead], offset BytesWritten, 0
jmp     CopyLoop                ; dosyanin tumu islenene kadar tekrarla

EndCopy:

; giris dosyasini kapat
INVOKE  CloseHandle, [SrcFileHandle]

; cikis dosyasini kapat
INVOKE  CloseHandle, [DstFileHandle]

; isletim sistemine geri don
INVOKE  ExitProcess, 0

BadSrc:
mov     esi, offset BadSourceMsg    ; giris dosyasi acilamadi iletisi
mov     ecx, BadSourceMsgLen
jmp     ErrorExit                   ; standart hataya yaz 

BadDst:
mov     esi, offset BadDestMsg      ; cikis dosyasi acilamadi iletisi
mov     ecx, BadDestMsgLen

ErrorExit:
INVOKE  GetStdHandle, STD_OUTPUT_HANDLE ; tutmaci al
; stadart hataya yaz
INVOKE  WriteFile, eax, esi, ecx, offset BytesWritten, 0
; isletim sistemine geri don
INVOKE  ExitProcess, 0

ScanBlanks_1:               ; bosluklari atla
inc     esi
ScanBlanks:
mov     al, [esi]
cmp     al, ' '
je      ScanBlanks_1
cmp     al, tab
je      ScanBlanks_1
ret                         ; bosluk olmayan ilk karakter pozisyonu ESI de

ScanArg:                ; bosluk olmayanlari (argumanlari) atla
mov     al, [esi]
cmp     al, 0
je      ExitScanArg
cmp     al, '"'
je      ScanQuoted
ScanUnquoted:           ; bosluk karakteri icermeyen argumanlari isle
mov     [edi], al
inc     esi
inc     edi
mov     al, [esi]
cmp     al, 0
je      ExitScanArg
cmp     al, ' '
je      ExitScanArg
cmp     al, tab
je      ExitScanArg
cmp     al, '"'
je      ExitScanArg
jmp     ScanUnquoted
ScanQuoted:
inc     esi             ; bosluk karakterli argumanlardaki tirnaklari isle
mov     al, [esi]
cmp     al, 0
je      ExitScanArg
cmp     al, '"'
je      ExitQuoted
ScanQuoted_1:
mov     [edi], al
inc     esi
inc     edi
mov     al, [esi]
cmp     al, 0
je      ExitScanArg
cmp     al, '"'
je      ExitQuoted
jmp     ScanQuoted_1
ExitQuoted:
inc     esi             ; tirnaklari da atla
ExitScanArg:
mov     byte ptr [edi], 0    ; karakter dizisi sonuna 0 koy
inc     edi
ret                     ; argumandan sonraki ilk karakter ESI de

end start
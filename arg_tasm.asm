; Derleme (Assemble) ve Link icin
;
;tasm32 /ml /zi arg_tasm
;tlink32 /Tpe /v arg_tasm,,, import32.lib
;
.586                ; islemci tipi
.model flat         ; bellek modeli

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

extrn   GetCommandLineA:near
extrn   CreateFileA:near
extrn   ReadFile:near
extrn   WriteFile:near
extrn   GetStdHandle:near
extrn   CloseHandle:near
extrn   ExitProcess:near

public  _start
.code               ; kod kismi
_start:

call    GetCommandLineA         ; M[CmdLinePtr] <- Komut satirinin tumu 
mov     [CmdLinePtr], eax

mov     esi, [CmdLinePtr]       ; islemler sirasinda CmdLineTmp ile calis
mov     edi, offset CmdLineTmp

call    ScanBlanks              ; bosluklari atla
call    ScanArg                 ; program adini (argv[0]) atla
call    ScanBlanks              ; bosluklari atla
mov     [SrcFileNamePtr], edi   ; M[SrcFileNamePtr] <- giris dosya adi 
call    ScanArg                 ; giris dosya adini atla
call    ScanBlanks              ; bosluklari atla
mov     [DstFileNamePtr], edi   ; M[DstFileNamePtr] <- cikis dosya adi
call    ScanArg                 ; cikis dosya adini atla

push    large 0    ; giris dosyasini ac
push    large FILE_ATTRIBUTE_NORMAL
push    large OPEN_EXISTING
push    large 0    ; guvenlik oznitelikleri
push    large 0    ; paylasim modu
push    large GENERIC_READ
push    [SrcFileNamePtr]
call    CreateFileA
cmp     eax, INVALID_HANDLE_VALUE
je      BadSrc
mov     [SrcFileHandle], eax        ; M[SrcFileHandle] <- giris dosya tutmaci

push    large 0    ; cikis dosyasini ac
push    large FILE_ATTRIBUTE_NORMAL
push    large CREATE_ALWAYS
push    large 0    ; guvenlik oznitelikleri
push    large 0    ; paylasim modu
push    large GENERIC_WRITE
push    [DstFileNamePtr]
call    CreateFileA
cmp     eax, INVALID_HANDLE_VALUE
je      BadDst
mov     [DstFileHandle], eax        ; M[DstFileHandle] <- cikis dosya tutmaci

CopyLoop:                   ; ReadFile geri donus degerlerini yigina it
push    0                   ; giris dosyasýndan okunacak tampona gosterici
push    offset BytesRead    ; okunan byte sayisi donus degeri
push    BUFFER_SIZE         ; okunabilecek en buyuk blok uzunlugu
push    offset TempBuffer   ; tampon
push    [SrcFileHandle]     ; giris dosyasi tutmaci
call    ReadFile            ; giris dosyasindan oku
cmp     [BytesRead], 0      ; dosya sonu ise
je      EndCopy             ; kopyalamayi bitir

push    0                   ; benzer sekilde WriteFile icin gerekenleri yigina
push    offset BytesWritten ; cikis dosyasina yazilan byte geri donus degeri
push    [BytesRead]         ; okunan tum bytelari yaz
push    offset TempBuffer   ; tampon
push    [DstFileHandle]     ; cikis dosyasi tutmaci
call    WriteFile           ; cikis dosyasina yaz
jmp     CopyLoop            ; giris dosyasinin tumu islenene kadar tekrarla

EndCopy:

push    [SrcFileHandle]     ; giris dosyasini kapat
call    CloseHandle

push    [DstFileHandle]     ; cikis dosyasini kapat
call    CloseHandle

push    large 0             ; isletim sistemine geri don
call    ExitProcess

BadSrc:
mov     esi, offset BadSourceMsg    ; giris dosyasi acilamadi iletisi
mov     ecx, BadSourceMsgLen
jmp     ErrorExit                   ; standart hataya yaz 

BadDst:
mov     esi, offset BadDestMsg      ; cikis dosyasi acilamadi iletisi
mov     ecx, BadDestMsgLen

ErrorExit:
push    large 0                     ; dosyadan okunacak tampona gosterici
push    offset BytesWritten         ; cikis dosyasina yazilan byte donus degeri
push    ecx                         ; byte sayisi
push    esi                         ; tampon
push    large STD_OUTPUT_HANDLE     ; stadart hata tutmaci
call    GetStdHandle                ; tutmaci al
push    eax                         ; yigina koy
call    WriteFile                   ; stadart hataya yaz
push    large 0                     ; isletim sistemine geri don
call    ExitProcess

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

end _start
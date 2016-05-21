global main                   ; make the main function externally visible

is_cpuid_avail:               ; check if we can write to id bit in eflags
  pushfd                      ; save eflags
  pushfd                      ; store flags on stack
  xor dword [esp], 0x00200000 ; invert id bit
  popfd                       ; store eflags back in register
  pushfd                      ; grab flags back out of register
  pop eax                     ; put eflags into eax so we can compare to orig 
  xor eax,[esp]               ; xor to check changes
  popfd                       ; restore the original eflags
  and eax, 0x00200000         ; if the eflags bit is set from xor, its writable
  ret

print_vendor_string:
  push ebp
  mov ebp, esp
  mov eax, 0x0
  cpuid                 ; vendor string: ebw + edx + ecx
                        ; next 4 instructions set up string for write
  push 0x0a00           ; line feed + null terminator 
  push ecx              ; vendor string 3
  push edx              ; vendor string 2
  push ebx              ; vendor string 1
  push 0xE              ; param 1, write(len, string, fd), 3 reg * 4 + 1
  lea eax, [ebp-0x10]   ; push the address of vendor string on our stack
  push eax              ; param 2, address of string on local stack 
  push 1                ; param 3, stdout file descriptor
  mov eax, 0x4          ; syscall for write()
  sub esp, 4            ; 0x14, syscall stack space
  int 0x80              ; make write syscall
  mov esp, ebp          ; destroy local stack
  pop ebp               ; restore previous base
  ret


main:
  mov ebp, esp
  call is_cpuid_avail
  je exit
  call print_vendor_string

exit:
  push 0        ; exit status
  mov eax, 0x1  ; syscall for exit
  sub esp, 4    ; syscall stack space
  int 0x80      ; make syscall

  %include "const.inc"
   section loader vstart=LOADER_BASE_ADDR
   LOADER_STACK_TOP equ LOADER_BASE_ADDR
   jmp loader_start					

    GDT_BASE:  dd    0x00000000 
	        dd    0x00000000

   CODE_DESC:  dd    0x0000FFFF 
	        dd    DESC_CODE_HIGH4

   DATA_STACK_DESC:  dd    0x0000FFFF
		     dd    DESC_DATA_HIGH4

   VIDEO_DESC: dd    0x80000007	      
	       dd    DESC_VIDEO_HIGH4  

   GDT_SIZE   equ   $ - GDT_BASE
   GDT_LIMIT   equ   GDT_SIZE -	1 
   times 60 dq 0					 
   SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0         ; (CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0
   SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0	
   SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0	 


   gdt_ptr  dw  GDT_LIMIT 
	    dd  GDT_BASE
   loadermsg db 'we are in real mode.'

loader_start:

    mov	 sp, LOADER_BASE_ADDR
    mov	 bp, loadermsg          
    mov	 cx, 19	
    mov	 ax, 0x1301		 
    mov	 bx, 0x001f		 
    mov	 dx, 0x1800		 
    int	 0x10                   


   ;-----------------  open A20  ----------------
   in al,0x92
   or al,0000_0010B
   out 0x92,al

   ;-----------------  load GDT  ----------------
   lgdt [gdt_ptr]


   ;-----------------  set cr0   ----------------
   mov eax, cr0
   or eax, 0x00000001
   mov cr0, eax


   jmp  SELECTOR_CODE:p_mode_start	    

[bits 32]
p_mode_start:
   mov ax, SELECTOR_DATA
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov esp,LOADER_STACK_TOP
   mov ax, SELECTOR_VIDEO
   mov gs, ax

   ; -------------------------   load kernel bin to the memory  ----------------------
   mov eax, KERNEL_START_SECTOR    
   mov ebx, KERNEL_BIN_BASE_ADDR    
   mov ecx, 200			     

   call read_kernel_bin

   call setup_page

   sgdt [gdt_ptr] ; record the original address of gdt
   ; move vga spaces to kenel space
   mov ebx, [gdt_ptr + 2]  
   or dword [ebx + 0x18 + 4], 0xc0000000  
   add dword [gdt_ptr + 2], 0xc0000000

   ; move stack spaces to kernel
   add esp, 0xc0000000
   ; save page table directory address to register
   mov eax, PAGE_DIR_TABLE_POS
   mov cr3, eax
   ; enable pg on controler register
   mov eax, cr0
   or eax, 0x80000000
   mov cr0, eax

   lgdt [gdt_ptr] 

   mov byte [gs:160], 'X'
   mov byte [gs:162], 'M'
   mov byte [gs:164], 'O'
   mov byte [gs:166], 'D'
   mov byte [gs:168], 'E'
   jmp SELECTOR_CODE:enter_kernel


;-------------   create page directory table and page table   ---------------
setup_page:
; initialize for page directory table
   mov ecx, 4096 ; 1024 * 4KB
   mov esi, 0
.clear_page_dir:
   mov byte [PAGE_DIR_TABLE_POS + esi], 0
   inc esi
   loop .clear_page_dir

.create_pde:				     
   mov eax, PAGE_DIR_TABLE_POS
   add eax, 0x1000 			     ; add 4096(4KB), this is the position of the first page table, it is next to the page directory table.
   mov ebx, eax				     ; set base address to ebx

;  save the address(as well as attributes) of the first page table to the first(0x0) and 768th(0xc00) position of page directory table.
;  0xc0000000~0xffffffff(1GB) belongs to kernel and 0x0~0xbfffffff(3GB) belongs to user processes.
   or eax, PG_US_U | PG_RW_W | PG_P	     ; set attributes
   mov [PAGE_DIR_TABLE_POS + 0x0], eax       
   mov [PAGE_DIR_TABLE_POS + 0xc00], eax ; addresses above 0xc00 belong to kernel.
					     
   sub eax, 0x1000
   mov [PAGE_DIR_TABLE_POS + 4092], eax	     ; the entry in the last position refers to page directory table itself.

; create 256 page table entries for low 1MB 
   mov ecx, 256				     ; 1MB/4KB every page = 256
   mov esi, 0
   mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:				     
   mov [ebx+esi*4], edx
   add edx, 4096 
   inc esi
   loop .create_pte

   mov eax, PAGE_DIR_TABLE_POS
   add eax, 0x2000 		     ; the second position in page directory table
   or eax, PG_US_U | PG_RW_W | PG_P 
   mov ebx, PAGE_DIR_TABLE_POS
   mov ecx, 254			     
   mov esi, 769
.create_kernel_pde:
   mov [ebx+esi*4], eax
   inc esi
   add eax, 0x1000
   loop .create_kernel_pde
   ret


read_kernel_bin:
      mov esi,eax	 
      mov di,cx		  
      mov dx,0x1f2
      mov al,cl
      out dx,al         

      mov eax,esi	   
      mov dx,0x1f3                       
      out dx,al                          

    
      mov cl,8
      shr eax,cl
      mov dx,0x1f4
      out dx,al

   
      shr eax,cl
      mov dx,0x1f5
      out dx,al

      shr eax,cl
      and al,0x0f	   
      or al,0xe0	   
      mov dx,0x1f6
      out dx,al

      mov dx,0x1f7
      mov al,0x20                        
      out dx,al

  .not_ready:		  
      nop
      in al,dx
      and al,0x88	   
      cmp al,0x08
      jnz .not_ready

      mov ax, di	   
      mov dx, 256	   
      mul dx
      mov cx, ax	   
      mov dx, 0x1f0
  .go_on_read:
      in ax,dx		
      mov [ebx], ax
      add ebx, 2
      loop .go_on_read
      ret

;-----------------   move kernel.bin   -----------
kernel_init:
   xor eax, eax
   xor ebx, ebx	
   xor ecx, ecx		
   xor edx, edx		

   mov dx, [KERNEL_BIN_BASE_ADDR + 42]	 
   mov ebx, [KERNEL_BIN_BASE_ADDR + 28]  
   add ebx, KERNEL_BIN_BASE_ADDR
   mov cx, [KERNEL_BIN_BASE_ADDR + 44]    
.each_segment:
   cmp byte [ebx + 0], PT_NULL		 
   je .PTNULL


   push dword [ebx + 16]		
   mov eax, [ebx + 4]			
   add eax, KERNEL_BIN_BASE_ADDR	  
   push eax				  
   push dword [ebx + 8]			  
   call mem_cpy				  
   add esp,12				  
.PTNULL:
   add ebx, edx				
   loop .each_segment
   ret


mem_cpy:		      
   cld
   push ebp
   mov ebp, esp
   push ecx		  
   mov edi, [ebp + 8]	   ; dst
   mov esi, [ebp + 12]	   ; src
   mov ecx, [ebp + 16]	   ; size
   rep movsb		  

   pop ecx		
   pop ebp
   ret

enter_kernel:    

   mov byte [gs:320], 'k'     
   mov byte [gs:322], 'e'     
   mov byte [gs:324], 'r'     
   mov byte [gs:326], 'n'     
   mov byte [gs:328], 'e'     
   mov byte [gs:330], 'l'     

   call kernel_init
   mov esp, 0xc009f000
   jmp KERNEL_ENTRY_POINT

#include "print.h"
#include "init.h"
#include "debug.h"
#include "memory.h"
int main()
{

    put_char('j');
    put_int(20);
    put_str("\nthis is kernel codes\n");

    init_all();
    //ASSERT(1 == 2);
    //asm volatile("sti"); // 为演示中断处理,在此临时开中断
    void *addr = get_kernel_pages(3);
    put_str("\n get_kernel_page start vaddr is ");
    put_int((uint32_t)addr);
    put_str("\n");
    void *addr2 = get_kernel_pages(2);
    put_str("\n get_kernel_page start vaddr2 is ");
    put_int((uint32_t)addr2);
    put_str("\n");
    while (1)
    {
        /* code */
    }

    return 0;
}
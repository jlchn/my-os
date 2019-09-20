
#include "print.h"
int main()
{

    put_char('j');
    put_int(20);
    put_str("\nthis is kernel codes\n");

    init_all();
    asm volatile("sti"); // 为演示中断处理,在此临时开中断
    while (1)
    {
        /* code */
    }

    return 0;
}
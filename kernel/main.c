
#include "print.h"
#include "init.h"
#include "debug.h"
#include "memory.h"
#include "thread.h"

void k_thread_a(void *arg);

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

    thread_start("k_thread_a", 31, k_thread_a, "K-thread-a-argA ");

    while (1)
    {
        /* code */
    }

    return 0;
}

void k_thread_a(void *arg)
{
    /* 用void*来通用表示参数,被调用的函数知道自己需要什么类型的参数,自己转换再用 */
    char *para = arg;
    while (1)
    {
        put_str(para);
    }
}
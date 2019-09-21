
#include "print.h"
#include "init.h"
#include "debug.h"
#include "memory.h"
#include "thread.h"
#include "console.h"
#include "interrupt.h"
#include "ioqueue.h"
#include "keyboard.h"

void k_thread_a(void *);
void k_thread_b(void *);
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

    thread_start("consumer_a", 31, k_thread_a, "argA-");
    thread_start("consu,er_b", 8, k_thread_b, "argB-");

    intr_enable(); // 打开中断,使时钟中断起作用
    while (1)
    {
        // console_put_str("Main ");
    };

    return 0;
}

void k_thread_a(void *arg)
{
    while (1)
    {
        enum intr_status old_status = intr_disable();
        if (!ioq_empty(&kbd_buf))
        {
            console_put_str(arg);
            char byte = ioq_getchar(&kbd_buf);
            console_put_char(byte);
        }
        intr_set_status(old_status);
    }
}

/* 在线程中运行的函数 */
void k_thread_b(void *arg)
{
    while (1)
    {
        enum intr_status old_status = intr_disable();
        if (!ioq_empty(&kbd_buf))
        {
            console_put_str(arg);
            char byte = ioq_getchar(&kbd_buf);
            console_put_char(byte);
        }
        intr_set_status(old_status);
    }
}
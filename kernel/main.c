
#include "print.h"
int main()
{

    int i = 10;
    while (i-- > 0)
    {
        put_char('j');
        put_char('i');
        put_char('a');
        put_char('n');
        put_char('g');
        put_char('\n');
        put_char('l');
        put_char('i');
        put_char('\n');
        put_str("this is kernel codes\n");
        put_int(90);
        put_char('\n');
        put_int(0x00021a3f);
        put_char('\n');
        put_int(0x12345678);
        put_char('\n');
        put_int(0x00000000);
    }
    while (1)
    {
        /* code */
    }

    return 0;
}
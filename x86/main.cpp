#include <stdio.h>

extern "C" int func(char *a);

int main(void)
{
  char text[]="Wind On The Hill";
  int result;
  
  printf("Input string      > %s\n", text);
  result=func(text);
  printf("Conversion results> %s\n", text);
  
  return 0;
}

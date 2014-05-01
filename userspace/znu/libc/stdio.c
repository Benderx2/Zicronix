// Borrowed from SmallerC.
// (C) Alexei Frounze under 2-clause BSD 
// https://github.com/alexfru/SmallerC/blob/master/license.txt
int vprintf(char* fmt, void* vl)
{
  int* pp = vl;
  int cnt = 0;
  char* p;
  char* phex;
  char s[12]; // up to 11 octal digits in 32-bit numbers
  char* pc;
  int n, sign, msign;
  int minlen = 0, len;

  for (p = fmt; *p != '\0'; p++)
  {
    if (*p != '%' || p[1] == '%')
    {
      putchar(*p);
      p = p + (*p == '%');
      cnt++;
      continue;
    }
    p++;
    minlen = 0;
    msign = 0;
    if (*p == '+') { msign = 1; p++; }
    else if (*p == '-') { msign = -1; p++; }
    if (isdigit(*p))
    {
      while (isdigit(*p))
        minlen = minlen * 10 + *p++ - '0';
      if (msign < 0)
        minlen = -minlen;
      msign = 0;
    }
    if (!msign)
    {
      if (*p == '+') { msign = 1; p++; }
      else if (*p == '-') { msign = -1; p++; }
    }
    phex = "0123456789abcdef";
    switch (*p)
    {
    case 'c':
      while (minlen > 1) { putchar(' '); cnt++; minlen--; }
      putchar(*pp++);
      while (-minlen > 1) { putchar(' '); cnt++; minlen++; }
      cnt++;
      break;
    case 's':
      pc = *pp++;
      len = 0;
      if (pc)
        len = strlen(pc);
      while (minlen > len) { putchar(' '); cnt++; minlen--; }
      if (len)
        while (*pc != '\0')
        {
          putchar(*pc++); 
          cnt++;
        }
      while (-minlen > len) { putchar(' '); cnt++; minlen++; }
      break;
    case 'i':
    case 'd':
      pc = &s[sizeof s - 1];
      *pc = '\0';
      len = 0;
      n = *pp++;
      sign = 1 - 2 * (n < 0);
      do
      {
        *--pc = '0' + (n - n / 10 * 10) * sign;
        n = n / 10;
        len++;
      } while (n);
      if (sign < 0)
      {
        *--pc = '-';
        len++;
      }
      else if (msign > 0)
      {
        *--pc = '+';
        len++;
        msign = 0;
      }
      while (minlen > len) { putchar(' '); cnt++; minlen--; }
      while (*pc != '\0')
      {
        putchar(*pc++); 
        cnt++;
      }
      while (-minlen > len) { putchar(' '); cnt++; minlen++; }
      break;
    case 'u':
      pc = &s[sizeof s - 1];
      *pc = '\0';
      len = 0;
      n = *pp++;
      do
      {
        unsigned nn = n;
        *--pc = '0' + nn % 10;
        n = nn / 10;
        len++;
      } while (n);
      if (msign > 0)
      {
        *--pc = '+';
        len++;
        msign = 0;
      }
      while (minlen > len) { putchar(' '); cnt++; minlen--; }
      while (*pc != '\0')
      {
        putchar(*pc++); 
        cnt++;
      }
      while (-minlen > len) { putchar(' '); cnt++; minlen++; }
      break;
    case 'X':
      phex = "0123456789ABCDEF";
      // fallthrough
    case 'p':
    case 'x':
      pc = &s[sizeof s - 1];
      *pc = '\0';
      len = 0;
      n = *pp++;
      do
      {
        unsigned nn = n;
        *--pc = phex[nn & 0xF];
        n = nn >> 4;
        len++;
      } while (n);
      while (minlen > len) { putchar(' '); cnt++; minlen--; }
      while (*pc != '\0')
      {
        putchar(*pc++); 
        cnt++;
      }
      while (-minlen > len) { putchar(' '); cnt++; minlen++; }
      break;
    case 'o':
      pc = &s[sizeof s - 1];
      *pc = '\0';
      len = 0;
      n = *pp++;
      do
      {
        unsigned nn = n;
        *--pc = '0' + (nn & 7);
        n = nn >> 3;
        len++;
      } while (n);
      while (minlen > len) { putchar(' '); cnt++; minlen--; }
      while (*pc != '\0')
      {
        putchar(*pc++); 
        cnt++;
      }
      while (-minlen > len) { putchar(' '); cnt++; minlen++; }
      break;
    default:
      return -1;
    }
  }

  return cnt;
}
/*
	putchar - Required by SmallerC's printf
*/
int putchar(int c)
{
  if (c == '\n')
    {
		newline();
	}
  printc(c);
}
/*
	printf - Another Awesomeness of vsprintf
*/
int printf(char* fmt, ...)
{
		void** pp = &fmt;
		return vprintf(fmt, pp + 1);
}
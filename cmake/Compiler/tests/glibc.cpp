#include <sys/types.h>

#if defined(__clang__)
#pragma clang diagnostic error "-W#pragma-messages"
#endif

struct X
{
   static int minor()
   {
      return 0;
   }

   static int major()
   {
      return 0;
   }
};

int main()
{
   return X::minor() + X::major();
}

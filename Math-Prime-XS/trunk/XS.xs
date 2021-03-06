#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"



MODULE = Math::Prime::XS                PACKAGE = Math::Prime::XS

void
xs_mod_primes (number, ...)
      long number
    PREINIT:
      long base;
    PROTOTYPE: $;$
    INIT:
      long i, n;
      bool modulo_rest_null;
    PPCODE:
      if (items == 1)
        base = 2;
      else
        base = SvIV (ST(1));
      if (base >= number)
        croak ("Base is greater or equal number");
      for (n = base; n <= number; n++)
        {
          if (n > base && n / 2 == 0)
            continue;
          modulo_rest_null = 0;
          for (i = 2; i <= number; i++)
            {
              if (n % i == 0)
                modulo_rest_null++;
              if (modulo_rest_null > 1)
                break;
            }
          if (modulo_rest_null == 1)
            {
              EXTEND (SP,1);
              PUSHs (sv_2mortal(newSViv(n)));
            }
        }

void
xs_sieve_primes (number, ...)
      long number
    PREINIT:
      long base;
    PROTOTYPE: $;$
    INIT:
      long i, n;
      bool composite[number];
    PPCODE:
      if (items == 1)
        base = 2;
      else
        base = SvIV (ST(1));
      if (base >= number)
        croak ("Base is greater or equal number");
      memset (&composite, 0, number);
      for (n = 2; n <= number;)
        {
          if (n >= base)
            {
              EXTEND (SP,1);
              PUSHs (sv_2mortal(newSViv(n)));
            }
          for (i = n; i <= number; i += n)
            composite[i] = 1;
          while (composite[n] == 1)
            n++;
        }

void
xs_sum_primes (number, ...)
      long number
    PREINIT:
      long base;
    PROTOTYPE: $;$
    INIT:
      long primes[number], psum[number];
      long i, n, pcount, square_root;
      bool is_prime;
    PPCODE:
      if (items == 1)
        base = 2;
      else
        base = SvIV (ST(1));
      if (base >= number)
        croak ("Base is greater or equal number");
      square_root = floor (sqrt(number)) + 1;
      primes[0] = 2;
      for (pcount = 0, n = 2; n <= number; n++)
        {
          is_prime = 1;
          for (i = 0, psum[i] = 0;
               (i < pcount) && is_prime && primes[i] <= square_root;
               psum[++i] = 0
          ) {
              while (psum[i] < n)
                psum[i] += primes[i];
              if (psum[i] == n)
                is_prime = 0;
            }
          if (is_prime)
            {
              primes[++pcount] = n;
              if (n >= base)
                {
                  EXTEND (SP,1);
                  PUSHs (sv_2mortal(newSViv(n)));
                }
            }
        }

void
xs_trial_primes (number, ...)
      long number
    PREINIT:
      long base;
    PROTOTYPE: $;$
    INIT:
      long i, n, square_root;
      bool is_prime;
      HV* primes;
      char* num_key;
      STRLEN len_key;
      SV* num;
      SV* num_val;
    PPCODE:
      if (items == 1)
        base = 2;
      else
        base = SvIV (ST(1));
      if (base >= number)
        croak ("Base is greater or equal number");
      primes = newHV();
      for (n = 2; n <= number; n++)
        {
          is_prime = 1;
          square_root = floor (sqrt(n)) + 1;
          for (i = 2; i <= square_root; i++)
            {
              num = newSViv (i);
              num_key = SvPV (num, len_key);
              if (hv_exists (primes, num_key, len_key))
                {
                  if (n % i == 0)
                    {
                      is_prime = 0;
                      break;
                    }
                }
              num = newSViv (i);
              num_key = SvPV (num, len_key);
              num_val = newSViv (1);
              hv_store (primes, num_key, len_key, num_val, 0);
            }
          if (is_prime && n >= base)
            {
              EXTEND (SP,1);
              PUSHs (sv_2mortal(newSViv(n)));
            }
        }

void
xs_is_prime (number)
      long number
    PROTOTYPE: $
    INIT:
      long primes[number], psum[number];
      long i, n, pcount, square_root;
      bool is_prime;
    PPCODE:
      square_root = floor (sqrt(number)) + 1;
      primes[0] = 2;
      for (pcount = 0, n = 2; n <= number; n++)
        {
          is_prime = 1;
          for (i = 0, psum[i] = 0;
               (i < pcount) && is_prime && primes[i] <= square_root;
               psum[++i] = 0
          ) {
              while (psum[i] < n)
                psum[i] += primes[i];
              if (psum[i] == n)
                is_prime = 0;
            }
          if (is_prime)
            {
              primes[++pcount] = n;
              if (n == number)
                XSRETURN_IV (1);
            }
          else
            {
              if (n == number)
                XSRETURN_IV (0);
            }
        }

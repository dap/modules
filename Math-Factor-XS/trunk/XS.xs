#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

enum { false, true };

MODULE = Math::Factor::XS               PACKAGE = Math::Factor::XS

void
xs_factors (number)
      unsigned long number
    PROTOTYPE: $
    INIT:
      unsigned long i;
    PPCODE:
      AV *factors = newAV ();
      unsigned long square_root = sqrt (number);

      for (i = 2; i <= number; i++)
        {
          if (i > square_root)
            break;
          if (number % i == 0)
            {
              EXTEND (SP, 1);
              PUSHs (sv_2mortal(newSVuv(i)));
              if ((number / i) > i)
                av_push (factors, newSVuv(number / i));
            }
        }
      while (av_len (factors) >= 0)
        {
          EXTEND (SP, 1);
          PUSHs (sv_2mortal(av_pop(factors)));
        }

      SvREFCNT_dec (factors);

void
xs_matches (number, factors_aref, ...)
      unsigned long number
      SV *factors_aref
    PROTOTYPE: $\@
    INIT:
      AV *factors;
      unsigned long *prev_base = NULL;
      unsigned int b, c, p = 0;
      unsigned int top = items - 1;
      bool Skip_multiples = false;
      bool skip = false;
    PPCODE:
      factors = (AV*)SvRV (factors_aref);

      if (SvROK (ST(top)) && SvTYPE (SvRV(ST(top))) == SVt_PVHV)
        {
          const char *opt = "skip_multiples";
          unsigned int len = strlen (opt);
          HV *opts = (HV*)SvRV (ST(top));

          if (hv_exists (opts, opt, len))
            {
              SV **val = hv_fetch (opts, opt, len, 0);
              if (val)
                Skip_multiples = SvTRUE (*val);
            }
        }

      for (b = 0; b <= av_len (factors); b++)
        {
          unsigned long base = SvUV (*av_fetch(factors, b, 0));
          for (c = 0; c <= av_len (factors); c++)
            {
              unsigned long cmp = SvUV (*av_fetch(factors, c, 0));
              if ((cmp >= base) && (base * cmp == number))
                {
                  if (Skip_multiples)
                    {
                      unsigned int i;
                      skip = false;
                      for (i = 0; i < p; i++)
                        if (base % prev_base[i] == 0)
                          skip = true;
                    }
                  if (!skip)
                    {
                      AV *match = newAV ();
                      av_push (match, newSVuv(base));
                      av_push (match, newSVuv(cmp));

                      EXTEND (SP, 1);
                      PUSHs (sv_2mortal(newRV_noinc((SV*)match)));

                      if (Skip_multiples)
                        {
                          if (!prev_base)
                            Newx (prev_base, 1, unsigned long);
                          else
                            Renew (prev_base, p + 1, unsigned long);
                          prev_base[p++] = base;
                        }
                    }
                }
            }
        }

      Safefree (prev_base);

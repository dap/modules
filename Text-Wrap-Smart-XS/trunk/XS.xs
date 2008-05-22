#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

MODULE = Text::Wrap::Smart::XS                PACKAGE = Text::Wrap::Smart::XS

void
xs_exact_wrap (text, wrap_at)
      char *text;
      unsigned int wrap_at;
    PROTOTYPE: $$
    INIT:
      char *str;
      char *str_iter;
      char *text_iter;
      unsigned int i;
      unsigned long c;
      unsigned long average;
      unsigned long length;
      unsigned long offset;
      long length_iter;
    PPCODE:
      length = strlen (text);
      text_iter = text;

      length_iter = length;
      i = 0;
      do
        {
          length_iter -= wrap_at;
          i++;
        }
      while (length_iter > 0);
      average = ceil ((float) length / (float) i);

      for (offset = 0; offset < length; offset += average)
        {
          Newx (str, average + 1, char);

          c = average;
          str_iter = str;
          while (c-- > 0 && *text_iter)
            *str_iter++ = *text_iter++;
          *str_iter = '\0';

          EXTEND (SP, 1);
          PUSHs (sv_2mortal(newSVpv(str, 0)));

          Safefree (str);
        }

void
xs_fuzzy_wrap (text, wrap_at)
      char *text;
      unsigned int wrap_at;
    PROTOTYPE: $$
    INIT:
      char *p;
      char *str;
      char *str_iter;
      char *text_iter;
      unsigned int i;
      unsigned long average;
      unsigned long count;
      unsigned long diff;
      unsigned long length;
      long average_iter;
      long length_iter;
    PPCODE:
      length = strlen (text);
      text_iter = text;

      length_iter = length;
      i = 0;
      do
        {
          length_iter -= wrap_at;
          i++;
        }
      while (length_iter > 0);
      average = ceil ((float) length / (float) i);

      while (*text_iter)
        {
          unsigned int seen_spaces = 0;

          average_iter = average;
          count = 0;
          str_iter = text_iter;

          while (*str_iter)
            {
              if (*str_iter == ' ')
                seen_spaces++;
              p = strchr (str_iter, ' ');
              if (p == NULL)
                diff = 0;
              else
                diff = p - str_iter;
              if (diff > average_iter && seen_spaces > 1)
                break;
              if (average_iter <= 0 && *str_iter == ' ')
                break;
              average_iter--;
              count++;
              str_iter++;
            }
          if (count == 0)
            break;

          Newx (str, count + 1, char);

          i = count;
          str_iter = str;
          while (i--)
            {
              if (i == 0 && *text_iter == ' ')
                break;
              *str_iter++ = *text_iter++;
            }
          *str_iter = '\0';

          EXTEND (SP, 1);
          PUSHs (sv_2mortal(newSVpv(str, 0)));

          Safefree (str);

          if (*text_iter != '\0')
            text_iter++;
        }

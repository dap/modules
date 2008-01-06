#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

int
quick_sort(const long *num1, const long *num2)
{
    if (*num1 <  *num2) return -1;
    if (*num1 == *num2) return  0;
    if (*num1 >  *num2) return  1;
}

void
bubble_sort(long *numbers, int realitems)
{
    long buffer;
    int is_sorted, i;

    do {
        is_sorted = 1;

        for (i = 0; i < (realitems - 1); i++) {
            if ((numbers[i-1] < numbers[i]) && (numbers[i] < numbers[i+1]))
                continue;

            if (numbers[i] > numbers[i+1]) {
                buffer       = numbers[i];
                numbers[i]   = numbers[i+1];
                numbers[i+1] = buffer;

                is_sorted = 0;
            }
        }
    } while (!is_sorted);
}

MODULE = Algorithm::MedianSelect::XS        PACKAGE = Algorithm::MedianSelect::XS

void
xs_median(...)
    PROTOTYPE: @\@
    INIT:
        long buffer, numbers[items > 1 ? items : (av_len((AV*)SvRV(ST(0))) + 1)];
        int i, is_sorted, median, mode, realitems;
        SV* element;
        SV* flags;
        AV* aref;
    PPCODE:
        if (items == 1) {
            if (SvROK(ST(0))) {
                if (SvTYPE(SvRV(ST(0))) == SVt_PVAV) {
                    aref = (AV*)SvRV(ST(0));
                    for (i = 0; i <= av_len(aref); i++) {
                        element = *av_fetch(aref, i, 0);
                        numbers[i] = SvIV(element);
                    }
                    realitems = av_len(aref) + 1;
                }
                else {
                    croak("median: reference isn't a list reference");
                }
            }
            else {
                croak("median: requires either list or reference to list");
            }
        }
        else {
            for (i = 0; i < items; i++) {
                numbers[i] = SvIV(ST(i));
            }
            realitems = items;
        }

        flags = get_sv("Algorithm::MedianSelect::XS::ALGORITHM", FALSE);

        switch (SvIV(flags)) {
            case 1:  bubble_sort(numbers, realitems);
                     break;
            case 2:  qsort(numbers, realitems, sizeof(long), (void *)quick_sort);
                     break;
            default: croak("Internal error: no mode available");
                     break;
        }

        if (realitems % 2 == 0) median =  realitems      / 2;
        else                    median = (realitems - 1) / 2;

        EXTEND(SP,1);
        PUSHs(sv_2mortal(newSViv(numbers[median])));

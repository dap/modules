#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


MODULE = Math::Factor::XS		PACKAGE = Math::Factor::XS		

void
factors(number)
        long number
    PROTOTYPE: $
    INIT:
        long i;
    PPCODE:
        for (i = 2; i <= number; i++) {
	    if (i > (number / 2)) break;
	    if (number % i == 0) {
	        EXTEND(SP,1);
	        PUSHs(sv_2mortal(newSViv(i)));
	    }
	}

void
matches(number, ...)
        long number
    PROTOTYPE: $@
    INIT:
        long base[items], cmp[items], prev_base[items];
        long b, c, i, p = 0;
	bool Skip_multiple, skip = 0;
	SV* skip_multiple;
	AV* match;
    PPCODE:
        skip_multiple = get_sv("Math::Factor::XS::Skip_multiple", FALSE);
	Skip_multiple = skip_multiple != NULL ? SvIV(skip_multiple) : 0;
        for (i = 0; i < items; i++) {
	    base[i] = SvIV(ST(i));
	    cmp[i]  = SvIV(ST(i));
	}
	for (b = 0; b < items; b++) {
	    for (c = 0; c < items; c++) {
		if (cmp[c] >= base[b] && base[b] * cmp[c] == number) {
		    if (Skip_multiple) {
		        skip = 0;
			for (i = 0; i < p; i++) {
			    if (base[b] % prev_base[i] == 0) skip = 1;
			}
	            }
		    if (!skip) {
		        match = (AV*)sv_2mortal((SV*)newAV());
			av_push(match, newSViv(base[b]));
			av_push(match, newSViv(cmp[c]));
			EXTEND(SP,2);
	                PUSHs(sv_2mortal(newRV((SV*)match)));
			if (Skip_multiple) {
			    prev_base[p++] = base[b];
			}
		    }
		}
	    }
	}

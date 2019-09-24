/*

LICENSE FOR BHP SU Suite of Programs

The following is the license that applies to the copy of the software hereby
provided to Licensee. BHP's Software Manager may be contacted at the following
address:

Colorado School of Mines
1500 Illinois Street
Golden, Colorado 80401
Attention: John Stockwell
e-mail: john@dix.mines.edu
Telephone: 303-273-3049

Copyright 2001 BHP Software. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software") to deal
in the Software, without restriction, except as hereinafter provided,
including without limitation the rights to use, copy, modify merge,
publish, and distribute the Software and to permit persons
to whom the Software is furnished to do so, provided that the above
copyright notice and this permission notice appear in all copies of the
Software and that both the above copyright notice and this permission
notice appear in supporting documentation. No charge may be made for
any redistribution of the Software, including modified or merged versions
of the Software. The complete source code must be included
in any distribution. For an executable file, complete source code means the
source code for all modules it contains.

Modified or merged versions of the Software must be provided to the Software
Manager, regardless of whether such modified or merged versions are
distributed to others.

THE SOFTWARE IS PROVIDED 'AS IS" WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGMENT OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE
COPYRIGHT HOLDER INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM OR
ANY SPECIAL INDIRECT OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OF PERFORMANCE OF
THIS SOFTWARE.

The name of the copyright holder shall not be used in advertising or
otherwise to promote the use or other dealings in this Software, without
prior written consent of the copyright holder.

*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "su.h"
#include "segy.h"

/*********************** self documentation ******************************/
char *sdoc[] = {
"                                                                       ",
" BHPWAVELET -  Make Mexican Hat Wavelet                                ",
"                                                                       ",
" bhpwavelet > stdout [optional parameters]                             ",
"                                                                       ",
" Required Parameters: none                                             ",
"                                                                       ",
" Optional parameters:                                                  ",
"                                                                       ",
" verbose=0         Debug print                                         ",
"                                                                       ",
NULL};

/*
" type=mexh         Wavelet type (currently only Mexican Hat)           ",
" np=1024           Number of points in wavelet                         ",
" p1=-8             Lower limit of data for Mexican Hat wavelet         ",
" p2=8              Upper limit of data for Mexican Hat wavelet         ",
*/

int main(int argc, char **argv)
{

  int np, i;
  int verbose;
  int dt=1000;

  float p1, p2;

  double x, inc;
  double *xval;
  double *x2;
  double t1;

  segy wavelet;

  /* Initialize */
  initargs(argc, argv);
  requestdoc(0);
  
  /* debug option */    
  if(!getparint("verbose",&verbose))
    verbose = 0;

  /* number of input points */
  /*if(!getparint("np",&np))*/
    np = 1024;

  /* lower limit */
  /*if(!getparfloat("p1",&p1))*/
    p1 = -8.;

  /* upper limit */
  /*if(!getparfloat("p2",&p2))*/
    p2 = 8.;

  inc = (p2 - p1) / (np - 1);

  if(verbose) {
    fprintf(stderr,"Making Mexican Hat wavelet\n");
    fprintf(stderr,"Number of Points: %d, Lower Limit: %f, Upper Limit: %f, Increment: %0.10f\n",
            np,p1,p2,inc);
  }

  xval = calloc(np,sizeof(double));
  x2 = calloc(np,sizeof(double));

  for(i=0,x=p1; i<np; i++,x+=inc)
    xval[i] = x;

  t1 = 2.0 / (sqrt(3.) * pow(M_PI,0.25));

  for(i=0; i<np; i++)
    x2[i] = xval[i] * xval[i];

  /* put wavelet in SU trace */
  wavelet.ns = np;
  wavelet.dt = dt;
  wavelet.cdp = 1;
  wavelet.fldr = 1;
  wavelet.ep = 1;
  wavelet.ntr = 1;
  for(i=0; i<np; i++)
    wavelet.data[i] = t1 * (1. - x2[i]) * exp(-x2[i] / 2);

  puttr(&wavelet);

  return EXIT_SUCCESS;

}
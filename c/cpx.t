/* complexlib.h */

#define PI_value   3.141592653589793238462643
#define PID2_value 1.570796326794896619231322

/* Prototypes */
COMPLEX Csqrt(COMPLEX);
COMPLEX Clog(COMPLEX);
COMPLEX Cexp(COMPLEX);
COMPLEX Csin(COMPLEX);
COMPLEX Ccos(COMPLEX);
COMPLEX Ctan(COMPLEX);
COMPLEX Casin(COMPLEX);
COMPLEX Cacos(COMPLEX);
COMPLEX Catan(COMPLEX);
COMPLEX Csinh(COMPLEX);
COMPLEX Ccosh(COMPLEX);
COMPLEX Ctanh(COMPLEX);
COMPLEX Casinh(COMPLEX);
COMPLEX Cacosh(COMPLEX);
COMPLEX Catanh(COMPLEX);
COMPLEX Cadd(COMPLEX,COMPLEX);
COMPLEX Csub(COMPLEX,COMPLEX);
COMPLEX Cmult(COMPLEX,COMPLEX);
COMPLEX Cmultd(COMPLEX,double);
COMPLEX Cdiv(COMPLEX,COMPLEX);
COMPLEX Cdivd(COMPLEX,double);
COMPLEX Cpowd(COMPLEX,double);
double  Cabs(COMPLEX);


complexlib.c from http://www.swin.edu.au/astronomy/pbourke/unixsoftware/libraries/complexlib.c
/*
   Cadd(z1,z2) = z1 + z2
*/
COMPLEX Cadd(z1,z2)
COMPLEX z1,z2;
{
    COMPLEX ztmp;

    ztmp.real = z1.real + z2.real;
    ztmp.imag = z1.imag + z2.imag;
    return(ztmp);
}

/*
   Csub(z1,z2) = z1 - z2
*/
COMPLEX Csub(z1,z2)
COMPLEX z1,z2;
{
    COMPLEX ztmp;

    ztmp.real = z1.real - z2.real;
    ztmp.imag = z1.imag - z2.imag;
    return(ztmp);
}

/*
   Cmult(z1,z2) = z1 * z2
*/
COMPLEX Cmult(z1,z2)
COMPLEX z1,z2;
{
    COMPLEX ztmp;

    ztmp.real = z1.real * z2.real - z1.imag * z2.imag;
    ztmp.imag = z1.real * z2.imag + z2.real * z1.imag;
    return(ztmp);
}

/*
   Cmultd(z,d) = z * d
*/
COMPLEX Cmultd(z,d)
COMPLEX z;
double d;
{
    COMPLEX ztmp;

    ztmp.real = z.real * d;
    ztmp.imag = z.imag * d;
    return(ztmp);
}

/*
   Csqrt(z) = u (+-) jv
   where u = sqrt(0.5*(root+x)) and v = sqrt(0.5*(root-x))
   and root is the magnitude of z
   the sign is the same as that of the imaginary part of z
*/
COMPLEX Csqrt(z)
COMPLEX z;
{
    COMPLEX ztmp;
    double root;

    if (z.real == 0.0 && z.imag == 0.0) {
        ztmp.real = 0.0;
        ztmp.imag = 0.0;
    } else if (z.imag == 0.0) {
        ztmp.real = sqrt(z.real);
        ztmp.imag = 0.0;
    } else {
        root = sqrt(z.real*z.real + z.imag*z.imag);
        ztmp.real = sqrt(0.5 * (root + z.real));
        ztmp.imag = sqrt(0.5 * (root - z.real));
        if (z.imag < 0.0)
            ztmp.imag = - ztmp.imag;
    }
    return(ztmp);
}

/*
   Natural logarithm of a complex number
*/
COMPLEX Clog(z)
COMPLEX z;
{
    COMPLEX ztmp;

    if (z.imag == 0.0 && z.real > 0.0) {
        ztmp.real = log(z.real);
        ztmp.imag = 0.0;
    } else if (z.real == 0.0) {
        if (z.imag > 0.0) {
            ztmp.real = log(z.imag);
            ztmp.imag = PID2_value;
        } else {
            ztmp.real = log(-(z.imag));
            ztmp.imag = - PID2_value;
        }
    } else {
        ztmp.real = log(sqrt(z.real*z.real + z.imag*z.imag));
        ztmp.imag = atan2(z.imag,z.real);
    }
    return(ztmp);
}

/*
   Cexp(z) = exp(real) cos(imag) + j( exp(real) sin(imag) )
   where z = real + j imag
*/
COMPLEX Cexp(z)
COMPLEX z;
{
    double r;
    COMPLEX ztmp;

    r = exp(z.real);
    ztmp.real = r * cos(z.imag);
    ztmp.imag = r * sin(z.imag);
    return(ztmp);
}

/*
  Csin(z) = sin(real) cosh(imag) + j cos(real) sinh(imag)
*/
COMPLEX Csin(z)
COMPLEX z;
{
    COMPLEX ztmp;

    if (z.imag == 0.0) {
        ztmp.real = sin(z.real);
        ztmp.imag = 0.0;
    } else {
        ztmp.real = sin(z.real) * cosh(z.imag);
        ztmp.imag = cos(z.real) * sinh(z.imag);
    }
    return(ztmp);
}

/*
   Ccos(z) = cos(real) cosh(imag) - j sin(real) sinh(imag)
*/
COMPLEX Ccos(z)
COMPLEX z;
{
    COMPLEX ztmp;

    if (z.imag == 0.0) {
        ztmp.real = cos(z.real);
        ztmp.imag = 0.0;
    } else {
        ztmp.real =   cos(z.real) * cosh(z.imag);
        ztmp.imag = - sin(z.real) * sinh(z.imag);
    }
    return(ztmp);
}

/*
  Ctan(z) = ( sin(2*real) + jsinh(2*imag) )
            -------------------------------
            ( cos(2*real) + cosh(2*imag) )
*/
COMPLEX Ctan(z)
COMPLEX z;
{
    COMPLEX ztmp;
    double denom,real2,imag2;

    if (z.imag == 0.0) {
        ztmp.real = tan(z.real);
        ztmp.imag = 0.0;
    } else {
        real2 = 2.0 * z.real;
        imag2 = 2.0 * z.imag;
        denom = cos(real2) + cosh(imag2);
        ztmp.real = sin(real2) / denom;
        ztmp.imag = sinh(imag2) / denom;
    }
    return(ztmp);
}

/*
   Casin(z) = k*pi + (-1)^k asin(b)
                   + j (-1)^k log(a + sqrt(a^2 - 1))
   where a = 0.5 sqrt((x+1)^2 + y^2) + 0.5 sqrt((x-1)^2 + y^2)
   and   b = 0.5 sqrt((x+1)^2 + y^2) - 0.5 sqrt((x-1)^2 + y^2)
   and z = x + jy, k an integer
*/
COMPLEX Casin(z)
COMPLEX z;
{
    COMPLEX ztmp;
    double a,b;
    double xm1,xp1,x2,y2;
    double part1,part2;

    if (z.imag == 0.0) {
        ztmp.real = asin(z.real);
        ztmp.imag = 0.0;
    } else {
        x2 = z.real * z.real;
        y2 = z.imag * z.imag;
        xp1 = x2 + 2.0 * z.real + 1.0;
        xm1 = x2 - 2.0 * z.real + 1.0;
        part1 = 0.5 * sqrt(xp1 + y2);
        part2 = 0.5 * sqrt(xm1 + y2);
        a = part1 + part2;
        b = part1 - part2;
        ztmp.real = asin(b);
        ztmp.imag = log(a + sqrt(a * a - 1.0) );
    }
    return(ztmp);
}

/*
   Cacos(z) = 2*k*pi (+-) [ acos(b)
                       - j log(a + sqrt(a^2 - 1))
   where a = 0.5 sqrt((x+1)^2 + y^2) + 0.5 sqrt((x-1)^2 + y^2)
   and   b = 0.5 sqrt((x+1)^2 + y^2) - 0.5 sqrt((x-1)^2 + y^2)
   and   z = x + jy, K an integer.
*/
COMPLEX Cacos(z)
COMPLEX z;
{
    COMPLEX ztmp;
    double a,b;
    double xm1,xp1,x2,y2;
    double part1,part2;

    if (z.imag == 0.0) {
        ztmp.real = acos(z.real);
        ztmp.imag = 0.0;
    } else {
        x2 = z.real * z.real;
        y2 = z.imag * z.imag;
        xp1 = x2 + 2.0 * z.real + 1.0;
        xm1 = x2 - 2.0 * z.real + 1.0;
        part1 = 0.5 * sqrt(xp1 + y2);
        part2 = 0.5 * sqrt(xm1 + y2);
        a = part1 + part2;
        b = part1 - part2;
        ztmp.real = acos(b);
        ztmp.imag = - log( a + sqrt(a*a - 1.0) );
    }
    return(ztmp);
}

/*
   Catan(z) = k*pi + 0.5 * atan(2x/(1-x^2-y^2))
                   + j/4 * log (( x^2+(y+1)^2) / ( x^2+(y-1)^2))
*/
COMPLEX Catan(z)
COMPLEX z;
{
    COMPLEX ztmp;
    double ym1,yp1,x2,y2,denom;

    if (z.imag == 0.0) {
        ztmp.real = atan(z.real);
        ztmp.imag = 0.0;
    } else {
        x2 = z.real * z.real;
        y2 = z.imag * z.imag;
        denom = 1.0 - x2 - y2;
        yp1 = x2 + y2 + 2.0 * z.imag + 1.0;
        ym1 = x2 + y2 - 2.0 * z.imag + 1.0;
        ztmp.real = 0.5 * atan( 2.0 * z.real / denom );
        ztmp.imag = 0.25 * log( yp1 / ym1 );
    }
    return(ztmp);
}

/*
   Csinh(z) = 0.5 ( Cexp(z) - Cexp(-z) )
*/
COMPLEX Csinh(z)
COMPLEX z;
{
    COMPLEX ztmp;
    COMPLEX mz,zt1,zt2;

    mz.real = - z.real;
    mz.imag = - z.imag;
    zt1 = Cexp(z);
    zt2 = Cexp(mz);
    ztmp.real = 0.5 * (zt1.real - zt2.real );
    ztmp.imag = 0.5 * (zt1.imag - zt2.imag );
    return(ztmp);
}

/*
   Ccosh(z) = 0.5 ( Cexp(z) + Cexp(-z) )
*/
COMPLEX Ccosh(z)
COMPLEX z;
{
    COMPLEX ztmp;
    COMPLEX mz,zt1,zt2;

    mz.real = - z.real;
    mz.imag = - z.imag;
    zt1 = Cexp(z);
    zt2 = Cexp(mz);
    ztmp.real = 0.5 * ( zt1.real + zt2.real );
    ztmp.imag = 0.5 * ( zt1.imag + zt2.imag );
    return(ztmp);
}

/*
   Ctanh(z) = ( 1 - Cexp(-2z) ) / ( 1 + Cexp(-2z) )
*/
COMPLEX Ctanh(z)
COMPLEX z;
{
    COMPLEX ztmp;
    COMPLEX zt1,zt2,num,denom;

    if (z.imag == 0.0) {
        ztmp.real = tanh(z.real);
        ztmp.imag = 0.0;
    } else {
        zt1.real = -2.0 * z.real;
        zt1.imag = -2.0 * z.imag;
        zt2 = Cexp(zt1);
        num.real = 1.0 - zt2.real;
        num.imag = - zt2.imag;
        denom.real = 1.0 + zt2.real;
        denom.imag = zt2.imag;
        ztmp = Cdiv(num,denom);
    }
    return(ztmp);
}

/*
   Casinh(z) = Clog( z + Csqrt( z^2 + 1 ))
*/
COMPLEX Casinh(z)
COMPLEX z;
{
    COMPLEX ztmp;
    COMPLEX zt1,zt2;

    zt1.real = z.real * z.real - z.imag * z.imag + 1.0;
    zt1.imag = 2.0 * z.real * z.imag;
    zt2 = Csqrt(zt1);
    zt2.real += z.real;
    zt2.real += z.imag;
    ztmp = Clog(zt2);
    return(ztmp);
}

/*
   Cacosh(z) = Clog ( z + Csqrt(z^2 - 1) )
*/
COMPLEX Cacosh(z)
COMPLEX z;
{
    COMPLEX ztmp;
    COMPLEX zt1,zt2;

    zt1.real = z.real * z.real - z.imag * z.imag - 1.0;
    zt1.imag = 2.0 * z.real * z.imag;
    zt2 = Csqrt(zt1);
    zt2.real += z.real;
    zt2.imag += z.imag;
    ztmp = Clog(zt2);
    return(ztmp);
}

/*
   Catanh(z) = 0.5 * Clog( (1+z) / (1-z) )
*/
COMPLEX Catanh(z)
COMPLEX z;
{
    COMPLEX ztmp;
    COMPLEX zp1,zm1,zt1;

    zp1.real = 1.0 + z.real;
    zp1.imag = z.imag;
    zm1.real = 1.0 - z.real;
    zm1.imag = - (z.imag);
    zt1 = Clog(Cdiv(zp1,zm1));
    ztmp.real = zt1.real * 0.5;
    ztmp.real = zt1.imag * 0.5;
    return(ztmp);
}

/*
   Cdiv(z1,z2) = z1 / z2
*/
COMPLEX Cdiv(z1,z2)
COMPLEX z1,z2;
{
    COMPLEX ztmp;
    double den,r;
    double absr,absi;

    absr = (z2.real >= 0 ? z2.real : -z2.real);
    absi = (z2.imag >= 0 ? z2.imag : -z2.imag);

    if (z1.real == 0.0 && z1.imag == 0.0) {
        ztmp.real = 0.0;
        ztmp.imag = 0.0;
    } else if (z2.real == 0.0 && z2.imag == 0.0) {
        ztmp.real = 0.0;
        ztmp.imag = 0.0;
    } else if (absr >= absi) {
        r = z2.imag / z2.real;
        den = z2.real + r * z2.imag;
        ztmp.real = (z1.real + z1.imag * r) / den;
        ztmp.imag = (z1.imag - z1.real * r) / den;
    } else {
        r = z2.real / z2.imag;
        den = z2.imag + r * z2.real;
        ztmp.real = (z1.real * r + z1.imag) / den;
        ztmp.imag = (z1.imag * r - z1.real) / den;
    }
    return(ztmp);
}

/*
   Cdivd(z1,d) = z / d
*/
COMPLEX Cdivd(z,d)
COMPLEX z;
double d;
{
    COMPLEX ztmp;

    if (d == 0.0) {
        ztmp.real = 0.0;
        ztmp.imag = 0.0;
    } else if (z.real == 0.0 && z.imag == 0.0) {
        ztmp.real = 0.0;
        ztmp.imag = 0.0;
    } else {
        ztmp.real = z.real / d;
        ztmp.imag = z.imag / d;
    }
    return(ztmp);
}

/*
   Cpowd(z,d) = z ^ d
*/
COMPLEX Cpowd(z,d)
COMPLEX z;
double d;
{
   COMPLEX ztmp;
   double phi,r,absr,absi,sqrr,sqri;

   if (z.real > 0.0) {
      phi = atan(z.imag / z.real);
   } else if (z.real < 0.0 && z.imag >= 0.0) {
      phi = atan(z.imag / z.real) + PI_value;
   } else if (z.real < 0.0 && z.imag < 0.0) {
      phi = atan(z.imag / z.real) - PI_value;
   } else if (z.real == 0.0 && z.imag == 0.0) {
      ztmp.real = 0.0;
      ztmp.imag = 0.0;
      return(ztmp);
   } else if (z.real == 0.0 && z.imag > 0.0) {
      phi = PID2_value;
   } else if (z.real == 0.0 && z.imag < 0.0) {
      phi = -PID2_value;
   }

   absr = (z.real >= 0 ? z.real : -z.real);
   absi = (z.imag >= 0 ? z.imag : -z.imag);

   r = Cabs(z);
   r = exp(d * log(r));
   phi = d * phi;

   ztmp.real = r * cos(phi);
   ztmp.imag = r * sin(phi);
   return(ztmp);
}

/*
   Cabs(z) = sqrt( real^2 + imag^2 )
   where z = real + j imag
*/
double Cabs(z)
COMPLEX z;
{
   double absr,absi,sqrr,sqri;

   if ((absr = z.real) < 0)
      absr = -z.real;
   if ((absi = z.imag) < 0)
      absi = -z.imag;

   if (absr == 0.0) {
      return(absi);
   } else if (absi == 0.0) {
      return(absr);
   } else if (absr > absi) {
      sqrr = absr * absr;
      sqri = absi * absi;
      return(absr * sqrt(1 + sqri/sqrr));
   } else {
      sqrr = absr * absr;
      sqri = absi * absi;
      return(absi * sqrt(1 + sqrr/sqri));
   }
}

http://www.swin.edu.au/astronomy/pbourke/unixsoftware/libraries/sigproclib.h
int    FFT(int,int,double *,double *);
int    FFT2D(COMPLEX **, int,int,int);
int    DFT(int,int,double *,double *,double *,double *);
int    Powerof2(int,int *,int *);
void   Correlate(double *,double *,int,double *);
int    GSolve(double **,int,double *);
double AutoCorr(double *,int,int);
double CrossCorr(double *,double *,int,int);

http://www.swin.edu.au/astronomy/pbourke/unixsoftware/libraries/sigproclib.c
/*-------------------------------------------------------------------------
   This computes an in-place complex-to-complex FFT
   x and y are the real and imaginary arrays of 2^m points.
   dir =  1 gives forward transform
   dir = -1 gives reverse transform

     Formula: forward
                  N-1
                  ---
              1   \          - j k 2 pi n / N
      X(n) = ---   >   x(k) e                    = forward transform
              N   /                                n=0..N-1
                  ---
                  k=0

      Formula: reverse
                  N-1
                  ---
                  \          j k 2 pi n / N
      X(n) =       >   x(k) e                    = forward transform
                  /                                n=0..N-1
                  ---
                  k=0
*/
int FFT(int dir,int m,double *x,double *y)
{
   long nn,i,i1,j,k,i2,l,l1,l2;
   double c1,c2,tx,ty,t1,t2,u1,u2,z;

   /* Calculate the number of points */
   nn = 1;
   for (i=0;i<m;i++)
      nn *= 2;

   /* Do the bit reversal */
   i2 = nn >> 1;
   j = 0;
   for (i=0;i<nn-1;i++) {
      if (i < j) {
         tx = x[i];
         ty = y[i];
         x[i] = x[j];
         y[i] = y[j];
         x[j] = tx;
         y[j] = ty;
      }
      k = i2;
      while (k <= j) {
         j -= k;
         k >>= 1;
      }
      j += k;
   }

   /* Compute the FFT */
   c1 = -1.0;
   c2 = 0.0;
   l2 = 1;
   for (l=0;l<m;l++) {
      l1 = l2;
      l2 <<= 1;
      u1 = 1.0;
      u2 = 0.0;
      for (j=0;j<l1;j++) {
         for (i=j;i<nn;i+=l2) {
            i1 = i + l1;
            t1 = u1 * x[i1] - u2 * y[i1];
            t2 = u1 * y[i1] + u2 * x[i1];
            x[i1] = x[i] - t1;
            y[i1] = y[i] - t2;
            x[i] += t1;
            y[i] += t2;
         }
         z =  u1 * c1 - u2 * c2;
         u2 = u1 * c2 + u2 * c1;
         u1 = z;
      }
      c2 = sqrt((1.0 - c1) / 2.0);
      if (dir == 1)
         c2 = -c2;
      c1 = sqrt((1.0 + c1) / 2.0);
   }

   /* Scaling for forward transform */
   if (dir == 1) {
      for (i=0;i<nn;i++) {
         x[i] /= (double)nn;
         y[i] /= (double)nn;
      }
   }

   return(TRUE);
}

/*-------------------------------------------------------------------------
   Perform a 2D FFT inplace given a complex 2D array
   The direction dir, 1 for forward, -1 for reverse
   The size of the array (nx,ny)
   Return false if there are memory problems or
      the dimensions are not powers of 2
*/
int FFT2D(COMPLEX **c,int nx,int ny,int dir)
{
   int i,j;
   int m,twopm;
   double *real,*imag;

   /* Transform the rows */
   real = (double *)malloc(nx * sizeof(double));
   imag = (double *)malloc(nx * sizeof(double));
   if (real == NULL || imag == NULL)
      return(FALSE);
   if (!Powerof2(nx,&m,&twopm) || twopm != nx)
      return(FALSE);
   for (j=0;j<ny;j++) {
      for (i=0;i<nx;i++) {
         real[i] = c[i][j].real;
         imag[i] = c[i][j].imag;
      }
      FFT(dir,m,real,imag);
      for (i=0;i<nx;i++) {
         c[i][j].real = real[i];
         c[i][j].imag = imag[i];
      }
   }
   free(real);
   free(imag);

   /* Transform the columns */
   real = (double *)malloc(ny * sizeof(double));
   imag = (double *)malloc(ny * sizeof(double));
   if (real == NULL || imag == NULL)
      return(FALSE);
   if (!Powerof2(ny,&m,&twopm) || twopm != ny)
      return(FALSE);
   for (i=0;i<nx;i++) {
      for (j=0;j<ny;j++) {
         real[j] = c[i][j].real;
         imag[j] = c[i][j].imag;
      }
      FFT(dir,m,real,imag);
      for (j=0;j<ny;j++) {
         c[i][j].real = real[j];
         c[i][j].imag = imag[j];
      }
   }
   free(real);
   free(imag);

   return(TRUE);
}

/*-------------------------------------------------------------------------
        Direct fourier transform
*/
int DFT(int dir,int m,double *x1,double *y1,double *x2,double *y2)
{
   long i,k;
   double arg;
   double cosarg,sinarg;

   for (i=0;i<m;i++) {
      x2[i] = 0;
      y2[i] = 0;
      arg = - dir * 2.0 * 3.141592654 * (double)i / (double)m;
      for (k=0;k<m;k++) {
         cosarg = cos(k * arg);
         sinarg = sin(k * arg);
         x2[i] += (x1[k] * cosarg - y1[k] * sinarg);
         y2[i] += (x1[k] * sinarg + y1[k] * cosarg);
      }
   }

   /* Copy the data back */
   if (dir == 1) {
      for (i=0;i<m;i++) {
         x1[i] = x2[i] / (double)m;
         y1[i] = y2[i] / (double)m;
      }
   } else {
      for (i=0;i<m;i++) {
         x1[i] = x2[i];
         y1[i] = y2[i];
      }
   }

   return(TRUE);
}

/*-------------------------------------------------------------------------
        Calculate the closest but lower power of two of a number
        twopm = 2**m <= n
        Return TRUE if 2**m == n
*/
int Powerof2(n,m,twopm)
int n;
int *m,*twopm;
{
        if (n <= 1) {
                *m = 0;
                *twopm = 1;
                return(FALSE);
        }

   *m = 1;
   *twopm = 2;
   do {
      (*m)++;
      (*twopm) *= 2;
   } while (2*(*twopm) <= n);

   if (*twopm != n) 
                return(FALSE);
        else
                return(TRUE);
}

/*-------------------------------------------------------------------------
        Calculate the Pearsons cross correlation series for all delays
        Input arrays are s1 and s2
        Number of points in each array is n
        The output correlation sequence at delays of -n/2 to n/2 is sout
        The zero lag correlation coeficient is at index n/2
        The series is assumed to be 0 for indexes below 0 and above n-1
*/
void Correlate(s1,s2,n,sout)
double *s1,*s2;                                 
int n;
double *sout;
{
        int i,j,delay;
        double ms1=0,ms2=0,ss1=0,ss2=0,denom,ss1s2;

        /* Calculate the means */
        for (i=0;i<n;i++) {
                ms1 += s1[i];
                ms2 += s2[i];
        }
        ms1 /= n;
        ms2 /= n;

        /* Calculate the variances */
        for (i=0;i<n;i++) {
                ss1 += (s1[i] - ms1) * (s1[i] - ms1);
                ss2 += (s2[i] - ms2) * (s2[i] - ms2);
        }
        denom = sqrt(ss1 * ss2);

        for (delay=-n/2;delay<n/2;delay++) {
                ss1s2 = 0;
                for (i=0;i<n;i++) {
                        j = i + delay;
                        if (j < 0 || j >= n)
            continue;
                        ss1s2 += (s1[i] - ms1) * (s2[j] - ms2);
                }
                sout[delay+n/2] = ss1s2 / denom;
        }
}

/*-------------------------------------------------------------------------
   Solve a system of n equations in n unknowns using Gaussian Elimination
   Solve an equation in matrix form Ax = b
   The 2D array a is the matrix A with an additional column b.
   This is often written (A:b)

   A0,0    A1,0    A2,0    ....  An-1,0     b0
   A0,1    A1,1    A2,1    ....  An-1,1     b1
   A0,2    A1,2    A2,2    ....  An-1,2     b2
   :       :       :             :          :
   :       :       :             :          :
   A0,n-1  A1,n-1  A2,n-1  ....  An-1,n-1   bn-1

   The result is returned in x, otherwise the function returns FALSE
   if the system of equations is singular.
*/
int GSolve(double **a,int n,double *x)
{
   int i,j,k,maxrow;
   double tmp;
  
   for (i=0;i<n;i++) {

      /* Find the row with the largest first value */
      maxrow = i;
      for (j=i+1;j<n;j++) {
         if (ABS(a[i][j]) > ABS(a[i][maxrow]))
            maxrow = j;
      }

      /* Swap the maxrow and ith row */
      for (k=i;k<n+1;k++) {
         tmp = a[k][i];
         a[k][i] = a[k][maxrow];
         a[k][maxrow] = tmp;
      }

      /* Singular matrix? */
      if (ABS(a[i][i]) < EPS)
         return(FALSE);

      /* Eliminate the ith element of the jth row */
      for (j=i+1;j<n;j++) {
         for (k=n;k>=i;k--) {
            a[k][j] -= a[k][i] * a[i][j] / a[i][i];
         }
      }
   }

   /* Do the back substitution */
   for (j=n-1;j>=0;j--) {
      tmp = 0;
      for (k=j+1;k<n;k++)
         tmp += a[k][j] * x[k];
      x[j] = (a[n][j] - tmp) / a[j][j];
   }

   return(TRUE);
}

/*-------------------------------------------------------------------------
        Compute the circular autocorrelation (the long way without fft)
        Series in array x of length N, calculate autocorrelation at lag delay
        NOT normalised!
*/
double AutoCorr(double *x,int n,int delay)
{
        int i,k;
        double sum=0,mean=0;

        for (i=0;i<n;i++)
                mean += x[i];
        mean /= n;

        for (i=0;i<n;i++) {
                k = (i + delay) % n;
                sum += (x[i] - mean) * (x[k] - mean);
        }

        return(sum);
}

/*-------------------------------------------------------------------------
   Compute the circular crosscorrelation (the long way without fft)
   Series in array x and y of same length N, 
        Calculate crosscorrelation at lag delay
        NOT normalised!
*/
double CrossCorr(double *x,double *y,int n,int delay)
{
   int i,k;
   double sum=0,mean1=0,mean2=0;

   for (i=0;i<n;i++) {
      mean1 += x[i];
                mean2 += y[i];
        }
   mean1 /= n;
        mean2 /= n;

   for (i=0;i<n;i++) {
      k = (i + delay) % n;
      sum += (x[i] - mean1) * (y[k] - mean2);
   }

   return(sum);
}

http://www.swin.edu.au/astronomy/pbourke/unixsoftware/random/randomlib.h

void   RandomInitialise(int,int);
double RandomUniform(void);
double RandomGaussian(double,double);
int    RandomInt(int,int);
double RandomDouble(double,double);

http://www.swin.edu.au/astronomy/pbourke/unixsoftware/random/randomlib.c

#define FALSE 0
#define TRUE 1

/*
   This Random Number Generator is based on the algorithm in a FORTRAN
   version published by George Marsaglia and Arif Zaman, Florida State
   University; ref.: see original comments below.
   At the fhw (Fachhochschule Wiesbaden, W.Germany), Dept. of Computer
   Science, we have written sources in further languages (C, Modula-2
   Turbo-Pascal(3.0, 5.0), Basic and Ada) to get exactly the same test
   results compared with the original FORTRAN version.
   April 1989
   Karl-L. Noell <NOELL@DWIFH1.BITNET>
      and  Helmut  Weber <WEBER@DWIFH1.BITNET>

   This random number generator originally appeared in "Toward a Universal
   Random Number Generator" by George Marsaglia and Arif Zaman.
   Florida State University Report: FSU-SCRI-87-50 (1987)
   It was later modified by F. James and published in "A Review of Pseudo-
   random Number Generators"
   THIS IS THE BEST KNOWN RANDOM NUMBER GENERATOR AVAILABLE.
   (However, a newly discovered technique can yield
   a period of 10^600. But that is still in the development stage.)
   It passes ALL of the tests for random number generators and has a period
   of 2^144, is completely portable (gives bit identical results on all
   machines with at least 24-bit mantissas in the floating point
   representation).
   The algorithm is a combination of a Fibonacci sequence (with lags of 97
   and 33, and operation "subtraction plus one, modulo one") and an
   "arithmetic sequence" (using subtraction).

   Use IJ = 1802 & KL = 9373 to test the random number generator. The
   subroutine RANMAR should be used to generate 20000 random numbers.
   Then display the next six random numbers generated multiplied by 4096*4096
   If the random number generator is working properly, the random numbers
   should be:
           6533892.0  14220222.0  7275067.0
           6172232.0  8354498.0   10633180.0
*/

/* Globals */
double u[97],c,cd,cm;
int i97,j97;
int test = FALSE;

/*
   This is the initialization routine for the random number generator.
   NOTE: The seed variables can have values between:    0 <= IJ <= 31328
                                                        0 <= KL <= 30081
   The random number sequences created by these two seeds are of sufficient
   length to complete an entire calculation with. For example, if sveral
   different groups are working on different parts of the same calculation,
   each group could be assigned its own IJ seed. This would leave each group
   with 30000 choices for the second seed. That is to say, this random
   number generator can create 900 million different subsequences -- with
   each subsequence having a length of approximately 10^30.
*/
void RandomInitialise(int ij,int kl)
{
   double s,t;
   int ii,i,j,k,l,jj,m;

   /*
      Handle the seed range errors
         First random number seed must be between 0 and 31328
         Second seed must have a value between 0 and 30081
   */
   if (ij < 0 || ij > 31328 || kl < 0 || kl > 30081) {
      ij = 1802;
      kl = 9373;
   }

   i = (ij / 177) % 177 + 2;
   j = (ij % 177)       + 2;
   k = (kl / 169) % 178 + 1;
   l = (kl % 169);

   for (ii=0; ii<97; ii++) {
      s = 0.0;
      t = 0.5;
      for (jj=0; jj<24; jj++) {
         m = (((i * j) % 179) * k) % 179;
         i = j;
         j = k;
         k = m;
         l = (53 * l + 1) % 169;
         if (((l * m % 64)) >= 32)
            s += t;
         t *= 0.5;
      }
      u[ii] = s;
   }

   c    = 362436.0 / 16777216.0;
   cd   = 7654321.0 / 16777216.0;
   cm   = 16777213.0 / 16777216.0;
   i97  = 97;
   j97  = 33;
   test = TRUE;
}

/* 
   This is the random number generator proposed by George Marsaglia in
   Florida State University Report: FSU-SCRI-87-50
*/
double RandomUniform(void)
{
   double uni;

   /* Make sure the initialisation routine has been called */
   if (!test) 
      RandomInitialise(1802,9373);

   uni = u[i97-1] - u[j97-1];
   if (uni <= 0.0)
      uni++;
   u[i97-1] = uni;
   i97--;
   if (i97 == 0)
      i97 = 97;
   j97--;
   if (j97 == 0)
      j97 = 97;
   c -= cd;
   if (c < 0.0)
      c += cm;
   uni -= c;
   if (uni < 0.0)
      uni++;

   return(uni);
}

/*
  ALGORITHM 712, COLLECTED ALGORITHMS FROM ACM.
  THIS WORK PUBLISHED IN TRANSACTIONS ON MATHEMATICAL SOFTWARE,
  VOL. 18, NO. 4, DECEMBER, 1992, PP. 434-435.
  The function returns a normally distributed pseudo-random number
  with a given mean and standard devaiation.  Calls are made to a
  function subprogram which must return independent random
  numbers uniform in the interval (0,1).
  The algorithm uses the ratio of uniforms method of A.J. Kinderman
  and J.F. Monahan augmented with quadratic bounding curves.
*/
double RandomGaussian(double mean,double stddev)
{
   double  q,u,v,x,y;

   /*  
      Generate P = (u,v) uniform in rect. enclosing acceptance region 
      Make sure that any random numbers <= 0 are rejected, since
      gaussian() requires uniforms > 0, but RandomUniform() delivers >= 0.
   */
   do {
      u = RandomUniform();
      v = RandomUniform();
      if (u <= 0.0 || v <= 0.0) {
          u = 1.0;
          v = 1.0;
      }
      v = 1.7156 * (v - 0.5);

      /*  Evaluate the quadratic form */
      x = u - 0.449871;
      y = fabs(v) + 0.386595;
      q = x * x + y * (0.19600 * y - 0.25472 * x);

      /* Accept P if inside inner ellipse */
      if (q < 0.27597)
         break;

      /*  Reject P if outside outer ellipse, or outside acceptance region */
    } while ((q > 0.27846) || (v * v > -4.0 * log(u) * u * u));

    /*  Return ratio of P's coordinates as the normal deviate */
    return (mean + stddev * v / u);
}

/*
   Return random integer within a range, lower -> upper INCLUSIVE
*/
int RandomInt(lower,upper)
int lower,upper;
{
   return((int)(RandomUniform() * (upper - lower + 1)) + lower);
}

/*
   Return random float within a range, lower -> upper
*/
double RandomDouble(lower,upper)
double lower,upper;
{
   return((upper - lower) * RandomUniform() + lower);
}







Name        : cephes
Author      : Stephen L. Moshier, moshier@world.std.com
Description : extremely good library for numerical computation in C.
              Emphasis on special functions (of very high accuracy), but
              also contains useful code for matrices, eigenvalues,
              integration, ODEs, complex arithmetic, chebyshev approximation.
Where       : the many files in directory cephes on netlib   http://www.netlib.org/cephes/
Version     : 2.2, June 1992



/* http://www.math.grin.edu/~stone/courses/fundamentals/complex-numbers.html

Complex numbers as an abstract data type

A complex number is the sum of a real number and a real multiple of the ``imaginary unit'' i, which is conventionally interpreted as
the principal square root of -1. So, for instance, the sum of the real number -3.7 and i times the real number 18.93 is a complex
number, usually written as -3.7+18.93i.

Initially, it is probably easiest to understand complex numbers pictorially: Just as the real numbers can be understood as the
coordinates, relative to an arbitrarily selected origin, of the points on a line, so the complex numbers can be understood as the
coordinates of the points on a plane, with the first real number as the abscissa and the multiple of the imaginary number as the
ordinate. The origin is 0.0+0.0i; horizontal distances are real multiples of the real unit, 1.0, and vertical distances are real multiples
the imaginary unit. Since any point can be uniquely identified by its (signed) horizontal and vertical distances from the origin, this
gives a way of using real numbers to identify complex numbers.

This ``rectangular'' coordinate system is the most common way of identifying points on a plane, and is also the most common way to
identify complex numbers. The abscissa and the ordinate are then referred to as the real part and the imaginary part of the complex
number. In both cases, however, a system of polar coordinates is often a useful alternative. In polar coordinates, a point is identified
by its magnitude -- that is, its absolute distance from the origin, as a non-negative real number -- and its phase -- that is, the
angle (measured as a real number of radians) from the non-negative part of the x-axis to a ray starting at the origin and passing
through the point.

In this system, there are several ways to denote the same point; if we want to require unique representation, we must stipulate that
the phase be in a certain range, say from -pi (exclusive) to pi (inclusive), and select an arbitrary value from this range, say 0.0, as
the phase of the origin. A polar-coordinate numeral for a complex number will consist of a numeral for its magnitude (the distance
from the origin of the corresponding point), the symbol @, and a numeral for its phase. In polar representation, then, 0.0+0.0i is
0.0@0.0 and -3.7+18.93i turns out to be approximately 19.288206241121@1.763819774188. (The latter equation is approximate
because the true magnitude and phase are both irrational numbers.)

Of course, since in the implementation most reals are approximated, the same is true of most complex numbers. The complex
numbers that can be represented exactly form an irregular lattice of points on the plane, each serving as the representative for the
points in a rectangular region surrounding it. As in the case of reals, it is usual to treat this approximation strategy as a generally
acknowledged precondition on the use of operations on complex numbers; but, as in the case of reals, this is a frequent source of
programming errors.

The only complex number for which it seems worthwhile to provide a special numeral is i itself, conceived as 0.0+1.0i:

i, the imaginary unit, as a complex number.

The following operations belong to my proposed interface for the complex-number data type.

To begin with, there should be ways of constructing a complex number from its coordinates, either rectangular or polar:

make-rectangular
Inputs: real-part and imaginary-part, both real numbers.
Output: result, a complex number.
Preconditions: none.
Postcondition: result is equal to the sum of real-part and the product of imaginary-part and i.

make-polar
Inputs: magnitude and phase, both real numbers.
Output: result, a complex number.
Precondition: magnitude is not negative.
Postconditions: result has a magnitude equal to magnitude. If the magnitude of result is 0.0, then its phase is also 0.0; otherwise,
its phase is in the range from -pi (exclusive) to pi (inclusive), and differs from phase by a multiple of twice pi.

As a special case of make-rectangular, it is often handy to have a function that supplies an imaginary part of 0.0:

real-to-complex-number
Input: real-part, a real number.
Output: result, a complex number.
Preconditions: none.
Postcondition: result is the sum of real-part and 0.0 times the imaginary unit.

Similarly, as a special case of make-polar, it is often handy to have a function that returns a complex number of unit magnitude
with a given phase:

unit-magnitude
Input: phase, a real number.
Output: result, a complex number.
Preconditions: none.
Postcondition: result has a magnitude of 1.0 and a phase in the range from -pi (exclusive) to pi (inclusive), differing from phase by
a multiple of twice pi.

A related operation is ``normalizing'' a given complex number to obtain one that has the same phase but a unit magnitude. If an
exception is made for the origin, which really has an indeterminate phase, the operation is often called signum:

signum
Input: operand, a complex number.
Output: result, a complex number.
Preconditions: none.
Postconditions: If operand is 0.0+0.0i, then the magnitude of result is 0.0 and its phase is also 0.0; otherwise, the magnitude of
result is 1.0 and its phase is the phase of operand.

We should be able to recover the coordinates -- either kind of coordinates -- from any given complex number:

real-part
Input: operand, a complex number.
Output: result, a real number.
Preconditions: none.
Postcondition: result is the real part of operand.

imaginary-part
Input: operand, a complex number.
Output: result, a real number.
Preconditions: none.
Postcondition: result is the imaginary part of operand.

magnitude
Input: operand, a complex number.
Output: result, a real number.
Preconditions: none.
Postcondition: result is the magnitude of operand.

phase
Input: operand, a complex number.
Output: result, a real number.
Preconditions: none.
Postcondition: result is the phase of operand. It
Inputs: base and power, both complex numbers.
Output: exponent, a complex number.
Preconditions: Neither base and exponent is 0.0+0.0i. base is not 1.0+0.0i.
Postconditions: power is the result of raising base to the power of exponent.

The next three operations are special cases of the preceding ones that occur frequently enough to be treated separately:

reciprocal
Input: operand, a complex number.
Output: result, a complex number.
Precondition: operand is not 0.0+0.0i
Postcondition: The product of operand and result is 1.0+0.0i.

square
Input: operand, a complex number.
Output: result, a complex number.
Preconditions: none.
Postcondition: result is the result of multiplying operand by itself.

square-root
Input: operand, a complex number.
Output: result, a complex number.
Preconditions: none.
Postcondition: result is the result of raising operand to the power 0.5.

Trigonometric functions can be extended to complex numbers by considering their expansions as sums of infinite series:

sine
Input: operand, a complex number.
Output: result, a complex number.
Preconditions: none.
Postcondition: result is the sine of operand.

cosine
Input: operand, a complex number.
Output: result, a complex number.
Preconditions: none.
Postcondition: result is the cosine of operand.

tangent
Input: operand, a complex number.
Output: result, a complex number.
Precondition: Either the imaginary part of operand is not 0.0 or the result of dividing operand by half of pi is not an odd integer.
Postcondition: result is the tangent of operand.

arc-sine
Input: operand, a complex number.
Output: result, a complex number.
Preconditions: none.
Postconditions: operand is the sine of result. The real part of result is greater than or equal to half of the negative of pi and less
than or equal to half of pi. If the imaginary part of result is positive, its real part is less than half of pi. If the imaginary part of
result is negative, its real part is greater than half of the negative of pi.

arc-cosine
Input: operand, a complex number.
Output: result, a complex number.
Precondition: none.
Postconditions: operand is the cosine of result. The real part of result is non-negative and less than or equal to pi. If the
imaginary part of result is positive, its real part is less than pi. If the imaginary part of result is negative, its real part is positive.

arc-tangent
Input: operand, a complex number.
Output: result, a complex number.
Preconditions: Either the real part of operand is not 0.0 or the absolute value of its imaginary part is not 1.0.
Postconditions: operand is the tangent of result. result is greater than or equal to the negative of half of pi and less than or equal
to half of pi. If the imaginary part of result is negative, its real part is less than half of pi. If the imaginary part of result is positive,
its real part is greater than the negative of half of pi.

Since complex numbers are not linearly ordered, only one comparison operation is really needed:

equal
Inputs: left-operand and right-operand, both complex numbers.
Output: result, a Boolean.
Preconditions: none.
Postcondition: result is true if the operands are the same complex number, false if they are different complex numbers.

Finally, the input and output operations:

read
Input: source, a data source (e.g., a file, the keyboard, a device).
Outputs: legend, a complex number, and success, a Boolean.
Preconditions: none.
Postcondition: Either some representation of a complex number has been extracted from source and legend is that complex
number,or an input error of some kind has occurred and success is false.

write
Inputs: target, a data sink (e.g., a file, a window, a device), and scribend, a complex number.
Outputs: none.
Preconditions: none.
Postcondition: A representation of scribend has been appended to target.

A ComplexNumbers module in HP Pascal

The implementation provided here is an HP Pascal module that can be separately compiled and treated as a function library by other
HP Pascal modules and programs. Application programmers can import the ComplexNumber data type and the functions and
procedures that are exported by this module and then use them as if they were predefined by the language.

The ComplexNumbers module uses the following non-standard features of HP Pascal: 

       It begins with a module header and ends with the corresponding end keyword. 
       The module is divided into an export section, containing type definitions and the headers of functions and procedures to be
       exported, and an implement section, containing local definitions and the bodies of the exported functions and procedures. 
       In Standard Pascal, values of structured types may not be returned from functions. Many of the functions in this module
       return values of the ComplexNumber type, which is a structured type. 
       Some constants, variables, and functions are imported into ComplexNumbers from other modules, using HP Pascal's import
       declaration. The HP Pascal compiler option search is used to indicate the location of one of the imported modules. 
       The HP Pascal Assert procedure is used to enforce the preconditions for the various functions. The assert_halt compiler
       option is used to ensure that the program will halt if a precondition is violated. 
       The non-standard keyword otherwise is used to pick up unexpected alternatives in case statements. 

In this implementation, complex numbers are represented by records -- specifically, by tagged variant records. Each
ComplexNumber record has three fields. The first field, Tag, indicates whether the coordinates from which the complex number was
constructed were rectangular or polar; the value of this field is fixed when the complex number is first constructed and never
changed thereafter. If the Tag is Rectangular, the other two fields are named RealPart and ImaginaryPart and contain the complex
number's rectangular coordinates; if Tag is Polar, the other two fields are named Magnitude and Phase and contain the polar
coordinates instead. In the latter case, Magnitude is always a non-negative real number, Phase is always in the range from -Pi
(exclusive) to Pi (inclusive), and if Magnitude is zero, so is Phase.

The fact that ComplexNumber is a record type and the names of the fields that it uses are visible to the application programmer; the
field identifiers are exported along with the type. This means that application programmers can, in principle, change the Tag field of
an existing complex number, assign negative values to Magnitude, access the (non-existent) RealPart field of a complex number in
which Tag is Polar, and commit other, similar misdemeanors. All of these actions violate the abstraction of the data type, and users
of the module should be warned against them: The only operations that application programmers should perform on ComplexNumber
values are procedure and function calls and whole-record assignments.

One could make it impossible for application programmers to commit these misdemeanors by making ComplexNumber an opaque data
type -- one in which the internal structure is not exported. Unfortunately, under HP Pascal, the only way to accomplish this is to
make ComplexNumber a pointer type; a pointer type can be exported without exporting its base type. This would mean that storage
for complex numbers would have to be explicitly allocated and, worse, explicitly deallocated. Since HP Pascal does not have a
built-in ``garbage collector'' (a storage-recycling system), programming with complex numbers would as a result be much more
complicated and much less robust.

Each of the functions that takes an argument of type ComplexNumber checks it for validity before operating on it, as a partial
protection against meddling by the application programmer; but this does not prevent meddling that merely replaces the value stored
in a ComplexNumber record with a different value.

The ComplexNumbers module contains several procedures that are not exported; the scope of such a procedure begins at the point of
declaration and ends at the end of the module. The ComplexNumberExceptionHandler procedure prints out an appropriate error
message whenever a precondition is violated. The ValidComplexNumber procedure checks to make sure that a given ComplexNumber
record contains a correctly constructed value. The ToRectangular and ToPolar functions take a complex number that may be
represented in either kind of coordinates and returns an (approximately) equal complex number in the specified representation. The
ToPhaseRange function similarly converts a given real number, representing a phase, into the equivalent value in the range from -Pi
(exclusive) to Pi (inclusive).

Here are some additional notes on the coding of particular functions and procedures:

The constant i is implemented as a function I of no arguments that simply constructs and returns the appropriate ComplexNumber
value. HP Pascal provides a mechanism for defining structured constants, so it would also be possible to write 

const
  I = ComplexNumber [Tag: Rectangular, RealPart: 0.0, ImaginaryPart: 1.0];

and it is arguable that this would be a better way to meet the specification.

Most of the arithmetic functions on complex numbers begin by coercing their operands to whichever form, rectangular or polar,
allows the operation to be coded more easily. When calls to these functions are nested in an expression, it can happen that any or all
of the computed intermediate values are coerced to the other form by the next function out, with a loss of precision each time.
Application programmers who are concerned about speed and/or precision should inspect the implementation code carefully to see
where these coercions occur.

The coding for the arithmetic operations is based on the following identities. In difficult cases, I was guided by the discussion of
complex numbers in section 12.5 of Guy L. Steele, Jr.'s Common Lisp: the language, second edition (n.p.: Digital Press, 1990).

       (a + bi) + (c + di) = (a + c) + (b + d)i

       (a + bi) - (c + di) = (a - c) + (b - d)i

       (r @ theta)(s @ alpha) = rs @ (theta + alpha)

       (r @ theta) / (s @ alpha) = (r / s) @ (theta - alpha)

       e ^ (a + bi) = (e ^ a) @ b

       ln (r @ theta) = (ln r) + theta i

       z ^ y = e ^ (y ln z)

       log (base y) z = (ln z) / (ln y)

       sin z = ((e ^ iz) - (e ^ -iz)) / 2i

       cos z = ((e ^ iz) + (e ^ -iz)) / 2

       tan z = (sin z) / (cos z)

       Arcsin z = -i ln (iz + sqrt (1 - z^2))

       Arccos z = -i ln (z + i sqrt (1 - z^2))

       Arctan z = (ln (1 + iz) + ln (1 - iz)) / 2i

The ReadComplexNumber procedure recognizes only rectangular-coordinate numerals for complex numbers; adding polar-coordinate
numerals is left as an exercise for the reader.

Two output procedures are provided: WriteComplexNumber writes the rectangular-coordinate numeral, and
WriteComplexNumberAsPolar the polar-coordinate one.

module ComplexNumbers;

export

  type
    ComplexNumberRepresentation = (Rectangular, Polar);
    ComplexNumber = record
                      case Tag: ComplexNumberRepresentation of
                      Rectangular:
                        (RealPart: Real; ImaginaryPart: Real);
                      Polar:
                        (Magnitude: Real; Phase: Real)
                    end;

  function I: ComplexNumber;

  function MakeRectangularComplexNumber (RealPart: Real;
    ImaginaryPart: Real): ComplexNumber; 

  function MakePolarComplexNumber (Magnitude: Real; Phase: Real):
    ComplexNumber;

  function RealToComplexNumber (RealPart: Real): ComplexNumber;

  function UnitMagnitudeComplexNumber (Phase: Real): ComplexNumber;

  function SignumOfComplexNumber (Operand: ComplexNumber): ComplexNumber;

  function RealPartOfComplexNumber (Operand: ComplexNumber): Real;

  function ImaginaryPartOfComplexNumber (Operand: ComplexNumber): Real;

  function MagnitudeOfComplexNumber (Operand: ComplexNumber): Real;

  function PhaseOfComplexNumber (Operand: ComplexNumber): Real;

  function ZeroComplexNumber (Operand: ComplexNumber): Boolean;

  function NegateComplexNumber (Negand: ComplexNumber): ComplexNumber;

  function ConjugateComplexNumber (Conjugand: ComplexNumber):
    ComplexNumber;

  function AddComplexNumber (Augend, Addend: ComplexNumber):
    ComplexNumber;

  function SubtractComplexNumber (Minuend, Subtrahend: ComplexNumber):
    ComplexNumber; 

  function MultiplyComplexNumber (Multiplicand, Multiplier: ComplexNumber):
    ComplexNumber; 

  function DivideComplexNumber (Dividend, Divisor: ComplexNumber):
    ComplexNumber; 

  function ExponentialOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber;

  function NaturalLogarithmOfComplexNumber (Power: ComplexNumber):
    ComplexNumber;

  function RaiseComplexNumber (Base, Exponent: ComplexNumber):
    ComplexNumber;

  function LogarithmOfComplexNumber (Base, Power: ComplexNumber):
    ComplexNumber; 

  function ReciprocalOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber; 

  function SquareOfComplexNumber (Operand: ComplexNumber): ComplexNumber;

  function SquareRootOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber;

  function SineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;

  function CosineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;

  function TangentOfComplexNumber (Operand: ComplexNumber): ComplexNumber;

  function ArcSineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;

  function ArcCosineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;

  function ArcTangentOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber; 

  function EqualComplexNumber (LeftOperand, RightOperand: ComplexNumber):
    Boolean; 

  procedure ReadComplexNumber (var Source: Text;
    var Legend: ComplexNumber; var Success: Boolean);

  procedure WriteComplexNumber (var Target: Text; Scribend: ComplexNumber);

  procedure WriteComplexNumberAsPolar (var Target: Text;
    Scribend: ComplexNumber);

implement

$search 'reals.o'$
import Reals, StdErr;

$assert_halt on$

  const
    FirstExceptionCode = 1;

    InvalidComplexNumberException = 1;
    NegativeMagnitudeException = 2;
    DivideDomainException = 3;
    NaturalLogarithmDomainException = 4;
    RaiseDomainException = 5;
    LogarithmDomainException = 6;
    ReciprocalDomainException = 7;
    TangentDomainException = 8;
    ArcTangentDomainException = 9;
    ReadComplexNumberException = 10;
    ExceptionException = 11;

    LastExceptionCode = 11;

  procedure ComplexNumberExceptionHandler (ExceptionCode: Integer);
  begin
    if (ExceptionCode < FirstExceptionCode) or
                        (LastExceptionCode < ExceptionCode) then
      ExceptionCode := ExceptionException;
    WriteLn (StdErr, 'Exception #', ExceptionCode : 1,
             ' in module ComplexNumbers:');
    case ExceptionCode of
    InvalidComplexNumberException:
      WriteLn (StdErr, 'One of the arguments to a function in ',
               'ComplexNumbers was an incorrectly constructed complex ',
               'number.');
    NegativeMagnitudeException:
      WriteLn (StdErr, 'The Magnitude argument to the ',
               'MakePolarComplexNumber function was negative.');
    DivideDomainException:
      WriteLn (StdErr, 'The Divisor argument to the ',
               'DivideComplexNumber function was zero.');
    NaturalLogarithmDomainException:
      WriteLn (StdErr, 'The argument to the ',
               'NaturalLogarithmOfComplexNumber function was zero.');
    RaiseDomainException:
      WriteLn (StdErr, 'The arguments to the RaiseComplexNumber function ',
               'were not in its domain.');
    LogarithmDomainException:
      WriteLn (StdErr, 'The arguments to the LogarithmOfComplexNumber ',
               'function were not in its domain.');
    ReciprocalDomainException:
      WriteLn (StdErr, 'The argument to the ReciprocalOfComplexNumber ',
               'function was zero.');
    TangentDomainException:
      WriteLn (StdErr, 'The arguments to the TangentOfComplexNumber ',
               'function were not in its domain.');
    ArcTangentDomainException:
      WriteLn (StdErr, 'The arguments to the ArcTangentOfComplexNumber ',
               'function were not in its domain.');
    ReadComplexNumberException:
      WriteLn (StdErr, 'The ReadComplexNumber procedure read in an ',
               'incorrectly constructed complex number.');
    ExceptionException:
      WriteLn (StdErr, 'The ComplexNumberExceptionHandler function ',
               'received an unknown exception code.')
    end
  end;

  function ValidComplexNumber (Candidate: ComplexNumber): Boolean;
  begin
    case Candidate.Tag of
    Rectangular:
      ValidComplexNumber := True;
    Polar:
      ValidComplexNumber := Positive (Candidate.Magnitude) or
                (Zero (Candidate.Magnitude) and Zero (Candidate.Phase));
    otherwise
      ValidComplexNumber := False
    end
  end;

  function ToRectangular (Operand: ComplexNumber): ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Result.Tag := Rectangular;
    case Operand.Tag of
    Rectangular:
      Result := Operand;
    Polar:
      begin
        Result.RealPart := Operand.Magnitude * Cos (Operand.Phase);
        Result.ImaginaryPart := Operand.Magnitude * Sin (Operand.Phase)
      end
    end;
    ToRectangular := Result
  end;
      
  function ToPhaseRange (ProposedPhase: Real): Real;
  var
    Reduced: Real;
  begin
    if (-Pi < ProposedPhase) and (ProposedPhase <= Pi) then
      ToPhaseRange := ProposedPhase
    else if -Pi = ProposedPhase then
      ToPhaseRange := Pi
    else begin
      Reduced := Modulo (ProposedPhase, Twice (Pi));
      if Reduced <= Pi then
        ToPhaseRange := Reduced
      else
        ToPhaseRange := Reduced - Twice (Pi)
    end
  end;

  function ToPolar (Operand: ComplexNumber): ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Result.Tag := Polar;
    case Operand.Tag of
    Rectangular:
      begin
        Result.Magnitude :=
            Sqrt (Sqr (Operand.RealPart) + Sqr (Operand.ImaginaryPart));
        if Zero (Operand.ImaginaryPart) then begin
          if Negative (Operand.RealPart) then
            Result.Phase := Pi
          else
            Result.Phase := 0.0
        end
        else
          Result.Phase := RatioArcTangent (Operand.ImaginaryPart,
                                           Operand.RealPart)
      end;
    Polar:
      Result := Operand
    end;
    ToPolar := Result
  end;

  function I: ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Result.Tag := Rectangular;
    Result.RealPart := 0.0;
    Result.ImaginaryPart := 1.0;
    I := Result
  end;

  function MakeRectangularComplexNumber (RealPart: Real;
    ImaginaryPart: Real): ComplexNumber; 
  var
    Result: ComplexNumber;
  begin
    Result.Tag := Rectangular;
    Result.RealPart := RealPart;
    Result.ImaginaryPart := ImaginaryPart;
    MakeRectangularComplexNumber := Result
  end;

  function MakePolarComplexNumber (Magnitude: Real; Phase: Real):
    ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Assert (not Negative (Magnitude), NegativeMagnitudeException,
            ComplexNumberExceptionHandler);
    Result.Tag := Polar;
    if Zero (Magnitude) then begin
      Result.Magnitude := 0.0;
      Result.Phase := 0.0
    end
    else begin
      Result.Magnitude := Magnitude;
      Result.Phase := ToPhaseRange (Phase)
    end;
    MakePolarComplexNumber := Result
  end;

  function RealToComplexNumber (RealPart: Real):ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Result.Tag := Rectangular;
    Result.RealPart := RealPart;
    Result.ImaginaryPart := 0.0;
    RealToComplexNumber := Result
  end;

  function UnitMagnitudeComplexNumber (Phase: Real): ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Result.Tag := Polar;
    Result.Magnitude := 1.0;
    Result.Phase := ToPhaseRange (Phase);
    UnitMagnitudeComplexNumber := Result
  end;

  function SignumOfComplexNumber (Operand: ComplexNumber): ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Result := ToPolar (Operand);
    if not Zero (Result.Magnitude) then
      Result.Magnitude := 1.0;
    SignumOfComplexNumber := Result
  end;

  function RealPartOfComplexNumber (Operand: ComplexNumber): Real;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    case Operand.Tag of
    Rectangular:
      RealPartOfComplexNumber := Operand.RealPart;
    Polar:
      RealPartOfComplexNumber := Operand.Magnitude * Cos (Operand.Phase)
    end
  end;

  function ImaginaryPartOfComplexNumber (Operand: ComplexNumber): Real;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    case Operand.Tag of
    Rectangular:
      ImaginaryPartOfComplexNumber := Operand.ImaginaryPart;
    Polar:
      ImaginaryPartOfComplexNumber :=
                                Operand.Magnitude * Sin (Operand.Phase)
    end
  end;

  function MagnitudeOfComplexNumber (Operand: ComplexNumber): Real;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    case Operand.Tag of
    Rectangular:
      MagnitudeOfComplexNumber :=
            Sqrt (Sqr (Operand.RealPart) + Sqr (Operand.ImaginaryPart));
    Polar:
      MagnitudeOfComplexNumber := Operand.Magnitude
    end
  end;

  function PhaseOfComplexNumber (Operand: ComplexNumber): Real;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    case Operand.Tag of
    Rectangular:
      if Zero (Operand.ImaginaryPart) then begin
        if Negative (Operand.RealPart) then
          PhaseOfComplexNumber := Pi
        else
          PhaseOfComplexNumber := 0.0
      end
      else
        PhaseOfComplexNumber := RatioArcTangent (Operand.ImaginaryPart,
                                                 Operand.RealPart);
    Polar:
      PhaseOfComplexNumber := Operand.Phase
    end
  end;

  function ZeroComplexNumber (Operand: ComplexNumber): Boolean;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    case Operand.Tag of
    Rectangular:
      ZeroComplexNumber :=
            Zero (Operand.RealPart) and Zero (Operand.ImaginaryPart);
    Polar:
      ZeroComplexNumber := Zero (Operand.Magnitude)
    end
  end;

  function NegateComplexNumber (Negand: ComplexNumber): ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Negand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Result.Tag := Negand.Tag;
    case Negand.Tag of
    Rectangular:
      begin
        Result.RealPart := -Negand.RealPart;
        Result.ImaginaryPart := -Negand.ImaginaryPart
      end;
    Polar:
      begin
        Result.Magnitude := Negand.Magnitude;
        if Zero (Negand.Magnitude) then
          Result.Phase := 0.0
        else if Positive (Negand.Phase) then
          Result.Phase := Negand.Phase - Pi
        else
          Result.Phase := Negand.Phase + Pi
      end
    end;
    NegateComplexNumber := Result
  end;

  function ConjugateComplexNumber (Conjugand: ComplexNumber):
    ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Conjugand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Result.Tag := Conjugand.Tag;
    case Conjugand.Tag of
    Rectangular:
      begin
        Result.RealPart := Conjugand.RealPart;
        Result.ImaginaryPart := -Conjugand.ImaginaryPart
      end;
    Polar:
      begin
        Result.Magnitude := Conjugand.Magnitude;
        if Conjugand.Phase = Pi then
          Result.Phase := Pi
        else
          Result.Phase := -Conjugand.Phase
      end
    end;
    ConjugateComplexNumber := Result
  end;

  function AddComplexNumber (Augend, Addend: ComplexNumber):
    ComplexNumber;
  var
    RectangularAugend, RectangularAddend: ComplexNumber;
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Augend) and ValidComplexNumber (Addend),
            InvalidComplexNumberException, ComplexNumberExceptionHandler);
    RectangularAugend := ToRectangular (Augend);
    RectangularAddend := ToRectangular (Addend);
    Result.Tag := Rectangular;
    Result.RealPart :=
                RectangularAugend.RealPart + RectangularAddend.RealPart;
    Result.ImaginaryPart :=
        RectangularAugend.ImaginaryPart + RectangularAddend.ImaginaryPart;
    AddComplexNumber := Result;
  end;

  function SubtractComplexNumber (Minuend, Subtrahend: ComplexNumber):
    ComplexNumber;
  var
    RectangularMinuend, RectangularSubtrahend: ComplexNumber;
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Minuend) and ValidComplexNumber (Subtrahend),
            InvalidComplexNumberException, ComplexNumberExceptionHandler);
    RectangularMinuend := ToRectangular (Minuend);
    RectangularSubtrahend := ToRectangular (Subtrahend);
    Result.Tag := Rectangular;
    Result.RealPart :=
            RectangularMinuend.RealPart - RectangularSubtrahend.RealPart;
    Result.ImaginaryPart := RectangularMinuend.ImaginaryPart -
                                    RectangularSubtrahend.ImaginaryPart;
    SubtractComplexNumber := Result;
  end;

  function MultiplyComplexNumber (Multiplicand, Multiplier: ComplexNumber):
    ComplexNumber; 
  var
    PolarMultiplicand, PolarMultiplier: ComplexNumber;
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Multiplicand) and
                                        ValidComplexNumber (Multiplier),
            InvalidComplexNumberException, ComplexNumberExceptionHandler);
    PolarMultiplicand := ToPolar (Multiplicand);
    PolarMultiplier := ToPolar (Multiplier);
    Result.Tag := Polar;
    Result.Magnitude :=
                PolarMultiplicand.Magnitude * PolarMultiplier.Magnitude;
    if Zero (Result.Magnitude) then
      Result.Phase := 0.0
    else
      Result.Phase :=
        ToPhaseRange (PolarMultiplicand.Phase + PolarMultiplier.Phase);
    MultiplyComplexNumber := Result
  end;

  function DivideComplexNumber (Dividend, Divisor: ComplexNumber):
    ComplexNumber;
  var
    PolarDividend, PolarDivisor: ComplexNumber;
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Dividend) and ValidComplexNumber (Divisor),
            InvalidComplexNumberException, ComplexNumberExceptionHandler);
    Assert (not ZeroComplexNumber (Divisor), DivideDomainException,
            ComplexNumberExceptionHandler);
    PolarDividend := ToPolar (Dividend);
    PolarDivisor := ToPolar (Divisor);
    Result.Tag := Polar;
    Result.Magnitude := PolarDividend.Magnitude / PolarDivisor.Magnitude;
    if Zero (Result.Magnitude) then
      Result.Phase := 0.0
    else
      Result.Phase :=
        ToPhaseRange (PolarDividend.Phase - PolarDivisor.Phase);
    DivideComplexNumber := Result
  end;

  function ExponentialOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber;
  var
    RectangularOperand: ComplexNumber;
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    RectangularOperand := ToRectangular (Operand);
    Result.Tag := Polar;
    Result.Magnitude := Exp (RectangularOperand.RealPart);
    Result.Phase := ToPhaseRange (RectangularOperand.ImaginaryPart);
    ExponentialOfComplexNumber := Result
  end;

  function NaturalLogarithmOfComplexNumber (Power: ComplexNumber):
    ComplexNumber;
  var
    PolarPower: ComplexNumber;
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Power), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Assert (not ZeroComplexNumber (Power), NaturalLogarithmDomainException,
            ComplexNumberExceptionHandler);
    PolarPower := ToPolar (Power);
    Result.Tag := Rectangular;
    Result.RealPart := Ln (PolarPower.Magnitude);
    Result.ImaginaryPart := PolarPower.Phase;
    NaturalLogarithmOfComplexNumber := Result
  end;

  function RaiseComplexNumber (Base, Exponent: ComplexNumber):
    ComplexNumber;
  begin
    Assert (ValidComplexNumber (Base) and ValidComplexNumber (Exponent),
            InvalidComplexNumberException, ComplexNumberExceptionHandler);
    Assert (not ZeroComplexNumber (Base) or ZeroComplexNumber (Exponent) or
                        Positive (RealPartOfComplexNumber (Exponent)),
            RaiseDomainException, ComplexNumberExceptionHandler);
    if ZeroComplexNumber (Base) then begin
      if ZeroComplexNumber (Exponent) then
        RaiseComplexNumber := RealToComplexNumber (1.0)
      else
        RaiseComplexNumber := RealToComplexNumber (0.0)
    end
    else
      RaiseComplexNumber :=
        ExponentialOfComplexNumber (
          MultiplyComplexNumber (Exponent,
                                 NaturalLogarithmOfComplexNumber (Base)))
  end;

  function LogarithmOfComplexNumber (Base, Power: ComplexNumber):
    ComplexNumber; 
  begin
    Assert (ValidComplexNumber (Base) and ValidComplexNumber (Power),
            InvalidComplexNumberException, ComplexNumberExceptionHandler);
    Assert (not ZeroComplexNumber (Power) and
                not ZeroComplexNumber (Base) and
                ((RealPartOfComplexNumber (Base) <> 1.0) or
                 (ImaginaryPartOfComplexNumber (Base) <> 0.0)),
            LogarithmDomainException, ComplexNumberExceptionHandler);
    LogarithmOfComplexNumber :=
      DivideComplexNumber (NaturalLogarithmOfComplexNumber (Power),
                           NaturalLogarithmOfComplexNumber (Base))
  end;

  function ReciprocalOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber;
  var
    Result: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Assert (not ZeroComplexNumber (Operand), ReciprocalDomainException,
            ComplexNumberExceptionHandler);
    Result := ToPolar (Operand);
    Result.Magnitude := Reciprocal (Result.Magnitude);
    ReciprocalOfComplexNumber := Result
  end;

  function SquareOfComplexNumber (Operand: ComplexNumber): ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    SquareOfComplexNumber := MultiplyComplexNumber (Operand, Operand)
  end;

  function SquareRootOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber;
  var
    Log: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    if ZeroComplexNumber (Operand) then
      SquareRootOfComplexNumber := Operand
    else begin
      Log := NaturalLogarithmOfComplexNumber (Operand);
      Log.RealPart := Half (Log.RealPart);
      Log.ImaginaryPart := Half (Log.ImaginaryPart);
      SquareRootOfComplexNumber :=  ExponentialOfComplexNumber (Log)
    end
  end;

  function SineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;
  var
    ITimesOperand: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    ITimesOperand := MultiplyComplexNumber (I, Operand);
    SineOfComplexNumber :=
        DivideComplexNumber (
          SubtractComplexNumber (
            ExponentialOfComplexNumber (ITimesOperand),
            ExponentialOfComplexNumber (NegateComplexNumber (ITimesOperand))),
          MakeRectangularComplexNumber (0.0, 2.0))
  end;

  function CosineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;
  var
    ITimesOperand: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    ITimesOperand := MultiplyComplexNumber (I, Operand);
    CosineOfComplexNumber :=
        DivideComplexNumber (
          AddComplexNumber (
            ExponentialOfComplexNumber (ITimesOperand),
            ExponentialOfComplexNumber (NegateComplexNumber (ITimesOperand))),
          RealToComplexNumber (2.0))
  end;

  function TangentOfComplexNumber (Operand: ComplexNumber): ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Assert (not Zero (ImaginaryPartOfComplexNumber (Operand)) or
            not Zero (Modulo (
                          RealPartOfComplexNumber (Operand) - Half (Pi),
                          Pi)),
            TangentDomainException, ComplexNumberExceptionHandler);
    TangentOfComplexNumber :=
                DivideComplexNumber (SineOfComplexNumber (Operand),
                                     CosineOfComplexNumber (Operand))
  end;

  function ArcSineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    ArcSineOfComplexNumber :=
        MultiplyComplexNumber (
          MakeRectangularComplexNumber (0.0, -1.0),
          NaturalLogarithmOfComplexNumber (
            AddComplexNumber (
              MultiplyComplexNumber (I, Operand),
              SquareRootOfComplexNumber (
                SubtractComplexNumber (
                  RealToComplexNumber (1.0),
                  SquareOfComplexNumber (Operand))))))
  end;

  function ArcCosineOfComplexNumber (Operand: ComplexNumber): ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    ArcCosineOfComplexNumber :=
        MultiplyComplexNumber (
          MakeRectangularComplexNumber (0.0, -1.0),
          NaturalLogarithmOfComplexNumber (
            AddComplexNumber (
              Operand,
              MultiplyComplexNumber (
                I,
                SquareRootOfComplexNumber (
                  SubtractComplexNumber (
                    RealToComplexNumber (1.0),
                    SquareOfComplexNumber (Operand)))))))
  end;

  function ArcTangentOfComplexNumber (Operand: ComplexNumber):
    ComplexNumber; 
  var
    RealUnit: ComplexNumber;
    ITimesOperand: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Operand), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    Assert (not Zero (RealPartOfComplexNumber (Operand)) or
            (Abs (ImaginaryPartOfComplexNumber (Operand)) <> 1.0),
            ArcTangentDomainException, ComplexNumberExceptionHandler);
    RealUnit := RealToComplexNumber (1.0);
    ITimesOperand := MultiplyComplexNumber (I, Operand);
    ArcTangentOfComplexNumber :=
        DivideComplexNumber (
          SubtractComplexNumber (
            NaturalLogarithmOfComplexNumber (
              AddComplexNumber (RealUnit, ITimesOperand)),
            NaturalLogarithmOfComplexNumber (
              SubtractComplexNumber (RealUnit, ITimesOperand))),
          MakeRectangularComplexNumber (0.0, 2.0))
  end;

  function EqualComplexNumber (LeftOperand, RightOperand: ComplexNumber):
    Boolean;
  var
    RectangularLeftOperand, RectangularRightOperand: ComplexNumber;
  begin
    Assert (ValidComplexNumber (LeftOperand) and
                                        ValidComplexNumber (RightOperand),
            InvalidComplexNumberException, ComplexNumberExceptionHandler);
    RectangularLeftOperand := ToRectangular (LeftOperand);
    RectangularRightOperand := ToRectangular (RightOperand);
    EqualComplexNumber :=
        (RectangularLeftOperand.RealPart =
                                RectangularRightOperand.RealPart) and
        (RectangularLeftOperand.ImaginaryPart =
                                RectangularRightOperand.ImaginaryPart)
  end;

  procedure ReadComplexNumber (var Source: Text;
    var Legend: ComplexNumber; var Success: Boolean);
  label 99;
  type
    Sign = (Negative, NonNegative);
  var
    FirstSign, SecondSign: Sign;
    FirstReal, SecondReal: Real;

    procedure SkipWhiteSpace (var Source: Text);
    var
      Continue: Boolean;
    begin
      Continue := True;
      while Continue do
        if EOF (Source) then
          Continue := False
        else if Source^ <= ' ' then
          Get (Source)
        else
          Continue := False
    end;

  begin
    SkipWhiteSpace (Source);
    if EOF (Source) then begin { no numeral left in file }
      Success := False;
      goto 99
    end;
    if Source^ = '-' then
      FirstSign := Negative
    else
      FirstSign := NonNegative;
    if Source^ in ['-', '+'] then begin
      Get (Source);
      if EOF (Source) then begin { file ended after initial sign }
        Success := False;
        goto 99
      end
    end;
    if Source^ in ['i', 'I'] then begin { +i, -i, or i }
      Get (Source);
      if FirstSign = Negative then
        Legend := MakeRectangularComplexNumber (0.0, -1.0)
      else
        Legend := MakeRectangularComplexNumber (0.0, 1.0)
    end
    else begin { After the sign, there should be a numeral. }
      if not (Source^ in ['0' .. '9']) then begin { There wasn't. }
        Success := False;
        goto 99
      end;
      Read (Source, FirstReal);
      if EOF (Source) then begin { file ended after real part }
        if FirstSign = Negative then
          Legend := MakeRectangularComplexNumber (-FirstReal, 0.0)
        else
          Legend := MakeRectangularComplexNumber (FirstReal, 0.0)
      end
      else if Source^ in ['i', 'I'] then begin { imaginary number }
        Get (Source);
        if FirstSign = Negative then
          Legend := MakeRectangularComplexNumber (0.0, -FirstReal)
        else
          Legend := MakeRectangularComplexNumber (0.0, FirstReal)
      end
      else begin
        Legend.Tag := Rectangular;
        if FirstSign = Negative then
          Legend.RealPart := -FirstReal
        else
          Legend.RealPart := FirstReal;
        if Source^ in ['+', '-'] then begin
          if Source^ = '-' then
            SecondSign := Negative
          else
            SecondSign := NonNegative;
          Get (Source);
          if EOF (Source) then begin { file ended after sign of imag. part }
            Success := False;
            goto 99
          end;
          if Source^ in ['i', 'I'] then begin { imag. part is +i or -i }
            Get (Source);
            if SecondSign = Negative then
              Legend.ImaginaryPart := -1.0
            else
              Legend.ImaginaryPart := 1.0
          end
          else begin { After the sign, there should be a numeral. }
            if not (Source^ in ['0' .. '9']) then begin { There wasn't. }
              Success := False;
              goto 99
            end;
            Read (Source, SecondReal);
            if EOF (Source) then begin { file ended without i in imag. part }
              Success := False;
              goto 99
            end;
            if not (Source^ in ['i', 'I']) then begin { no i in imag. part }
              Success := False;
              goto 99
            end;
            Get (Source);
            if SecondSign = Negative then
              Legend.ImaginaryPart := -SecondReal
            else
              Legend.ImaginaryPart := SecondReal
          end
        end
        else { nothing useful after real part }
          Legend.ImaginaryPart := 0.0
      end
    end;
    Success := True;
    Assert (ValidComplexNumber (Legend), ReadComplexNumberException,
            ComplexNumberExceptionHandler);
  99:
  end;

  procedure WriteComplexNumber (var Target: Text; Scribend: ComplexNumber);
  var
    RectangularScribend: ComplexNumber;
    AbsoluteValueOfImaginaryPart: Real;
  begin
    Assert (ValidComplexNumber (Scribend), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    RectangularScribend := ToRectangular (Scribend);
    if Zero (RectangularScribend.ImaginaryPart) then
      Write (Target, Scribend.RealPart : 1 : 6)
    else if Zero (RectangularScribend.RealPart) then begin
      if RectangularScribend.ImaginaryPart = 1.0 then
        Write (Target, 'i')
      else if RectangularScribend.ImaginaryPart = -1.0 then
        Write (Target, '-i')
      else
        Write (Target, RectangularScribend.ImaginaryPart : 1 : 6, 'i')
    end
    else begin
      Write (Target, RectangularScribend.RealPart : 1 : 6);
      if Positive (RectangularScribend.ImaginaryPart) then
        Write (Target, '+')
      else
        Write (Target, '-');
      AbsoluteValueOfImaginaryPart :=
                                Abs (RectangularScribend.ImaginaryPart);
      if AbsoluteValueOfImaginaryPart <> 1.0 then
        Write (Target, AbsoluteValueOfImaginaryPart : 1 : 6);
      Write (Target, 'i')
    end
  end;

  procedure WriteComplexNumberAsPolar (var Target: Text;
    Scribend: ComplexNumber);
  var
    PolarScribend: ComplexNumber;
  begin
    Assert (ValidComplexNumber (Scribend), InvalidComplexNumberException,
            ComplexNumberExceptionHandler);
    PolarScribend := ToPolar (Scribend);
    Write (Target, PolarScribend.Magnitude : 1 : 6, '@',
           PolarScribend.Phase : 1 : 6)
  end;

end.


/* http://www.ma.iup.edu/MathDept/Projects/CalcDEMma/complex/complex4.html: */
 * So, Exp[iy]=Cos[y]+iSin[y] and therefore Exp[z]=Exp[x]*Exp[iy]=Exp[x]{Cos[y]+iSin[y]}. */
 * This last equation is Euler's equation. */
 *
 * Sqrt[z]=Sqrt[ |z|Exp[i theta] ]=Sqrt[ |z| ] Exp[i theta/2], 
 * remember, |z| is a REAL number.
 *
 * In general, z^(1/n)=|z|^(1/n) Exp[i theta/n]
 *
 * In general, the nth roots are evenly spaced around the circle of radius |z|^(1/n), starting with the
 * "first", or principal root. Putting this together with the polar form, one can also see that the n nth
 * roots of z are given by
 * |z|^(1/n) Exp[i (theta/n + 2kPi/n)], k=0, 1, 2, 3, . . ., n-1
 *
 * http://www4.informatik.uni-erlangen.de/Services/Doc/SPRO/c-plusplus/c++_lrm/Complex.doc.html 
 *
 * gcc claims to support complex now, dunno if that includes trig fns &tc
 * http://unlser1.unl.csi.cuny.edu/faqs/g++-faq/wp/jan95/lib-numerics.html suggests it does

CComplex Sqrt(const CComplex &z)
{
   ASSERT_VALID(&z);
   CComplex temp;
	float x, y, w, r;

	if((z.fc.r == 0.0F) && (z.fc.i == 0.0F)) {
		temp.fc.r = 0.0F;
		temp.fc.i = 0.0F;
	} else {
		x = (float)fabs(z.fc.r);
		y = (float)fabs(z.fc.i);
		if (x >= y) {
			r = y / x;
			w = (float)(sqrt(x) * sqrt(0.5F * (1.0F + sqrt(1.0F + r * r))));
		} else {
			r = x / y;
			w = (float)(sqrt(y) * sqrt(0.5F * (r + sqrt(1.0F + r * r))));
		}
		if (z.fc.r >= 0.0F) {
			temp.fc.r = w;
			temp.fc.i = z.fc.i / (2.0F * w);
		} else {
			temp.fc.i = ((z.fc.i >= 0) ? w : -w);
			temp.fc.r = z.fc.i / (2.0F * temp.fc.i);
	   }
   }
   return temp;
}

from http://www.netlib.org/c/numcomp-free-c:

Name        : Euler
Where       : By anonymous ftp from ftp.ku-eichstaett.de
Files       : 212 kb /pub/unix/math/euler.tar.Z
Language    : ANSI-C
Author      : Rene Grothmann (rene.grothmann@ku-eichstaett.de)
Version     : 3.18
Description : Runs on UNIX/XWindow systems (OS/2 version available).
              Real and complex numbers and matrices. Lots of built in
              functions. Programming language. 2D/3D plots. ASCII-
              documentation and demo mode.  Matlab like.
Comments    : Tested on IBM Risc, Linux and Sun (with acc compiler)



Name        : bignum
Where       : pub/bignum on rpub.msu.edu ; ripem.msu.edu
Description : directory filled with bignum software, and a file
              BIGNUMS.TXT which summaries bignum alternatives.
Author      : BIGNUMS.TXT is by Mark Riordan (mrr@scss3.cl.msu.edu)
              The ftp site is maintained by him.
Version     : April 1993.


Name        : bignum.tar.Z
Where       : in tars/math on einstein.mse.lehigh.edu (128.180.9.162)
Systems     : Unix
Description : Arbitrary Precision Integer Arithmetic
Author      : Serpette, Vuillemin, Jean-Claude Herve 
Version     : 23 Sept 1990
Comments    : Excellent. very fast. possible problems with unalloc call. 



 */
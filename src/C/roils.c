// roils.c - code for doing least squares fitting of ROI shapes using LSQR algorithm

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include "lsqr.h"

#define Calloc(size,type) (type *) calloc(size, sizeof(type));
#define Malloc(size,type) (type *) malloc(size*sizeof(type));

typedef struct {
	int ndims;
	int nroi;
	int T;
	int *isize; // image size, len = ndims
	int *psize; // patch size, len = ndims
	int *c; // position of patch corners in larger image, len = ndims*nroi, dimension first, roi index second
	double *v; // time course of each ROI, len = nroi*T, time first, roi index second
} params;


void aprod(int mode, int m, int n, double x[], double y[], void *UsrWrk) {
// aprod - linear operator passed to lsqr
// The shape of y is the shape of an entire video, with time index first,
// while the shape of x is the shape of all the ROIs, with patch index first
	params *p = (params *)UsrWrk;
	int i,j,k,t,idx,dp,di,iout,ii;
	int np = 1;
	for (i = 0; i < p->ndims; i++) {
		np *= p->psize[i];
	}
	for (i = 0; i < np; i++) {
		for (j = 0; j < p->nroi; j++) {
			// convert the index from local patch coordinates to global image coordinates
			idx = 0;
			iout = 0;
			dp = 1;
			di = 1;
			for (k = 0; k < p->ndims; k++) {
				ii = p->c[k + p->ndims*j] + ((i/dp) % p->psize[k]); // the index along dimension k in global image coordinates
				if (ii >= p->isize[k]) {
					iout = 1;
				}
				idx += di*ii;
				dp *= p->psize[k];
				di *= p->isize[k];
			}
			if (!iout) {
				idx *= p->T;
				// Depending on which way we are applying the operator, take an inner or outer product
				for (t = 0; t < p->T; t++) {
					if (mode == 1) {
						y[idx + t] += x[i + j*np]*p->v[t + j*p->T];
					} else {
						x[i + j*np] += y[idx + t]*p->v[t + j*p->T];
					}
				}
			}
		}
	}
}

void roilsqr(double x[], double y[], double damp, params *p, int show) {
	int m = p->T;
	int i;
	for (i = 0; i < p->ndims; i++) {
		m *= p->isize[i];
	}

	int n = p->nroi;
	for (i = 0; i < p->ndims; i++) {
		n *= p->psize[i];
	}

	FILE *nout;
	if (show) {
		nout = stdout;
	} else {
		nout = NULL;
	}

	// Declare necessary variables for lsqr
    double v[n];
    double w[n];
	// The remaining variables are output only.
	int    istop_out;
	int    itn_out;
	double anorm_out;
	double acond_out;
	double rnorm_out;
	double arnorm_out;
	double xnorm_out;

	lsqr(m, n, &aprod, damp, (void *)p, y, v, w, x, NULL, 1e-9, 1e-9, 1e8, 1000, nout,
		&istop_out, &itn_out, &anorm_out, &acond_out, &rnorm_out, &arnorm_out, &xnorm_out);
}

void roiadmm(double x[], double y[], params *p, double lambda, double gamma) {
// This will be full ADMM for doing joint nuclear norm (and possibly l_1)
// minimization for fitting shape of ROIs.
}

int main(int argc, char* argv[]) {
	srand(time(NULL));
	const int ndims = 2;
	int isize[2] = {512,512};
	int psize[2] = {40,40};

	int nroi = 66;
	int T = 725;
	int i;
	int c[ndims*nroi];
	for (i=0; i<nroi; i++) {
		c[i*ndims]     = rand() % isize[0];
		c[i*ndims + 1] = rand() % isize[1];
	}
	double v[nroi*T];
	for (i=0; i<nroi*T; i++) {
		v[i] = ((double)rand()/(double)RAND_MAX);
	}

	params p;
	p.ndims = 2;
	p.nroi = nroi;
	p.T = T;
	p.isize = isize;
	p.psize = psize;
	p.c = c;
	p.v = v;

	double * y = Malloc(T*isize[0]*isize[1],double);
	for (i=0; i<T*isize[0]*isize[1]; i++) {
		y[i] = ((double)rand()/(double)RAND_MAX);
	}
	double * x = Malloc(nroi*psize[0]*psize[1],double);
	struct timeval start, end;
    gettimeofday(&start, NULL);
	aprod(1, T*isize[0]*isize[1], nroi*psize[0]*psize[1], x, y, &p);
    gettimeofday(&end, NULL);
    printf("%ld\n", ((end.tv_sec * 1000000 + end.tv_usec)
		  - (start.tv_sec * 1000000 + start.tv_usec)));
    roilsqr(x,y,0.0,&p,1);
	free(y);
	free(x);
	return 0;
}
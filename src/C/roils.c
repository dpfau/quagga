// roils.c - code for doing least squares fitting of ROI shapes using LSQR algorithm

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <float.h>
#include <sys/time.h>
#include <math.h>
#include <string.h>
#include "lsqr.h"
#include "tiffio.h"

#ifndef SVD_ERROR
#define SVD_ERROR 30
#endif

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

double * plus(double x[], const double y[], const double c, const int n) {
// x = x + c*y
	int i;
	for (i = 0; i < n; i++) {
		x[i] += c*y[i];
	}
	return x;
}

double * scale(double x[], const double c, const int n) {
	int i;
	for (i = 0; i < n; i++) {
		x[i] *= c;
	}
	return x;
}

double normsq(const double x[], const int n) {
	double y = 0.0;
	int i;
	for (i = 0; i < n; i++) y += x[i]*x[i];
	return y;
}

double eucdist(const double x[], const double y[], int n) {
	double d = 0.0;
	int i;
	for (i = 0; i < n; i++) {
		d += (x[i] - y[i])*(x[i] - y[i]);
	}
	return sqrt(d);
}

void dump(FILE *fout, double x[], int n) {
	int i;
	for (i = 0; i < n; i++) {
		fprintf(fout, "%f\n", x[i]);
	}
}

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

void svt(int m, int n, double A[], double B[], double U[], double s[], double Vt[], double t) {
// Singular value thresholding operator applied to mxn matrix A, with the result written to B
// U, s, Vt hold the values of the SVD, and t is the amount to threshold.

	int i,j,k;
	int p = m<n?m:n; // Find the smaller dimension
	memcpy(B,A,m*n*sizeof(double)); // to avoid destroying A, copy contents to B before SVD

	// Set LAPACK variables
	double workSize;
    double *work = &workSize;
    int lwork = -1;
    int *iwork = malloc(8*p*sizeof(int));
    int info = 0;
	dgesdd_("S", &m, &n, B, &m, s, U, &m, Vt, &p, work, &lwork, iwork, &info);
	if (info) exit(SVD_ERROR);
	lwork = workSize;
	work = malloc(lwork * sizeof *work);

	// Call SVD
	dgesdd_("S", &m, &n, B, &m, s, U, &m, Vt, &p, work, &lwork, iwork, &info);
	if (info) exit(SVD_ERROR);

	// Threshold singular values
	for (i = 0; i < p; i++)
		s[i] = (s[i]>t)?s[i]-t:0.0;

	// Fold everything back together.
	for (i = 0; i < m; i++) {
		for (j = 0; j < n; j++) {
			B[i+m*j] = 0;
			for (k = 0; k < p; k++) {
				B[i+m*j] += s[k]*U[i+m*k]*Vt[k+p*j];
			}
		}
	}
	free(work);
	free(iwork);
}

double * roilsqr(double x[], double y[], double v[], double w[], double damp, params *p, int show) {
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

	// The remaining variables are output only.
	int    istop_out;
	int    itn_out;
	double anorm_out;
	double acond_out;
	double rnorm_out;
	double arnorm_out;
	double xnorm_out;

	lsqr(m, n, &aprod, damp, (void *)p, y, v, w, x, NULL, 1e-9, 1e-9, 1e8, 10, nout,
		&istop_out, &itn_out, &anorm_out, &acond_out, &rnorm_out, &arnorm_out, &xnorm_out);
	return x;
}

void roiadmm(double x[], double y[], params *p, double lambda, double gamma, int show) {
// finds argmin_x 1/2||aprod(x)-y||^2 + lambda*||x||_* + gamma||x||_1 via ADMM

	int m = p->T;
	int i;
	for (i = 0; i < p->ndims; i++) {
		m *= p->isize[i];
	}

	int np = 1; // Number of pixels in a patch
	for (i = 0; i < p->ndims; i++) {
		np *= p->psize[i];
	}
	int n = p->nroi*np;

	// Declare necessary variables for lsqr
    double * v = Malloc(n,double);
    double * w = Malloc(n,double);

    if (lambda == 0.0 && gamma == 0.0) { // just do least squares
    	roilsqr(x, y, v, w, 0.0, p, show); // warning: this changes the value of y
	} else {
		double rho = 10; // Dual learning rate

		double eps_abs = 1e-6;
		double eps_rel = 1e-6;

		double r_p = DBL_MAX;
		double r_d = DBL_MAX;
		double e_p = 0.0;
		double e_d = 0.0;

		int itnlim = 100;
		int itn = 0;

		double * ycpy = Malloc(m,double); // because roilsqr changes y, create a copy of it upfront and rewrite it at each iteration

		if (lambda != 0.0) {
			double * z  = Calloc(n,double); // Auxiliary variable
			double * z_ = Calloc(n,double); // Keep the aux variable from the last step around for computing the stopping criterion
			double * u  = Calloc(n,double); // Lagrange multiplier (scaled form)

			// allocate space for implementing SVT
			int nsv = p->nroi<np?p->nroi:np; // number of singular values = min(number of ROIs, number of pixels in a patch)
			double * uu = Malloc(p->nroi*nsv,double);
			double * ss = Malloc(nsv,double);
			double * vv = Malloc(np*nsv,double);

			if (show) printf("Iter:\tr_p\t\te_p\t\tr_d\t\te_d\n");
			while(itn < itnlim && (r_p > e_p || r_d > e_d)) {
				itn++;
				memcpy(ycpy, y, m*sizeof(double));

				aprod(1, m, n, scale(plus(z_, u, -1.0, n), -1.0, n), ycpy, p); // z_ -> u - z_ and ycpy -> y + aprod(u-z_)
				roilsqr(x, ycpy, v, w, sqrt(rho), p, 0);
				plus(x, z_, -1.0, n); // x update
				
				plus(u, x, 1.0, n); // store u + x in u for the moment
				svt(p->nroi, np, u, z_, uu, ss, vv, lambda/rho); // z -> svt_{lambda/rho}(u+x)
				
				plus(u, z_, -1.0, n); // u -> u + x - z

				r_p = eucdist(x,z_,n);
				r_d = eucdist(z,z_,n);
				e_p = eps_abs*sqrt(n) + 0.5*eps_rel*(sqrt(normsq(z_,n))+sqrt(normsq(x,n)));
				e_d = eps_abs*sqrt(n) + eps_rel*sqrt(normsq(u,n));

				memcpy(z, z_, n*sizeof(double)); // copy contents of z_ into z
				if (show) printf("%d\t%f\t%f\t%f\t%f\n",itn,r_p,e_p,r_d,e_d);
			}

			free(z);
			free(z_);
			free(u);

			free(uu);
			free(ss);
			free(vv);
		}

		free(ycpy);
	}

	free(v);
	free(w);
}

void testlsqr() {
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
	double V[nroi*T];
	for (i=0; i<nroi*T; i++) {
		V[i] = ((double)rand()/(double)RAND_MAX);
	}

	params p;
	p.ndims = 2;
	p.nroi = nroi;
	p.T = T;
	p.isize = isize;
	p.psize = psize;
	p.c = c;
	p.v = V;

	double * y = Malloc(T*isize[0]*isize[1],double);
	for (i=0; i<T*isize[0]*isize[1]; i++) {
		y[i] = ((double)rand()/(double)RAND_MAX);
	}
	double * x = Malloc(nroi*psize[0]*psize[1],double);
	double * v = Malloc(nroi*psize[0]*psize[1],double);
	double * w = Malloc(nroi*psize[0]*psize[1],double);
	struct timeval start, end;
    gettimeofday(&start, NULL);
	aprod(1, T*isize[0]*isize[1], nroi*psize[0]*psize[1], x, y, &p);
    gettimeofday(&end, NULL);
    printf("%ld\n", ((end.tv_sec * 1000000 + end.tv_usec)
		  - (start.tv_sec * 1000000 + start.tv_usec)));
    roilsqr(x,y,v,w,0.0,&p,1);
	free(y);
	free(x);
	free(w);
	free(v);
}

void testsvt() {
	double A[12] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 1.0};
	double U[12];
	double s[3];
	double Vt[9];
	svt(4, 3, A, A, U, s, Vt, 0.1);
	int i;
	for (i = 0; i < 12; i++) {
		printf("%f\n",A[i]);
	}
}

void testadmm() {
	srand(time(NULL));
	int isize[2] = {512,512};
	int psize[2] = {40,40};
	params p;
	p.nroi = 66;
	p.ndims = 2;
	p.T = 725;
	p.isize = isize;
	p.psize = psize;
	int c[p.nroi*p.ndims];
	double v[p.nroi*p.T];

	int i,j;
	for (i = 0; i < p.nroi; i++) {
		for (j = 0; j < p.ndims; j++) {
			c[j + i*p.ndims] = rand() % isize[j];
		}

		for (j = 0; j < p.T; j++) {
			v[j + i*p.T] = ((double)rand()/(double)RAND_MAX);
		}
	}
	p.c = c;
	p.v = v;

	double * x = Malloc(p.nroi*isize[0]*isize[1],double);
	double * y = Malloc(p.T*isize[0]*isize[1],double);
	for (i = 0; i < p.T*isize[0]*isize[1]; i++) y[i] = ((double)rand()/(double)RAND_MAX);
	printf("Data initialized, running ADMM\n");
	roiadmm(x, y, &p, 1.0, 0.0, 1);

	free(x);
	free(y);
}

int main(int argc, char* argv[]) {
	// testlsqr();
	// testsvt();
	testadmm();
	return 0;
}
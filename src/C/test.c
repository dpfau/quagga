#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#ifndef MAT_MUL_MODE_ERROR
#define MAT_MUL_MODE_ERROR 2
#endif

void mul(int mode, int m, int n, double x[], double y[], void *UsrWrk ) {
	// A is a matrix represented in row-major order
	double *A = (double *)UsrWrk;
	int i,j;
	if (mode == 1) {
		for (i = 0; i < m; i++) {
			for (j = 0; j < n; j++) {
				y[i] += A[i + j*m]*x[j];
			}
		}
	} else if (mode == 2) {
		for (i = 0; i < n; i++) {
			for (j = 0; j < m; j++) {
				x[i] += A[j + i*m]*y[j];
			}
		}
	} else {
		exit(MAT_MUL_MODE_ERROR);
	}
}

int main(int argc, char* argv[]) {
	srand(time(NULL));
	const int m = atoi(argv[1]);
	const int n = atoi(argv[2]);
	double A[m*n];
	double x[n];
	double y[m];
	int i;
	for (i = 0; i < m*n; i++) {
		A[i] = rand();
	}
	for (i = 0; i < m; i++) {
		y[i] = rand();
	}
	
	// Declare necessary variables for lsqr
	double damp = 0.0;
    double v[n];
    double w[n];
	double atol = 1e-9;
	double btol = 1e-9;
	double conlim = 1e8;
	int    itnlim = 1000;
	// The remaining variables are output only.
	int    istop_out;
	int    itn_out;
	double anorm_out;
	double acond_out;
	double rnorm_out;
	double arnorm_out;
	double xnorm_out;

	lsqr(m, n, &mul, damp, (void *)A, y, v, w, x, NULL, atol, btol, conlim, itnlim, stdout,
		&istop_out, &itn_out, &anorm_out, &acond_out, &rnorm_out, &arnorm_out, &xnorm_out);

	return 0;
}
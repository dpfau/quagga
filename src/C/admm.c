#include <Accelerate/Accelerate.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <string.h>

#ifndef SVD_ERROR
#define SVD_ERROR 30
#endif

#define Calloc(size,type) (type *) calloc(size, sizeof(type));
#define Malloc(size,type) (type *) malloc(size*sizeof(type));


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

double * times(int m, int n, double x[], double y[], double A[], int zero) {
// y = y + A*x if zero == 0, else
// y = A*x
	int i,j;
	for (i = 0; i < m; i++) {
		if (zero!=0) {
			y[i] = 0;
		}
		for (j = 0; j < n; j++) {
			y[i] += A[i + j*m]*x[j];
		}
	}
	return y;
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

void dump(double x[], int n) {
	int i;
	for (i = 0; i < n; i++) {
		printf("%e\n", x[i]);
	}
}

void svd(int m, int n, double A[], double U[], double s[], double Vt[]) {
	int p = m<n?m:n; // Find the smaller dimension
	// Set LAPACK variables
	double workSize;
    double *work = &workSize;
    int lwork = -1;
    int *iwork = malloc(8*p);
    int info = 0;
	dgesdd_("S", &m, &n, A, &m, s, U, &m, Vt, &p, work, &lwork, iwork, &info);
	if (info) exit(SVD_ERROR);
	lwork = workSize;
	work = malloc(lwork * sizeof *work);

	// Call SVD
	dgesdd_("S", &m, &n, A, &m, s, U, &m, Vt, &p, work, &lwork, iwork, &info);
	if (info) exit(SVD_ERROR);

	// clean up
	free(work);
	free(iwork);
}

void pinv(int m, int n, double A[], double B[], double U[], double s[], double Vt[]) {
// Moore-Penrose Pseudoinverse
// U, s, Vt hold the values of the SVD, and t is the amount to threshold.

	int i,j,k;
	int p = m<n?m:n; // Find the smaller dimension
	memcpy(B,A,m*n*sizeof(double)); // SVD destroys the contents of the original array, so be sure to copy it.
	svd(m, n, B, U, s, Vt);

	// Invert nonzero singular values
	for (i = 0; i < p; i++) {
		if (s[i] > 0.0) {
			s[i] = 1.0/s[i];
		}
	}

	// Fold everything back together (and transpose it).
	for (i = 0; i < m; i++) {
		for (j = 0; j < n; j++) {
			B[j+n*i] = 0;
			for (k = 0; k < p; k++) {
				B[j+n*i] += s[k]*U[i+m*k]*Vt[k+p*j];
			}
		}
	}
}

void svt(int m, int n, double A[], double B[], double U[], double s[], double Vt[], double t) {
// Singular value thresholding operator applied to mxn matrix A, with the result written to B
// U, s, Vt hold the values of the SVD, and t is the amount to threshold.

	int i,j,k;
	int p = m<n?m:n; // Find the smaller dimension
	memcpy(B,A,m*n*sizeof(double)); // SVD destroys the contents of the original array, so be sure to copy it.
	svd(m, n, B, U, s, Vt);

	// Threshold singular values
	for (i = 0; i < p; i++)
		s[i] = (s[i]>t)?s[i]-t:0.0;

	// Fold everything back together
	for (i = 0; i < m; i++) {
		for (j = 0; j < n; j++) {
			B[i+m*j] = 0;
			for (k = 0; k < p; k++) {
				B[i+m*j] += s[k]*U[i+m*k]*Vt[k+p*j];
			}
		}
	}
}

void admm(int m, int n, int p, double x[], double y[], double A[], double lambda, int show) {
// finds argmin_x 1/2||A(x)-y||^2 + lambda*||x||_* via ADMM

	double rho = 100000; // Dual learning rate

	double eps_abs = 1e-3;
	double eps_rel = 1e-3;

	double r_p = DBL_MAX;
	double r_d = DBL_MAX;
	double e_p = 0.0;
	double e_d = 0.0;

	int itnlim = 100;
	int itn = 0;

	double ycpy[m]; // because roilsqr changes y, create a copy of it upfront and rewrite it at each iteration

	double z[n*p]; // Auxiliary variable
	double z_[n*p]; // Keep the aux variable from the last step around for computing the stopping criterion
	double u[n*p]; // Lagrange multiplier (scaled form)

	// allocate space for implementing SVT
	int nsv = n<p?n:p; // number of singular values
	double uu[n*nsv];
	double ss[nsv];
	double vv[p*nsv];

	// allocate space for implementing PINV
	double uuu[(m+(n*p))*(n*p)];
	double sss[n*p];
	double vvv[n*p*n*p];

	double Aeye[(m+(n*p))*n*p]; // pinv([A; eye(n*p)])
	int i,j;
	for (i = 0; i < n*p; i++) {
		for (j = 0; j < m; j++) {
			Aeye[j + i*(m+(n*p))] = A[j + i*m];
		}
	}
	for (i = 0; i < n*p; i++) {
		Aeye[i + m + i*(m+(n*p))] = sqrt(rho);
	}
	pinv(m+(n*p), n*p, Aeye, Aeye, uuu, sss, vvv);

	if (show) printf("Iter:\tr_p\t\te_p\t\tr_d\t\te_d\n");
	while(itn < itnlim && (r_p > e_p || r_d > e_d)) {
		itn++;
		memcpy(ycpy, y, m*sizeof(double));

		times(m, n*p, scale(plus(z_, u, -1.0, n*p), -1.0, n*p), ycpy, A, 0); // z_ -> u - z_ and ycpy -> y + A(u-z_)
		times(n*p, m, ycpy, x, Aeye, 1);
		plus(x, z_, -1.0, n*p); // x update

		plus(u, x, 1.0, n*p); // store u + x in u for the moment
		svt(n, p, u, z_, uu, ss, vv, lambda/rho); // z -> svt_{lambda/rho}(u+x)
		
		plus(u, z_, -1.0, n*p); // u -> u + x - z

		r_p = eucdist(x,z_,n*p);
		r_d = eucdist(z,z_,n*p);
		e_p = eps_abs*sqrt(n*p) + 0.5*eps_rel*(sqrt(normsq(z_,n*p))+sqrt(normsq(x,n*p)));
		e_d = eps_abs*sqrt(n*p) + eps_rel*sqrt(normsq(u,n*p));

		memcpy(z, z_, n*p*sizeof(double)); // copy contents of z_ into z
		if (show) printf("%d\t%f\t%f\t%f\t%f\n",itn,r_p,e_p,r_d,e_d);
	}
}

int main() {
	int m = 512;
	int n = 8;
	int p = 16;

	double A[m*n*p];
	double y[m];
	double x[n*p];
	int i,j,k;
	j = 0;
	k = 1;
	for (i = 0; i < m*n*p; i++) {
		A[i] = j;
		j++;
		if (j == k) {
			j = 0;
			k++;
		}
	}
	for (i = 0; i < m; i++) {
		y[i] = i+1;
	}
	// double U[(m+n*p)*n*p];
	// double S[n*p];
	// double V[n*n*p*p];
	// double Aeye[(m+(n*p))*n*p];
	// for (i = 0; i < n*p; i++) {
	// 	for (j = 0; j < m; j++) {
	// 		Aeye[j + i*(m+(n*p))] = A[j + i*m];
	// 	}
	// 	for (j = 0; j < n*p; j++) {
	// 		if (i==j) {
	// 			Aeye[j + m + i*(m+(n*p))] = sqrt(100000.0);
	// 		} else {
	// 			Aeye[j + m + i*(m+(n*p))] = 0.0;
	// 		}
	// 	}
	// }
	// dump(Aeye,(m+(n*p))*n*p);
	// printf("Hi\n");
	// svd(m+(n*p), n*p, Aeye, U, S, V);
	admm(m,n,p,x,y,A,200000,1);
	return 0;
}
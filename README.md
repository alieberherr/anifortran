# Use ANI neural networks with Fortran

Usage:

#### 1. Clone the repository

`git clone git@github.com:alieberherr/anifortran.git`

#### 2. Setting up

Install `pytorch` and `torchani` with conda:

`conda install pytorch`

`conda install -c conda-forge torchani`

#### 3. Compilation and Running

First, compile the Python library:

`python3 builder.py`

This creates the shared library \texttt{libplugin.so} and the C executable \texttt{my\_plugin.o}. In order for the program to find the library, set the environment variable:

`export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/github/repository`

Now compile the Fortran program:

`gfortran -o run -L./ -lplugin run.f pot.f init.f`

and run

`./run`

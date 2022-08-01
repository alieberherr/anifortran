# Use ANI neural networks with Fortran (for MD)

Usage:

#### 1. Clone the repository

`git clone git@github.com:alieberherr/anifortran.git`

or download the .zip file (click dropdown menu "Code" and select lowest option).

#### 2. Setting up

Make sure you are using a Python version with the python-dev package available (for the C interfacing).
Install `pytorch` and `torchani` with conda:

`conda install pytorch`

`conda install -c conda-forge torchani`

If necessary, install `numpy` and `cffi` with conda:

`conda install numpy`

`conda install cffi`

#### 3. Compilation

First, compile the Python library:

`python3 builder.py`

This creates the shared library `libplugin.so`. Then, create the fortran library `libani.a`:

`gfortran -c anipy2f.f`

`ar rcv libani.a anipy2f.o`

`ranlib libani.a`

For general use, move the libraries to some home directory (eg. $HOME/lib):

`mkdir $HOME/lib`

`mv lib* $HOME/lib`

and create some environment variable which points to the libraries:

`export ani=$HOME/lib/*`

#### 4. Usage

There are two methods, `aninit(s)` and `pot(q,z,v,dvdq)`, which can be used now.

The parameters are:
- `aninit(na,nb,ipot)`
  - `na`: number of atoms
  - `nb`: number of ring polymer beads
  - `ipot`: identifier for NN model (0: ANI-1x, 1: ANI-1ccx, 2: ANI-2x)
- `pot(na,nb,q,z,v,dvdq)`
  - `na`: number of atoms
  - `nb`: number of ring polymer beads
  - `q(3*na,nb)`: coordinates of ring polymer beads
  - `z(na)`: atom numbers
  - `v(nb)`: potential energy of each bead
  - `dvdq(3*na,nb)`: gradient for each bead

Now compile the program (for example named `run.f`)

`gfortran -o run.x run.f $ani`

and run

`./run.x`


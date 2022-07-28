# Use ANI neural networks with Fortran

Usage:

#### 1. Clone the repository

`git clone git@github.com:alieberherr/anifortran.git`

or download the .zip file (click dropdown menu "Code" and select lowest option).

#### 2. Setting up

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

For general use, move the libraries to some home directory (eg. $HOME/lib and set the environment variable $LD_LIBRARY_PATH:

`mkdir $HOME/lib`

`mv lib* $HOME/lib`

`export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH`

#### 4. Usage

There are two methods, `aninit(s)` and `pot(q,z,v,dvdq)`, which can be used now. The file `run.f` has an example program.

The parameters are:
- `aninit(s)`
  - `s(3)`: array of number of atoms, number of beads and identifier for NN model (0: ANI-1x, 1: ANI-1ccx, 2: ANI-2x)
- `pot(q,z,v,dvdq)`
  - `q(nf,nb)`: coordinates of ring polymer beads
  - `z(na)`: atom numbers
  - `v(nb)`: potential energy of each bead
  - `dvdq(nf,nb)`: gradient for each bead

In order for the program to recognise the libraries, we also have to create symbolic links (not happy with this but I couldn't come up with anything better)

`ln -s $HOME/lib/libani.a /path/to/working/directory/libani.a`

`ln -s $HOME/lib/libplugin.so /path/to/working/directory/libplugin.so`


Now compile the program as (using the example program run.f from the repository)

`gfortran -L./ -lplugin -lani -o run run.f`

and run

`./run`

The number of atoms, beads and model can be specified in `run.f`.


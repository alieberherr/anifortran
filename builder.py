import cffi
ffibuilder = cffi.FFI()

header = """
extern void pyaninit(double *);
extern void test_ani(double *,int,double *,int,double *);
"""

module = """
from my_plugin import ffi
import numpy as np
import sys
sys.path.insert(0, ".")
import my_module
import torch
import torchani

@ffi.def_extern()
def pyaninit(s_ptr):
    global na
    global nb
    global device
    global model
    s = my_module.asarray(ffi, s_ptr, shape=(3,))
    na = int(s[0])
    nb = int(s[1])
    imod = int(s[2])
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    if (imod==0):
        print("Initialising model ANI-1x")
        model = torchani.models.ANI1x(periodic_table_index=True).to(device)
    elif (imod==1):
        print("Initialising model ANI-1ccx")
        model = torchani.models.ANI1ccx(periodic_table_index=True).to(device)
    elif (imod==2):
        print("Initialising model ANI-2x")
        model = torchani.models.ANI2x(periodic_table_index=True).to(device)
    else:
        raise ValueError("invalid model, imod=%i"%imod)

@ffi.def_extern()
def test_ani(q_ptr,n,z_ptr,m,out_ptr):
    # fetch the arrays via pointers and change to the right types
    q = my_module.asarray(ffi, q_ptr, shape=(nb,na,3,)).tolist()
    z = my_module.asarray(ffi, z_ptr, shape=(1,na,)).tolist()
    out = my_module.asarray(ffi, out_ptr, shape=(nb,3*na+1,))
    z = [[int(tmp) for tmp in z[0]]]*nb
    print("q (0):",q[0])
    print("q (1):",q[1])
    print("z:",z)
    # set up NN calculation and run it
    coordinates = torch.tensor(q,requires_grad=True, device=device)
    species = torch.tensor(z,device=device)
    # collect results
    energy = model((species, coordinates)).energies
    derivative = torch.autograd.grad(energy.sum(), coordinates)[0]
    force = -derivative
    print("force:",force)
    print("force 1:",force.squeeze()[0])
    print("force 2:",force.squeeze()[1])
    # move results into output array
    for j in range(nb):
        out[j,0] = energy[j].item()
        for i in range(na):
            out[j,3*i+1] = force.squeeze()[j,i,0]
            out[j,3*i+2] = force.squeeze()[j,i,1]
            out[j,3*i+3] = force.squeeze()[j,i,2]
"""

with open("plugin.h", "w") as f:
    f.write(header)

ffibuilder.embedding_api(header)
ffibuilder.set_source("my_plugin", r'''
    #include "plugin.h"
''')

ffibuilder.embedding_init_code(module)
ffibuilder.compile(target="libplugin.so", verbose=True)

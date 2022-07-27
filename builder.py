import cffi
ffibuilder = cffi.FFI()

header = """
extern void init(void);
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
def init():
    global na
    global device
    global model
    na = 5
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = torchani.models.ANI2x(periodic_table_index=True).to(device)

@ffi.def_extern()
def test_ani(q_ptr,n,z_ptr,m,out_ptr):
    # fetch the arrays via pointers and change to the right types
    q = my_module.asarray(ffi, q_ptr, shape=(1,na,3,)).tolist()
    z = my_module.asarray(ffi, z_ptr, shape=(1,na,)).tolist()
    out = my_module.asarray(ffi, out_ptr, shape=(1,3*na+1,))
    z = [[int(tmp) for tmp in z[0]]]
    # set up NN calculation and run it
    coordinates = torch.tensor(q,requires_grad=True, device=device)
    species = torch.tensor(z,device=device)
    # collect results
    energy = model((species, coordinates)).energies
    derivative = torch.autograd.grad(energy.sum(), coordinates)[0]
    force = -derivative
    # move results into output array
    out[0,0] = energy.item()
    for i in range(na):
        out[0,3*i+1] = force.squeeze()[i,0]
        out[0,3*i+2] = force.squeeze()[i,1]
        out[0,3*i+3] = force.squeeze()[i,2]
"""

with open("plugin.h", "w") as f:
    f.write(header)

ffibuilder.embedding_api(header)
ffibuilder.set_source("my_plugin", r'''
    #include "plugin.h"
''')

ffibuilder.embedding_init_code(module)
ffibuilder.compile(target="libplugin.so", verbose=True)

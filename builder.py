import cffi
ffibuilder = cffi.FFI()
import os

header = """
extern void caninit(double *);
extern void canipot(double *,int,double *,int,double *);
extern void canihes(double *,int,double *,int,double *,int,double *);
"""

module = """
from my_plugin import ffi
import numpy as np
import sys
sys.path.insert(0, ".")
import torch
import torchani
######## MODULE: MY_MODULE
import numpy as np

# Create the dictionary mapping ctypes to np dtypes.
ctype2dtype = {}
# Integer types
for prefix in ('int', 'uint'):
    for log_bytes in range(4):
        ctype = '%s%d_t' % (prefix, 8 * (2**log_bytes))
        dtype = '%s%d' % (prefix[0], 2**log_bytes)
        # print( ctype )
        # print( dtype )
        ctype2dtype[ctype] = np.dtype(dtype)

# Floating point types
ctype2dtype['float'] = np.dtype('f4')
ctype2dtype['double'] = np.dtype('f8')


def asarray(ffi, ptr, shape, **kwargs):
    length = np.prod(shape)
    # Get the canonical C type of the elements of ptr as a string.
    T = ffi.getctype(ffi.typeof(ptr).item)
    # print( T )
    # print( ffi.sizeof( T ) )

    if T not in ctype2dtype:
        raise RuntimeError("Cannot create an array for element type: %s" % T)

    a = np.frombuffer(ffi.buffer(ptr, length * ffi.sizeof(T)), ctype2dtype[T])\
          .reshape(shape, **kwargs)
    return a


@ffi.def_extern()
def caninit(s_ptr):
    global na
    global nb
    global device
    global model
    s = asarray(ffi, s_ptr, shape=(3,))
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
def canipot(q_ptr,n,z_ptr,m,out_ptr):
    # fetch the arrays via pointers and change to the right types
    q = asarray(ffi, q_ptr, shape=(nb,na,3,)).tolist()
    z = asarray(ffi, z_ptr, shape=(1,na,)).tolist()
    out = asarray(ffi, out_ptr, shape=(nb,3*na+1,))
    z = [[int(tmp) for tmp in z[0]]]*nb
    # set up NN calculation and run it
    coordinates = torch.tensor(q,requires_grad=True, device=device)
    species = torch.tensor(z,device=device)
    # collect results
    energy = model((species, coordinates)).energies
    derivative = torch.autograd.grad(energy.sum(), coordinates)[0]
    # move results into output array
    for j in range(nb):
        out[j,0] = energy[j].item()
        for i in range(na):
            out[j,3*i+1] = derivative[j].squeeze()[i,0]
            out[j,3*i+2] = derivative[j].squeeze()[i,1]
            out[j,3*i+3] = derivative[j].squeeze()[i,2]

@ffi.def_extern()
def canihes(q_ptr,n,z_ptr,m,out_ptr,l,out2_ptr):
    # fetch the arrays via pointers and change to the right types
    q = asarray(ffi, q_ptr, shape=(nb,na,3,)).tolist()
    z = asarray(ffi, z_ptr, shape=(1,na,)).tolist()
    out = asarray(ffi, out_ptr, shape=(nb,3*na+1,))
    out2 = asarray(ffi, out2_ptr, shape=(nb,3*na,3*na,))
    z = [[int(tmp) for tmp in z[0]]]*nb
    # set up NN calculation and run it
    coordinates = torch.tensor(q,requires_grad=True, device=device)
    species = torch.tensor(z,device=device)
    # collect results
    energy = model((species, coordinates)).energies
    derivative = torch.autograd.grad(energy.sum(), coordinates)[0]
    energy = model((species, coordinates)).energies
    hessian = torchani.utils.hessian(coordinates, energies=energy)
    # move results into output array
    for j in range(nb):
        out[j,0] = energy[j].item()
        for i in range(na):
            out[j,3*i+1] = derivative[j].squeeze()[i,0]
            out[j,3*i+2] = derivative[j].squeeze()[i,1]
            out[j,3*i+3] = derivative[j].squeeze()[i,2]
        for i in range(3*na):
            for k in range(3*na):
                out2[j,i,k] = hessian[j].squeeze()[i,k].item()
"""

with open("plugin.h", "w") as f:
    f.write(header)

ffibuilder.embedding_api(header)
ffibuilder.set_source("my_plugin", r'''
    #include "plugin.h"
''')

ffibuilder.embedding_init_code(module)
ffibuilder.compile(target="libplugin.so", verbose=True)
os.system('rm my_plugin.* plugin.h')

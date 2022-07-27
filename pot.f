        subroutine pot(q,z,v,dvdq)
        use, intrinsic :: iso_c_binding
        implicit double precision (a-h,o-z)
        common /arrays/ na,nf
        dimension q(nf),z(na),dvdq(nf),res(nf+1)
c
c       Calculate potential by evaluating the NN ANI
c
        interface
          subroutine test_ani(q_c,n,z_c,m,res_c,l) bind (c)
          use iso_c_binding
          integer(c_int) :: n,m,l
          real(c_double) :: q_c(n),z_c(m),res_c(l)
          end subroutine test_ani
        end interface
        call test_ani(q,size(q),z,size(z),res,size(res))
        v = res(1)
        dvdq = res(2:nf+1)
        end

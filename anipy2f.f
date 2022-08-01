      subroutine aninit(na,nb,ipot)
      use, intrinsic :: iso_c_binding
      implicit double precision (a-h,o-z)
      dimension s(3)
c
c     Initialises the data for the NN
c
      interface
      subroutine caninit(s_c,n) bind (c)
        use iso_c_binding
        integer(c_int) :: n
        real(c_double) :: s_c(n)
      end subroutine caninit
      end interface
      s(1) = na
      s(2) = nb
      s(3) = ipot
      call caninit(s,size(s))
      end

      subroutine anipot(na,nb,q,z,v,dvdq)
      use, intrinsic :: iso_c_binding
      implicit double precision (a-h,o-z)
      dimension q(3*na,nb),z(na),dvdq(3*na,nb),res(3*na+1,nb),
     &          v(nb)
c
c     Calculate potential by evaluating the NN ANI
c
      interface
      subroutine canipot(q_c,n,z_c,m,res_c,l) bind (c)
        use iso_c_binding
        integer(c_int) :: n,m,l
        real(c_double) :: q_c(n),z_c(m),res_c(l)
      end subroutine canipot
      end interface
      print *,"anipot> na,nb",na,nb
      call canipot(q,size(q),z,size(z),res,size(res))
      v = res(1,:)
      dvdq = res(2:3*na+1,:)
      end

      subroutine anihes(na,nb,q,z,v,dvdq,d2vdq2)
      implicit double precision (a-h,o-z)
      dimension q(3*na,nb),z(na),v(nb),dvdq(3*na,nb),
     &          d2vdq2(3*na,3*na,nb),res(3*na+1,nb),
     &          res2(3*na,3*na,nb)
c
c     Calculate hessian by evaluating the NN ANI
c
      interface
      subroutine canihes(q_c,n,z_c,m,res_c,l,res2_c,k) bind(c)
        use iso_c_binding
        integer(c_int) :: n,m,l,k
        real(c_double) :: q_c(n),z_c(m),res_c(l),res2_c(k)
      end subroutine canihes
      end interface
      call canihes(q,size(q),z,size(z),res,size(res),res2,size(res2))
      v = res(1,:)
      dvdq = res(2:3*na+1,:)
      d2vdq2 = res2
      end

      subroutine aninit(s)
      use, intrinsic :: iso_c_binding
      implicit double precision (a-h,o-z)
      dimension s(3)
c
c     Initialises the data for the NN
c
      interface
      subroutine pyaninit(s_c,n) bind (c)
        use iso_c_binding
        integer(c_int) :: n
        real(c_double) :: s_c(n)
      end subroutine pyaninit
      end interface
      call pyaninit(s,size(s))
      end

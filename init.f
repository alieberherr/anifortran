      subroutine finit()
      use, intrinsic :: iso_c_binding
      implicit double precision (a-h,o-z)
      interface
      subroutine init() bind (c)
      end subroutine init
      end interface
c
c     Initialises the data for the NN
c
      call init()
      end subroutine finit

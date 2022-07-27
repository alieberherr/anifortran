      program test
      use, intrinsic :: iso_c_binding
      implicit double precision (a-h,o-z)
      common /arrays/ na,nf

      allocatable :: q(:),z(:),dvdq(:)

      na = 5
      nf = 3*na     
 
      allocate(q(nf),z(na),dvdq(nf))
c     methane
      q(1) = 0.03192167
      q(2) = 0.00638559
      q(3) = 0.01301679
      q(4) = -0.83140486
      q(5) = 0.39370209
      q(6) = -0.26395324
      q(7) = -0.66518241
      q(8) = -0.84461308
      q(9) = 0.20759389
      q(10) = 0.45554739
      q(11) = 0.54289633
      q(12) = 0.81170881
      q(13) = 0.66091919
      q(14) = -0.16799635
      q(15) = -0.91037834

      z(1) = 6
      z(2) = 1
      z(3) = 1
      z(4) = 1
      z(5) = 1
     
      call finit()
      print *,"TESTING SUBROUTINE" 
      call pot(q,z,v,dvdq)
      print *,"Energy:"
      print "(f20.10)",v
      print *,"Force:"
      print "(3f20.10)",dvdq

      end program test

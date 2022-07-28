      program test
      use, intrinsic :: iso_c_binding
      implicit double precision (a-h,o-z)
      common /arrays/ na,nf,nb
      allocatable :: q(:,:),z(:),dvdq(:,:),s(:),
     &               v(:)
c
c     Test the subroutines for evaluating the NN
c
      na = 5
      nb = 3
      nf = 3*na
      imod = 1
      allocate(q(nf,nb),z(na),dvdq(nf,nb),v(nb),s(3))
c
c     initialise a geometry for methane and the
c     atomic numbers
c
      s(1) = na
      s(2) = nb
      s(3) = imod

      do ib=1,nb
        q(1,ib) = 0.03192167 + (ib-1)*0.01
        q(2,ib) = 0.00638559 + (ib-1)*0.01
        q(3,ib) = 0.01301679 + (ib-1)*0.01
        q(4,ib) = -0.83140486
        q(5,ib) = 0.39370209
        q(6,ib) = -0.26395324
        q(7,ib) = -0.66518241
        q(8,ib) = -0.84461308
        q(9,ib) = 0.20759389
        q(10,ib) = 0.45554739
        q(11,ib) = 0.54289633
        q(12,ib) = 0.81170881
        q(13,ib) = 0.66091919
        q(14,ib) = -0.16799635
        q(15,ib) = -0.91037834
      enddo
      z(1) = 6
      z(2) = 1
      z(3) = 1
      z(4) = 1
      z(5) = 1

      dvdq = 0.d0 
      call aninit(s)
      call pot(q,z,v,dvdq)
      print *,"Energy:"
      print "(f20.10)",v
      do ib=1,nb
        print *,"Force",ib
        print "(3f20.10)",dvdq(:,ib)
      enddo

      end program test

      program test
      use, intrinsic :: iso_c_binding
      implicit double precision (a-h,o-z)
      allocatable :: q(:,:),z(:),dvdq(:,:),v(:),d2vdq2(:,:,:)
      character(len=3) geom
      character(len=10) atm
c
c     Test the subroutines for evaluating the NN
c
      namelist /input/ na,nb,ipot,geom
      read(5,input)
      nf = 3*na
      allocate(q(nf,nb),z(na),dvdq(nf,nb),d2vdq2(nf,nf,nb),v(nb))
c
c     initialise a geometry for methane and the
c     atomic numbers
c

      call read_geom(na,nb,q,z,geom)

      do ib=1,nb
        print *,"Geom",ib
        print "(3f20.10)",q(:,ib)
      enddo
      print *,"Atom types:"
      print *,z

      call aninit(na,nb,ipot)
      call anipot(na,nb,q,z,v,dvdq)
      call anihes(na,nb,q,z,v,dvdq,d2vdq2)
      print *,"Energy:"
      print "(f20.10)",v
      do ib=1,nb
        print *,"Force",ib
        print "(3f20.10)",dvdq(:,ib)
        print *,"Hessian",ib
        write(atm,"(a1,i2,a)") "(",3*na,"f20.10)"
        print atm,d2vdq2(:,:,ib)
      enddo

      end program test

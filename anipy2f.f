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

      subroutine read_geom(na,nb,q,z,geom)
      implicit double precision (a-h,o-z)
      character(len=3) geom
      character(len=100) line
      dimension q(3*na,nb),z(na)
c
c     Reads geometry from file "geom.xyz" or "geom.sdf"
c     and defines the array z
c
      if (geom.eq.'xyz') then
        open(unit=9,file="geom.xyz")
        read(9,"(i10)") nax
        print *,"expected no. atoms:",na
        print *,"actual no. atoms:",nax
        if (na.ne.nax) stop "read_geom> invalid geometry?"
        read(9,"(a)") line
        do ia=1,na
          read(9,"(a)") line
          ! atom: we're only interested in C,H,N,O systems
          if (line(1:1).eq."C") then
            z(ia) = 6
          elseif (line(1:1).eq."H") then
            z(ia) = 1
          elseif (line(1:1).eq."N") then
            z(ia) = 7
          elseif (line(1:1).eq."O") then
            z(ia) = 8
          else
            stop "read_geom> invalid atom type"
          endif
          ! coordinates
          ioff = 2
          do i=1,3
            do while (line(ioff:ioff).eq." ")
              ioff = ioff+1
            enddo
            iend = ioff
            do while (line(iend:iend).ne." ")
              iend = iend+1
            enddo
            read(line(ioff:iend),*) tmp
            do ib=1,nb
              q(3*(ia-1)+i,ib) = tmp
            enddo
            ioff = iend
          enddo
        enddo
        close(9)
      elseif (geom.eq.'sdf') then
        open(unit=9,file="geom.sdf")
        read(9,"(a)") line
        read(9,"(a)") line
        read(9,"(a)") line
        read(9,"(i3)") nax
        print *,"expected no. atoms:",na
        print *,"actual no. atoms:",nax
        if (na.ne.nax) stop "read_geom> invalid geometry?"
        do ia=1,na
          read(9,"(a)") line
          ioff = 1
          do i=1,3
            do while (line(ioff:ioff).eq." ")
              ioff = ioff+1
            enddo
            iend = ioff
            do while (line(iend:iend).ne." ")
              iend = iend+1
            enddo
            read(line(ioff:iend),*) tmp
            do ib=1,nb
              q(3*(ia-1)+i,ib) = tmp
            enddo
            ioff = iend
          enddo
          ioff = ioff+1
          if (line(ioff:ioff).eq."C") then
            z(ia) = 6
          elseif (line(ioff:ioff).eq."H") then
            z(ia) = 1
          elseif (line(ioff:ioff).eq."N") then
            z(ia) = 7
          elseif (line(ioff:ioff).eq."O") then
            z(ia) = 8
          else
            stop "read_geom> invalid atom type"
          endif
        enddo
        close(9)
      else
        print *,"file type:",geom
        stop "read_geom> unknown file type: "
      endif
      end


python3 builder.py
gfortran -c anipy2f.f
ar rcv libani.a anipy2f.o
ranlib libani.a
rm anipy2f.o
mv lib* ~/lib/

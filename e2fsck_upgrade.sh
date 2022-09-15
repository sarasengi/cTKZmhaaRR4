cd /root/
wget -4 https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.46.5/e2fsprogs-1.46.5.tar.gz --no-check-certificate
tar -xf e2fsprogs-1.46.5.tar.gz
cd e2fsprogs-1.46.5
./configure
make
make install

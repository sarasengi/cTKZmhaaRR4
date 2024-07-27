cd /root/
wget -4 https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.47.1/e2fsprogs-1.47.1.tar.gz --no-check-certificate
tar -xf e2fsprogs-1.47.1.tar.gz
cd e2fsprogs-1.47.1
./configure
make
make install

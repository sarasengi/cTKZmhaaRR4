cd /root/
wget -4 https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.46.2/e2fsprogs-1.46.2.tar.gz
tar -xf e2fsprogs-1.46.2.tar.gz
cd e2fsprogs-1.46.2/
./configure
make
make install

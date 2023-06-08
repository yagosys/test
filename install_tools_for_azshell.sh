cd $HOME
mkdir $HOME/bin -p
curl -OfL https://udomain.dl.sourceforge.net/project/netcat/netcat/0.7.1/netcat-0.7.1.tar.gz
tar xvf netcat-0.7.1.tar.gz
cd netcat-0.7.1
./configure --prefix=$(pwd)
make && cp ./src/netcat ./../nc 
cd ./../
./nc --version
cp ./nc $HOME/bin
export PATH=$PATH:$HOME/bin
echo export PATH=$PATH:$HOME/bin | tee -a $HOME/.bashrc
echo alias "k=kubectl" | tee -a $HOME/.bashrc
source $HOME/.bashrc

# define environments for all users 

# User specific environment 

export PATH=$PATH:/opt/usr/bin
export HISTFILESIZE=10000
export HISTSIZE=2000
PS1='`basename \w`\$ '
export RAMDISK="/mnt/RAMDISK"
export ramdisk="/mnt/ramdisk"

# java setup
export JAVA_HOME=/opt/java/jdk
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
export UNZIP="-O gb18030"
export ZIPINFO="-O gb18030"

export PATH=$PATH:/opt/gcc/bin
alias go=/usr/local/go/bin/go
export GOROOT=/usr/local/go
export GOBIN=$GOROOT/bin
export PATH=$PATH:$GOBIN
export GOPATH=$HOME/gopath:~/Desktop/work
if [ `pwd` = $HOME ]; 
then
    cd $RAMDISK 
fi

export CUBRID=/home/cubrid/CUBRID
export CUBRID_DATABASES=$CUBRID/databases
if [ ! -z $LD_LIBRARY_PATH ]; then
  export LD_LIBRARY_PATH=$CUBRID/lib:$LD_LIBRARY_PATH
else
  export LD_LIBRARY_PATH=$CUBRID/lib
fi
export SHLIB_PATH=$LD_LIBRARY_PATH
export LIBPATH=$LD_LIBRARY_PATH
export PATH=$CUBRID/bin:$PATH

export TMPDIR=$CUBRID/tmp
export CUBRID_TMP=$CUBRID/var/CUBRID_SOCK

export JAVA_HOME=/usr/lib/jvm/java
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.
export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64:$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH

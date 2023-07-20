#!/bin/sh


module=cmem;
build_dir=build;
src_file=./${module}.pyx;
cpp_file=./${build_dir}/${module}.cpp;
obj_file=./${build_dir}/${module}.o;
so_file=./${build_dir}/${module}.so;

path_tmp=`python26 -c "import sys; print sys.prefix"`;
python_inc=${path_tmp}/include/python2.6/;
python_pkg=${path_tmp}/lib/python2.6/site-packages/;

cmem_version=asn1.3_v3.0.13_20130509
cmem_inc=./trmem_api_x32_${cmem_version};
cmem_lib=./trmem_api_x32_${cmem_version};

if uname -a | grep "x86_64";
then
    cmem_inc=./trmem_api_x64_${cmem_version};
    cmem_lib=./trmem_api_x64_${cmem_version};
    #echo $cmem_inc
fi

#--------------------------------------------------------
build()
{
    if [ ! -d ${build_dir} ];
    then
        mkdir ${build_dir};
    fi
    cython --cplus ${src_file} -o ${cpp_file};
    g++ -pthread -g -Wall -fPIC -I${python_inc} -I${cmem_inc} -c ${cpp_file} -o ${obj_file};
    g++ -pthread -shared ${obj_file} -L${cmem_lib} -ltrmem -lasn1c++ -lqos_client -o ${so_file};

}

install()
{
    cp ${so_file} ${python_pkg};
}


clean()
{
    if [ -e ${build_dir} ];
    then
        rm -rf ${build_dir};
    fi
    
    if [ -e dist ];
    then
        rm -rf dist;
    fi
    
    if [ -e cmem.cpp ];
    then
        rm cmem.cpp;
    fi
    
    if [ -e MANIFEST ];
    then
        rm MANIFEST;
    fi
}

#--------------------------------------------------------

case $1 in
    build)
        echo "start build..........";
        build;
        ;;
    install)
        echo "start build..........";
        build;
        install;
        ;;        
    clean)
        echo "start clean..........";
        clean;
        ;;
    *)
        echo " Usage: $0 { build | install | clean }";
esac

exit 0


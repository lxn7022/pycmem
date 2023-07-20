
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import platform

cmem_version='asn1.3_v3.0.13_20130509'
libpath = './trmem_api_x32_' + cmem_version
if platform.uname()[-1] == 'x86_64':
    libpath = './trmem_api_x64_' + cmem_version
    
setup(
    name = "cmem",
    version='1.1.0',
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
        Extension("cmem", 
                  ["cmem.pyx"],
                  language = "c++",
                  include_dirs = [libpath],
                  library_dirs = [libpath],
                  libraries =["trmem","asn1c++","qos_client"]
        )
    
    ]
)



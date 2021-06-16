from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize
import numpy as np
import os
import platform

libraries = {
    "Linux": [],
    "Windows": [],
}
language = "c"
args = ["-w", "-std=c11", "-O3", "-ffast-math", "-march=native"]#, "-no-pie"]
include_dirs = [np.get_include(), "./kmercy/libs/include"]
library_dirs = ["./kmercy/libs/shared"]
macros = [
    #("CYTHON_TRACE", "1"),
]

annotate = True
quiet = False
directives = {
    "binding": True,
    "boundscheck": False,
    "cdivision": True,
    "initializedcheck": False,
    "language_level": "3",
    #"linetrace": True,
    "nonecheck": False,
    #"profile": True,
    "wraparound": False,
}

data_files = {}

if __name__ == "__main__":
    system = platform.system()
    libs = libraries[system]
    extensions = []
    ext_modules = []
    
    #create extensions
    for path, dirs, file_names in os.walk("."):
        for file_name in file_names:
            if file_name.endswith("pyx"):
                ext_path = "{0}/{1}".format(path, file_name)
                ext_name = ext_path \
                    .replace("./", "") \
                    .replace("/", ".") \
                    .replace(".pyx", "")
                ext = Extension(
                    name=ext_name, 
                    sources=[ext_path], 
                    libraries=libs,
                    language=language,
                    extra_compile_args=args,
                    include_dirs=include_dirs,
                    library_dirs=library_dirs,
                    runtime_library_dirs=library_dirs,
                    define_macros=macros,
                )
                extensions.append(ext)
    
    #setup all extensions
    ext_modules = cythonize(
        extensions, 
        annotate=annotate, 
        compiler_directives=directives,
        quiet=quiet
    )

    setup(
        install_requires=["cython", "numpy", "setuptools"],
        packages=find_packages(),
        package_data=data_files,
        ext_modules=ext_modules,
    )

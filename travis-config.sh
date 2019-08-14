#!/bin/bash

# See:
# http://dirk.eddelbuettel.com/blog/2017/11/27/
# https://www.jumpingrivers.com/blog/speeding-up-package-installation/
# https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/script/r.rb
echo 'Running travis setup'

mkdir $HOME/.R

echo -e 'CXX_STD = CXX14\n\nVER=\nCCACHE=ccache\nCC=$(CCACHE) gcc$(VER) -std=gnu99\nCXX=$(CCACHE) g++$(VER)\nC11=$(CCACHE) g++$(VER)\nC14=$(CCACHE) g++$(VER)\nFC=$(CCACHE) gfortran$(VER)\nF77=$(CCACHE) gfortran$(VER)\n' > $HOME/.R/Makevars
echo 'max_size = 5.0G\n# important for R CMD INSTALL *.tar.gz as tarballs are expanded freshly -> fresh ctime\nsloppiness = include_file_ctime\n# also important as the (temp.) directory name will differ\nhash_dir = false' > ~/.ccache/ccache.conf

CORES=`Rscript -e "getOption('Ncpus', 1L)"`
echo "Existing Ncpus: $CORES"

CORES=`Rscript -e "parallel::detectCores()"`
echo "Detected Cores: $CORES"

CORES=2
echo "options(Ncpus = ${CORES})" >> ~/.Rprofile
CORES=`Rscript -e "getOption('Ncpus', 1L)"`
echo "Final Ncpus: $CORES"


# Note: this is a hack.  Add Bioconductor repos to default repos, so install.packages will pick them up.
if [ -e ~/.Rprofile ];then
    echo 'Rprofile exists:'
    cat ~/.Rprofile
fi

# Log repos to ensure Bioconductor used:
cat "options(repos = BiocManager::repositories(version = 'devel'))" >> ~/.Rprofile
cat "options(repos = BiocManager::repositories(version = 'devel'))" >> ~/.Rprofile.site

echo 'R repos:'
Rscript -e "getOption('repos')"
echo "Bioconductor repos:"
Rscript -e "BiocManager::repositories(version = 'devel')"
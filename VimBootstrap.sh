#!/bin/sh

VIMDIR=`/bin/pwd`
RTDIR=$VIMDIR/vim80
BINDIR=$VIMDIR/bin
MASTER=archive/master/master.tar.gz

pushd $VIMDIR

# Prepare directory
rm -rf $RTDIR $BINDIR
mkdir -p $BINDIR

# Vim
VIMGZ=vim-master.tar.gz
curl -L https://github.com/vim/vim/$MASTER -o $VIMGZ
tar xvfz $VIMGZ
pushd vim-master
./configure --prefix=/usr --localstatedir=/var/lib/vim --with-features=huge --with-x=yes --disable-gui --enable-multibyte --enable-pythoninterp=dynamic --enable-python3interp=dynamic --enable-luainterp=dynamic --disable-netbeans --disable-gpm --disable-sysmouse --disable-nls
make
popd
mv vim-master/runtime $RTDIR
mv vim-master/src/vim $RTDIR
mv vim-master/src/xxd/xxd $RTDIR
rm -r vim-master*

# Dotfiles
DOTFILESGZ=dotfiles-master.tar.gz
curl -L https://github.com/psicopep/dotfiles/$MASTER -o $DOTFILESGZ
tar xvfz $DOTFILESGZ
mv dotfiles-master/vim/* .
rm -r dotfiles-master*

# Make Vim use our vimrc
echo "#!/bin/sh" > $BINDIR/vim
echo "VIM=$RTDIR exec $RTDIR/vim -u $VIMDIR/_vimrc \"\$@\"" >> $BINDIR/vim
chmod 500 $BINDIR/vim

# Link xxd from bin directory
ln -s $RTDIR/xxd $BINDIR/xxd

# Install ag
AGGZ=the_silver_searcher-master.tar.gz
curl -L https://github.com/ggreer/the_silver_searcher/$MASTER -o $AGGZ
tar xvfz $AGGZ
pushd the_silver_searcher-master
./build.sh
popd
cp the_silver_searcher-master/ag $BINDIR
rm -r the_silver_searcher-master*

# Install ctags
CTAGSGZ=ctags-5.8.tar.gz
curl -L http://prdownloads.sourceforge.net/ctags/$CTAGSGZ -o $CTAGSGZ
tar xvfz $CTAGSGZ
pushd ctags-5.8
./configure
make
popd
cp ctags-5.8/ctags $BINDIR
rm -rf ctags-5.8*

# Install plugins
$BINDIR/vim -S BundleMan.vim

popd

#!/bin/sh

VIMDIR=`/bin/pwd`
RTDIR=$VIMDIR/vimdist
BINDIR=$VIMDIR/bin
MASTER=archive/master/master.tar.gz

pushd $VIMDIR

# Prepare directory
rm -rf $RTDIR $BINDIR
mkdir -p $BINDIR

# Vim
VIMGZ=vim-master.tar.gz
if [ ! -e $VIMGZ ]; then
    curl -L https://github.com/vim/vim/tarball/master -o $VIMGZ
fi
mkdir vim-master
tar xvfz $VIMGZ -C vim-master --strip-components 1
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
if [ ! -e $DOTFILESGZ ]; then
    curl -L https://github.com/psicopep/dotfiles/tarball/master -o $DOTFILESGZ
fi
mkdir dotfiles-master
tar xvfz $DOTFILESGZ -C dotfiles-master --strip-components 1
mv dotfiles-master/vim/* .
rm -r dotfiles-master*

# Make Vim use our vimrc
echo "#!/bin/sh" > $BINDIR/vim
echo "PATH=$BINDIR:\$PATH VIM=$RTDIR exec $RTDIR/vim -Nu $VIMDIR/_vimrc \"\$@\"" >> $BINDIR/vim
chmod 500 $BINDIR/vim

# Link xxd from bin directory
ln -s $RTDIR/xxd $BINDIR/xxd

# Install ripgrep
RGGZ=ripgrep-0.8.1-x86_64-unknown-linux-musl.tar.gz
if [ ! -e $RGGZ ]; then
    curl -L https://github.com/BurntSushi/ripgrep/releases/download/0.8.1/$RGGZ -o $RGGZ
fi
tar xvfz $RGGZ
cp ripgrep-0.8.1-x86_64-unknown-linux-musl/rg $BINDIR
rm -r ripgrep-0.8.1-x86_64-unknown-linux-musl*

# Install ctags
CTAGSGZ=ctags-5.8.tar.gz
if [ ! -e $CTAGSGZ ]; then
    curl -L http://prdownloads.sourceforge.net/ctags/$CTAGSGZ -o $CTAGSGZ
fi
tar xvfz $CTAGSGZ
pushd ctags-5.8
./configure
make
popd
cp ctags-5.8/ctags $BINDIR
rm -rf ctags-5.8*

# Install plugins
$BINDIR/vim -N -u NONE -S BundleMan.vim

popd

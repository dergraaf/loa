VHDL_VERSION="3.34.2"

# Path including the version number
EMACS_PREFIX=`dirname /usr/share/emacs/??.?/lisp`

wget http://www.iis.ee.ethz.ch/~zimmi/emacs/vhdl-mode-${VHDL_VERSION}.tar.gz
tar xzvf vhdl-mode-${VHDL_VERSION}.tar.gz
cd vhdl-mode-${VHDL_VERSION}/
sudo cp ${EMACS_PREFIX}/lisp/progmodes/vhdl-mode.elc ${EMACS_PREFIX}/lisp/progmodes/vhdl-mode.elc.bak
mv vhdl-mode.elc vhdl-mode.elc.bak
emacs --batch --eval "(byte-compile-file \"vhdl-mode.el\")"
sudo cp vhdl-mode.elc ${EMACS_PREFIX}/lisp/progmodes/
cd ..
rm -r vhdl-mode-${VHDL_VERSION}/
rm vhdl-mode-${VHDL_VERSION}.tar.gz


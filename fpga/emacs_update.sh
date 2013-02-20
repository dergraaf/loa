VHDL_VERSION="3.34.2"
EMACS_VERSION="23.3"

wget http://www.iis.ee.ethz.ch/~zimmi/emacs/vhdl-mode-${VHDL_VERSION}.tar.gz
tar xzvf vhdl-mode-${VHDL_VERSION}.tar.gz
cd vhdl-mode-${VHDL_VERSION}/
sudo cp /usr/share/emacs/${EMACS_VERSION}/lisp/progmodes/vhdl-mode.elc /usr/share/emacs/${EMACS_VERSION}/lisp/progmodes/vhdl-mode.elc.bak
mv vhdl-mode.elc vhdl-mode.elc.bak
emacs --batch --eval "(byte-compile-file \"vhdl-mode.el\")"
sudo cp vhdl-mode.elc /usr/share/emacs/${EMACS_VERSION}/lisp/progmodes/
cd ..
rm -r vhdl-mode-${VHDL_VERSION}/
rm vhdl-mode-${VHDL_VERSION}.tar.gz

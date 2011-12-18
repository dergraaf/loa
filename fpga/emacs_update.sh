wget http://www.iis.ee.ethz.ch/~zimmi/emacs/vhdl-mode-3.33.28.tar.gz
tar xzvf vhdl-mode-3.33.28.tar.gz
cd vhdl-mode-3.33.28/
sudo cp /usr/share/emacs/23.2/lisp/progmodes/vhdl-mode.elc /usr/share/emacs/23.2/lisp/progmodes/vhdl-mode.elc.bak
mv vhdl-mode.elc vhdl-mode.elc.bak
emacs --batch --eval "(byte-compile-file \"vhdl-mode.el\")"
sudo cp vhdl-mode.elc /usr/share/emacs/23.2/lisp/progmodes/
cd ..
rm -r vhdl-mode-3.33.28/
rm vhdl-mode-3.33.28.tar.gz


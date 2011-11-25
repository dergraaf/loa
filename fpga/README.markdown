File structure goes like this:

    |
    +- modules-\        is for the HDL level code 
    |          |
    |          +- <module name> -\
    |          |                 |
    |                            +- hdl    for HDL sources 
    |                            |
    |                            +- tb     for testbenches
    |
    \- toplevel -\
                 |
                 +- <target> -\
                 |            |
                              +- ISE    ISE Project goes here.
                              |
                              \- ...    implementation files (toplevel.vhd, board.ucf, ..)



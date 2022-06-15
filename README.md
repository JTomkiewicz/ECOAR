# Description

Computer architecture was the second most challenging subject for me during my engineering studies. 

The topics discussed covered how the computer works at the `lowest level of abstraction`, i.e. memory management and how many bits are used by specific primitive data types. We had the opportunity to write two projects in `assembly language` during the course.

# Projects

Two identical programs written in `RISC-V` and `x86` assembler that draws a single line of text (containing only numbers and dots) on the BMP image. Symbols were to be presented in 8x8 pixel matrix format. 

For example, number 1 looks as follows:

. . . * * . . .<br>
. * * * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . * * * * . .<br>

There were `three inputs`:

* 320x240px 24 bit RGB BMP file
* the text string to be drawn
* starting coordinates x and y, where numbers have to be drawn

As `output` program returned a 320x240px 24 bit RGB BMP file.

I created the RISC-V project using the RARS simulator, that is RISC-V Assembler and Runtime Simulator, and x86 project is a combination of C++ with an assembler that has was compiled with the GCC compiler.

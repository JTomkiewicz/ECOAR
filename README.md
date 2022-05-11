## Description

## Projects

The task was to create a program in **RISC-V** and **x86** assembler that draws a single line of text (containing only numbers and dots) on the BMP image. Symbols were to be presented in 8x8 pixel matrix format. For example, number 1 looks as follows:

. . . * * . . .<br>
. * * * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . . * * . . .<br>
. . * * * * . .<br>

There were three inputs:
* 320x240px 24 bit RGB BMP file containing the source image:
* the text string to be drawn
* starting coordinates x and y, where numbers have to be drawn

Output was a 320x240px 24 bit RGB BMP file containing modified image.

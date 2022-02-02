#include <stdio.h>

// structure that stores information about image
struct image
{
  int size;     // image size
  int height;   // image heigth
  int width;    // image width
  int lineSize; // line size IN BYTES
  char *img;
};

// read from bmp file
image *readBmp(const char *fileName)
{
  // create new image struct
  image *img;

  return img;
}

// save to bmp file
int saveBmp(const char *fileName, const image *imgToSave)
{

  // return true if success
  return 0;
}

extern "C" int func(image *sourceImg, image *numbersImg, image *destImg, char *inputText);

int main(void)
{
  // read source
  image *sourceImg = readBmp("source.bmp");

  // read numbers
  image *numbersImg = readBmp("numbers.bmp");

  // read destination
  image *destImg = readBmp("dest.bmp");

  char inputText[] = "Wind On The Hill";
  // printf("Input string      > %s\n", text);

  if (func(sourceImg, numbersImg, destImg, inputText) != 0)
  {
    printf("Error in func.asm!\n");
    return 1;
  };

  return 0;
}

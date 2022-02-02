#include <stdio.h>
#include <iostream>

// structure that stores information about image
struct image
{
  int size;     // image size
  int height;   // image heigth
  int width;    // image width
  int lineSize; // line size IN BYTES
  char *pImg;
};

// read from bmp file
image *readBmp(const char *fileName)
{
  // create new image struct
  image *img;
  // FILE pointer
  FILE *pFile;

  // rb stands for read binary
  pFile = fopen(fileName, "rb");

  // when file opened succesfully
  if (pFile != NULL)
  {
    fclose(pFile);

    return img;
  }
  else
  {
    return NULL;
  }
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

  // check if files opened successfully
  if (sourceImg == NULL || numbersImg == NULL || destImg == NULL)
  {
    std::cout << "Error while reading bmp fules!\n";
    return 1;
  }

  // read message & starting coordinates x and y
  char message[15];
  std::cout << "Input message to print (only numbers and dots are printed, other symbols will be ignored):\n";
  std::cin >> message;

  std::cout << "Input starting x (only integer allowed):\n";
  int x;
  std::cin >> x;

  std::cout << "Input starting y (only integer allowed):\n";
  int y;
  std::cin >> y;

  // run func.asm
  if (func(sourceImg, numbersImg, destImg, message) != 0)
  {
    std::cout << "Error in func.asm!\n";
    return 1;
  }

  // save image to dest.bmp
  if (saveBmp("dest.bmp", destImg) != 0)
  {
    std::cout << "Error in saveBmp function!\n";
    return 1;
  }

  // exit program
  return 0;
}

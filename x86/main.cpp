#include <stdio.h>
#include <iostream>
#include <string>

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

// check if message to print contains only numbers and dots
bool isCorrect(std::string msg)
{
  for (int i = 0; i < msg.length(); i++)
  {
    if ((msg[i] < '0' || msg[i] > '9') && msg[i] != '.')
      return false;
  }

  return true;
}

extern "C" int func(image *sourceImg, image *numbersImg, image *destImg, std::string inputText);

int main(void)
{
  // read source
  image *sourceImg = readBmp("source.bmp");
  // read numbers
  image *numbersImg = readBmp("numbers.bmp");
  // read dest
  image *destImg = readBmp("dest.bmp");

  // check if files opened
  if (sourceImg == NULL || numbersImg == NULL || destImg == NULL)
  {
    std::cout << "Error while reading bmp fules!\n";
    return 1;
  }

  // read message & starting coordinates x, y
  std::string message;
  std::cout << "Input message to print (only numbers and dots):\n";
  while (!isCorrect(message))
    std::cin >> message;

  std::cout << "Input starting x (must be in [0, 320]):\n";
  int x;
  while (x < 0 || x > 320)
    std::cin >> x;

  std::cout << "Input starting y (must be in [0, 240]):\n";
  int y;
  while (y < 0 || y > 240)
    std::cin >> y;

  // run func.asm
  if (func(sourceImg, numbersImg, destImg, message) != 0)
  {
    std::cout << "Error in func.asm!\n";
    return 1;
  }

  // save image
  if (saveBmp("dest.bmp", destImg) != 0)
  {
    std::cout << "Error in saveBmp function!\n";
    return 1;
  }

  // exit program
  return 0;
}

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
bool isCorrect(const std::string msg)
{
  for (int i = 0; i < msg.length(); i++)
  {
    if ((msg[i] < '0' || msg[i] > '9') && msg[i] != '.')
      return false;
  }

  return true;
}

int calculateX(const char letter)
{
  switch (letter)
  {
  case '0':
    return 0;
  case '1':
    return 8;
  case '2':
    return 16;
  case '3':
    return 24;
  case '4':
    return 32;
  case '5':
    return 40;
  case '6':
    return 48;
  case '7':
    return 56;
  case '8':
    return 64;
  case '9':
    return 72;
  case '.':
    return 80;
  default:
    return 0;
  }
}

extern "C" void func(image *srcImg, image *numbersImg, int startX, int startY, int numberX);

int main(void)
{
  // read source
  image *srcImg = readBmp("source.bmp");
  // read numbers
  image *numbersImg = readBmp("numbers.bmp");

  // check if files opened
  if (srcImg == NULL || numbersImg == NULL)
  {
    std::cout << "Error while reading bmp files!\n";
    return 1;
  }

  // read message & starting coordinates x, y
  std::string message;
  std::cout << "Input message to print (only numbers and dots):\n";
  while (!isCorrect(message))
    std::cin >> message;

  std::cout << "Input starting x (must be in [0, 312]):\n";
  int startX;
  while (startX < 0 || startX > 312)
    std::cin >> startX;

  std::cout << "Input starting y (must be in [0, 232]):\n";
  int startY;
  while (startY < 0 || startY > 232)
    std::cin >> startY;

  int numberX = 0;
  // loop through string
  for (int i = 0; i < message.length(); i++)
  {
    // x position of letter to print
    numberX = calculateX(message[i]);

    // run func.asm
    func(srcImg, numbersImg, startX, startY, numberX);

    startX += 8; // after printing move 8 bits right

    // look if x is outside boundaries
    if (startX >= 320)
      break;
  }

  // save image
  if (saveBmp("dest.bmp", srcImg) != 0)
  {
    std::cout << "Error in saveBmp function!\n";
    return 1;
  }

  // exit program
  return 0;
}

#include <stdio.h>
#include <iostream>
#include <string>
#include <stdlib.h>

// ============================================================================
//
// Jakub Tomkiewicz
// Index: 300183
//
// x86-32 Project No. 21 Adding Text
//
// ============================================================================

// structure that stores information about bmp image
struct image
{
  int size;     // image size
  int imgSize;  // image size minus header (54)
  int height;   // image heigth
  int width;    // image width
  int lineSize; // line size IN BYTES

  unsigned char header[54];
  unsigned char *img;
};

// read from bmp file
image *readBmp(const char *fileName)
{
  // create new image struct
  image *img = (image *)malloc(sizeof(image));
  // FILE pointer
  FILE *file;

  // rb stands for read binary
  file = fopen(fileName, "rb");

  // when opening fails
  if (file == NULL)
    return NULL;

  // read first 54 bytes (this is header)
  fread(img->header, 1, sizeof(54), file);

  // set width and height
  img->width = *(int *)&img->header[18];
  img->height = *(int *)&img->header[22];

  // bytes per row = 3 bytes * width
  img->lineSize = 3 * img->width;

  // data size is 3 * width * height
  img->imgSize = 3 * img->width * img->height;

  // whole size is data + header
  img->size = img->imgSize + 54;

  // read rest of bytes
  fread(img->img, sizeof(unsigned char), img->imgSize, file);

  // close file
  fclose(file);

  return img;
}

// save to bmp file
int saveBmp(const char *fileName, const image *img)
{
  // FILE pointer
  FILE *file;

  // wb stands for write binary
  file = fopen(fileName, "wb");

  // when opening fails
  if (file == NULL)
    return 1;

  // write header
  fwrite(img->header, sizeof(unsigned char), 54, file);

  // write data
  fwrite(img->img, sizeof(unsigned char), img->imgSize, file);

  // close file
  fclose(file);

  return 0;
}

// check if message to print contains only numbers and dots
bool isCorrect(const std::string msg)
{
  for (int i = 0; i < msg.length(); i++)
  {
    if ((msg[i] < '0' || msg[i] > '9') && msg[i] != '.')
    {
      std::cout << "Only numbers and dots are allowed. Try again!\n";
      return false;
    }
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

void printLetter(image *srcImg, image *numbersImg, int startX, int startY, int numberX)
{
  // pointers for both src and numbers imgs
  unsigned char *pSrc = srcImg->img;
  unsigned char *pNumbers = numbersImg->img;

  // go to the beginning of letter in numbersImg
  pNumbers += numberX * 3;

  // go to the place in scrImg
  pSrc += startY * srcImg->lineSize;
  pSrc += startX * 3;

  for (int i = 0; i < 8; i++)
  {
    for (int j = 0; j < 8; j++)
    {
      for (int k = 0; k < 3; k++)
      {
        // move from number to src
        *pSrc = *pNumbers;

        // increase pointers
        pSrc++;
        pNumbers++;
      }
    }

    pNumbers += 240;
    pSrc += 936;
  }
}

void deallocate(image *img)
{
  free(img->img);
  free(img->header);
  free(img);
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
    deallocate(srcImg);
    deallocate(numbersImg);

    return 1;
  }

  // read message & starting coordinates x, y
  std::string message;
  std::cout << "Input message to print (only numbers and dots):\n";
  do
  {
    std::cin >> message;
  } while (!isCorrect(message));

  std::cout << "Input starting x (must be in [0, 312]):\n";
  int startX;
  do
  {
    std::cin >> startX;
    if (startX < 0 || startX > 312)
      std::cout << "Number must be in [0, 312]. Try again!:\n";
  } while (startX < 0 || startX > 312);

  std::cout << "Input starting y (must be in [0, 232]):\n";
  int startY;
  do
  {
    std::cin >> startY;
    if (startY < 0 || startY > 232)
      std::cout << "Number must be in [0, 323]. Try again!:\n";
  } while (startY < 0 || startY > 232);

  int numberX = 0;
  // loop through string
  for (int i = 0; i < message.length(); i++)
  {
    // x position of letter to print
    numberX = calculateX(message[i]);

    // run func.asm
    // func(numbersImg, srcImg, startX, startY, numberX);

    // printLetter written in C++
    printLetter(numbersImg, srcImg, startX, startY, numberX);

    // after printing move 8 bits right
    startX += 8;

    // look if x is outside boundaries
    if (startX >= 320)
      break;
  }

  // save image
  if (saveBmp("dest.bmp", srcImg) != 0)
  {
    std::cout << "Error in saveBmp function!\n";
    deallocate(srcImg);
    deallocate(numbersImg);

    return 1;
  }

  // deallocate images
  deallocate(srcImg);
  deallocate(numbersImg);

  // exit program
  return 0;
}

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
  unsigned int size;     // image size minus header (54)
  unsigned int height;   // image heigth
  unsigned int width;    // image width
  unsigned int lineSize; // line size IN BYTES

  unsigned char *img;
  unsigned char *header;
};

// read from bmp file
image *readBmp(const char *fileName)
{
  // create new image struct
  image *img = (image *)malloc(sizeof(image));
  img->header = NULL;
  img->img = NULL;
  img->size = 0;
  img->height = 0;
  img->width = 0;
  img->lineSize = 0;

  // FILE pointer rb stands for read binary
  FILE *file = fopen(fileName, "rb");

  // when opening fails
  if (file == NULL)
    return NULL;

  img->header = new unsigned char[54];

  // read first 54 bytes (this is header)
  fread(img->header, sizeof(unsigned char), 54, file);

  // set width and height
  img->width = *(unsigned int *)&img->header[18];
  img->height = *(unsigned int *)&img->header[22];

  // bytes per row = 3 bytes * width
  img->lineSize = 3 * img->width;

  // data size is 3 * width * height
  img->size = 3 * img->width * img->height;

  img->img = new unsigned char[img->size];

  fread(img->img, sizeof(unsigned char), img->size, file);

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
  fwrite(img->img, sizeof(unsigned char), img->size, file);

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
  // at this point we know that letter must be 0-9 or .

  // when letter is 0-9, cast char to int and multiply by 8
  if (letter >= '0' && letter <= '9')
  {
    int letterInt = letter - '0';
    return letterInt * 8;
  }

  // if letter is NOT 0-9, it must be .
  return 80;
}

void printLetter(image *numbersImg, image *srcImg, unsigned int startX, unsigned int startY, unsigned int numberX)
{
  // pointers for both src and numbers imgs
  unsigned char *pSrc = srcImg->img;
  unsigned char *pNumbers = numbersImg->img;

  // go to the beginning of letter in numbersImg
  pNumbers += (numberX * 3);

  // go to the place in scrImg
  pSrc += (startY * srcImg->lineSize);
  pSrc += (startX * 3);

  for (int i = 0; i < 8; i++)
  {
    for (int j = 0; j < 24; j++) // 24 = 8 * 3
    {
      // move from number to src
      *pSrc = *pNumbers;

      // increase pointers
      pSrc++;
      pNumbers++;
    }

    pNumbers += (numbersImg->lineSize - 24);
    pSrc += (srcImg->lineSize - 24);
  }
}

void deallocate(image *img)
{
  if (img && img->header && img->img)
  {
    // all uint set to 0
    img->height = 0;
    img->width = 0;
    img->size = 0;
    img->lineSize = 0;

    // free
    free(img->img);
    free(img->header);
    free(img);
  }
}

extern "C" void func(image *numbersImg, image *srcImg, unsigned int startX, unsigned int startY, unsigned int numberX);

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

  std::cout << "BMP file opening successfull\n";

  // read message & starting coordinates x, y
  std::string message;
  std::cout << "Input message to print (only numbers and dots):\n";
  do
  {
    std::cin >> message;
  } while (!isCorrect(message));

  std::cout << "Input starting x (must be in [0, 312]):\n";
  unsigned int startX;
  do
  {
    std::cin >> startX;
    if (startX < 0 || startX > 312)
      std::cout << "Number must be in [0, 312]. Try again!:\n";
  } while (startX < 0 || startX > 312);

  std::cout << "Input starting y (must be in [0, 232]):\n";
  unsigned int startY;
  do
  {
    std::cin >> startY;
    if (startY < 0 || startY > 232)
      std::cout << "Number must be in [0, 323]. Try again!:\n";
  } while (startY < 0 || startY > 232);

  std::cout << "All inputs are correct. Starting printing\n";

  unsigned int numberX = 0;
  // loop through string
  for (int i = 0; i < message.length(); i++)
  {
    // x position of letter to print
    numberX = calculateX(message[i]);

    // run func.asm
    func(numbersImg, srcImg, startX, startY, numberX);

    // printLetter written in C++
    // printLetter(numbersImg, srcImg, startX, startY, numberX);

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

  std::cout << "BMP file saving successfull\n";

  // deallocate images
  deallocate(srcImg);
  deallocate(numbersImg);

  std::cout << "Deallocation successfull\n";

  // exit program
  return 0;
}

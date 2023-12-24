#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdbool.h>

#define FILENAME        "author.txt"
#define FILE_CHUNK_SIZE 256

char* locate(char* buffer, char* toFind);
bool isBytesEqual(char* s1, char* s2, const size_t numOfBytes);
void makeStringNull(char *buffer)
{
  for (size_t i = 0; buffer[i] != '\0'; i++)
  {
    buffer[i] = 0;
  }
}

int main()
{
  char requestedString[FILE_CHUNK_SIZE] = "program";
  const int requestedLen = strlen(requestedString);

  // const char* const filename = "author.txt";

  int fd = open(FILENAME, O_RDWR);
  if (fd == -1)
  {
    perror("Error: ");
    return 1;
  }

  char fileData[FILE_CHUNK_SIZE + 1];
  fileData[FILE_CHUNK_SIZE] = 0;

  char* requestedPointer;
  off_t requestedStringOffset;
  int bytes;

  while (true)
  {
    bytes = read(fd, fileData, FILE_CHUNK_SIZE);
    printf("Bytes: %d\n", bytes);
    if (bytes == -1)
    {
      perror("Error: ");
      return 2;
    }

    requestedPointer = locate(fileData, requestedString);
    off_t offset = 0 + (requestedPointer - fileData); // all readen bytes
    if (requestedPointer != NULL)
    {
      // possible to make
      // printf("Found! Its %d bytes from file\n", lseek(fd, 0, SEEK_CUR) - lseek(fd, 0, SEEK_SET));
      requestedStringOffset = offset;
      printf("Found! requestedStringOffset is %ld\n", requestedStringOffset);
      break;
    }
    lseek(fd, 1 - requestedLen, SEEK_CUR);
    makeStringNull(fileData);
  }

  const char *newString = "";
  int newFd = open("author-temporary.txt", O_CREAT | O_RDWR | O_TRUNC);
  if (newFd == -1)
  {
    perror("Error: ");
  }
  // need loop design
  
  makeStringNull(fileData);
  lseek(fd, 0, SEEK_SET);
  bytes = read(fd, fileData, requestedStringOffset);
  printf("bytes1: %d\n", bytes);
  printf("filedata: %s\n", fileData);
  bytes = write(newFd, fileData, requestedStringOffset);
  printf("bytes2: %d\n", bytes);
  bytes = write(newFd, newString, strlen(newString));
  printf("bytes3: %d\n", bytes);
  lseek(fd, requestedLen, SEEK_CUR);
  makeStringNull(fileData);
  bytes = read(fd, fileData, FILE_CHUNK_SIZE);
  printf("bytes4: %d\n", bytes);
  printf("filedata: %s\n", fileData);
  bytes = write(newFd, fileData, strlen(fileData));
  printf("bytes1: %d\n", bytes);
  if (bytes == -1)
  {
    perror("Error: ");
    return 3;
  }

  close(fd);
  close(newFd);
  return 0;
}

char* locate(char* buffer, char* toFind)
{
  const int stringLen = strlen(toFind);
  const int bufferLen = strlen(buffer);
  if (stringLen > bufferLen)
  {
    return NULL;
  }

  for (size_t i = 0; i <= bufferLen - stringLen; i++)
  {
    if (isBytesEqual(buffer + i, toFind, stringLen))
    {
      return buffer + i;
    }
  }
  
  return NULL;
}

bool isBytesEqual(char* s1, char* s2, const size_t numOfBytes)
{
  for (size_t i = 0; i < numOfBytes; i++)
  {
    if (s1[i] != s2[i])
    {
      return false;
    }
  }
  return true; 
}
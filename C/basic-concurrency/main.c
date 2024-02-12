#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#define ARR_SIZE    10000
#define THREADS_NUM 5

typedef struct
{
  int start_index;
  int end_index;
} RangeIndexes;

void fill_arr(int *arr);
void* sum_array_partial(void *arg);
pthread_t* init_threads(void *arg);

static int arr[ARR_SIZE];

int main()
{
  fill_arr(arr);

  RangeIndexes ranges[THREADS_NUM] = { {0, 2000}, {2000, 4000}, {4000, 6000}, {6000, 8000}, {8000, 10000} };
  // fill ranges
  pthread_t *threads = init_threads(ranges);
  

  size_t *partial_sums[THREADS_NUM];
  // threads join
  for (int i = 0; i < THREADS_NUM; i++)
  {
    pthread_join(threads[i], (void **) &partial_sums[i]); // return value here
    printf("Sum of thread is %ld\n", *partial_sums[i]);
    // fflush(stdout);
    free(partial_sums[i]);
  }
  free(threads);

  return 0;
}

pthread_t* init_threads(void *arg)
{
  pthread_t *threads = (pthread_t *) malloc(THREADS_NUM * sizeof(pthread_t));
  if (threads == NULL)
  {
    perror("malloc");
    return NULL;
  }

  for (int i = 0; i < THREADS_NUM; i++)
  {
    RangeIndexes *range = &(((RangeIndexes *) arg)[i]);

    int error;
    error = pthread_create(&threads[i], NULL, &sum_array_partial, range);
    if (error != 0)
    {
      printf("Failed to create thread\n");
      return NULL; // ?
    }
  }

  return threads;
}

void* sum_array_partial(void *arg)
{
  printf("Thread working...\n");
  printf("start: %d\n", ((RangeIndexes *) arg)->start_index);
  printf("end: %d\n", ((RangeIndexes *) arg)->end_index);
  fflush(stdout);
  int start = ((RangeIndexes *) arg)->start_index;
  int end = ((RangeIndexes *) arg)->end_index;
  
  size_t *sum = (size_t *) malloc(sizeof(size_t));
  if (sum == NULL)
  {
    return NULL;
  }

  for (int i = start; i < end; i++) // index
  {
    *sum += arr[i];
  }
  
  return sum;
}

void fill_arr(int *arr)
{
  for (size_t i = 0; i < ARR_SIZE; i++)
  {
    arr[i] = rand() % 100;
  }
}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <cuda.h>

//97 to 122 use only lowercase letters
//65 to 90 use only capital letters
//48 to 57 use only numbers

#define START_CHAR 48
#define END_CHAR 122
#define MAXIMUM_PASSWORD 20

__device__ long long my_pow(long long x, int y)
{
  long long res = 1;
  if (y==0)
    return res;
  else
    return x * my_pow(x, y-1);
}

__device__ int my_strlen(char *s)
{
    int sum = 0;
    while (*s++) sum++;
    return sum;
 }

__global__ void bruteForce(char *pass) 
{
  int pass_b26[MAXIMUM_PASSWORD];
    
  long long int j = blockIdx.x * blockDim.x + threadIdx.x;
  long long int pass_decimal = 0;
  int base = END_CHAR - START_CHAR + 2;
  int found = 0;

  //tamanho da senha
  int size = my_strlen(pass);

  for(int i = 0; i < size; i++)
    pass_b26[i] = (int) pass[i] - START_CHAR + 1; 

  for(int i = size - 1; i > -1; i--)
    pass_decimal += (long long int) pass_b26[i] * my_pow(base, i);

  long long int max = my_pow(base, size);
  char s[MAXIMUM_PASSWORD];

  while(j < max){
    if(found == 1) printf("%lli\n", j);
    
    if(j == pass_decimal){
      printf("Found password!\n");
      int index = 0;

      printf("Password in decimal base: %lli\n", j);
      while(j > 0){
        s[index++] = START_CHAR + j%base-1;
        j /= base;
      }
      s[index] = '\0';
      printf("Found password: %s\n", s);
      found = 1;
      break;
    }
    j += blockDim.x * gridDim.x;
  }
}

int main(int argc, char **argv) 
{
  char password[MAXIMUM_PASSWORD], *password_d;
  
  strcpy(password, argv[1]);
  cudaMalloc( (void**)&password_d, MAXIMUM_PASSWORD * sizeof(char));
  cudaMemcpy(password_d, password, MAXIMUM_PASSWORD * sizeof(char), cudaMemcpyHostToDevice);
  
  double dif, speedup, x;
  time_t t1, t2;

  int deviceId, numberOfSMs;
  cudaGetDevice(&deviceId);
  cudaDeviceGetAttribute(&numberOfSMs, cudaDevAttrMultiProcessorCount, deviceId);

  int number_of_blocks = numberOfSMs * 32;
  int threads_per_block = atoi(argv[2]);
  printf("number_of_blocks: %d | threads_per_block: %d\n", number_of_blocks, threads_per_block);

  t1 = time(nullptr);
  printf("Try to broke the password: %s\n", password);
  bruteForce<<< number_of_blocks, threads_per_block >>>(password_d);
  cudaDeviceSynchronize();
  t2 = time(nullptr);

  dif = difftime (t2, t1);

  printf("\n%f seconds\n", dif);

  FILE *fptr;
  FILE *fptr1;
  char c[1000];

  if ((fptr1 = fopen("firstValue.dat", "r")) != NULL)
  {
    fscanf(fptr1, "%[^\n]", c);
    x = atof(c);
    
    if(dif != 0) speedup = x/dif;
    else speedup = 100;
    
    printf("\n%lf\n", speedup);
    
    fclose(fptr1);
  }

  if ((fptr = fopen("speedup_cuda.dat", "a+")) != NULL)
  {
    fprintf(fptr, "%d\t%1.2f\n", threads_per_block, speedup);
    fclose(fptr);
  }
  else{
    fopen("speedup_cuda.dat", "w+");
    fprintf(fptr, "%d\t%1.2f\n", threads_per_block, speedup);
    fclose(fptr);
  }

  cudaFree(password_d);
  return 0;
}
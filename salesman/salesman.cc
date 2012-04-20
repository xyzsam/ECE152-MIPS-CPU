//#include <iostream>
#include <cstdio>
#include <list>
#include <queue>
#include <cmath>
#include <cstdio>
//#include "stdlib.h"
#include <cstdlib>
#include <stack>
#include <ctime>

using namespace std;

int* xPoints;
int* yPoints;
int minPath;
queue< int > availablePoints;
stack< int > bestPath;
int count;

int ptDistance(int pt1, int pt2)
{
     count++;
     int x1 = *(xPoints+pt1);
     int y1 = *(yPoints+pt1);
     int x2 = *(xPoints+pt2);
     int y2 = *(yPoints+pt2);
     int dist = pow(x2-x1,2)+pow(y2-y1,2); // note: no sqrt!!
     return dist;
}

void find_path(int pointsLeft, int prevPoint, int dist, stack< int > *currPath)
{
     if (pointsLeft==0)
     {
          if (dist<minPath)
          {
               minPath=dist;
               bestPath = *(currPath);
          }
          return;
     }
     for (int i=0; i<pointsLeft; i++)
     {
          int ptOut= availablePoints.front();
          availablePoints.pop();
          int toNextPoint = ptDistance(ptOut, prevPoint);
          currPath->push(ptOut);
          find_path(pointsLeft-1, ptOut, dist+toNextPoint, currPath);
          availablePoints.push(ptOut);
          currPath->pop();
     }
}

int main(int argc, const char* argv[])
{
     int numPoints = atoi(argv[1]);
     count=0;
     xPoints =(int *) malloc(numPoints*sizeof(int));
     yPoints =(int *) malloc(numPoints*sizeof(int));
     time_t start,end;
     time(&start);
     for (int i=1; i<numPoints+1; i++)
     {
          *(xPoints+i-1) = atoi(argv[i*2]);
          *(yPoints+i-1) = atoi(argv[i*2+1]);
          availablePoints.push(i-1);
     }
     minPath=0x0FFFFFFF;
     int firstPoint = availablePoints.front();
     availablePoints.pop();
     stack< int > *currPath = new stack< int >();
     currPath->push(firstPoint);
     find_path(numPoints-1, firstPoint, 0, currPath);
     printf("Distance: %i \n", minPath);
     stack< int > printStack;
     while (!bestPath.empty())
     {
          printStack.push(bestPath.top());
          bestPath.pop();
     }
     while (!printStack.empty())
     {
          printf("%i ",(int) printStack.top());
          printStack.pop();
     }
     time(&end);
     printf("Comparisons: %i \n", count);
     double dif = difftime(end,start);
     printf("Program runtime: %f \n", dif);
     printf("\n");
}

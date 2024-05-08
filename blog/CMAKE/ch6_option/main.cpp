#include<iostream>
#include"animal/dog.h"
#include"animal/cat.h"
#include "config.h"
int main(int argc,char const *argv[])
{
    Dog dog;
    std::cout<< dog.barking()<< std::endl;
    Cat cat;
    std::cout<<cat.barking()<<std::endl;
    std::cout<<CMAKE_CXX_STANDARD<<std::endl;
    return 0;
}
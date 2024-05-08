#include<iostream>
#include "include/dog.h"
#include "include/cat.h"
int main(int argc,char const *argv[])
{
    Dog dog;
    std::cout<< dog.barking()<< std::endl;
    Cat cat;
    std::cout<<cat.barking()<<std::endl;
    return 0;
}
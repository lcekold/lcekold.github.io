#include<iostream>
#include"animal/dog.h"
#include"animal/cat.h"
int main(int argc,char const *argv[])
{
    Dog dog;
    std::cout<< dog.barking()<< std::endl;
    Cat cat;
    std::cout<<cat.barking()<<std::endl;
    return 0;
}
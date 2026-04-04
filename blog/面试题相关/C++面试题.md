## 1. 类的静态成员函数有什么特性？

1. 静态成员函数不依赖于类的实例，因此可以在没有类对象的情况下调用。它们属于类本身而不是类的实例。这意味着你可以通过类名直接调用静态成员函数，而不需要创建类的对象。

2. 静态成员函数只能访问类的静态成员（静态数据成员和静态函数），不能访问非静态成员（普通数据成员和普通成员函数）。这是因为静态成员函数不关联于任何特定的类对象，因此无法访问实例相关的数据。

3. 静态成员函数可以具有公有、保护或私有的访问级别，就像普通成员函数一样。这意味着它们可以被外部代码访问，也可以在派生类中被重写。

4. 静态成员函数通常与静态数据成员一起使用，因为它们都与类本身相关，而不是与类的实例相关。静态成员函数可以用于操作和管理静态数据成员。

## 2.空类的大小？

空类的话就是类中没有任何数据成员和成员函数。空类的大小取决于编译器和平台，但通常情况下，**空类的大小为1字节**。

这1字节的大小通常用于标识对象在内存中的位置，以确保不同的对象具有不同的地址。

所以即使是空类，也必须在内存中占用至少一个字节。

## 3.空类默认生成哪几个成员函数？

1. **默认构造函数：**如果你没有显式定义构造函数，编译器会为你生成一个默认构造函数。这个构造函数不接受任何参数，用于创建类的对象。默认构造函数会执行默认的对象初始化。

2. **析构函数：**如果你没有显式定义析构函数，编译器会为你生成一个默认的析构函数。这个析构函数用于销毁类的对象，释放对象所占用的资源。默认析构函数通常是空的，不执行特定的清理工作。

3. **拷贝构造函数：**如果你没有显式定义拷贝构造函数，编译器会为你生成一个默认的拷贝构造函数。这个构造函数用于创建一个对象作为另一个对象的副本。默认的拷贝构造函数执行成员逐一拷贝，适用于大多数情况，但可能不适用于包含动态分配内存的类。

4. **拷贝赋值运算符：**如果你没有显式定义拷贝赋值运算符，编译器会为你生成一个默认的拷贝赋值运算符。这个运算符用于将一个对象的内容复制到另一个对象，通常与拷贝构造函数类似，执行成员逐一拷贝。


## 4. 分配内存时，malloc和new有什么区别？

语法和类型安全性：

1. malloc 是C语言中的函数，而 new 是C++中的操作符。

2. malloc 返回 void* 类型的指针，需要进行显式的类型转换，将其转换为所需的指针类型，这可能导致类型错误。

3. new 返回所需类型的指针，不需要显式类型转换，因此更类型安全。

构造函数和析构函数的调用：

1. malloc 只是分配内存，不会调用对象的构造函数。

2. new 不仅分配内存，还会调用对象的构造函数进行初始化。这使得 new 更适合在C++中用于动态分配自定义类型的对象。

内存分配失败处理：

1. malloc 在分配失败时返回 NULL 指针，需要显式检查。

2. new 在分配失败时引发 std::bad_alloc 异常，可以使用异常处理机制来处理。

内存分配数量：

1. malloc 接受一个表示要分配的字节数的参数，可以分配任意数量的字节。

2. new 用于分配特定类型的对象，它的大小由编译器自动计算，因此你不需要显式指定分配多少字节。

内存释放：

1. 使用 malloc 分配的内存应该使用 free 函数来释放。

2. 使用 new 分配的内存应该使用 delete 运算符来释放，如果分配时使用了 [] 运算符（用于数组），则应该使用 delete[] 来释放。

## 5. 重载、重写和重定义的区别

重载：函数名相同，函数的参数个数、参数类型或参数顺序三者中必须至少有一种不同。函数返回值的类型可以相同，也可以不相同。发生在一个类内部，不能跨作用域。

重定义：也叫做隐藏，子类重新定义父类中有相同名称的非虚函数 ( 参数列表可以不同 ) ，指派生类的函数屏蔽了与其同名的基类函数。可以理解成发生在继承中的重载。

重写：也叫做覆盖，一般发生在子类和父类继承关系之间。子类重新定义父类中有相同名称和参数的虚函数。(override)

重载的例子：

```cpp
class Example {
public:
    void display(int a) {
        std::cout << "Display with int: " << a << std::endl;
    }

    void display(double b) {
        std::cout << "Display with double: " << b << std::endl;
    }

    void display(int a, double b) {
        std::cout << "Display with int and double: " << a << ", " << b << std::endl;
    }
};
```

重写的例子：

```cpp
class Base {
public:
    virtual void show() {
        std::cout << "Base class show function" << std::endl;
    }
};

class Derived : public Base {
public:
    void show() override { // 重写基类的虚函数
        std::cout << "Derived class show function" << std::endl;
    }
};
```
重定义：

```cpp 
class Base {
public:
    void display() {
        std::cout << "Base class display function" << std::endl;
    }
};

class Derived : public Base {
public:
    void display() { // 重定义基类的非虚函数
        std::cout << "Derived class display function" << std::endl;
    }
};
```

## 6.虚函数和纯虚函数

虚函数：虚函数是基类中声明为 virtual 的成员函数，它可以在派生类中被重写（override）。当通过基类指针或引用调用虚函数时，会根据实际对象的类型来决定调用哪个版本的函数，这实现了运行时多态。

纯虚函数：纯虚函数是在基类中声明为 virtual 并且赋值为 0 的成员函数，其语法是 `virtual void function_name() = 0;`。包含纯虚函数的类被称为抽象类，不能创建该类的对象。派生类必须实现所有的纯虚函数，否则它们也将成为抽象类。

虚函数示例：

```cpp
#include <iostream>
using namespace std;

// 基类
class Animal {
public:
    // 虚函数：有默认实现
    virtual void makeSound() {
        cout << "动物发出声音" << endl;
    }
};

// 派生类 Dog
class Dog : public Animal {
public:
    // 重写基类的虚函数（推荐加 override 明确意图）
    void makeSound() override {
        cout << "汪汪汪" << endl;
    }
};

// 派生类 Cat
class Cat : public Animal {
public:
    void makeSound() override {
        cout << "喵喵喵" << endl;
    }
};

int main() {
    Animal* animal1 = new Dog();
    Animal* animal2 = new Cat();
    
    // 动态绑定：运行时根据对象实际类型调用对应函数
    animal1->makeSound();  // 输出：汪汪汪
    animal2->makeSound();  // 输出：喵喵喵
    
    delete animal1;
    delete animal2;
    return 0;
}
```

纯虚函数：
```cpp
#include <iostream>
using namespace std;

// 抽象类（包含纯虚函数）
class Shape {
public:
    // 纯虚函数：无实现，强制派生类重写
    virtual double getArea() = 0;
    
    // 普通虚函数：可提供默认实现
    virtual void printInfo() {
        cout << "这是一个图形" << endl;
    }
};

// 派生类 Circle
class Circle : public Shape {
private:
    double radius;
public:
    Circle(double r) : radius(r) {}
    
    // 必须重写纯虚函数 getArea()
    double getArea() override {
        return 3.14 * radius * radius;
    }
    
    void printInfo() override {
        cout << "圆形，面积：" << getArea() << endl;
    }
};

// 派生类 Rectangle
class Rectangle : public Shape {
private:
    double length, width;
public:
    Rectangle(double l, double w) : length(l), width(w) {}
    
    // 必须重写纯虚函数 getArea()
    double getArea() override {
        return length * width;
    }
    
    void printInfo() override {
        cout << "矩形，面积：" << getArea() << endl;
    }
};

int main() {
    // 错误：抽象类不能实例化
    // Shape shape; 
    
    Shape* shape1 = new Circle(5);
    Shape* shape2 = new Rectangle(4, 6);
    
    shape1->printInfo();  // 输出：圆形，面积：78.5
    shape2->printInfo();  // 输出：矩形，面积：24
    
    delete shape1;
    delete shape2;
    return 0;
}
```

## 7.“静态多态”（编译期多态）和“动态多态”（运行期多态）区别

### 静态多态

静态多态是在编译阶段由编译器决定采用哪种实现的多态，常见方式有：

* 函数重载（Function Overloading）
* 运算符重载（Operator Overloading）
* 模板（Templates/泛型）
* CRTP（Curiously Recurring Template Pattern，奇异递归模板模式）

#### 函数重载：

```cpp
#include <iostream>
#include <string>

// 定义多个同名函数，参数类型不同
void Print(int a) {
    std::cout << "int: " << a << std::endl;
}

void Print(double a) {
    std::cout << "double: " << a << std::endl;
}

void Print(const std::string& a) {
    std::cout << "string: " << a << std::endl;
}

int main() {
    Print(42);              // 调用 Print(int)
    Print(3.14);            // 调用 Print(double)
    Print("Hello C++");     // 调用 Print(const std::string&)，但这是const char*，会隐式转string

    std::string msg = "World";
    Print(msg);             // 调用 Print(const std::string&)

    return 0;
}

```

说明：

* 函数重载（Function Overloading）允许多个同名函数根据参数类型或数量不同实现不同的功能。
* 编译器在编译期间根据参数类型自动选择最合适的函数实现，这也是静态多态的一种体现。
* 这样可以让代码接口更友好，减少命名冲突和冗余代码。

#### 模板（泛型）：
```cpp
#include <iostream>
#include <string>

// 函数模板，实现通用的交换功能
template<typename T>
void Swap(T& a, T& b) {
    T tmp = a;
    a = b;
    b = tmp;
}

int main() {
    int x = 10, y = 20;
    Swap(x, y);    // 交换两个 int 变量
    std::cout << "x = " << x << ", y = " << y << std::endl;

    double dx = 1.5, dy = 2.8;
    Swap(dx, dy);  // 交换两个 double 变量
    std::cout << "dx = " << dx << ", dy = " << dy << std::endl;

    std::string s1 = "hello", s2 = "world";
    Swap(s1, s2);  // 交换两个字符串
    std::cout << "s1 = " << s1 << ", s2 = " << s2 << std::endl;

    return 0;
}

```

说明：

* 模板（Template）是 C++ 实现静态多态的重要机制，允许编写与类型无关的泛型代码。
* 上例中，Swap 函数模板可以自动适配各种类型（int、double、std::string 等）。
* 在编译期，编译器会根据实际参数类型生成对应的函数实例，实现“同一接口，多种实现”的静态多态。
* 除了函数模板，还有类模板，如 std::vector<T> 等。

#### 运算符重载：

```c++
#include <iostream>

class Point {
public:
    int x, y;

    Point(int x_, int y_) : x(x_), y(y_) {}

    // 重载加号运算符
    Point operator+(const Point& rhs) const {
        return Point(x + rhs.x, y + rhs.y);
    }

    // 重载输出流运算符（友元函数）
    friend std::ostream& operator<<(std::ostream& os, const Point& pt) {
        os << "(" << pt.x << ", " << pt.y << ")";
        return os;
    }
};

int main() {
    Point p1(2, 3);
    Point p2(5, 8);
    Point p3 = p1 + p2; // 编译时根据参数类型选择 operator+

    std::cout << "p1 + p2 = " << p3 << std::endl;
    return 0;
}

```

说明：

* 运算符重载允许你为自定义类型（如 Point）实现与内置类型一样的操作。
* operator+ 是成员函数，实现了 Point + Point 的功能。
* operator<< 是友元函数，支持 std::cout << point 输出。
* 编译器在编译期间，根据参数类型自动选择合适的重载函数，这体现了静态多态的特性。

#### CRTP 静态多态：

```c++
#include <iostream>

// 基类模板，T为派生类类型，实现部分通用逻辑
template <typename Derived>
class Base {
public:
    void Interface() {
        // 编译期间展开为调用派生类实现
        static_cast<Derived*>(this)->Implementation();
    }
    // 可以有其他通用成员函数
};

// 派生类A，实现专属行为
class DerivedA : public Base<DerivedA> {
public:
    void Implementation() {
        std::cout << "DerivedA implementation\n";
    }
};

// 派生类B，实现专属行为
class DerivedB : public Base<DerivedB> {
public:
    void Implementation() {
        std::cout << "DerivedB implementation\n";
    }
};

int main() {
    DerivedA a;
    DerivedB b;

    a.Interface();  // 输出：DerivedA implementation
    b.Interface();  // 输出：DerivedB implementation

    // 你也可以用模板参数处理不同派生类
    Base<DerivedA>* pa = &a;
    pa->Interface();

    return 0;
}

```
说明：

* CRTP（Curiously Recurring Template Pattern，奇异递归模板模式）是一种常见的静态多态技术。
* 基类模板 Base<Derived> 在成员函数中用 static_cast<Derived*>(this) 访问派生类，实现“部分行为通用，部分定制”。
* 派生类继承时传递自身类型（如 class DerivedA : public Base<DerivedA>），达到在编译期分发行为的效果。
* 与虚函数不同，没有任何虚表和运行时开销，所有行为都在编译期间决定，效率极高。

#### 静态多态的本质
* 静态多态是“代码的多种形态”，本质是编译器自动生成多份针对不同类型/参数的代码。
* 它不一定涉及到继承，也不关心对象类型，只是实现了接口重用和灵活性。
* 通常同一个类/函数名，模板参数不同，自动适配不同实现。
#### 静态多态优缺点
* 优点： 没有虚函数表（vtable）开销，速度快，编译期检查
* 缺点： 只能处理“已知类型”组合，不能用在需要运行时灵活切换类型的场景

### 动态多态

动态多态是运行时根据对象的真实类型决定采用哪种实现的多态，C++ 通过继承+虚函数+基类指针/引用实现。

```c++
#include <iostream>
#include <vector>
#include <memory>

// 基类：抽象动物
class Animal {
public:
    virtual ~Animal() {}              // 虚析构，确保通过基类指针安全析构
    virtual void Speak() = 0;         // 纯虚函数，子类必须实现
};

// 派生类：狗
class Dog : public Animal {
public:
    void Speak() override {           // override确保签名一致
        std::cout << "Woof!" << std::endl;
    }
};

// 派生类：猫
class Cat : public Animal {
public:
    void Speak() override {
        std::cout << "Meow!" << std::endl;
    }
};

// 通过基类指针使用多态
void MakeAnimalSpeak(Animal* pAnimal) {
    pAnimal->Speak();                 // 动态分派，根据实际类型调用
}

int main() {
    Dog dog;
    Cat cat;

    MakeAnimalSpeak(&dog);            // 输出：Woof!
    MakeAnimalSpeak(&cat);            // 输出：Meow!

    // 更常见的实际用法：存放指向不同子类的基类指针
    std::vector<std::unique_ptr<Animal>> animals;
    animals.emplace_back(new Dog());
    animals.emplace_back(new Cat());

    for (const auto& animal : animals) {
        animal->Speak();              // 输出：Woof! Meow!
    }

    return 0;
}
```

说明：

* 动态多态利用虚函数和继承机制，通过基类指针或引用，可以在运行时自动分派到实际子类实现。
* 基类通常包含虚析构函数，保证对象销毁时调用正确析构，防止资源泄漏。
* 典型场景：容器存储不同派生类对象，遍历时无需关心具体类型，直接调用虚函数即可获得“多种形态”的行为。

### 静态多态 VS 动态多态

|	|静态多态（编译期）|	动态多态（运行期）|
|-----|------|-----|
|实现方式|	函数重载、模板、CRTP|	继承+虚函数|
|类型决议|	编译期间|	运行期间|
|开销|	无虚表，无运行时开销|	有虚表，有轻微运行时开销|
|应用场景|	泛型编程、高性能、类型明确|	OOP 抽象、需要运行时类型切换|
|依赖继承|	否|	是|

## 8.面向对象三大特性

封装：封装是面向对象编程的核心概念之一，它指的是将数据（属性）和操作数据的函数（方法）组合在一起，形成一个独立的单元——类。通过封装，可以隐藏对象的内部实现细节，只暴露必要的接口给外部使用，从而提高代码的安全性和可维护性。

继承：继承是面向对象编程中的一种机制，它允许一个类（子类）从另一个类（父类）继承属性和方法。通过继承，子类可以重用父类的代码，并且可以扩展或修改父类的行为。这种机制促进了代码的复用和层次化设计，使得程序结构更加清晰。

多态：多态是面向对象编程中的一个重要特性，它允许不同的对象以相同的接口进行交互。多态可以分为静态多态（编译时多态）和动态多态（运行时多态）。静态多态通过函数重载和模板实现，而动态多态则通过继承和虚函数实现。多态使得程序具有更高的灵活性和可扩展性，能够在不修改现有代码的情况下添加新的功能。


cmake_minimum_required(VERSION 3.20.0)
set(VARBOOL TRUE)

if(VARBOOL)
    message(TRUE)
else()
    message(FALSE)
endif()

if(NOT VARBOOL OR VARBOOL)
    message(TRUE)
else()
    message(FALSE)
endif()

if(NOT VARBOOL AND VARBOOL)
    message(TRUE)
else()
    message(FALSE)
endif()

if(1 LESS 2)
    message("1 LESS 2")
endif()

if("ok" LESS 233)
    message("OK is less")
endif()

if(2 EQUAL "2")
    message("EQUAL")
endif()

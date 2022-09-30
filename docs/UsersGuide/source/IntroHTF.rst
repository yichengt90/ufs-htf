.. _IntroHTF:

=====================================
Goals for prototype Hierarchical Testing Framework
===================================== 

The main goal is to develop a transparent and approachable framework for UFS community testing of the UFS WM and its components consistent with the :term:`HSD` (Hierarchical Systems Development) approach and NOAA baseline operational metrics, that can be easily used by the community.

To achieve the goal above, we adopt `Ctest <https://cmake.org/cmake/help/latest/manual/ctest.1.html/>`__ approach. CTest is the part of CMake that handles testing code. Ctest allows for an easy way to run user-defined test cases with various argument and option settings, and then check the results against expected output/baseline. The following are the benefits of using CTest for our prototype HTF: 

* Ctest is the CMake test driver. Since CMake-based build system is used for all UFS components and applications, it is suitable to use CTest without any further changes o conduct tests and report results;
* Developers/users working on new codes can easily/quickly follow a few steps to design/add new tests in Ctests with HSD concepts (`example1 <https://ufs-htf.readthedocs.io/en/latest/AddTest.html/>`__, `example2 <https://github.com/clouden90/ufs-srweather-app/blob/ctest/htf/CMakeLists.txt/>`__);
* It is easy to maintain repeatability and reproducibility when transfer test cases to other users and whole community using Ctest;
* Ctest approach has potential to integrate with the existing EPIC Jenkins CI/CD pipeline (`example <https://github.com/clouden90/ufs-htf/blob/jenkins/Jenkinsfile/>`__)

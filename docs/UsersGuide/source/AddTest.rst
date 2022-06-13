.. _AddTest:

=====================================
More on Testing
===================================== 

The UFS-HTF comes with a suite of ctests. These tests are designed for proof of concept of :term:`HSD`. Developers working on a new test case could follow the below high-level instructions, and should ensure that all existing tests pass before adding a new test.

.. _addtest-htf:

Adding a test to HTF
======================================

When new test cases are added to UFS-HTF, this test (and corresponding files) should be added into the standard ctest set. This ensures this test could be potentially used in the CI/CD pipeline in the future (WIP).

All the ctesting in UFS-HTF is controlled through :code:`ufs-htf/test/CMakeLists.txt`. A ctest could be either a unit test, or an integration test that executes an application (e.g. UFS-SRW, UFS-WM, or UFS-MRW). Benchmark results are provided accompanying the ctests. A unit ctestcontains results in a reference log file based on analytical solutions or accurate numerical studies. For application ctest, one could compare to associated reference based on a previous execution of the same test. To determine the pass or failure for a ctest, the actual output could be compared against the reference or obs data (WIP). The reader is referred to :code:`ufs-htf/test/CMakeLists.txt`, where numerous examples exist for both. For example, one can modify :code:`ufs-htf/test/CMakeLists.txt` to add additional test cases:


.. code:: console


   add_test ( NAME ATM_c384_Barry
              COMMAND bash run_ctest.sh --app=ATM --grid=384 --case=Barry --ctest -v 
              WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )

This will add a C384 atm-only test case for Hurricane Barry. Keep in mind the developer will have to prepare the associated input files such as model ICs. Once can check `ufs-htf/test/prep.sh` for more details.

.. _AddTest:

=====================================
More on Testing
===================================== 

The UFS-HTF comes with a suite of ctests. These tests are designed for proof of concept of :term:`HSD`. Developers working on a new test case could follow the below high-level instructions, and should ensure that all existing tests pass before adding a new test.

.. _addtest-htf:

Adding a test to HTF
======================================

When new test cases are added to UFS-HTF, this test (and corresponding files) should be added into the standard ctest set. This ensures this test could be potentially used in the CI/CD pipeline in the future (WIP).

Example - Add C384 ATM-only case
---------------------------------------

All the ctesting in UFS-HTF is controlled through :code:`ufs-htf/test/CMakeLists.txt`. A ctest could be either a unit test, or an integration test that executes an application (e.g. UFS-SRW, UFS-WM, or UFS-MRW). Benchmark results are provided accompanying the ctests. A unit ctestcontains results in a reference log file based on analytical solutions or accurate numerical studies. For application ctest, one could compare to associated reference based on a previous execution of the same test. To determine the pass or failure for a ctest, the actual output could be compared against the reference or obs data (WIP). The reader is referred to :code:`ufs-htf/test/CMakeLists.txt`, where numerous examples exist for both. For example, one can modify :code:`ufs-htf/test/CMakeLists.txt` to add c384 atm-only test case:


.. code:: console

   add_test ( NAME ATM_c384_Barry
              COMMAND bash run_ctest.sh --app=ATM --grid=384 --case=Barry --ctest -v
              WORKING DIRECTORY ${CMAKE_BINARY_DIR}/test )
   set_tests_properties(ATM_c384_Barry PROPERTIES TIMEOUT 10800)

This will add a C384 atm-only test case for Hurricane Barry. Then you will have to rebuild under your `<build-directory>` folder. Then you will find a new test has been added in the test set:

.. code:: console
   
   cd  <build-directory>/test
   ctest -N
   Test  #1: build_ufs
   Test  #2: get_ufs_fix_data
   Test  #3: ATM_c96_Barry
   Test  #4: S2S_c96_Barry
   Test  #5: S2SW_c96_Barry
   Test  #6: S2SWA_c96_Barry
   Test  #7: Barry_track_err
   Test  #8: model_vrfy
   Test  #9: fcst_only_S2S_c96_Barry
   Test #10: ATM_c384_Barry

Keep in mind the developer will have to prepare the associated input files such as model ICs. Once can check `ufs-htf/test/prep.sh` for more details. To get model gird/fix input files, you can simply use the following command:

.. code:: console

   cd 
   ./prep.sh -a 384 -o 025

Then the script will get model input files from AWS S3. Initial condition (IC) files for FV3 (created from GFS operational dataset) can be downloaded from below link.

    .. container:: sphx-glr-footer
       :class: sphx-glr-footer-example


      .. container:: sphx-glr-download sphx-glr-download-python

        :download:`Download initial condition files: 2019071200.c384.tar.gz  <https://my-ufs-inputdata.s3.amazonaws.com/2019071200.c384.tar.gz>`

Since the C384 case requires more computational resources, users may have to modify a few env parameters, which is located in `<build-directory>/test/case/Barry.env`. If you are on Orion, please modify this file from:

.. code:: console

   export _QUEUE="debug"
   export _PARTITION_BATCH="debug"
   export _wtime_fcst_gfs="00:30:00"

to

.. code:: console

   export _QUEUE="batch"
   export _PARTITION_BATCH="orion"
   export _wtime_fcst_gfs="04:00:00"
   
Then you can run the new test:
 
.. code:: console

   ctest -VV -R ATM_c384_Barry

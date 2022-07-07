# ufs-htf
Hierarchical Testing Framework for ufs-weather-model

Currently, the following configurations are supported/tested:

Machine     | Orion  | Hera   | Hera   |
------------|--------|--------|--------|
Compiler(s) | Intel  | Intel  | Intel  |

## How to use

Currently there are 6 tests (you can type ``ctest -N`` to see the list) existed.

```
[Yi-cheng.Teng@hfe01 test]$ ctest -N
Test project /scratch2/NCEPDEV/stmp1/Yi-cheng.Teng/epic/20220707/ufs-htf/build/test
  Test #1: test_ATM_regional
  Test #2: test_ATM_c96_p8
  Test #3: test_S2S_c96mx100_p8
  Test #4: test_S2SW_c96mx100_p8
  Test #5: test_S2SWA_c96mx100_p8
  Test #6: test_S2SWA_c192mx050_p8

Total Tests: 6
```

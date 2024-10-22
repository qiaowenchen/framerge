# framerge

Link frames and copy variables from using frames based on multiple match relationships in Stata. 
See the [manuscript]() for details.

# Requirement
* Stata 16 or later version

# Install with Stata Command
```
** install from github
net install framerge, from("https://raw.githubusercontent.com/kerrydu/xtsfsp/main/xtsfsp/ado") replace
net get xtsfsp, from("https://raw.githubusercontent.com/kerrydu/xtsfsp/main/xtsfsp/ado") replace
```

# Compared to merge and joinby for handling large datasets
The `framerge` directly merge data between frames and avoid saving files to disks when using `merge` or `joinby` in the frame context. Intuitively, saving unnecessary temporary files into the disk may be inefficient, especially for large datasets. We compared the time costing of `framerge 1:m`, `merge 1:m`, `framerge m:m` and `joinby` for merging data between large datasets with different observations scale. All the code of testing and drawing can be seen in [test](). 
<!-- All the tests are conducted on a machine with Stata 18(8 cores), 12th Gen Intel(R) Core(TM) i9-12900 CPU @2.40GHz, 128GB RAM @4800MHz, and HDD Raid0. --> 

![macmini](https://github.com/user-attachments/assets/c1c755fc-79a6-4469-b76f-1facc3c1f2dd)

![nvme](https://github.com/user-attachments/assets/a003f7a9-623b-4674-94dc-85026875765a)


In merging 1:m and m:m, `framerge` takes less time than `merge` and `joinby` on average, except for merging 1:m with 10,000 observations, suggesting that our `framerge` command is more efficient than `merge` and `joinby` in handling large data. It is worth to mention that the gain of speed is from avoiding the slow Input/Output operations by saving and reading files.


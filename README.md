# framerge

Link frames and copy variables from using frames based on multiple match relationships in Stata. 
See the [manuscript]() for details.

# Requirement
* Stata 16 or later version

# Install with Stata Command
```
** install from github
<!-- net install framerge, from("https://raw.githubusercontent.com/kerrydu/xtsfsp/main/xtsfsp/ado") replace
net get xtsfsp, from("https://raw.githubusercontent.com/kerrydu/xtsfsp/main/xtsfsp/ado") replace -->
```

# Compared to merge and joinby for handling large datasets
The `framerge` directly merge data between frames and avoid saving files to disks when using `merge` or `joinby` in the frame context. Intuitively, saving unnecessary temporary files into the disk may be inefficient, especially for large datasets. We compared the time costing of `framerge 1:m`, `merge 1:m`, `framerge m:m` and `joinby` for merging data between large datasets with different observations scale. All the code of testing and drawing can be seen in [test](). 
<!-- (All the tests are conducted on a machine with Stata 18(8 cores), 12th Gen Intel(R) Core(TM) i9-12900 CPU @2.40GHz, 128GB RAM @4800MHz, and HDD Raid0. -->

![macmini](https://github.com/user-attachments/assets/c1c755fc-79a6-4469-b76f-1facc3c1f2dd)

![nvme](https://github.com/user-attachments/assets/a003f7a9-623b-4674-94dc-85026875765a)

In merging 1:m and m:m, `framerge` takes less time than `merge` and `joinby` on average, except for merging 1:m with 10,000 observations, suggesting that our `framerge` command is more efficient than `merge` and `joinby` in handling large data. It is worth to mention that the gain of speed is from avoiding the slow Input/Output operations by saving and reading files.

# Citation
If you use this module, please cite the following papers:

```
@article{mazrekaj_stata_2021,
	title = {Stata tip 142: joinby is the real merge m:m},
	volume = {21},
	issn = {1536-867X},
	url = {https://doi.org/10.1177/1536867X211063416},
	doi = {10.1177/1536867X211063416},
	shorttitle = {Stata tip 142},
	pages = {1065--1068},
	number = {4},
	journal = {The Stata Journal},
	author = {Mazrekaj, Deni and Wursten, Jesse},
	urldate = {2024-05-16},
	year = {2021},
	langid = {english}
}
```
Ho, A. T. Y., K. P. Huynh, D. T. Jacho-Ch´avez, and D. Rojas-Baez. 2021. Data Science in Stata 16: Frames, Lasso, and Python Integration. Journal of Statistical Software 98. http://www.jstatsoft.org/v98/s01/
```
@article{ho_data_2021,
	title = {Data Science in \textit{Stata} 16: Frames, Lasso, and \textit{Python} Integration},
	volume = {98},
	issn = {1548-7660},
	url = {http://www.jstatsoft.org/v98/s01/},
	doi = {10.18637/jss.v098.s01},
	shorttitle = {Data Science in \textit{Stata} 16},
	issue = {Software Review 1},
	journal = {Journal of Statistical Software},
	shortjournal = {J. Stat. Soft.},
	author = {Ho, Anson T. Y. and Huynh, Kim P. and Jacho-Chávez, David T. and Rojas-Baez, Diego},
	urldate = {2024-05-16},
	year = {2021},
	langid = {english}
}
```
Mazrekaj, D., and J. Wursten. 2021. Stata tip 142: joinby is the real merge m:m. The Stata Journal 21(4): 1065–1068. https://doi.org/10.1177/1536867X211063416.

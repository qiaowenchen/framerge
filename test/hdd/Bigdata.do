* 1:m case 

** generate master data 
clear
frame reset
set seed 123 

set obs 100000

gen id =_n 

gen double x = 10^6*runiform()+runiform()
save masterdta, replace

** generate using data
frame create usingframe 
frame usingframe{
	set seed 123 
	clear
	set obs 100000
	gen id =_n 
	expand 10
	bys id: gen year =_n
	gen double y = 10^6*runiform()+runiform()
	//save usingdta, replace
}

** test frlink2

timer clear 1
timer on 1

frlink2 1:m id, frame(usingframe)
frget y, from(usingframe)

timer off 1

timer list 1
scalar t1 = r(t1)

** test merge using the same master and using data
//frame drop usingframe
use masterdta, clear

timer clear 2
timer on 2
frame usingframe: save usingdta, replace
merge 1:m id using usingdta

timer off 2
timer list 2
scalar t2 = r(t2)

sort id year




* m:m case

** generate master data 
use masterdta, clear
expand 5
save masterdta_m, replace


** generate using data
frame create usingframe 
frame usingframe{
	use usingdta
}

** test frlink2

timer clear 3
timer on 3

frlink2 m:m id, frame(usingframe)
frget y, from(usingframe)

timer off 3

timer list 3
scalar t3 = r(t3)

** test joinby

cap frame drop usingframe

use masterdta_m, clear

timer clear 4
timer on 4

joinby id using usingdta

timer off 4

timer list 4
scalar t4 = r(t4)


scalar list

// 画图对比上述测试结果

clear
set obs 4
gen method = _n
gen time = .
replace time = t1 in 1
replace time = t2 in 2
replace time = t3 in 3
replace time = t4 in 4
twoway bar time method, title("Time costing between different methods") xlabel(1 "frlink2 1:m" 2 "merge 1:m" 3 "frlink2 m:m" 4 "joinby") ///
	ytitle("time(seconds)")

/*
// Second graph: frlink2 vs joinby
clear
set obs 2
gen method = _n
replace method = 1 in 1
replace method = 2 in 2
gen time = .
replace time = t3 in 1
replace time = t4 in 2
twoway bar time method, title("m:m") xlabel(1 "frlink2" 2 "joinby") ///
	ytitle("time(seconds)")
*/



//Q1:请写一个do测试脚本，产生测试数据，比较frlink2和joinby在大数据merge的运行时间，比较结果画图展示
//Q2: 对以上代码进行扩展：设置10组不同的obs，进行多种样本数的测试，对比运行时间，结果以图展示，横轴是样本数，纵轴是时间

clear
set more off

// Initialize arrays to store results
local num_tests 10
matrix frlink2_times = J(`num_tests', 1, .)
matrix joinby_times = J(`num_tests', 1, .)
matrix colnames frlink2_times = sample_size
matrix colnames joinby_times = sample_size

// Test different sample sizes
forvalues i = 1/`num_tests' {
    local obs = `i' * 100000

    // Generate test data
    set obs `obs'
    gen id1 = _n
    gen id2 = _n + round(runiform()*10, 0)
    gen value = runiform()

    tempfile data1
    save `data1'

    set obs = `obs' / 2
    gen id1 = _n*2
    gen id2 = _n*2 + round(runiform()*10, 0)
    gen other_value = runiform()

    tempfile data2
    save `data2'

    // Test frlink2
    use `data1', clear
    timer on 1
    frlink2 id1 id2 using `data2'
    timer off 1
    matrix frlink2_times[`i', 1] = r(t1)

    // Test joinby
    use `data1', clear
    timer on 2
    joinby id1 id2 using `data2'
    timer off 2
    matrix joinby_times[`i', 1] = r(t2)
}

// Display results
matrix list frlink2_times
matrix list joinby_times

// Plot results
twoway (line frlink2_times[sample_size] (1/`num_tests')*100000) ///
       (line joinby_times[sample_size] (1/`num_tests')*100000), ///
       ytitle("Time (seconds)") xtitle("Sample size") ///
       legend(order(1 "frlink2" 2 "joinby"))
	   
	   
	   



//比较frlink2 1:m, merge 1:m frlink2 m:m joinby
//的运行时间，设置不同的obs，进行多种样本数的测试，对比运行时间
//结果以图展示，横轴是样本数，纵轴是时间


clear
frame reset
cap scalar drop _all
// Define the list of sample sizes
local obslist ""
forvalues i = 1000(5000)100000 {
    local obslist "`obslist' `i'"
}

// Loop over each sample size
foreach obs in `obslist' {
    // Generate the master and using data
    clear
    set seed 123 
    set obs `obs'
    gen id =_n 
    gen double x = 10^6*runiform()+runiform()
    save masterdta, replace

    frame create usingframe 
    frame usingframe{
        set seed 123 
        clear
        set obs `obs'
        gen id =_n 
        expand 10
        bys id: gen year =_n
        gen double y = 10^6*runiform()+runiform()
        save usingdta, replace
    }

    // Test frlink2
    timer clear 1
    timer on 1
    frlink2 1:m id, frame(usingframe)
    frget y, from(usingframe)
    timer off 1
	timer list 1
    scalar _`obs't1 = r(t1)

    // Test merge
    frame drop usingframe
    use masterdta, clear
    timer clear 2
    timer on 2
    merge 1:m id using usingdta
    timer off 2
	timer list 2
    scalar _`obs't2 = r(t2)
	
	* m:m case

	** generate master data 
	use masterdta, clear
	expand 5
	save masterdta_m, replace


	** generate using data
	frame create usingframe 
	frame usingframe{
		use usingdta
	}

	** test frlink2
	
	timer clear 3
	timer on 3

	frlink2 m:m id, frame(usingframe)
	frget y, from(usingframe)

	timer off 3
	timer list 3
	scalar _`obs't3 = r(t3)

	** test joinby

	cap frame drop usingframe

	use masterdta_m, clear

	timer clear 4
	timer on 4

	joinby id using usingdta

	timer off 4
	timer list 4
	scalar _`obs't4 = r(t4)
}
	scalar list

clear
set obs 80

gen obs = .
gen t = .
gen time = .

local obs_list ""
forvalues obs = 1000(5000)100000 {
    local obs_list "`obs_list' `obs'"
}

local i = 1
foreach obs in `obs_list' {
    foreach t in 1 2 3 4 {
		scalar list _`obs't`t'
        replace obs = `obs' in `i'
        replace t = `t' in `i'
        replace time = _`obs't`t' in `i'
        local ++i
    }
}

reshape wide time, i(obs) j(t)

twoway (line time1 obs) (line time2 obs) (line time3 obs) (line time4 obs), ///
       legend(label(1 "frlink2 1:m") label(2 "merge 1:m") label(3 "frlink2 m:m") label(4 "joinby")) ///
       xtitle("Observations") ytitle("Time(seconds)")
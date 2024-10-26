
cd ~/desktop
adopath ++ "/Users/sigma/Library/CloudStorage/SynologyDrive-qwcwork/framerge/revise/new command"

clear all
frame reset
frame create usingframe

// Define the list of sample sizes
local olist 10 100 1000 2000 
mat define timer = J(4*100,3,.)
// Loop over each sample size
local i =1
forv l = 1/10{
foreach obs in `olist' {
    qui {
    tempfile m`obs'`l'
    tempfile u`obs'`l'
    // Generate the master and using data
    clear
    set seed 123 
    set obs 100000
    gen id =_n 
    expand 2
    gen double x = 10^6*runiform()+runiform()
    save `m`obs'`l'', replace 
    frame usingframe{
        set seed 123 
        clear
        set obs 1000
        gen id =_n 
        expand `obs'
        mat timer[`i',1] = `obs'*1000
        bys id: gen year =_n
        gen double y = 10^6*runiform()+runiform()
        gen strL ystr = string(y)
        clonevar ystr2 = ystr
        clonevar ystr3 = ystr
    }

    timer clear 1
    timer on 1
    framerge m:m id, frame(usingframe) get(y)
    timer off 1
	timer list 1
    mat timer[`i',2] = r(t1)

    // Test merge
    use `m`obs'`l'', clear
    timer clear 2
    timer on 2
    frame usingframe:qui save `u`obs'`l'', replace
    joinby id using `u`obs'`l'',  unmatched(master)
    timer off 2
	timer list 2
    mat timer[`i++',3] = r(t2)
    }
}

}
clear 
svmat timer, names(col)
format c1 %10.0g
rename c1 Obs
save timer_mm, replace

// 1:m

// Define the list of sample sizes
local olist 10 100 1000 2000 
mat define timer = J(4*100,3,.)
// Loop over each sample size
local i =1
forv l = 1/10{
foreach obs in `olist' {
    qui {
    tempfile m`obs'`l'
    tempfile u`obs'`l'
    // Generate the master and using data
    clear
    set seed 123 
    set obs 100000
    gen id =_n 
    gen double x = 10^6*runiform()+runiform()
    save `m`obs'`l'', replace 
    frame usingframe{
        set seed 123 
        clear
        set obs 1000
        gen id =_n 
        expand `obs'
        mat timer[`i',1] = `obs'*1000
        bys id: gen year =_n
        gen double y = 10^6*runiform()+runiform()
        gen strL ystr = string(y)
        clonevar ystr2 = ystr
        clonevar ystr3 = ystr
    }

    timer clear 1
    timer on 1
    framerge 1:m id, frame(usingframe) get(y)
    timer off 1
	timer list 1
    mat timer[`i',2] = r(t1)

    // Test merge
    use `m`obs'`l'', clear
    timer clear 2
    timer on 2
    frame usingframe:qui save `u`obs'`l'', replace
    merge 1:m id using `u`obs'`l'',  keep(1 3) nogen keepusing(y)
    timer off 2
	timer list 2
    mat timer[`i++',3] = r(t2)
    }
}

}
clear 

svmat timer, names(col)
format c1 %10.0g
rename c1 Obs
save timer_1m, replace


***figure 1***

/*
In order to make figure 1 more visible and beautiful, we used Matlab to finish
the drawing of figure 1.
The figure 1 produced by Matlab is the same pattern as the one drawn by the 
following codes.
*/

use timer_1m, clear

graph bar (mean) c2 c3, over(Obs) bar(1, color(green)) ///
    legend(label(1 "framerge 1:m") label(2 "merge 1:m") pos(11) ring(0)) ///
    ytitle("Time(seconds)") title("Mean of 1:m")
graph save 1m_mean_graph.gph, replace

graph bar (median) c2 c3, over(Obs) bar(1, color(green)) ///
    legend(label(1 "framerge 1:m") label(2 "merge 1:m") pos(11) ring(0)) ///
    ytitle("Time(seconds)") title("Median of 1:m")
graph save 1m_median_graph.gph, replace

graph bar (sum) c2 c3, over(Obs) bar(1, color(green)) ///
    legend(label(1 "framerge 1:m") label(2 "merge 1:m") pos(11) ring(0)) ///
    ytitle("Time(seconds)") title("Sum of 1:m")
graph save 1m_sum_graph.gph, replace


	
use timer_mm, clear

graph bar (mean)  c2 c3,  over(Obs) bar(1, color(blue)) ///
    legend(label(1 "framerge m:m") label(2 "joinby") pos(11) ring(0)) ///
    ytitle("Time(seconds)") title("Mean of m:m")
graph save mm_mean_graph.gph, replace    

graph bar (median)  c2 c3,  over(Obs) bar(1, color(blue)) ///
    legend(label(1 "framerge m:m") label(2 "joinby") pos(11) ring(0)) ///
    ytitle("Time(seconds)") title("Median of m:m")
graph save mm_median_graph.gph, replace

graph bar (sum)  c2 c3,  over(Obs) bar(1, color(blue)) ///
    legend(label(1 "framerge m:m") label(2 "joinby") pos(11) ring(0)) ///
    ytitle("Time(seconds)") title("Sum of m:m")
graph save mm_sum_graph.gph, replace    

graph combine 1m_mean_graph.gph 1m_median_graph.gph 1m_sum_graph.gph mm_mean_graph.gph mm_median_graph.gph mm_sum_graph.gph, xsize(15) ysize(5)

graph save merge_graph.gph, replace
graph export "merge_graph.png", as(png) name("Graph") replace

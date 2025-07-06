{smcl}
{* *! version 1.1.0  06mar2023}{...}
{vieweralsosee "[D] frlink" "mansection D frlink"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] fralias" "help fralias"}{...}
{vieweralsosee "[D] frget" "help frget"}{...}
{vieweralsosee "[D] frames intro" "help frames intro"}{...}
{vieweralsosee "[D] merge" "help merge"}{...}
{viewerjumpto "Syntax" "framerge##syntax"}{...}
{viewerjumpto "Description" "framerge##description"}{...}
{viewerjumpto "Links to PDF documentation" "framerge##linkspdf"}{...}
{viewerjumpto "Options" "framerge##options"}{...}
{viewerjumpto "Examples" "framerge##examples"}{...}
{viewerjumpto "Stored results" "framerge##results"}{...}
{p2colset 1 15 17 2}{...}
{p2col:{bf:[D] framerge} {hline 2}}Link frames and copy variable from the using frames {p_end}
{p2col:}({mansection D framerge:View complete PDF manual entry}){p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{marker linkage}{...}
{pstd}
Create linkage between current frame and another, and copy variables from the using frame to the current frame.

{p 8 35 2}
{cmd:framerge} {c -(}{cmd:1:1}|{cmd:m:1}|{cmd:1:m}|{cmd:m:m}{c )-}
{help framerge##varlist1:{it:varlist1}}{cmd:,}
{cmd:frame(}{it:frame2}
[{help framerge##varlist2:{it:varlist2}}]{cmd:)}{break}
[{cmdab:l:inkvar(}{help framerge##varlist3:{it:linkname}}{cmd:)}{break}
{cmd:get(}{help framerge##varlist3:{it:varlist3}}{cmd:)}{break}
{cmdab:pre:fix(}{it:string}{cmd:)}{break}
{cmdab:suf:fix(}{it:string}{cmd:)}{break}
{cmd:exclude(}{it:string}{cmd:)}]

{marker merge}{...}
{phang}
{cmd:1:1}, {cmd:m:1}, {cmd:1:m} and {cmd:m:m} indicate how observations are to be matched. 

{marker varlist1}{...}
{phang}
{it:{help varlist1:varlist1}} contains the match variables in the current
frame, which we will call frame 1.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:framerge} is an enhanced command of {cmd:frlink} and {cmd:frget} which is able to create linkages, 
and copy variables between different frames.  A linkage allows the variables in one frame to be
accessed by another.  See {helpb frames intro:[D] frames intro} if
you do not know what a frame is.


{marker linkspdf}{...}
{title:Links to PDF documentation}

        {mansection D frlink2Quickstart:Quick start}

        {mansection D frlink2Remarksandexamples:Remarks and examples}

{pstd}
The above sections are not included in this help file.


{marker options}{...}
{title:Options}

{marker opts_merge}{...}
{title:Options for framerge}

{marker varlist2}{...}
{phang}
{cmd:frame(}{it:frame2} [{it:{help varlist2:varlist2}}]{cmd:)} specifies the name of the
frame, {it:frame2}, and specifies the names of variables in {it:varlist2} to match in {it:frame2}.
If {it:varlist2} is not specified, the match variables are assumed to have 
the same names in both frames.  {cmd:frame()} is required.

{pmore}
     To create a link to a frame named {cmd:txcounty}, you can type 

{p 12 12 2}
{cmd:. framerge m:1 countyid, frame(txcounty) linkvar(txcounty)}

{pmore}
    This example omits specification of {it:varlist2}, and it works 
    when the match variable {cmd:countyid} has the same name 
    in both frames. If the variable were named {cmd:cntycode}, however, in 
    the other frame, you type 

{p 12 12 2}
    {cmd:. framerge m:1 countyid, frame(txcounty cntycode) linkvar(txcounty)}

{pmore}
    The rule for matching observations is thus that
    {cmd:countyid} in the current frame equals {cmd:cntycode} in the
    other frame.

{pmore}
    You can specify multiple match variables when necessary. 
    For example, you want to match on county names in U.S. data.
    County names repeat across the states, so you match on the 
    combined county and state names by typing 

{p 12 12 2}
{cmd:. framerge m:1 countyname statename, frame(txcounty) linkvar(txcounty)}

{pmore}
    If the match variables had different names in frame {cmd:txcounty},
    such as {cmd:cntycode} and {cmd:state}, you type

{p 12 12 2}
{cmd:. framerge m:1 countyid statename, frame(txcounty cntycode state) linkvar(txcounty)}

{marker linkname}{...}
{phang}
{cmdab:l:inkvar(}{it:{help linkname:linkname}}{cmd:)}
    specifies the name of the new variable that will contain
    all the information needed to link the frames.  This variable will be added to
    the dataset in frame 1.  {cmd:linkvar()} shold be specified when {cmd:get()} is not specifed.

{marker varlist3}{...}
{phang}
{cmd:get(}{it:{help varlist3:varlist3}}{cmd:)} 
        specifies the name of variables that we want to copy from the frame 
        we specified in the {cmd:frame()} option. If this option is not specified, the {cmd:framerge} 
        command creates the linkage between the current frame and the using frame

{pmore}
     To copy a variable from a frame named txcounty, you can type

{p 12 12 2}
{cmd:. framerge m:1 countyid, frame(txcounty) get(median_income)}

{phang}
{cmdab:pre:fix:(string)}
    specifies a string to be prefixed to the names of
    the new variables copied into the current frame.  Say that you type 

{p 12 12 2}
{cmd:. framerge m:1 countyid, frame(txcounty) get(median_income)}

{pmore}
    to request that variable {cmd:median_income} be
    copied to the current frame.  If variable {cmd:median_income} already
    exists in the current frame, the command would issue an error message to
    that effect and copy neither variable.  

{pmore}    
To copy this variable, you could type

{p 12 12 2}
{cmd:. framerge m:1 countyid, frame(txcounty) get(median_income) prefix(n_)}

{pmore}
    Then the variable would be copied to variable named 
    {cmd:n_median_income}.

{phang}
{cmdab:suf:fix:(string)}
    works like {cmd:prefix(}{it:string}{cmd:)}, the difference being that 
    the string is suffixed rather than prefixed to the variable names. 
    Both options may be specified if you wish. 


{phang}
{cmd: exclude({it:string})}
   specifies variables that are not to be copied.  An example of the
   option is

{p 12 14 2}
{cmd:. framerge m:1 countyid, frame(txcounty) get(*) exclude(emp*)}

{pmore}
    All variables except variables starting with {cmd:emp} would 
    be copied. 

{pmore}
    More correctly, all variables except {cmd:emp*}, {cmd:_*}, and the
    match variables would be copied because
    {cmd:get()} option always omits the underscore and match variables.  See the
    {mansection D frgetRemarksandexamplesexplain:explanation} below.



{marker examples}{...}
{title:Examples}

    {hline}

{pstd}Setup{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. webuse family}{p_end}
{phang2}{cmd:. frame create family}{p_end}
{phang2}{cmd:. frame family: webuse family    // yes, the same data}

{pstd}Create many-to-1 linkages{p_end}
{phang2}{cmd:. framerge m:1 pid_m, frame(family pid) linkvar(m)}{p_end}
{phang2}{cmd:. framerge m:1 pid_f, frame(family pid) linkvar(f)}

{pstd}Create a variable containing the ID of the current person's 
mother's mother, of the current person's mother's father,
of the current person's father's mother, and of the current person's
father's father{p_end}
{phang2}{cmd:. framerge m:1 pid_m, frame(family pid) get(pid_m) suf(_mm)}{p_end}
{phang2}{cmd:. framerge m:1 pid_m, frame(family pid) get(pid_f) suf(_mf)}{p_end}
{phang2}{cmd:. framerge m:1 pid_f, frame(family pid) get(pid_m) suf(_fm)}{p_end}
{phang2}{cmd:. framerge m:1 pid_f, frame(family pid) get(pid_f) suf(_ff)}

{pstd}Create many-to-1 linkages for each of the newly created variables
{p_end}
{phang2}{cmd:. framerge m:1 pid_m_mm, frame(family pid) linkvar(mm)}{p_end}
{phang2}{cmd:. framerge m:1 pid_f_mf, frame(family pid) linkvar(mf)}{p_end}
{phang2}{cmd:. framerge m:1 pid_m_fm, frame(family pid) linkvar(fm)}{p_end}
{phang2}{cmd:. framerge m:1 pid_f_ff, frame(family pid) linkvar(ff)}{p_end}

    {hline}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse discharge1, clear}{p_end}
{phang2}{cmd:. frame create discharge2}{p_end}
{phang2}{cmd:. frame discharge2: webuse discharge2}{p_end}

{pstd}Create 1-to-1 linkage to frame {cmd:discharge2} on variable
{cmd:patientid}{p_end}
{phang2}{cmd:. framerge 1:1 patientid, frame(discharge2) linkvar(discharge2)}

    {hline}



{pstd}Setup{p_end}
{phang2}{cmd:. webuse discharge1, clear}{p_end}
{phang2}{cmd:. frame create discharge2}{p_end}
{phang2}{cmd:. frame discharge2: webuse discharge2}{p_end}
{phang2}{cmd:. frame discharge2: expand 2}{p_end}

{pstd}Create one-to-many linkage to frame {cmd:discharge2} on variable
{cmd:patientid}{p_end}
{phang2}{cmd:. framerge 1:m patientid, frame(discharge2) linkvar(discharge2)}

    {hline}


{pstd}Setup{p_end}
{phang2}{cmd:. webuse discharge1, clear}{p_end}
{phang2}{cmd:. expand 2}{p_end}
{phang2}{cmd:. frame create discharge2}{p_end}
{phang2}{cmd:. frame discharge2: webuse discharge2}{p_end}
{phang2}{cmd:. frame discharge2: expand 2}{p_end}

{pstd}Create many-to-many (joinby) linkage to frame {cmd:discharge2} on variable
{cmd:patientid}{p_end}
{phang2}{cmd:. framerge m:m patientid, frame(discharge2) linkvar(discharge2)}

    {hline}


{pstd}Setup{p_end}
{phang2}{cmd:. webuse discharge1, clear}{p_end}
{phang2}{cmd:. expand 2}{p_end}
{phang2}{cmd:. frame create discharge2}{p_end}
{phang2}{cmd:. frame discharge2: webuse discharge2}{p_end}
{phang2}{cmd:. frame discharge2: expand 2}{p_end}

{pstd}Copy a variable from the using frame with many-to-many matched variable {cmd:patientid} without creating linkage{p_end}

{phang2}{cmd:. framerge m:m patientid, frame(discharge2) get(age) suf(_c)}

    {hline}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:framerge} store the following in
{cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt :{cmd:r(unmatched)}}{it:#} of observations in the current
frame unable to be matched{p_end}


{marker Note}{...}
{title:Note}
{phang}
{cmd: framerge m:m} operation establishes a {cmd:joinby} relationship, as opposed to the relationship generated by the {cmd: merge m:m} operation. {cmd: framerge 1:1} and {cmd: framerge m:1} are aliases of {cmd: frlink 1:1} 
and {cmd: frlink m:1}, respectively. {cmd: framerge} also supports subcommands {cmd: dir}, {cmd: describe}, {cmd: rebuild}, and drop which are subcommands of {cmd: frlink}.

{marker Cautions}{...}
{title:Cautions}
{phang}
{cmd:framerge 1:m} and {cmd:framerge m:m} would create a variable {it: rownum_usingdta}. 
If this variable has existed in the current data or the using data, 
the command would throw an error. 


{marker Authors}{...}
{title:Authors}
{phang}
{cmd:Kerry Du}, School of Managemnet, Xiamen University, China.{break}
 E-mail: {browse "mailto:kerrydu@xmu.edu.cn":kerrydu@xmu.edu.cn}. {break}

{phang}
{cmd:Qiaowen Chen}, School of Managemnet, Xiamen University, China.{break}
 E-mail: {browse "chenqiaowen@stu.xmu.edu.cn":chenqiaowen@stu.xmu.edu.cn}. {break}

{title:Also see}
{p 7 14 2}Help:  {help frlink}, {helpb frget}, 
{helpb merge}, {helpb joinby} {p_end}






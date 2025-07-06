* Tusday, October 8, 2024 at 16:12 remove the data signature parts
* Monday, May 27, 2024 at 22:41:54 if get() is empty, exit with linkage variable
program framerge16, rclass 
version 16
syntax anything, frame(string) [Linkvar(name)    /*keep linkvar as specified name
	                         */ get(string)      /* get varlist from frame()
							 */	PREfix(string)   /* prefix new variable names with string
							 */	SUFfix(string)   /* suffix new variable names with string
							 */	exclude(string) /* exclude specified variablesg
							 */  ]

	local orig `"`0'"'
    gettoken subcmd 0 : 0, parse(" ,")
    local frgetopts prefix(`prefix') suffix(`suffix') exclude(`exclude')
	gettoken frame varlist2 : frame
    if `"`linkvar'"'=="" local linkfr `frame'
    else local linkfr `"`linkvar'"'
	if `"`get'"' == ""  & `"`linkvar'"' ==""{
	 di as error "linkvar() shold be specified when get() is not specifed."
	 exit 198
	}
	if `"`get'"'!=""{ //check variables in get() are in frame `frame'
		cap frame `frame': checkvars `get'
		if _rc!=0{
			di as error "variables in get() not found in frame `frame'"
			frame `frame': checkvars `get'
		}
	}


	if ("`subcmd'"=="1:m" ) {
        gettoken v anything:anything
		frlink_gen1m `anything', frame(`frame' `varlist2') gen(`linkvar')
		if `"`get'"' == "" exit
        frget `get', from(`linkfr') `frgetopts'
        if `"`linkvar'"' == ""{
			qui drop `frame'
            qui drop rownum_usingdta
            frame `frame'{
				qui drop rownum_usingdta
			}
        } 
		//exit
	}
	else if ("`subcmd'"=="m:m" ){
        gettoken v anything:anything
		frlink_genmm `anything', frame(`frame' `varlist2') gen(`linkvar')
        frame `frame': qui  _datasignature rownum_usingdta, nonames
		if `"`get'"' == "" exit
        frget `get', `frgetopts' from(`linkfr')
        if `"`linkvar'"' == ""{
            qui drop  `linkfr'
            qui drop rownum_usingdta
            frame `frame'{
				qui drop rownum_usingdta
			}
        } 
		//exit		
	}
	else{ //using official frlink
        qui frlink `anything', frame(`frame' `varlist2') gen(`linkvar')
		if `"`get'"' == "" exit
        frget `get', `frgetopts' from(`linkfr')
        if `"`linkvar'"' == "" qui drop  `frame'
	}


end


////////////////////////subcommands////////////////////////
program define checkvars
version 16
syntax varlist
end


*framerge m:m
program define frlink_genmm, rclass 

	version 16



	*/The following codes are adapted from Stata oficial command frlink_gen*/

	/* ------------------------------------------------------------ */
					// check frame1

	local frame1 `c(frame)'
		cap confirm var rownum_usingdta
	if _rc==0{
		di as error "key variables: rownum_usingdta exists in frame `frame1'"
		error 198
	}




	
	/* ------------------------------------------------------------ */
					// parse
	gettoken mtyp: 0 

	syntax varlist , FRame(string)	  ///
		         [ GENerate(name) ///
			   DEBUG(string)     ]

	//_alias_not_allowed `varlist'

	// ---------------------------------------------------------------
					// parse frame(<frame2> [<varlist2]]

	frameop_parse frame2 varlist2 :   `"`frame'"'

					// parse debug([nodate] [d|v])
					// sets    
					//        usedate = 1|0 (default 1)
					//        usedata = 1|0 
					// usedate means phony date
					// usedata means use st_data

					// set default for usedata
	local usedata_default 1		// use 0=st_view(), 1=st_data()
	debugop_parse usedate usedata  : `usedata_default' `"`debug'"'

	// ---------------------------------------------------------------
					// generate(<newvarname>) 

	if ("`generate'"=="") {
		local generate `frame2'
	}
	capture confirm new variable `generate'
	if (_rc) {
		di as err "variable `generate' already exists"
		exit 110
	}

	// ---------------------------------------------------------------
					// check variables 
	if ("`varlist2'" != "") {
		confirm_var_cnt        "`varlist'"          "`varlist2'"
		confirm_var_typ_match  "`varlist'" `frame2' "`varlist2'"
	}
	else {
		confirm_var_exist      "`varlist'" `frame2' 
		confirm_var_typ_match  "`varlist'" `frame2' "`varlist'"
	}

	/* ------------------------------------------------------------ */
					// make varlist2p

	if ("`varlist2'"=="") {
		local varlist2p `varlist'
	}
	else {
		local varlist2p `varlist2'
	}
		
	/* ------------------------------------------------------------ */
					// set frame2

	frame `frame2' {
		quietly cwf `frame2'
		cap confirm var rownum_usingdta
		if _rc==0{
			di as error "key variable: rownum_usingdta exists in frame `frame2'"
			error 198
		}
	}

	// frame2:
	capture frame `frame2' {
		sort `varlist2p'
		by `varlist2p': assert _n==1
	}
	if (_rc==0) {
		di as "Warning: {`varlist2p'} uniquely identify observations in frame `frame2'"
		di as "         using frlink m:1 or frlink 1:1 is recommended."
	}

    




	frame `frame2'{
		bys `varlist2p': gen rownum_usingdta = _n
		tempname _temp_
		qui frame put `varlist2p' rownum_usingdta, into(`_temp_')
		sort `varlist2p' rownum_usingdta
	}

	frame `_temp_'{
		qui collapse (max) rowN_usingdta = rownum_usingdta, by(`varlist2p')
	}



	// obtain rowN_u from `_temp_'
	qui frlink m:1 `varlist' , frame(`_temp_' `varlist2p')
	qui frget rowN_usingdta, from(`_temp_') 
	qui frame drop `_temp_'
	cap drop `_temp_'
	
	// replicate the master data by rowN_u times
	tempvar rownum_usingdta
	qui bys `varlist': gen `rownum_usingdta' = _n
	qui expand rowN_usingdta
	qui drop rowN_usingdta

	//generate a rownum identifier for each obs in the master data
	qui bys `varlist' `rownum_usingdta': gen rownum_usingdta = _n


	qui frlink m:1 `varlist' rownum_usingdta , frame(`frame2' `varlist2p' rownum_usingdta) gen(`generate')



end




program define frlink_gen1m, rclass 

	version 16



	*/The following codes are adapted from Stata oficial command frlink_gen*/

	/* ------------------------------------------------------------ */
					// check frame1

	local frame1 `c(frame)'
		cap confirm var rownum_usingdta
	if _rc==0{
		di as error "key variables: rownum_usingdta exists in frame `frame1'"
		error 198
	}



	
	/* ------------------------------------------------------------ */
					// parse
	gettoken mtyp: 0 

	syntax varlist , FRame(string)	  ///
		         [ GENerate(name) ///
			   DEBUG(string)     ]

	//_alias_not_allowed `varlist'

	// ---------------------------------------------------------------
					// parse frame(<frame2> [<varlist2]]

	frameop_parse frame2 varlist2 :   `"`frame'"'

					// parse debug([nodate] [d|v])
					// sets    
					//        usedate = 1|0 (default 1)
					//        usedata = 1|0 
					// usedate means phony date
					// usedata means use st_data

					// set default for usedata
	local usedata_default 1		// use 0=st_view(), 1=st_data()
	debugop_parse usedate usedata  : `usedata_default' `"`debug'"'

	// ---------------------------------------------------------------
					// generate(<newvarname>) 

	if ("`generate'"=="") {
		local generate `frame2'
	}
	capture confirm new variable `generate'
	if (_rc) {
		di as err "variable `generate' already exists"
		exit 110
	}

	// ---------------------------------------------------------------
					// check variables 
	if ("`varlist2'" != "") {
		confirm_var_cnt        "`varlist'"          "`varlist2'"
		confirm_var_typ_match  "`varlist'" `frame2' "`varlist2'"
	}
	else {
		confirm_var_exist      "`varlist'" `frame2' 
		confirm_var_typ_match  "`varlist'" `frame2' "`varlist'"
	}

	/* ------------------------------------------------------------ */
					// make varlist2p

	if ("`varlist2'"=="") {
		local varlist2p `varlist'
	}
	else {
		local varlist2p `varlist2'
	}
		
	/* ------------------------------------------------------------ */
					// set frame2
	frame `frame2' {
		quietly cwf `frame2'
		cap confirm var rownum_usingdta
		if _rc==0{
			di as error "key variable: rownum_usingdta exists in frame `frame2'"
			error 198

		}
	}


	// frame2:
	capture frame `frame2' {
		sort `varlist2p'
		by `varlist2p': assert _n==1
	}
	if (_rc==0) {
		di as "Warning: {`varlist2p'} uniquely identify observations in frame `frame2'"
		di as "         using frlink m:1 or frlink 1:1 is recommended."
	}
    
	frame `frame2' {
		// generate a rownumber variable rownum_usingdta for unique indentification
		qui bys `varlist2p' : gen rownum_usingdta = _n
        tempname _temp_
	    qui frame put `varlist2p' rownum_usingdta, into(`_temp_')
		sort `varlist2p' rownum_usingdta
	}

	frame `_temp_'{
		qui collapse (max) rowN_usingdta = rownum_usingdta, by(`varlist2p')
	}

	// obtain rowN_u from `_temp_'
	qui frlink 1:1 `varlist', frame(`_temp_' `varlist2p')
	qui frget rowN_usingdta, from(`_temp_') 
	qui frame drop `_temp_'
	cap drop `_temp_'

	// replicate the master data by rowN_u times
	qui expand rowN_usingdta
	qui drop rowN_usingdta

	//generate a rownum identifier for each obs in the master data
	qui bys `varlist' : gen rownum_usingdta = _n 




	frlink 1:1 `varlist' rownum_usingdta, frame(`frame2' `varlist2p' rownum_usingdta) gen(`generate')


end

/* -------------------------------------------------------------------- */
						// confirm_var_typ_match
/*
    confirm_var_typ_match "<varlist1>" <frame2> "<varlist2>"

	Confirm that <default>::<varlist1> variables have the 
	same type as <frame2>::<varlist2>.

	This routine assumes there are the same number of variables in 
	each varlist.
*/

program confirm_var_typ_match
	args varlist1 frame2 varlist2

	foreach name1 of local varlist1 {
		gettoken name2 varlist2 : varlist2
		confirm_var_typ_u g2 : `name1'
		frame `frame2': confirm_var_typ_u g1 : `name2'
		if ("`g1'"!="`g2'") { 
			if ("`name1'"=="`name2'") {
				di as err "`name1' variable types mismatch"
			}
			else {
				di as err ///
				"`name1'/`name2' variable types mismatch"
			}
			exit 459
		}
		//frame `frame2': _alias_not_allowed `name2'
	}
end
		
program confirm_var_typ_u 
	args	gtypemac colon varname

	local typ : type `varname'
	if (substr("`typ'", 1, 3) == "str") {
		c_local `gtypemac' str
	}
	else {
		c_local `gtypemac' num
	}
end


/* -------------------------------------------------------------------- */
					// confirm_var_exist

/*
    confirm_var_exist "<varlist1>" <frame2>

	Confirm that each unabbreviated variable name in <varlist1>
	exists in <frame2> in unabbreviated form.
	Issues error message
*/


program confirm_var_exist
	args varlist1 frame2

	/* ------------------------------------------------------------ */
				// confirm vars exist, perhaps
				// in abbreviated form

	foreach name1 of local varlist1 {
		capture frame `frame2': confirm var `name1'
		if (_rc) {
			di as err ///
			"variable {bf:`name1'} not found in frame `frame2'"
			exit 111
		}
	}

	/* ------------------------------------------------------------ */
				// unabbreviate <varlist1> in <frame2>
				// we know this will not error out
				// because we just checked existence

	frame `frame2': unab ulist2 : `varlist1'

	/* ------------------------------------------------------------ */
				// verify unabbreviated names equal 
				// names in <varlist1> 

	foreach name1 of local varlist1 {
		gettoken name2 ulist2 : ulist2
		if ("`name1'"!="`name2'") {
			di as err ///
			"variable {bf:name1} not found in frame `frame2'"
			exit 111
		}
	}
end


/* -------------------------------------------------------------------- */
					// debugop_parse
/*
	framedebug_parse usedate usedate : dflt_usedata str

	Parse
		[nodate [d|v]]
	
	Return
		usedate	0|1,            0 if -nodate- specified
		usedata 0|1, dflt_usedata if -d- and -v- not specified
                                        1 if -d- specified
				        0 if -v- specified
				    error if -d- and -v- specified
*/

program debugop_parse
	args m_usedate m_usedata colon dflt_usedata str

	local 0 `", `str'"'
	syntax [, NODATE D V]

	// -----------------------------------------------------------
						// set m_usedate

	local x = cond("`nodate'"=="", 1, 0)
	c_local `m_usedate' `x'

	// -----------------------------------------------------------
						// set m_usedata


	local dv = "`d'`v'"
	if ("`dv'"=="") {
		c_local `m_usedata' `dflt_usedata'
		exit
		// NotReached
	}

	if ("`dv'"=="d") {
		local x 1 
	}
	else if ("`dv'"=="v") {
		local x 0
	}
	else {
		di as err "option {bf:debug()} used incorrectly"
		exit 198
	}

	c_local `m_usedata' `x'
	local y = cond(`x', "st_data()", "st_view()")
	local z = cond(`x'!=`dflt_usedata', "(overriding default)", ///
					    "(which is default)")
	di as txt "  DEBUG: using `y' `z'"
end



/*-----------------------------------------------*/



*! version 1.1.0  01mar2023
program frget2
	version 16
	syntax anything(equalok),	///
		from(varname)		///
	[	PREfix(string)		///
		SUFfix(string)		///
		EXclude(string)		///
	]

	frlink_dd get frame : `from' fname2
	frlink_dd get match : `from' vl2p

	local EQ = ustrpos(`"`anything'"', "=")
	if `EQ' {
		if `"`prefix'"' != "" {
			di as err "option {bf:prefix()} not allowed"
			exit 198
		}
		if `"`suffix'"' != "" {
			di as err "option {bf:suffix()} not allowed"
			exit 198
		}
		if `"`exclude'"' != "" {
			di as err "option {bf:exclude()} not allowed"
			exit 198
		}

		// generated macros:
		// 	K	- number of pairs
		// 	src#	- source variable in #th pair
		// 	new#	- new variable in #th pair
		ParseEQ `frame' `anything'
	}
	else {
		if "`prefix'" != "" {
			CheckNamePart prefix `"`prefix'"'
		}
		if "`suffix'" != "" {
			CheckNamePart suffix `"`suffix'"'
		}

		// generated macros:
		// 	K	- number of pairs
		// 	src#	- source variable in #th pair
		// 	new#	- new variable in #th pair
		//	xcluded	- list of excluded variables 
		ParseList `frame' `anything' ,	///
			prefix(`prefix')	///
			suffix(`suffix')	///
			exclude(`exclude')	///
			match(`match')
	}

	forval i = 1/`K' {
		_frget `from' `new`i'' = `src`i''
		local newlist `newlist' `new`i''
		local srclist `srclist' `src`i''
	}
	Post "`newlist'" "`srclist'" "`xcluded'"
end

program Post, rclass
	args newlist srclist xcluded
	local k : list sizeof newlist
	if `k' != 1 {
		local s s
	}
	di as txt "{p 0 1 2}"
	di as txt "(`k' variable`s' copied from linked frame)"
	di as txt "{p_end}"
	return scalar k = `k'
	return local newlist `newlist'
	return local srclist `srclist'
	return local excluded `xcluded'
end

program CheckNamePart
	args name value

	local p : list sizeof prefix
	if `p' > 1 {
		di as err "invalid {bf:`name'()} option;"
		di as err "only one word can be used as a `name'"
		exit 198
	}
	capture confirm name `value'
	if c(rc) {
		di as err "invalid {bf:`name'()} option;"
		di as err "{bf:`value'} found where a name `name' expected"
		exit 198
	} // c(rc)
end

program NotName
	local n : list sizeof 0
	if `n' == 0 {
		exit
	}
	if `n' == 1 {
		di as err "{bf:`0'} invalid varname"
		exit 198
	}
	di as err "{bf:`1'} found where a varname was expected;"
	di as err "{p 0 0 2}"
	di as err "invalid name specifications: "
	di as err "`0'"
	di as err "{p_end}"
	exit 198
end

program Ambig
	local n : list sizeof 0
	if `n' == 0 {
		exit
	}
	if `n' == 1 {
		di as err "{bf:`0'} ambiguous abbreviation"
		exit 111
	}
	di as err "{bf:`1'} ambiguous abbreviation;"
	di as err "{p 0 0 2}"
	di as err "ambiguous abbreviations: "
	di as err "`0'"
	di as err "{p_end}"
	exit 111
end

program NotFound, rclass
	local n : list sizeof 0
	if `n' == 0 {
		exit
	}
	return local notfound `"`0'"'
	if `n' == 1 {
		di as err "variable {bf:`0'} not found"
		exit 111
	}
	di as err "{p 0 0 2}"
	di as err "variables not found: "
	di as err "{bf}`0'{reset}"
	di as err "{p_end}"
	exit 111
end

program NewVarlist, rclass
	local reps : list dups 0
	local reps : list uniq reps
	local nreps : list sizeof reps
	if `nreps' {
		if `nreps' > 1 {
			local s s
		}
		di as err "{p 0 0 2}"
		di as err "duplicate new variable names not allowed;{break}"
		di as err "duplicate name`s': {bf}`reps'{reset}"
		di as err "{p_end}"
		exit 110
	}

	foreach v of local 0 {
		capture confirm new variable `v'
		if c(rc) {
			local dups `dups' `v'
		}
	}

	local ndups : list sizeof dups
	if `ndups' == 0 {
		exit
	}
	return local dups `"`dups'"'
	if `ndups' == 1 {
		di as err "variable {bf:`dups'} already exists"
		exit 110
	}
	di as err "{p 0 0 2}"
	di as err "variables that already exist: "
	di as err "{bf}`dups'{reset}"
	di as err "{p_end}"
	exit 110
end

program ParseEQ
	// Syntax:
	// 	<frame> <pair> [<pair> ...]
	//
	// 	<pair>:
	// 		<newvarname> = <varname>
	//
	// <newvarname> is new in the current frame
	// <varname> refers to a variable in frame <frame>
	gettoken frame 0 : 0

	local i 0
	while `:list sizeof 0' {
		local ++i
		gettoken new`i' 0 : 0, parse(" =")
		capture confirm name `new`i''
		if c(rc) {
			local notname `notname' `new`i''
		}
		local newlist `newlist' `new`i''
		gettoken EQ 0 : 0, parse(" =")
		if `"`EQ'"' != "=" {
			di as err ///
			`"{bf:`EQ'} found where equal sign, {bf:=}, expected"'
			exit 198
		}
		gettoken src`i' 0 : 0, parse(" =")
		capture confirm name `src`i''
		if c(rc) {
			local notname `notname' `src`i''
		}
	}

	NotName `notname'

	local K = `i'

	frame `frame' {
		forval i = 1/`K' {
			capture unab thevar : `src`i''
			if c(rc) {
				if c(varabbrev) == "on" {
					capture unab thevar : `src`i''*
					if c(rc) == 0 {
						local ambig `ambig' `src`i''
						local src`i'
					}
				}
				local notfound `notfound' `src`i''
			}
			else {
				local src`i' = `"`thevar'"'
			}
		}
	}

	Ambig `ambig'
	NotFound `notfound'
	NewVarlist `newlist'

	forval i = 1/`K' {
		c_local src`i' `src`i''
		c_local new`i' `new`i''
	}
	c_local K `K'
end

program Excluded
	local n : list sizeof 0
	if `n' == 0 {
		exit
	}
	local 0 : list retok 0
	if `n' > 1 {
		local s s
	}
	di as txt "{p 0 1 2}(variable`s' not copied from linked"
	di as txt "frame: {bf}`0'{reset})"
	di as txt "{p_end}"
end

program ParseList
	gettoken frame 0 : 0

	frame `frame' {
		syntax varlist [,		///
			prefix(string)		///
			suffix(string)		///
			exclude(varlist)	///
			match(varlist)		///
		]
	}

	local varlist : list uniq varlist
	local xcluded : list varlist & exclude
	local varlist : list varlist - exclude
	local matched : list varlist & match
	local varlist : list varlist - match
	local system
	foreach v of local varlist {
		if substr("`v'",1,1) == "_" {
			local system `system' `v'
		}
	}
	local varlist : list varlist - system

	Excluded `xcluded' `matched' `system'

	local i 0
	foreach v of local varlist {
		local ++i
		c_local src`i' `v'
		local new `prefix'`v'`suffix'
		c_local new`i' `new'
		local newlist `newlist' `new'
	}
	c_local K `i'

	NewVarlist `newlist'

	c_local xcluded `xcluded' `matched' `system'
end











	
/* -------------------------------------------------------------------- */
					// frameop_parse

/*
	frameop_parse m1 m2 : str

	Parse
		<frname> [<varlist_in_frname>]

	return:
		m1   <frname>
                m2   <varlist_in_frname> or ""
*/
	
	
program frameop_parse
	args frame2mac varlist2mac colon str


	local frame1 `c(frame)'

	/* ------------------------------------------------------------ */
						// Parse <frname>
	gettoken frame2 0 : str
	if ("`frame2'" == "") {
		frameop_err `"`frame(`frameop')"'
		// NotReached
	}

	/* ------------------------------------------------------------ */
						// Check <frname> is specified
						// in a valid manner

	capture confirm name `frame2'
	if (_rc) {
		local rc = _rc 
		di as err "{bf:frame()} option specified incorrectly"
		di as err "{p 4 4 2}"
		di as err "The option requires a name of an existing frame,"
		di as err "optionally followed by the names of one or more"
		di as err "match variables in that frame.  You specified"
		di as err `""{bf:`frame2'}" as the frame name, which Stata"'
		di as err "thinks is not a valid name.  Perhaps you included"
		di as err "punctuation such as a comma."
		di as err "{p_end}"
		exit `rc'
	}

	/* ------------------------------------------------------------ */
						// Check <frname> exists
						// Parse <varlist> 
	
	capture noi frame `frame2': syntax [varlist(default=none)]
	if (_rc) {
		local rc = _rc 
		di as err "{p 4 4 2}"
		di as err "The error refers to a variable in frame `frame2'."
		di as err "Perhaps you made an obvious mistake."
		di as err "If, however, the variables used for matching"
		di as err "have different names in the two frames, then"
		di as err "{p_end}"
		di as err "{p 8 12 2}"
		di as err "1.  Specify `frame1''s variable name(s) just as you"
		di as err "are now doing, following the {bf:frlink}"
		di as err "command."
		di as err "{p_end}"
		di as err "{p 8 12 2}"
		di as err "2.  Specify `frame2''s corresponding name(s)"
		di as err "in the {bf:frame(`frame2')} option.  The"
		di as err "syntax is {bf:frame(`frame2'} {it:varlist}{bf:)}."
		di as err "{p_end}"
		exit `rc'
	}


	/* ------------------------------------------------------------ */
						// Done

	c_local   `frame2mac' `frame2'
	c_local `varlist2mac' `varlist'
end

program frameop_err
	args	specified
	di as err "option frame() misspecified"
	di as err "{p 4 4 2}"
	di as err `"You specified {bf:`specified'}."'
	di as err "The syntax of frame() is"
	di as err "{p_end}"
	di as err
	di as err "{col 8}{bf:frame(}{it:framename}{bf:)}" 
	di as err "   {it:or}"
	di as err "{col 8}{bf:frame(}{it:framename}{bf:)} {it:varlist}{bf:)}" 
	di as err 
	di as err "{p 4 4 2}"
	di as err "Use the first syntax when the match variables have"
	di as err "the same name in {it:framename} as they do in"
	di as err "the current frame.  The second is for when they differ."
	di as err "{p_end}"
	exit 198
end

					// frameop_parse
/* -------------------------------------------------------------------- */


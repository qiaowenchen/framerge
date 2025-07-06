* Tusday, October 8, 2024 at 16:12 remove the data signature parts
* Monday, May 27, 2024 at 22:41:54 if get() is empty, exit with linkage variable
program framerge, rclass 
	syntax anything, frame(string) [Linkvar(name)    /*keep linkvar as specified name
								*/ get(string)      /* get varlist from frame()
								*/	PREfix(string)   /* prefix new variable names with string
								*/	SUFfix(string)   /* suffix new variable names with string
								*/	exclude(string) /* exclude specified variablesg
								*/  ]

	if `c(version)' < 16{
		version 16
	}
	else if `c(version)' >= 17{
		framerge17 `0'
	}
	else{
		framerge16 `0'
	}
end
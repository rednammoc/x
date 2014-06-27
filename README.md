xdir will store the path to the current folder in a list and restore it when required.  

Usage:
	xdir [OPTION...]

Options:

	-a [folder] 	append folder to current profile. 
 			 when no folder is specified, the current folder 
 			 will be appended to the current profile.
	-p [folder] 	prepend folder to list. when no folder is 
 			 specified, the current folder will be prepended
 			 to the current profile.
 	-l 		list folders within current profile.
 	-r [number]	restore nth folder from the current profile.
 			 when no number is specified, the current profile
 			 will be printed and the user will be prompted
 			 to specify a number.
 	-d [number]	delete nth folder from the current profile.
 			 when no number is specified, the current profile
 			 will be printed and the user will be prompted
 			 to specify a number.
	-c 		clear current profile.
	-pc [name] 	create new profile. when no name is specified
			 the user will be prompted to specify one.
	-ps [name] 	select profile. when no name is specified
			 a list of profiles will be printed to select from.
	-pl [number]	list folders of nth profile. when no number
			 is specified, a list of available profiles will be
			 printed.
	-pi		show info about current profile.
	-h 		show this help.

Examples:

	# store current folder
	:/$ xdir -a

	# store another folder
	:/$ xdir -a /bin

	# list all stored folders
	:/$ xdir -l
	1	/
	2	/bin

	# restore second entry "/bin"
	:/$ xdir -r 2
	:/bin$ sudo ./make_me_a_sandwich"


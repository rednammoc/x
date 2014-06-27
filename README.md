Store and navigate to paths within a list.  

Usage:
	x [OPTION...]

Options:

	-a [path] 	    append path to list. (default: current path)
	-p [path] 	    prepend path to list. (default: current path)
 	-r [index]	    restores nth path from list.
 	-d [index]	    deletes nth path from list.
	-c 		        clear list.
	-h 		        show this help.

Examples:

	# store current path
	:/$ x -a

	# store another path
	:/$ x -a /bin

	# list all stored paths
	:/$ x -l
	1	/
	2	/bin

	# restore second entry "/bin"
	:/$ x -r 2
	:/bin$ sudo ./make_me_a_sandwich"


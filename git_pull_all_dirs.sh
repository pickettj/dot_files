# https://stackoverflow.com/questions/3497123/run-git-pull-over-all-subdirectories
#find . searches the current directory
#-type d to find directories, not files
#-depth 1 for a maximum depth of one sub-directory
#-exec {} \; runs a custom command for every find
#git --git-dir={}/.git --work-tree=$PWD/{} pull git pulls the individual directories

# find . -type d -depth 1 -exec echo git --git-dir={}/.git --work-tree=$PWD/{} status \;


find . -type d -depth 1 -exec git --git-dir={}/.git --work-tree=$PWD/{} pull origin master \;

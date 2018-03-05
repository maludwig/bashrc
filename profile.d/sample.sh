# This example shows you how to make your own custom extensions to your bash profile
# Any time a user logs in with the bashrc extensions installed, 
#  the ~/profile.d/ folder (if it exists) is searched for all *.sh scripts
#  which are then sourced

# Lines with a hashtag in from of them are commented out

# MYSECRETPASSWORD='uW!llNVR_EVR_EVRguessThis1,haha'
# function myssh { ssh -p 2222 katniss@"$1"; }
# alias cdd="cd $HOME/dev"

# Lines without a hashtag are actually executed
# This will make the terminal go directly to the user's home directory when it launches
cd "$HOME"

# This is all just normal bash that is just run as if you'd directly typed it in with your hands



# # This common set of functions can be included in many scripts
# # All of the functions below should work in zsh and bash

# #30 = black
# #31 = red
# #32 = green
# #33 = yellow
# #34 = blue
# #35 = pink
# #36 = cyan
# #37 = white

_colors_test () {
  echo -e "${CBLACK}This is black${CDEFAULT}"
  echo -e "${CRED}This is red${CDEFAULT}"
  echo -e "${CGREEN}This is green${CDEFAULT}"
  echo -e "${CYELLOW}This is yellow${CDEFAULT}"
  echo -e "${CBLUE}This is blue${CDEFAULT}"
  echo -e "${CPINK}This is pink${CDEFAULT}"
  echo -e "${CCYAN}This is cyan${CDEFAULT}"
  echo -e "${CWHITE}This is white${CDEFAULT}"
  echo -e "${CDEFAULT}This is the default${CDEFAULT}"
  ask-yes "Are these the right colors?" && [[ "$ASK" == "y" ]]
}
_colors_test

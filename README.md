# bashrc

CentOS 7 ![CentOS 7 Build Status](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiRkNZSzBhdFlQZzg5RUY4UHY2Z216L0lPbGFQUWZiZEV0MGZwT3ZPMnlmbjBQVFhITk9KQjFhNnk2dTVpbnhIbytMWDZUUURtaE16azI2WEQ1Vm5Ic3hBPSIsIml2UGFyYW1ldGVyU3BlYyI6Ilhmbi8rY1NwR2t4U1F1eWwiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
CentOS 8 ![CentOS 8 Build Status](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoieVo5dmRJTENXMG1zQlpwSFJ3M2lQb3JhUlNsV2ExV3RkUDcwUG9DVjMvQWIwNUs4NUxmbHFMVzl5QWdQWlhLVHl1T3Brdm1XMm9wVTVad0Z0S2ZuYU1JPSIsIml2UGFyYW1ldGVyU3BlYyI6IklpbjliYSs1R1ZrN0Y2bXQiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
Ubuntu 18 ![Ubuntu 18 Build Status](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiaUl5c2Vodkg1QkZGcmJnMmZaV1VxSkQwakhsaW41Nkx6SC9EZEpPdXVGY2F1Nm1PMnI2NFZQRGhxeEE1LzFab1ZWSTlzeWNCa3lJQmJzTy9ha0JJeXNZPSIsIml2UGFyYW1ldGVyU3BlYyI6IjVvSnlBYVdpOG1kcXNlZzMiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

This is a collection of all of my favorite customizations for bash and zsh.

### Installation

```bash
git clone https://github.com/maludwig/bashrc
./bashrc/install
```

### Customization

After the bashrc extensions are loaded, the final
step is to look at ~/profile.d/ for files that end
in .sh, and source each file. See [50_sample.sh](profile.d/50_sample.sh) for an example.

### User Experience

```bash
log-8601 "Launching example"

ask "Enter your username"
msg-info "Your username is '$ASK'"

ask-password "Enter your password secretly"
msg-dry "Your password is '$ASK'"

ask-yes "Are you sure?"
if [[ "$ASK" == "y" ]]; then
  msg-success "You said yes"
else
  msg-error "You said no"
fi

ask-enter "Continue?"

md /tmp/new_dir
msg-info "You are already in: $PWD"

~/profile.d
msg-info "You don't need to 'cd' anymore"
ll

cat 50_sample.sh
msg-info "Edit 50_sample.sh to try out extra customizations"

j tm w_d
msg-info "You jumped back to $PWD, you can only jump to places you have already been"

j file.d
msg-info "You jumped back to $PWD, you can only jump to places you have already been"

msg-info "Show the first column"
echo "FIRST LAST
one two
gold silver" | awk1

msg-error "$(echo 'why are you yelling?' | upper)"
msg-success "$(echo 'SILENCE IS GOLDEN' | lower)"

log-8601-local "Customize your experience"
PS1="${CGREEN}\u@\H:${CDEFAULT}"'${PWD}\n\$ '

echo -e "Show the git branch name in ${CYELLOW}yellow${CDEFAULT}"
ps1_add_fn git-branch-name YELLOW '' ' '

echo -e "Show the UTC ISO-8601 timestamp in ${CGREEN}yellow${CDEFAULT}"
ps1_add_fn date-8601 GREEN

echo -e "Show the local time ISO-8601 timestamp in ${CCYAN}cyan${CDEFAULT}"
ps1_add_fn date-8601-local CYAN

echo -e "${CRED}Ra${CYELLOW}in${CGREEN}bo${CCYAN}w ${CBLUE}wa${CCYAN}it${CDEFAULT}"
for X in {1..9}; do rainbow-sleep 0.5; done

msg-info "Test TCP ports"
testport google.com 443

msg-info "Make a good SSH key"
generate-ssh-key

```


# Git aliases
function is_git_repo {
  ( 
    while [[ "$PWD" != "/" ]]; do 
      if [[ -d ".git" ]]; then
        return
      fi
      cd ..
    done
    return 1
  )
}

function git_branch_name {
  if is_git_repo; then
    git log --pretty='%C(yellow)%h %C(auto)%d' --max-count 1 --color=always 2> /dev/null || echo '<new>'
  fi
}

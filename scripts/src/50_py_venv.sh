PROJECT_LIST_PATH="$HOME/.virtualenvs/projects.txt"

function mkvirtualenv () {
    PROJECT_DIR="$(realpath "$1")"
    PROJECT_NAME="$(basename "$PROJECT_DIR")"
    mkdir -p "$HOME/.virtualenvs"
    if [[ -d "$HOME/.virtualenvs/${PROJECT_NAME}" ]]; then
        echo "Project already exists"
    else
        python -m venv "$HOME/.virtualenvs/${PROJECT_NAME}"
    fi
    if [[ -d "$HOME/.virtualenvs/${PROJECT_NAME}/bin" ]]; then
        echo "Sourcing: '$HOME/.virtualenvs/${PROJECT_NAME}/bin/activate'"
        source "$HOME/.virtualenvs/${PROJECT_NAME}/bin/activate"
    else
        echo "Sourcing: '$HOME/.virtualenvs/${PROJECT_NAME}/Scripts/activate'"
        source "$HOME/.virtualenvs/${PROJECT_NAME}/Scripts/activate"
    fi
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    echo "$PROJECT_DIR" >> "$PROJECT_LIST_PATH"
}

function workon () {
    PROJECT_SEARCH_TERM="$1"
    PROJECTS="$(grep "$PROJECT_SEARCH_TERM" "$PROJECT_LIST_PATH")"
    PROJECT_COUNT="$(echo "$PROJECTS" | wc -l)"
    if (( "$PROJECT_COUNT" == 1 )); then
        PROJECT_DIR="$PROJECTS"
        echo "Working on: '$PROJECT_DIR'"
    else
        if (( "$PROJECT_COUNT" == 0 )); then
          echo "No projects found matching search: '$PROJECT_SEARCH_TERM'"
          echo "Projects:"
          cat "$PROJECT_LIST_PATH"
          return 1
        else
          echo "Multiple project found matching search: '$PROJECT_SEARCH_TERM'"
          echo "Projects:"
          echo "$PROJECTS"
          return 2
        fi
    fi
    PROJECT_NAME="$(basename "$PROJECT_DIR")"
    if [[ -d "$HOME/.virtualenvs/${PROJECT_NAME}/bin" ]]; then
        echo "Sourcing: '$HOME/.virtualenvs/${PROJECT_NAME}/bin/activate'"
        source "$HOME/.virtualenvs/${PROJECT_NAME}/bin/activate"
    else
        echo "Sourcing: '$HOME/.virtualenvs/${PROJECT_NAME}/Scripts/activate'"
        source "$HOME/.virtualenvs/${PROJECT_NAME}/Scripts/activate"
    fi
    cd "$PROJECT_DIR"
}
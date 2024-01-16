#!/bin/bash


# $@ - special variable in bash. it holds whatever argument we pass from
# the command line
# echo $@

# set -e - exit the script if any command or line in the script fails
# set -e

# print each line and it's output while executing (useful for debugging)
# set -ex


# Bash maintains a number of variables including BASH_SOURCE which is an array of source file pathnames.
# ${} acts as a kind of quoting for variables.
# $() acts as a kind of quoting for commands but they're run in their own context.
# dirname gives you the path portion of the provided argument.
# cd changes the current directory.
# pwd gives the current path.
# && is a logical and but is used in this instance for its side effect of running commands one after another.


# In summary, that command gets the script's source file pathname,
# strips it to just the path portion, cds to that path,
#then uses pwd to return the (effectively) full path of the script.
#This is assigned to DIR. After all of that,
# the context is unwound so you end up back in the directory
#you started at but with an environment variable DIR containing the script's path.


# set THIS_DIR to folder where run.sh script is present
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# function to remove any build artifacts
function clean {
    rm -rf dist build
    find . \
      -type d \
      \( \
        -name "*cache*" \
        -o -name "*.dist-info" \
        -o -name "*.egg-info" \
      \) \
      -not -path "./pkg_venv/*" \
      -exec rm -r {} +
}

function load-dotenv {
    if [ ! -f "$THIS_DIR/.env" ]; then
        echo "no .env file found"
        return 1
    fi

    while read -r line; do
        export "$line"
    done < <(grep -v '^#' "$THIS_DIR/.env" | grep -v '^$')
   
}

function install {
    which python
    python -m pip install --upgrade pip
    python -m pip install --editable "$THIS_DIR/[dev]"
}

function lint {
    pre-commit run --all-files
}

function build {
    python -m build --sdist --wheel "$THIS_DIR/"
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A  function | cat -n
}

function release:test {
    lint
    clean
    build
    publish:test
}

function release:prod {
    release:test
    publish:prod
}

function publish:test {
    load-dotenv
    twine upload dist/* \
        --repository testpypi \
        --username=__token__ \
        --password="$TEST_PYPI_TOKEN"
}

function publish:prod {
    load-dotenv
    twine upload dist/* \
        --repository pypi \
        --username=__token__ \
        --password="$PROD_PYPI_TOKEN"
}

TIMEFORMAT="Task completed in %3lR"
# if nothing is set in the variable $@, :- operator says default to the value on the right
time ${@:-help}

for t in $(find . -type f -name '*_test.sh'); do
    echo "Running tests in ${t}"
    bash "${t}" || {
        exit 1
    }
done
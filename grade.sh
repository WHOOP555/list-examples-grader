CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

if (($# < 1)); then
    echo "Usage: grade.sh <git-repo-url>"
    exit 1
fi

rm -rf student-submission
git clone $1 student-submission 2>/dev/null

if [[ "$?" -ne 0 ]]; then
    echo "Error cloning repository"
    exit 1
fi

echo '[1] Finished cloning'

# Check that the required files exist
if [[ ! -f student-submission/ListExamples.java ]]; then
    echo "Missing ListExamples.java"
    exit 1
fi

echo '[2] Found ListExamples.java'

# Check for the class
grep "class ListExamples" student-submission/ListExamples.java > /dev/null
if [[ "$?" -ne 0 ]]; then
    echo "ListExamples.java does not contain a class named ListExamples"
    exit 1
fi

echo '[3] Found class ListExamples'

# Check for the methods
METHOD1="static List<String> filter(List<String>.*, StringChecker.*)"
METHOD2="static List<String> merge(List<String>.*, List<String>.*)"

grep "$METHOD1" student-submission/ListExamples.java > /dev/null
if [[ "$?" -ne 0 ]]; then
    echo "ListExamples.java does not contain a method named filter"
    exit 1
fi

grep "$METHOD2" student-submission/ListExamples.java > /dev/null
if [[ "$?" -ne 0 ]]; then
    echo "ListExamples.java does not contain a method named merge"
    exit 1
fi

echo '[4] Found methods filter and merge'

# Create a dummy directory for the necessary files
mkdir -p playground

cp student-submission/ListExamples.java playground

# Compile the code
javac -cp $CPATH -d playground playground/ListExamples.java TestListExamples.java

if [[ "$?" -ne 0 ]]; then
    echo "Error compiling ListExamples.java"
    exit 1
fi

echo '[5] Compiled ListExamples.java'

# Run the tests
echo '[6] Running tests from TestListExamples.java'

java -cp $CPATH:playground org.junit.runner.JUnitCore TestListExamples 1>output.log 2>&1

if [[ "$?" -ne 0 ]]; then
    echo 'Error running tests:'
    cat output.log

    contents=$(cat output.log)
    final_line=$(grep "Tests run:" output.log)

    # Get the numbers from the final line
    numbers=$(grep "Tests run:" output.log | grep -oe '\([0-9.]*\)')
    num_tests=$(echo $numbers | cut -d ' ' -f 1)
    num_failures=$(echo $numbers | cut -d ' ' -f 2)
    percent=$(( (num_failures * 100) / num_tests ))
    echo "[END] Passed $percent% of tests"

    exit 1
fi

echo '[END] All tests passed!'

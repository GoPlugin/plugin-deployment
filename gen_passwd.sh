#!/bin/bash

PASS_KEYSTORE=""
PASS_POSTGRES=""
PASS_API=""
BEGIN=true
AGAIN=false


FUNC_GEN_KEYSTORE(){

digits='[[:digit:]].*[[:digit:]].*[[:digit:]]'
upper='[[:upper:]].*[[:upper:]].*[[:upper:]]'
lower='[[:lower:]].*[[:lower:]].*[[:lower:]]'
punct='[[:punct:]].*[[:punct:]].*[[:punct:]]'

while $BEGIN || (( len_pass < 8 && len_pass > 28 )) ||
    [[ ! ( $test_pass =~ $digits && $test_pass =~ $upper && $test_pass =~ $lower && $test_pass =~ $punct ) ]]
do
    #$AGAIN && echo "###  Warning: Does not meet complexity - rehashing!" || AGAIN=true
    $AGAIN || AGAIN=true
    BEGIN=false
    PASS_KEYSTORE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9%:+*!;.?=' | head -c32)
    if [[ ! -z $PASS_KEYSTORE ]]
    then
        len_pass=${#PASS_KEYSTORE}
        test_pass=${PASS_KEYSTORE#?}
        test_pass=${test_pass%?}
    else
        BEGIN=true
    fi
done

#echo "new password is $PASS_KEYSTORE"
echo "$PASS_KEYSTORE"

#Credit: Grail @ https://www.linuxquestions.org/questions/programming-9/bash-password-complexity-script-898056/
}

FUNC_GEN_POSTGRES(){
    
digits='[[:digit:]].*[[:digit:]].*[[:digit:]]'
upper='[[:upper:]].*[[:upper:]].*[[:upper:]]'
lower='[[:lower:]].*[[:lower:]].*[[:lower:]]'

while $BEGIN || (( len_pass < 8 && len_pass > 28 )) ||
    [[ ! ( $test_pass =~ $digits && $test_pass =~ $upper && $test_pass =~ $lower ) ]]
do
    #$AGAIN && echo "###  Warning: Does not meet complexity - rehashing!" || AGAIN=true
    $AGAIN || AGAIN=true
    BEGIN=false
    PASS_POSTGRES=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
    if [[ ! -z $PASS_POSTGRES ]]
    then
        len_pass=${#PASS_POSTGRES}
        test_pass=${PASS_POSTGRES#?}
        test_pass=${test_pass%?}
    else
        BEGIN=true
    fi
done

#echo "new password is $PASS_POSTGRES"
echo "$PASS_POSTGRES"

}

FUNC_GEN_API(){
    
digits='[[:digit:]].*[[:digit:]].*[[:digit:]]'
upper='[[:upper:]].*[[:upper:]].*[[:upper:]]'
lower='[[:lower:]].*[[:lower:]].*[[:lower:]]'

while $BEGIN || (( len_pass < 8 && len_pass > 20 )) ||
    [[ ! ( $test_pass =~ $digits && $test_pass =~ $upper && $test_pass =~ $lower ) ]]
do
    #$AGAIN && echo "###  Warning: Does not meet complexity - rehashing!" || AGAIN=true
    $AGAIN || AGAIN=true
    BEGIN=false
    PASS_API=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w18 | head -n1)
    if [[ ! -z $PASS_API ]]
    then
        len_pass=${#PASS_API}
        test_pass=${PASS_API#?}
        test_pass=${test_pass%?}
    else
        BEGIN=true
    fi
done

#echo "new password is $PASS_API"
echo "$PASS_API"

}


case "$1" in
        -keys)
                FUNC_GEN_KEYSTORE
                ;;
        -db)
                FUNC_GEN_POSTGRES
                ;;
        -api)
                FUNC_GEN_API
                ;;
        *)
                echo 
                echo 
                echo "Usage: $0 {function}"
                echo 
                echo "where {function} is one of the following;"
                echo 
                echo "      -keys    ==  Randomly generates new keys secret that meets the requirements defined in readme & VARS file"
                echo 
                echo "      -db      ==  Randomly generates new Postgres compatible password as defined in readme & VARS file"
                echo 
                echo "      -api     ==  Randomly generates new node gui compatible password as defined in readme & VARS file"
                echo 
esac

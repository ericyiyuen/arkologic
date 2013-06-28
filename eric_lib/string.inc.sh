
function is_integer() {
    s=$(echo $1 | tr -d 0-9)
    if [ -z "$s" ]; then
        return 0
    else
        return 1
    fi
}
function is_alphanumeric() {
    if grep -q '^[0-9a-z]*$' <<<"$1"; then
        return 0
    else 
        return 1
    fi
}

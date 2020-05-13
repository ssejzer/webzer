#!/bin/bash

httpReply() {
    if [ $1 -ge 400 ] ; then echo "HTTP/1.1 $1 Bad Request"
    else echo "HTTP/1.1 $1 OK"
    fi
    shift; body="$@"    
    cat <<EOF
Server: Apache/2.4.29 (Ubuntu)
Connection: close
Content-Type: text/html; charset=iso-8859-1
Content-Length: ${#body}

$body
EOF
}

httpDispatcher() {
    if [[ $@ =~ ^GET\ /[\ \/\#?] ]]; then
	httpReply 200 "<h2>Root page</h2><br><a href='/page1'>Page 1</a><br><a href='/page2'>Page 2</a>"
    elif [[ $@ =~ ^GET\ /page1[\ \/\#?] ]]; then
	httpReply 200 "<h2>Page 1</h2><br><a href='/'>Root</a><br><a href='/page2'>Page 2</a>"
    elif [[ $@ =~ ^GET\ /page2[\ \/\#?] ]]; then
	httpReply 200 "<h2>Page 2</h2><br><a href='/'>Root</a><br><a href='/page1'>Page 1</a>"
    else
	httpReply 404 "<h2>PAGE NOT FOUND<h2>"
    fi
}

httpServer() {
    requestHead=`while read line && [ " " "<" "$line" ] ; do echo "$line" ; done`
    httpRequest="`echo \"$requestHead\" | head -n 1`"
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] $httpRequest"
    httpDispatcher $httpRequest > $1
}

mkfifo pipe 2>/dev/null
while true ; do cat pipe | nc -l -p $1 | httpServer pipe; done

# Copy file from kali container to local
function cf() {
    local src=$1;
    local dst=$2;
    if [ -z $src ] || [ -z $dst ]; then
        echo "Usage: ct <remote source> <local destination>"
        return 1
    fi
    rsync -ave 'ssh -p 55000' attacker@localhost:$src $dst
}

# Copy file from local to kali container
function ct() {
    local src=$1;
    local dst=$2;
    if [ -z $src ] || [ -z $dst ]; then
        echo "Usage: ct <local source> <remote destination>"
        return 1
    fi
    rsync -ave 'ssh -p 55000' $src attacker@localhost:$dst
}

# Monitor changes for specific file
function monitor() {
    local file=$1
    local command=$2

    if [ -z "$file" ] || [ -z "$command" ]; then
        echo "Usage: monitor <file name> <command>"
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "$file does not exist!"
        return 1
    fi

    local last_change=$(stat -f '%m' "$file")

    while :; do
        sleep 1

        if [ "$last_change" -ne $(stat -f '%m' "$file") ]; then
            echo "Change detected!"
            last_change=$(stat -f '%m' "$file")
            eval "$command"
        fi

    done
}
# Docker create kali container function
function skc() {
    local name="$(echo -e $1 | tr -d '[:space:]')";
    shift;
    if [ -z $name ]; then
        echo "Usage: skc <container name> [<docker run options>]";
        return 1;
    fi
    docker run -dtP --rm --expose 22 -p 4445:4445 -p 4444:4444 -p 53:53 $@ --name "$name" --hostname "$name" -v kali-usr:/usr -v kali-var:/var -v kali-etc:/etc -v kali-attacker:/home/attacker kalilinux/kali-rolling /bin/bash && docker exec -u root $name /usr/local/sbin/startup;
    echo "Container '$name' is running. You can connect via ssh $(docker port $name 22 | cut -d ":" -f 2) port.";
}

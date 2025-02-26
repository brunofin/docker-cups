#!/bin/bash -e

echo -e "${ADMIN_PASSWORD}\n${ADMIN_PASSWORD}" | passwd admin

if [ ! -f /etc/cups/cupsd.conf ]; then
  cp -rpn /etc/cups-skel/* /etc/cups/
fi

/usr/bin/expect <<'EOF'
spawn hp-plugin -i
expect {
    -re ".*Enter option.*" { send "d\r"; exp_continue }
    eof
}
expect {
    -re ".*Do you accept the license terms for the plug-in*" { send "y\r"; exp_continue }
    eof
}
EOF

exec "$@"

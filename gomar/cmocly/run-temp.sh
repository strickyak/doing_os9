go build cmocly.go && (
    cd testdata 
    ../cmocly -cmoc /opt/yak/cmoc/bin/cmoc  -o temp temp.c defs.c octet.c
)

/^[0-9A-F][0-9A-F][0-9A-F][0-9A-F]     / {
  if (tolower($4) == "rmb") {
    print $3, "equ", "$" $1
  }
}

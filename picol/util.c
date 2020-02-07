/* Tcl_StringMatch copied from tcl6.7/tclUtil.c
 *
 * Copyright 1987-1991 Regents of the University of California
 * Permission to use, copy, modify, and distribute this
 * software and its documentation for any purpose and without
 * fee is hereby granted, provided that the above copyright
 * notice appear in all copies.  The University of California
 * makes no representations about the suitability of this
 * software for any purpose.  It is provided "as is" without
 * express or implied warranty.
 */

int Tcl_StringMatch(const char *string, const char *pattern) {
  char c2;

  while (1) {
    /* See if we're at the end of both the pattern and the string.
     * If so, we succeeded.  If we're at the end of the pattern
     * but not at the end of the string, we failed.
     */

    if (*pattern == 0) {
      if (*string == 0) {
        return 1;
      } else {
        return 0;
      }
    }
    if ((*string == 0) && (*pattern != '*')) {
      return 0;
    }

    /* Check for a "*" as the next pattern character.  It matches
     * any substring.  We handle this by calling ourselves
     * recursively for each postfix of string, until either we
     * match or we reach the end of the string.
     */

    if (*pattern == '*') {
      pattern += 1;
      if (*pattern == 0) {
        return 1;
      }
      while (1) {
        if (Tcl_StringMatch(string, pattern)) {
          return 1;
        }
        if (*string == 0) {
          return 0;
        }
        string += 1;
      }
    }

    /* Check for a "?" as the next pattern character.  It matches
     * any single character.
     */

    if (*pattern == '?') {
      goto thisCharOK;
    }

    /* Check for a "[" as the next pattern character.  It is followed
     * by a list of characters that are acceptable, or by a range
     * (two characters separated by "-").
     */

    if (*pattern == '[') {
      pattern += 1;
      while (1) {
        if ((*pattern == ']') || (*pattern == 0)) {
          return 0;
        }
        if (*pattern == *string) {
          break;
        }
        if (pattern[1] == '-') {
          c2 = pattern[2];
          if (c2 == 0) {
            return 0;
          }
          if ((*pattern <= *string) && (c2 >= *string)) {
            break;
          }
          if ((*pattern >= *string) && (c2 <= *string)) {
            break;
          }
          pattern += 2;
        }
        pattern += 1;
      }
      while ((*pattern != ']') && (*pattern != 0)) {
        pattern += 1;
      }
      goto thisCharOK;
    }

    /* If the next pattern character is '/', just strip off the '/'
     * so we do exact matching on the character that follows.
     */

    if (*pattern == '\\') {
      pattern += 1;
      if (*pattern == 0) {
        return 0;
      }
    }

    /* There's no special character.  Just make sure that the next
     * characters of each string match.
     */

    if (*pattern != *string) {
      return 0;
    }

  thisCharOK:
    pattern += 1;
    string += 1;
  }
}

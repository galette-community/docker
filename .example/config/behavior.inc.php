<?php
//change this *ONLY* for debug purposes!
//define('GALETTE_DISPLAY_ERRORS', true);

/* Uncomment and tune to read user IP addresses from the X-Forwarded-For header
 *
 * This is for applications sitting behind one or several proxies.
 *
 * Don't uncomment if the application doesn't sit behind a proxy, as it would
 * allow potential attackers to replace their IP addresses with anything,
 * increasing a bit their stealth (IP address don't mean that much anyway)
 *
 *  Typically each proxy will append its client's IP address to this header
 *  The value is used the index of the IP address to consider, from the end
 *  of the header values, starting with 1.
 *
 * Hence the provided example is the simplest suitable for being behind
 *  a single reverse proxy
 */
//define('GALETTE_X_FORWARDED_FOR_INDEX', 1);

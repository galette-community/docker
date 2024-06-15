<?php
/* Per default, Galette will create session with default lifetime duration (and it seems
   browsers acts differently in this case). You can anyways define a constant named
   GALETTE_TIMEOUT to change session lifetime using behavior configuration:
   - see https://www.php.net/manual/en/session.configuration.php#ini.session.cookie-lifetime
*/
//define('GALETTE_TIMEOUT', 0);
     
/* Uncomment and tune to read user IP addresses from the X-Forwarded-For header
 
   This is for applications sitting behind one or several proxies.
 
   Don't uncomment if the application doesn't sit behind a proxy, as it would
   allow potential attackers to replace their IP addresses with anything,
   increasing a bit their stealth (IP address don't mean that much anyway)
 
   Typically each proxy will append its client's IP address to this header
   The value is used the index of the IP address to consider, from the end
   of the header values, starting with 1.
 
   Hence the provided example is the simplest suitable for being behind
   a single reverse proxy
 */
//define('GALETTE_X_FORWARDED_FOR_INDEX', 1);


/* Several modes are provided in Galette you can configure with GALETTE_MODE 
   constant (see Galette behavior configuration). This directive can take the 
   following values:
   PROD: production mode (non production instance should be on an other mode).
         This is the default mode for releases, but it may change in development
         branch.
   DEMO: demonstration mode, the same as PROD but with some features disabled
         like sending emails, modifying superadmin data, ...
   TEST: reserved for unit tests.
   MAINT: maintainance mode. Only super admin will be able to login.
*/
//define('GALETTE_MODE', 'PROD');

/*change this *ONLY* for debug purposes!
*/
//define('GALETTE_DEBUG', true);

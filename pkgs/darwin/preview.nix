{ writeShellApplication }:

writeShellApplication {
  name = "preview";
  text = ''
    exec open -a Preview.app "$@";
  '';
}

#https://ss64.com/bash/exec.html
/* exec
   Execute a command

   Syntax
         exec [-cl] [-a name] [command [arguments]]

   Options
         -c   Causes command to be executed with an empty environment.

         -l   Place a dash at the beginning of the zeroth arg passed to command.
              (This is what the login program does.)

         -a   The shell passes name as the zeroth argument to command.
*/


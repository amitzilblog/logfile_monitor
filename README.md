# logfile_monitor
A short script to provide infra to scan only new lines in a log for monitoring purposes

This is the infra for monitoring a log file using bash and this is how it works:
Usage is:
line=$(getFileLine "SYSLOG" "${my_log}") # this will get the last line that was scanned in the log
((line++)) # increase the line by one
new_lines=$(tail -n +${line} ${my_log}) # will return the new lines in the log, of course you can add grep or anything you'd like

Note thatthe first parameter of getFileLine (SYSLOG in the example) is a code to identify the file. You can run the same code many times on different files, as long as this identifier is different.
For example:
syslog=/var/log/messages
bootlog=/var/log/boot.log
line=$(getFileLine "SYSLOG" "${syslog}")
((line++))
syslog_new_lines=$(tail -n +${line} ${syslog})
line=$(getFileLine "BOOTLOG" "${bootlog}")
((line++))
bootlog_new_lines=$(tail -n +${line} ${bootlog})

Some internal info:
In order to return the last scanned line the script checks if this is the same file that was scanned before. The check is done by md5 on the first lines of the file (defined by the HASH_LINES parameter)
The md5 of the previous file scanned and the last line is saved in the file configured by the INTERNAL_FILE parameter.
Every run will update the line number in the 
If the md5 is different, the code will update the md5 in the internal file.

#! /usr/bin/env tclsh
# vclock.fcg -- borrowed from Don Libes' cgi.tcl, and modified slightly for
#  fcgi.tcl
#


package require cgi
package require Fcgi

# common definitions for all examples (was example.tcl)

set EXPECT_HOST	http://expect.nist.gov
set CGITCL	$EXPECT_HOST/cgi.tcl

cgi_admin_mail_addr bounce_to_me@nowhere.stuff

set TOP target=_top
cgi_link CGITCL   "cgi.tcl homepage"		$CGITCL $TOP



# fcgi.tcl:
# redefine cgi_cgi to append .fcg instead of .cgi
rename cgi_cgi _old_cgi_cgi
proc cgi_cgi {args} {
  set docPath [eval _old_cgi_cgi $args]
  regsub {.cgi$} $docPath .fcg docPath
  return $docPath
}

set counter 0
while {[FCGI_Accept] >= 0} {

  cgi_eval {

    cgi_input
    cgi_root [file dirname $env(SCRIPT_NAME)]

    set format ""
    if [llength [cgi_import_list]] {
	if 0==[catch {cgi_import time}] {
	  append format [expr {[cgi_import type] == "12-hour" ? "%r " : "%T " }]
	}
	catch {cgi_import day;          append format "%a "}
	catch {cgi_import month;        append format "%h "}
	catch {cgi_import day-of-month; append format "%d "}
	catch {cgi_import year;         append format "'%y "}
    } else {
	append format "%r %a %h %d '%y"
    }

    # fastcgi - use tcl's 'clock' command instead of 'date' command
    set time [clock format [clock seconds] -format $format]

    cgi_title "Virtual Clock"

    cgi_body {
	h1 "Virtual Clock - fcgi.tcl style"
	p "Virtual clock has been accessed [incr counter] times since startup."
	hr
	p "At the tone, the time will be [strong $time]"
	hr
	h2 "Set Clock Format"

	cgi_form vclock {
	    puts "Show: "
	    foreach x {time day month day-of-month year} {
		cgi_checkbox $x checked
		put $x
	    }
	    br
	    puts "Time style: "
	    cgi_radio_button type=12-hour checked;put "12-hour"
	    cgi_radio_button type=24-hour        ;put "24-hour"
	    br
	    cgi_reset_button
	    cgi_submit_button =Set
	}
	hr
	cgi_puts "See Don Libes' cgi.tcl and original vclock "
	cgi_puts "at the [cgi_link CGITCL]"
    }
  }

}  ;# while FCGI_Accept


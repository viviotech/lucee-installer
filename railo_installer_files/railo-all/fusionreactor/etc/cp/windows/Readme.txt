This directory contains the FusionReactor Crash Protection sample scripts which
are intended to be used on machines running Windows.

If the monitored server runs on UNIX add the appropriate
Restart-Coldfusion[x]-OnUnix.bat script, if the monitored server runs on Windows
add the appropriate Restart-Coldfusion[x]-OnWindows.bat to the FusionReactor
Enterprise Dashboard.

For additional information about the SC command used in the example scripts see
http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/sc.mspx?mfr=true

If you need Windows authentication to be passed you can use the free tool PsService provided
by Microsoft (formerly SysInternals) instead of the SC utility. See
http://technet.microsoft.com/en-us/sysinternals/bb897542.aspx

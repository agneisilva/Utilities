ATTRIB -S c:\windows\system32\termsrv.dll

RDPWInst -u

NET STOP TERMSERVICE /Y

COPY termsrv-v168-backup.dll c:\windows\system32

TAKEOWN /a /f C:\Windows\System32\termsrv.dll

ICACLS C:\Windows\System32\termsrv.dll /Grant Administrators:F

COPY C:\Windows\System32\termsrv.dll C:\Windows\System32\termsrv.dll.backup

DEL C:\Windows\System32\termsrv.dll

RENAME C:\Windows\System32\termsrv-v168-backup.dll termsrv.dll

RDPWInst -i -o

ATTRIB +S c:\windows\system32\termsrv.dll
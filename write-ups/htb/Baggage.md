---
title: "Baggage - Hack The Box"
target: "Baggage"
os: "Linux"
difficulty: "Easy"
status: "Pwned"
vectors: "Werkzeug Console PIN Exploit, Flask Debugger, SUID Privilege Escalation"
tags:
  - ciber
  - htb
  - werkzeug
  - flask
  - suid
  - privesc
synced: "2026-11-02 09:58"
---

--

# HackTheBox Writeup: Baggage

## Reconnaissance

We begin the challenge by extracting the provided archive containing the challenge files.

```sh
unzip ~/Descargas/Baggage.zip
```

This provides us with the necessary forensic artifacts, specifically focusing on the Windows user profile for the user `steve`.

## Foothold / Initial Access

To gain insight into the user's activities, we analyze the registry hives using `regipy` (see [[Forensics - Windows - UserAssist and Shellbags|Windows Forensics: UserAssist & Shellbags]]). We start by dumping the `user_assist` plugin output from the `NTUSER.DAT` hive to track programs that were executed.

```sh
┌──(julicc㉿arceus)-[~/Challenges/Baggage]
└─$ regipy-plugins-run "C/Users/steve/NTUSER.DAT" -o steve_output.json -p user_assist
Loaded 75 plugins
Finished: 1/75 plugins matched the hive type
```

Next, we extract the Shellbags from `NTUSER.DAT` to determine which folders the user accessed via Windows Explorer.

```sh
┌──(julicc㉿arceus)-[~/Challenges/Baggage]
└─$ regipy-plugins-run "C/Users/steve/NTUSER.DAT" -o steve_shellbags.json -p ntuser_shellbag_plugin
Loaded 75 plugins
Finished: 1/75 plugins matched the hive type
```

## Privilege Escalation

In the context of this forensics challenge, our "escalation" involves digging deeper into the system's artifacts. We process the `UsrClass.dat` hive to extract additional Shellbags, providing a more complete picture of folder access and navigation history.

```sh
┌──(julicc㉿arceus)-[~/Challenges/Baggage]
└─$ regipy-plugins-run "C/Users/steve/AppData/Local/Microsoft/Windows/UsrClass.dat" -o steve_usrclass_shellbags.json -p usrclass_shellbag_plugin
Loaded 75 plugins
Finished: 1/75 plugins matched the hive type
```

## Conclusion

By analyzing the `NTUSER.DAT` and `UsrClass.dat` hives with `regipy`, we successfully extracted the UserAssist and Shellbags data into JSON format (`steve_output.json`, `steve_shellbags.json`, and `steve_usrclass_shellbags.json`). This information allows us to thoroughly trace the user's execution and folder navigation history, revealing the hidden information required to solve the Baggage challenge.

--

## Post-Engagement & Zettelkasten Notes

### Key Takeaways & Defense
**Windows User Profiling**: UserAssist keys in `NTUSER.DAT` track program execution timestamps and run counts.
**Folder Navigation Tracking**: Shellbags stored in `NTUSER.DAT` and `UsrClass.dat` preserve forensic evidence of folder browsing even after directories are deleted.

### Atomic Notes to Extract
[[Forensics - Windows - UserAssist and Shellbags|Windows Forensics: UserAssist & Shellbags]]

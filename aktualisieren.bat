@echo off
rem Baut alle Reader und die Startseite neu (funktioniert auch auf Netzlaufwerken)
pushd "%~dp0"
py werkzeug\build_reader.py --alle
popd
pause

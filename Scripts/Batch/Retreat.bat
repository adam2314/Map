@REM Israel Hiking and Biking - IsraelHiking.osm.org.il
@REM
@REM Usage: retreat [Language] [Phase ...]
@REM
@REM Enable selective non-incremental tile generation by seting the
@REM status of the Cache for a given language as if tile generation
@REM was just completed, before calling advance() and the deletion of
@REM the *.done files
@REM
@REM Optional arguments:
@REM 
@REM   Language: Either Hebrew or English (case insensitive).
@REM       Default: Hebrew
@REM   Phase: Space-separated list of phases to be enabled after the
@REM       retreat.
@REM       Substrings such as MTB and 16 are accepted. 
@REM       Match is case insensitive.
@REM       Default: all phases are enabled
@REM
@REM Copyright 2017 Zeev Stadler CC BY-NC-SA 3.0
@REM https://creativecommons.org/licenses/by-nc-sa/3.0/
@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION

IF NOT DEFINED LANGUAGE (
  PUSHD "%~dp0"
  SET LANGUAGE="Hebrew"
  START "%~n0 %*" %~n0 %*
  POPD
  EXIT /B
)

IF "%*" == "" (
  SET TASKNAME=%~n0 Hebrew
) ELSE (
  SET TASKNAME=%~n0 Hebrew %*
)
ECHO " Hebrew English " | FIND /I " %~1 " > NUL && (
  SET LANGUAGE="%~1"
  SET TASKNAME=%~n0 %*
  SHIFT
)

@REM Script is located at IsraelHiking\Scripts\Batch 
CD ..\..
SET ISRAELHIKING="%CD%"
CD %ISRAELHIKING%\Cache\%LANGUAGE%

IF %LANGUAGE% == "Hebrew" (
  CALL %ISRAELHIKING%\Scripts\Batch\WaitInQueue %ISRAELHIKING%\Cache\Queue "%TASKNAME%"
  IF ERRORLEVEL 1 EXIT 
)

IF EXIST "israel-and-palestine-updated.osm.pbf" (
  DIR
  ECHO.
  ECHO === Tile generation was not completed, cannot retreat ===
  POPD
  EXIT /B 1
)

IF EXIST israel-and-palestine-latest.osm.pbf (
  REN israel-and-palestine-latest.osm.pbf israel-and-palestine-updated.osm.pbf
)
IF EXIST israel-and-palestine-*trails* (
  DEL israel-and-palestine-*trails*
)

SET ALLPHASES=IsraelHiking15 IsraelMTB15 IsraelHiking16 IsraelMTB16
IF /I %LANGUAGE% == "Hebrew" (
  SET ALLPHASES=%ALLPHASES% IsraelHikingOverlay IsraelMTBOverlay
)

IF "%1"=="" (
  IF EXIST *.done (
    DEL *.done
  )
) ELSE (
  FOR %%P in ( %ALLPHASES% ) DO (
    (CALL) > %%P.done
    FOR %%M in ( %* ) DO (
      ECHO %%P | FINDSTR /I %%M > NUL && DEL %%P.done
    )
  )
)

IF EXIST "%QUEUEFILE%" DEL "%QUEUEFILE%"

ECHO.
DIR
EXIT
@REM vim:sw=2:ai:ic:expandtab

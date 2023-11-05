@echo off
setlocal enabledelayedexpansion

set MASM32_PATH=C:\masm32

:: Check if MASM32_PATH is set and if it points to a valid directory
if not defined MASM32_PATH (
    echo MASM32 path not found in the PATH environment variable.
    exit /b 1
)

:: Get the program name as an argument
set "program_name=%~1"

:: Check if the program name is provided as an argument
if "%program_name%"=="" (
    set "program_name=main"  :: Set a default program name
    echo Using default program name: !program_name!.asm
)

:: Assemble the assembly source code
echo Compiling...
"%MASM32_PATH%\bin\ml.exe" /c /AT /nologo %program_name%.asm

if exist "%program_name%.com" (
    echo Deleting old binary...
    del "%program_name%.com"
)

:: Link the object file to create an executable
echo Linking...
"%MASM32_PATH%\bin\link16.exe" /TINY /nologo %program_name%.obj

:: Pause to see the program's output
pause

endlocal
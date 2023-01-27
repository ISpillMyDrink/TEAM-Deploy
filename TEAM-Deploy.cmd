@echo off
setlocal EnableDelayedExpansion

cd /d %~dp0

set pathbase=%~dp0
set configfile=%pathbase%TEAM-Deploy.cfg

set moduleLocation=%pathbase%Modules
set imageLocation=%pathbase%Images
set answerfileLocation=%pathbase%Answerfiles
set associationfileLocation=%pathbase%Associationfiles
set packageLocation=%pathbase%Packages

for /f "delims=" %%a in (%configfile%) do set "%%a"

set dism=dism
if exist %adkLocation% set dism=%adkLocation%\dism.exe

call :updateDriveInfo
call :updateImageList
call :updateImageInfo
call :updateAnswerfileList
call :updateAnswerfileInfo
call :updateAssociationfileList
call :updateAssociationfileInfo
call :updatePackageList
call :updatePackageInfo
call :updatePEBootType

:menuMain
set paddedSizeSystem=      (%sizeSystem%MB)
set paddedSizeMSR=      (%sizeMSR%MB)
set paddedSizeRecovery=      (%sizeRecovery%MB)

cls
call :writeMenuHeader "Main Menu"
call :writeMenuEntry "[A] Architecture: %arch%"              "[B] Bootloader: %bootType% / %partitionTable%"
echo.
call :writeMenuEntry "[I] Image:        %image%"             "[L] Drive:	   %driveName%"
call :writeMenuEntry "[E] Index:        %imageIndex%"
call :writeMenuEntry ""                                      "[S] System:     %letterSystem%: %paddedSizeSystem:~-8%"
call :writeMenuEntry "[U] Answerfile:   %answerfile%"        "    MSR:        -- %paddedSizeMSR:~-8%"
call :writeMenuEntry "[F] Assocfile:    %associationfile%"   "[W] Windows:    %letterOS%:"
call :writeMenuEntry ""                                      "[R] Recovery:   %letterRecovery%: %paddedSizeRecovery:~-8%"
call :writeMenuEntry "[P] Provisioning: %package%"
echo.
echo.
echo. [X] Exit
echo. [G] Start
echo.
set instruction=
set /P instruction=Please make a selection: 

if /i "%instruction%" EQU "X" (
    exit /b
) else if /i "%instruction%" EQU "A" (
    if "%arch%" EQU "X64" (
        set arch=X86
    ) else (
        set arch=X64
    )

    set imageID=X
    set ImageIndex=X
    set answerID=X
    set assocID=X

    call :updateImageInfo
    call :updateAnswerfileInfo
    call :updateAssociationfileInfo
) else if /i "%instruction%" EQU "E" (
    if "%imageIndex%" NEQ "-------------" (
        goto menuIndexSelection
    )
) else if /i "%instruction%" EQU "S" (
    goto menuSystemPartition
) else if /i "%instruction%" EQU "W" (
    goto menuWindowsPartition
) else if /i "%instruction%" EQU "R" (
    goto menuRecoveryPartition
) else if /i "%instruction%" EQU "B" (
    if "%bootType%" EQU "UEFI" (
        set bootType=BIOS
        set partitionTable=MBR
    ) else if "%bootType%" EQU "BIOS" (
        set bootType=ALL
        set partitionTable=GPT
    ) else if "%bootType%" EQU "----" (
        set bootType=UEFI
        set partitionTable=GPT
    ) else (
        set bootType=----
        set partitionTable=----
    )
) else if /I "%instruction%" EQU "L" (
    goto menuDriveSelection
) else if /I "%instruction%" EQU "I" (
    goto menuImageSelection
) else if /i "%instruction%" EQU "U" (
    goto menuAnswerfileSelection
) else if /i "%instruction%" EQU "F" (
    goto menuAssociationfileSelection
) else if /i "%instruction%" EQU "P" (
    goto menuPackageSelection
) else if /i "%instruction%" EQU "G" (
    goto menuDeployment
)
goto menuMain

:menuDriveSelection
cls
call :writeMenuHeader "Drive Selection"
echo list disk > %temp%\team_deploy_diskpart.txt
for /f "usebackq skip=5 tokens=*" %%a in (`diskpart /s %temp%\team_deploy_diskpart.txt`) do echo. %%a
del %temp%\team_deploy_diskpart.txt > nul
echo.
echo.
echo.
echo Enter drive number or ^<X^> to disable partitioning.
set /P diskID=Drive's ID (%diskID%):

call :updateDriveInfo
goto menuMain

:menuSystemPartition
cls
call :writeMenuHeader "System Partition"
echo. Bootloader partition, recommended size: 200MB, configurable in TEAM-Deploy.cfg.
echo. Contains the bootloader for BIOS or UEFI boot.
echo.
echo. Drive letter: %letterSystem%
echo. Size (MB):    %sizeSystem%
echo.
set newLetterSystem=%letterSystem%
set /P newLetterSystem=Please enter a drive letter the partition will be mounted as (%letterSystem%): 

set newLetterSystem=%newLetterSystem:~0,1%

for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "newLetterSystem=!newLetterSystem:%%a=%%a!"

echo %newLetterSystem%|findstr /r "[a-zA-Z]" > nul
if %errorlevel% EQU 1 goto menuSystemPartition
set letterSystem=%newLetterSystem%
goto menuMain

:menuWindowsPartition
cls
call :writeMenuHeader "Windows Partition"
echo. Windows partition, will span the rest of the drive minus the recovery partition.
echo. Partition the image will be deployed to.
echo. 
echo. Drive letter: %letterOS%
echo.
set newLetterOS=%letterOS%
set /P newLetterOS=Please enter a drive letter the partition will be mounted as (%letterOS%): 

set newLetterOS=%newLetterOS:~0,1%

for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "newLetterOS=!newLetterOS:%%a=%%a!"

echo %newLetterOS%|findstr /r "[a-zA-Z]" > nul
if %errorlevel% EQU 1 goto menuWindowsPartition
set letterOS=%newLetterOS%
goto menuMain

:menuRecoveryPartition
cls
call :writeMenuHeader "Recovery Partition"
echo. Recovery partition, recommended size: 1000MB, configurable in TEAM-Deploy.cfg.
echo. Contains the recovery image for Windows.
echo.
echo. Drive letter: %letterRecovery%
echo. Size (MB):    %sizeRecovery%
echo.
set newLetterRecovery=%letterRecovery%
set /P newLetterRecovery=Please enter a drive letter the partition will be mounted as (%letterRecovery%): 

set newLetterRecovery=%newLetterRecovery:~0,1%

for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "newLetterRecovery=!newLetterRecovery:%%a=%%a!"

echo %newLetterRecovery%|findstr /r "[a-zA-Z]" > nul
if %errorlevel% EQU 1 goto menuRecoveryPartition
set letterRecovery=%newLetterRecovery%
goto menuMain

:menuImageSelection
call :updateImageList

cls
call :writeMenuHeader "Image selection"
for /l %%b in (1,1,%i%) do echo %%b. !image[%%b]!
echo.
echo.
echo.
echo Please enter the image number or ^<X^> to disable image deployment.
set newImageID=%imageID%
set /P newImageID=Image number (%imageID%):

echo %newImageID%|findstr /r "[xX0-9]" > nul
if %errorlevel% EQU 1 goto menuImageSelection
set imageID=%newImageID%

call :updateImageInfo
goto menuMain

:menuIndexSelection
cls
call :writeMenuHeader "Index Selection"
echo.
dism /get-imageinfo /imagefile:"%imagepath%" 
echo.
echo Please enter the image index to deploy.
set newImageIndex=%imageIndex%
set /P newImageIndex=Index (%imageIndex%):

echo %newImageIndex%|findstr /r "[1-9]" > nul
if %errorlevel% EQU 1 goto menuIndexSelection
set imageIndex=%newImageIndex%

goto menuMain

:menuAnswerfileSelection
call :updateAnswerfileList

cls
call :writeMenuHeader "Answerfile selection"
for /l %%b in (1,1,%i%) do echo %%b. !answer[%%b]!
echo.
echo.
echo.
set /P newAnswerID=Please enter answerfile number or ^<X^> to disable answerfile (%answerID%):

echo %newAnswerID%|findstr /r "[xX0-9]" > nul
if %errorlevel% EQU 1 goto menuAnswerfileSelection
set answerID=%newAnswerID%

call :updateAnswerfileInfo
goto menuMain

:menuAssociationfileSelection
call :updateAssociationfileList

cls
call :writeMenuHeader "Association file selection"
for /l %%b in (1,1,%i%) do echo %%b. !assoc[%%b]!
echo.
echo.
echo.
set /P newAssocID=Please enter the association file number or ^<X^> to disable association file (%assocID%):

echo %newAssocID%|findstr /r "[xX0-9]" > nul
if %errorlevel% EQU 1 goto menuAssociationfileSelection
set assocID=%newAssocID%

call :updateAssociationfileInfo
goto menuMain

:menuPackageSelection
call :updatePackageList

cls
call :writeMenuHeader "Package selection"
for /l %%b in (1,1,%i%) do echo %%b. !package[%%b]!
echo.
echo.
echo.
echo Please enter the package number or ^<X^> to disable package deployment.
set /P newPackageID=Package-Nr. (%packageID%):

echo %newPackageID%|findstr /r "[xX0-9]" > nul
if %errorlevel% EQU 1 goto menuPackageSelection
set packageID=%newPackageID%

call :updatePackageInfo

goto menuMain

:menuDeployment
cls
call :writeMenuHeader "Deployment"
if /i "%diskID%" NEQ "X" echo. Drive %driveName% will be formatted as %partitionTable%.
if /i "%imageID%" NEQ "X" echo. Index %imageIndex% from image %image% will be extracted to %letterOS%:\.
if /i "%bootType%" NEQ "----" echo. %bootType% bootloader will be created on %letterSystem%:\ with reference to %letterOS%:\Windows.
if /i "%answerID%" NEQ "X" echo. The answerfile %answerfile% will be applied to %letterOS%:\.
if /i "%assocID%" NEQ "X" echo. The associationfile %associationfile% will be applied to %letterOS%:\.
if /i "%packageID%" NEQ "X" echo. Provisioning package %packagefile% will be applied to %letterOS%:\.
echo.
set /p safe=Start deployment? (y/n)
if /I "%safe%" EQU "n" goto menuMain
if /I "%safe%" NEQ "y" goto menuDeployment

cls
call :writeMenuHeader "Deployment"
if /I "%diskID%" EQU "X" goto continue
if /I "%partitionTable%" EQU "MBR" goto mbrPart

echo. Partitioning %driveName% as GPT with drive letters %letterSystem%, %letterOS%, %letterRecovery%...
echo.
call %moduleLocation%\Partition_GPT.cmd %diskID% %sizeSystem% %sizeMSR% %sizeRecovery% %letterSystem% %letterOS% %letterRecovery%
echo.
echo. Partitioning has finished.

goto continue

:mbrPart
echo. Partitioning %driveName% as MBR with drive letters %letterSystem%, %letterOS%, %letterRecovery%...
echo.
call %moduleLocation%\Partition_MBR.cmd %diskID% %sizeSystem% %sizeRecovery% %letterSystem% %letterOS% %letterRecovery%
echo.
echo. Partitioning has finished.

:continue
echo.
if /I "%imageID%" NEQ "X" (
    echo. Extracting index %imageIndex% from %image% Image to %letterOS%:\...
    echo.
    call :deployImage
    echo.
    echo. The image extraction has finished.
)
echo.
if "%bootType%" NEQ "----" (
    echo. Writing %bootType% bootloader to %letterSystem%:\
    echo.
    call :createBootloader
    echo.
    echo. The bootloader was successfully written.
)
echo.
if /i "%answerID%" NEQ "X" (
    echo. Copying Answer file %answerfile% to %letterOS%:\Windows\Panther...
    call :deployAnswerfile
    echo.
    echo. Copying finished.
)
echo.
if /i "%assocID%" NEQ "X" (
    echo. Applying Association file %associationfile%...
    call :deployAssociationfile
    echo.
    echo Apply finished.
)
if /i "%packageID%" NEQ "X" (
    echo. Applying Provisioning Package %package%...
    call :deployPackage
    echo.
    echo Apply finished.
)
echo.
echo. Deployment complete.
echo.
pause
goto menuMain

:updatePEBootType
wpeutil UpdateBootInfo 1>nul 2>nul
if %errorlevel% EQU 9009 exit /b

reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType | find "0x2" >nul
if %errorlevel% EQU 1 (
    set bootType=BIOS
    set partitionTable=MBR
)
exit /b

:deployImage
%dism% /Apply-Image /ImageFile:%imagepath% /Index:"%imageIndex%" /ApplyDir:%letterOS%:\
exit /b

:deployAnswerfile
if exist %letterOS%:\Windows\Panther (
    del /s /q %letterOS%:\Windows\Panther\*
    rmdir /s /q %letterOS%:\Windows\Panther\
)
mkdir %letterOS%:\Windows\Panther
copy /y %answerfilePath% %letterOS%:\Windows\Panther\unattend.xml > nul
exit /b

:deployAssociationfile
%dism% /image:%letterOS%:\ /import-defaultappassociations:%associationfilePath%
exit /b

:deployPackage
%dism% /apply-siloedpackage /imagepath:%letterOS%:\ /packagepath:%packagePath%
exit /b

:createBootloader
%letterOS%:\Windows\System32\bcdboot %letterOS%:\Windows /s %letterSystem%: /f %bootType%
exit /b

:updateDriveInfo
if /i "%diskID%" EQU "X" (
    set driveName=-------------
    exit /b
)
echo select disk %diskID% > %temp%\team_deploy_diskpart.txt
echo detail disk >> %temp%\team_deploy_diskpart.txt
for /f "usebackq skip=8 tokens=*" %%a in (`diskpart /s %temp%\team_deploy_diskpart.txt`) do (
    set driveName=%%a
    exit /b
)
exit /b

:updateImageList
set i=0
for %%a in (%imageLocation%\%arch%\*.wim %imageLocation%\%arch%\*.esd) do (
    set /a i=i+1
    set image[!i!]=%%~na%%~xa
)
if %i% EQU 0 set imageID=X
exit /b

:updatePackageList
set i=0
for %%a in (%packagelocation%\%arch%\*.spp) do (
    set /a i=i+1
    set package[!i!]=%%~na%%~xa
)
if %i% EQU 0 set packageID=X
exit /b

:updateImageInfo
if /i "%imageID%" EQU "X" (
    set image=-------------
    set imageIndex=-------------
    set imagepath=
    exit /b
)
set image=!image[%imageID%]!
set imageIndex=1
set imagepath=%imageLocation%\%arch%\%image%
exit /b

:updateAnswerfileList
set i=0
for %%a in (%answerfileLocation%\%arch%\*.xml) do (
    set /a i=i+1
    set answer[!i!]=%%~na%%~xa
)
if %i% EQU 0 set answerID=X
exit /b

:updateAnswerfileInfo
if /i "%answerID%" EQU "X" (
    set answerfile=-------------
    set answerfilePath=
    exit /b
)
set answerfile=!answer[%answerID%]!
set answerfilePath=%answerfileLocation%\%arch%\%answerfile%
exit /b

:updateAssociationfileList
set i=0
for %%a in (%associationfileLocation%\%arch%\*.xml) do (
    set /a i=i+1
    set assoc[!i!]=%%~na%%~xa
)
if %i% EQU 0 set assocID=X
exit /b

:updateAssociationfileInfo
if /i "%assocID%" EQU "X" (
    set associationfile=-------------
    set associationfilePath=
    exit /b
)
set associationfile=!assoc[%assocID%]!
set associationfilePath=%associationfileLocation%\%arch%\%associationfile%
exit /b

:updatePackageInfo
if /i "%packageID%" EQU "X" (
    set package=-------------
    set packagePath=
    exit /b
)
set package=!package[%packageID%]!
set packagePath=%packageLocation%\%arch%\%package%
exit /b

:writeMenuHeader
echo.
echo.     TEAM-Computer Deployment Tool - %~1
echo.
exit /b

:writeMenuEntry
set l=%~1                                                       
set r=%~2                                                       
echo. %l:~0,55%   %r:~0,55%
exit /b
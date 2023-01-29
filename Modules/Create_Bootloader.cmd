REM Create_Bootloader.cmd [LetterOfWindows] [LetterOfSystem] [BootloaderType]

%1:\Windows\System32\bcdboot %1:\Windows /s %2: /f %3
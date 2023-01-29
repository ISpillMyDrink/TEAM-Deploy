REM Deploy_Answerfile.cmd [LetterOfWindows] [AnswerfilePath]

if exist %1:\Windows\Panther (
    del /s /q %1:\Windows\Panther\*
    rmdir /s /q %1:\Windows\Panther\
)
mkdir %1:\Windows\Panther
copy /y %2 %1:\Windows\Panther\unattend.xml > nul
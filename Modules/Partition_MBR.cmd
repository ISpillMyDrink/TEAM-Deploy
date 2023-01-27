REM Partition_MBR.cmd [DiskNumber] [SizeOfSystem] [SizeOfRecovery] [LetterOfSystem] [LetterOfWindows] [LetterOfRecovery]

(echo select disk %1
echo clean
echo convert mbr
echo create partition primary size=%2
echo format quick fs=ntfs label="System"
echo assign letter=%4
echo active
echo create partition primary
echo shrink minimum=%3
echo format quick fs=ntfs label="Windows"
echo assign letter=%5
echo create partition primary
echo format quick fs=ntfs label="Recovery"
echo assign letter=%6
echo set id=27 override
) | diskpart
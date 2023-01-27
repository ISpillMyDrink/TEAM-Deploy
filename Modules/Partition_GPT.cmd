REM Partition_GPT.cmd [DiskNumber] [SizeOfSystem] [SizeOfMSR] [SizeOfRecovery] [LetterOfSystem] [LetterOfWindows] [LetterOfRecovery]

(echo select disk %1
echo clean
echo convert gpt
echo create partition efi size=%2
echo format quick fs=fat32 label="System"
echo assign letter=%5
echo create partition msr size=%3
echo create partition primary
echo shrink minimum=%4
echo format quick fs=ntfs label="Windows"
echo assign letter=%6
echo create partition primary
echo format quick fs=ntfs label="Recovery"
echo assign letter=%7
echo set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" override
echo gpt attributes=0x8000000000000001
) | diskpart
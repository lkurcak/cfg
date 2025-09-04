@echo off
start steam://rungameid/252950

for /l %%x in (1, 1, 10) do (
    wmic process where name="rocketleague.exe" CALL setpriority "high priority"
    timeout 5
)
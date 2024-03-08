#KingMaker + Helpful PF2e Tools +Tables:
<#
Version Log:
WIP
- Weather Event Tables
- Hazard Generator
- Add Compainion Stats (Leveling Options?)
- To Finish - Camping Steps Step 2-5
1.8
- Fixed Some Info Topics
- Suggestion to remove Install-Module Scripts any installing from other sources would stop this script from running
Credit: JoeJJohnsonII
1.7
- Early April Fools David Hasselhoff function
1.6
- Added Function Convert-Attacks-Roll20-CMD 
1.5
- Added Camp Activities + Function
- Added Explortation Actitivies + Function
- Added Compainion Activities + Funtion
- Add Monster Lanaguages, Spells, Reaction, Immunites,Resitances, Weakness, and All Traits 
- Improved Monster Load, if file detected skip download
1.4
- Added Function Speed-Calculator (Quick lookup on Speed Based on PF2 Math)
- Added Function Travel-Calculator-Builder-Mile (Summarize Travel based on Miles + Speed)
- Added Function Travel-Calculator-Single-Mile (Quick lookup on Speed for Single Hex 12 Miles)
- Added Function Speed-Based-Difficult-Terrain
- Retired Function Hexploration-Activities-Per-Day - Calculation based on Miles
- Retired Function Hexploration-Days-to-Cross-Tile - Calculation based on Miles
1.3
- Added Function Hexploration-Activities-Per-Day
- Added Function Hexploration-Days-to-Cross-Tile
- Added Random Terrian Feature
- Fixed Typos
1.2
- Added Random Encounter Type
- Added Random Encouner Chance
- Added Information on Terrian Types
- Started List of Activities -Formating YAML-
- Started Camping Steps. -Step 1-
- Fixed Search Monster was not loading the search from prompt
- Changed Function Roll to include "title" option to help label Rolls
- Changed Function Monster Search label "skills and attack Section better visibility"
1.1
- Updated Nested Table Rolls
- Added Rumor Table" Function Roll-Rumor + YAML Entries
- Added Monster Lookup for stat block (Downloads Google Sheet Then Import)
- Added Camping Zones (DCs of area and Encounters with Page)
  •Note• Issue in lookup "Guard" Still hits multiple entries
*Credits to RedditUser:Exocist for creating this Google Spreadsheet*
1.0
- Added Monster Encounter Tables Zones 0 - 6 (YAML)
- Added Dice Roller Function Roll
- Tied Together Function "Enc-Roll"
- Added Stolen Lands Zones Info (Code of Zone + Page + Description)
- YAML Database

Author: Tony V
#>

<#
Powershell Module Required
#>
Import-Module PSYaml -ErrorAction SilentlyContinue

$Module_check = Get-Module -ListAvailable "PSYaml"
IF (($Module_check | measure).Count -eq 0){Write-Host -ForegroundColor Magenta "PowerShell Module - PSYaml not installed...";Write-Host -ForegroundColor Cyan "PowerShell Module - Please Run this Command to install...'Install-Module -Name PSYaml -RequiredVersion 1.0.2'"}

$ThisScriptPath = $MyInvocation.MyCommand.Path
$FolderScriptPath = (Get-ChildItem "$ThisScriptPath").Directory.FullName

Write-Host ""
Write-Host -ForegroundColor Cyan "Path where Script is: "$ThisScriptPath
Write-Host -ForegroundColor Cyan "Using Parent Folder "$FolderScriptPath

Write-Host ""
Write-Host -ForegroundColor Yellow "Downloading Monsters..." 
$MonstersFile = Test-Path -Path "$FolderScriptPath\PF2_Monsters.txt"

IF ($MonstersFile -eq $True){Write-Host -ForegroundColor Green "Monsters...Detected...Skipping Download..." }
IF ($MonstersFile -eq $False){invoke-webrequest -Uri "https://docs.google.com/spreadsheets/d/1SpzEGKgmPNI3fxab4wQtPZm8weqXDgAJeIubIiU-B4U/export?format=csv" -OutFile "$FolderScriptPath\PF2_Monsters.txt"}

Write-Host ""
Write-Host -ForegroundColor Yellow "Loading YAML Database..."

$YAML = ConvertFrom-Yaml (Get-Content "$FolderScriptPath\Tables.yml" -Raw)
IF (($YAML | measure).Count -eq 0){Write-Host "*** WARNING ***" -ForegroundColor Red ; Write-Host "YAML File did not Import correctly" -ForegroundColor yellow; Write-Host "*** WARNING ***" -ForegroundColor Red; $YAMLERROR = Show-Menu -Title ***YAML ERROR - Quit Now?*** -options "No","Yes" }
IF ($YAMLERROR -eq 'Yes'){exit}
#$YAML = ConvertFrom-Yaml (Get-Content "C:\Monsters\PF2 Kingmaker\Tables.yml" -Raw)

Write-Host ""
Write-Host -ForegroundColor Yellow "Loading Functions..."

Function Show-Menu {
    param (
        [string]$Title,
        [array]$options
    )
    Write-Host "================ $Title ================"
    $i = 1
    foreach ($option in $options){
    Write-Host ("$i"+':'+"$option")
    $i++
   }
   $selection = Read-Host
   Write-Host "You Selected "$options[$selection-1]
   $options[$selection-1]
}

Function Roll {

   [CmdletBinding(DefaultParameterSetName = 'Normal')]
   Param(
   [Parameter(Position=0)]
   [int32]$NumberDice = 1,

   [Parameter(Position=1)]
   [int32]$DiceValue = 20,

   [Parameter(Position=2)]
   [int32]$Bonus = 0,

   [Parameter(Position=3)]
   [String]$Title
   )

    $output = 0
    $i = 0
    foreach ($d in @(1..$NumberDice)){
        $i++
        $roll = get-random -Minimum 1 -Maximum ($DiceValue + 1)
        Write-verbose "D$DiceValue #$d rolled $roll"
        IF ($Bonus -ne '0'){
        Write-Verbose "Bonus: $Bonus"
        }
        $roll = $roll+$Bonus
        $roll
        $output += $roll
        IF ($Title -ne $null){
        $Title = $Title+" -"
        }

        IF ($i -eq $NumberDice){
        Switch ($i)
        {
         '1'     {write-host -ForegroundColor yellow $Title "Dice Roll:"$output}
         default {write-host -ForegroundColor yellow $Title "Sum of Dice Rolls:"$output}
        }
        }
    }

}

Function Enc-Roll{

   [CmdletBinding(DefaultParameterSetName = 'Normal')]
   Param(
   [Parameter(Position=0)]
   [string]$Zone = $null)

$Zones = $YAML.'Hex-Encounter'.'Hex-Crawl'.Keys

Do {
    IF ($Zone -eq ''){
    $Zone = Show-Menu -Title "Select Zone For Encounter Table" -options $Zones
    }
    $Enc_List = @()
        ForEach ($Key in $YAML.'Hex-Encounter'.'Hex-Crawl'.$Zone.Keys) {
        $Hash = $YAML.'Hex-Encounter'.'Hex-Crawl'.$Zone
            $Array = [PSCustomObject]@{
                'Dice' = $Hash[$Key].Dice
                'Encounter' = $Hash[$Key].Encounter
                'Notes' = $Hash[$Key].Notes
                'Challenge' = $Hash[$Key].Challenge
                'Reroll' =  $Hash[$Key].Reroll
                }
        $Enc_List += $Array
        }
    
    Switch ($RollType)
    {
    custom {$Enc_Roll = Roll -NumberDice 1 -DiceValue 12 -Bonus 8 -Title "Zone Encounter Roll" -Verbose; break}
    default {$Enc_Roll = Roll -NumberDice 1 -DiceValue 20 -Title "Zone Encounter" -Verbose; break} 
    }
 
    $Result = $Enc_List | where Dice -Contains $Enc_Roll
    $Result | Select Encounter, Notes, Challenge | fl
    IF ($Result.Reroll -ne $null){
        $Reroll = $True
        Write-Host -ForegroundColor Red "Reroll Detected switching to"$Result.Reroll
        $Zone = $Result.Reroll
        IF ($Result.Encounter -eq "Roll 1d12+8 on zone 5 Table"){
            $RollType = "custom"
        }
        }
    ELSE {$Reroll = $False}
} While ($Reroll)
}

Function Search-Monster {

   [CmdletBinding(DefaultParameterSetName = 'Normal')]
   Param(
   [Parameter(Position=0)]
   [string]$MonsterName = '')

$Monsters = Import-Csv "$FolderScriptPath\PF2_Monsters.txt"
<#
$Monsters = Import-Csv "C:\Monsters\PF2 Kingmaker\PF2_Monsters.txt" 
#>
IF ($MonsterName -eq ''){$MonsterName = Read-Host "Enter Monster Name" }

$ChooseMonster =  $Monsters | where name -like "*$MonsterName*"
$M = $ChooseMonster
IF (($ChooseMonster.name | measure).Count -gt '1'){
    $M = Show-Menu -Title "Please Select 1 Monster" -options $ChooseMonster.name;
    $M = $Monsters | where name -eq $M
    }
$TraitList = ('Trait 1','Trait 2','Trait 3','Trait 4','Trait 5','Trait 6','Trait 7')
$TraitPost = ""
foreach ($Trait in $TraitList) {
$check = $M.$Trait
    IF ($check -ne ""){$TraitPost = $TraitPost+"$check "}
}

$LangList = ('Language 1','Language 2','Language 3','Language 4','Language 5','Language 6','Language 7','Language 8','Language 9','Language 10','Language 11','Language 12','Language 13','Language 14','Language 15')
$LangPost = ""
foreach ($Lang in $LangList) {
$check = $M.$Lang
    IF ($check -ne ""){$LangPost = $LangPost+"$check, "}
}

$SkillList = ('Acrobatics','Arcana','Athletics','Crafting','Deception','Diplomacy','Intimidation','Medicine','Nature','Occultism','Performance','Religion','Society','Stealth','Survival','Thievery')
$SkillPost = New-Object -Type PSObject
$SkillPost | Add-Member -Name '::Skills::' -Value '' -MemberType NoteProperty
foreach ($skill in $SkillList) {
$check = $M.$skill
    IF ($check -ne ""){$SkillPost | Add-Member -Name $skill -Value $check -MemberType NoteProperty}
}
$Attacks = @('Attack 1','Attack 2','Attack 3','Attack 4','Attack 5','Attack 6','Attack 7')
$AttacksPost = New-Object -Type PSObject
$AttacksPost | Add-Member -Name '::Attacks::' -Value '' -MemberType NoteProperty
foreach ($Attack in $Attacks) {
$check = $M.$Attack
    IF ($check -ne ""){$AttacksPost | Add-Member -Name $attack -Value $check -MemberType NoteProperty}
}

$ReactList = @('Reaction 1','Reaction 2','Reaction 3')
$ReactPost = New-Object -Type PSObject
$ReactPost | Add-Member -Name '::Reactions::' -Value '' -MemberType NoteProperty
foreach ($React in $ReactList) {
$check = $M.$React
    IF ($check -ne ""){$ReactPost | Add-Member -Name $React -Value $check -MemberType NoteProperty}
}

$SpellsList = @('Spells 1','Spells 2','Spells 3')
$SpellsPost = New-Object -Type PSObject
$SpellsPost | Add-Member -Name '::Spells::' -Value '' -MemberType NoteProperty
foreach ($Spell in $SpellsList) {
$check = $M.$Spell
    IF ($check -ne ""){$SpellsPost | Add-Member -Name $Spell -Value $check -MemberType NoteProperty}
}
Write-Host "##################################################"
Write-Host ""
Write-Host $M.name -ForegroundColor Yellow
Write-Host $M.Alignment $M.Size$TraitPost
Write-Host "Source:"$M.Source
Write-Host "Perception:"$M.Perception";"$M.Senses
IF ($LangPost -ne ""){
$LangPost = $LangPost -replace ".{2}$"; Write-Host "Languages: $LangPost"
}
$SkillPost | FL
Write-Host "Str:"$M.Strength"Dex:"$M.Dexterity"Con:"$M.Constitution"Int:"$M.Intelligence"Wis:"$M.Wisdom"Cha:"$M.Charisma
Write-Host "##################################################"
Write-Host "AC:"$M.AC"Fort:"$M.Fort"Ref:"$M.Ref"Will:"$M.Will
Write-Host "HP:"$M.HP
IF ($M.Immunities -ne ""){ 
Write-Host "Immunites:"$M.Immunities
}
IF ($M.Resistances -ne ""){
Write-Host "Resistances:"$M.Resistances
}
IF ($M.Weaknesses -ne ""){
Write-Host "Weaknesses:"$M.Weaknesses
}
IF ($ReactPost -ne ""){
$ReactPost | FL
}

Write-Host "##################################################"
Write-Host "Speed:"$M.Speed
$AttacksPost | FL
Write-Host "##################################################"
$SpellsPost | FL

$R20Attacks =  Show-Menu -Title "Convert Attacks to Roll 20?" -options Yes,No
IF ($R20Attacks -eq "Yes"){
    IF ($AttacksPost.'Attack 1' -ne ""){
        $R20Attack1 = Convert-Attacks-Roll20-CMD -Num 1 -MonsterName $M.name -AttackString $AttacksPost.'Attack 1'
    }
    IF ($AttacksPost.'Attack 2'.Length -ne "0" ){
        $R20Attack2 = Convert-Attacks-Roll20-CMD -Num 2 -MonsterName $M.name -AttackString $AttacksPost.'Attack 2'
    }   
    IF ($AttacksPost.'Attack 3'.Length -ne "0" ){
        $R20Attack3 = Convert-Attacks-Roll20-CMD -Num 3 -MonsterName $M.name -AttackString $AttacksPost.'Attack 3'
    }
    IF ($AttacksPost.'Attack 4'.Length -ne "0" ){
        $R20Attack4 = Convert-Attacks-Roll20-CMD -Num 4 -MonsterName $M.name -AttackString $AttacksPost.'Attack 4'
    } 
    
}
}

Function Convert-Attacks-Roll20-CMD {
   [CmdletBinding(DefaultParameterSetName = 'Normal')]
   Param(
   $Num,
   $MonsterName,
   $AttackString
   )
#$AttackString = "Melee horn +5, Damage 1d4+3 bludgeoning and Push"
#$AttackString = "Melee claw +26 (agile, magical, reach 10 feet), Damage 3d8+12 slashing"

$Attack_Name = $AttackString -match "(?>Melee\s|Ranged\s)(.*)(?>\s\+)"
$Attack_Name = $Matches[1].Trim()

$Attack_MR   = $AttackString -match "(?>Melee|Ranged)"
$Attack_MR   = $Matches[0].Trim()

$Attack_Hit  = $AttackString -match "(?>Melee\s|Ranged\s)(\w*\s)(\+\d*)"
$Attack_Hit  = $Matches[2].Trim()

$Attack_Traits = $AttackString -match "(?>\()(.*)(?>\))"
$Attack_Traits = $Matches[0].Trim()

$Damage = $AttackString -match "(?>Damage\s)(\d*\w\d*[^ ]\d*)(\s)(\w*(\sand\s\w*)|\w*)"
$Damage = $Matches[1].Trim()

$Damage_Type = $AttackString -match "(?>Damage\s)(\d*\w\d*[^ ]\d*)(\s)(\w*(\sand\s\w*)|\w*)"
$Damage_Type = $Matches[3].Trim()

$Plus_Damage = $AttackString -match "(?>plus\s)((\d*\w\d*[^ ]\d*)(\s)(\w*(\sand\s\w*)|\w*)|(\w*))"
IF ($Plus_Damage -ne $False){
$Plus_Damage = $Matches[2].Trim()
} ELSE {$Plus_Damage = ""}

$Plus_Damage_Type_1 = $AttackString -match "(?>plus\s)((\d*\w\d*[^ ]\d*)(\s)(\w*(\sand\s\w*)|\w*)|(\w*\s\w*))"
IF ($Plus_Damage_Type_1 -ne $False){
$Plus_Damage_Type_1 = $Matches[4].Trim()
}

$Plus_Damage_Type_2 = $AttackString -match "(?>plus\s)((\d*\w\d*[^ ]\d*)(\s)(\w*(\sand\s\w*)|\w*)|(\w*\s\w*))"
IF ($Plus_Damage_Type_2 -ne $False){
    try{
        $Plus_Damage_Type_2 = $Matches[6].Trim()
    }
    catch {
        $Plus_Damage_Type_2 = ""
    }
}
$MonsterAtk  = "$MonsterName : Attack $Num `r`n $Attack_Name ($Attack_MR) [[1d20$Attack_Hit]] `r`n"
$MonsterDmg  = "[[$Damage]] $Damage_Type"
$MonsterPlus = " | Plus [[$Plus_Damage]] $Plus_Damage_Type_1 $Plus_Damage_Type_2"

IF ($MonsterPlus -like "*False False*"){
Write-Host $MonsterAtk$MonsterDmg
Write-Host $Attack_Traits
} ELSE {
Write-Host $MonsterAtk$MonsterDmg$MonsterPlus
Write-Host $Attack_Traits
}
}


Function Roll-Rumor {
Write-Host -ForegroundColor Yellow "***Rumors Table***"
$Rumor_Choice = Show-Menu -Title "Choose Rumors Area" -options $YAML.Generators.Rumors.Keys
$hash = $YAML.Generators.Rumors.$Rumor_Choice
$Rumor_List = @()
foreach ($key in $YAML.Generators.Rumors.$Rumor_Choice.Keys){
$Array = [PSCustomObject]@{
    'D' = $key
    'Rumor' = $hash[$key]
    }
$Rumor_List += $Array
}
Write-Host -ForegroundColor Yellow $hash.Note
IF ($Rumor_Choice -eq 'CENTRAL STOLEN LANDS'){
Write-Host -ForegroundColor Red "*Note* Please Select if you want lower-level Rumors"
$LowRumor = Show-Menu -Title "lower-level Rumors?" -options "Yes","No"
    IF ($LowRumor -eq "No"){$RollType = "custom"}
}
    Switch ($RollType)
    {
    custom {[int]$Rumor_Roll = Roll -NumberDice 1 -DiceValue 20 -Verbose; break}
    default {[int]$Rumor_Roll = Roll -NumberDice 1 -DiceValue 10 -Verbose; break} 
    }
($Rumor_List | Where D -eq $Rumor_Roll).Rumor
}

Function Topic-Info {
$Info_Choice = Show-Menu -title "Choose Topic" -options $YAML.Information.Topic.Keys
$hash = $YAML.Information.Topic.$Info_Choice
$Info_List = @()

switch ($Info_Choice)
{
'Stolen Lands Zones Summary'      {$InfoSet = 'SLZ';break}
'Stolen Lands Zones Area-Details' {$InfoSet = 'SLZAD';break}
'CAMPING ZONES'                   {$InfoSet = 'CZ';break}
'TERRAIN'                         {$InfoSet = 'T';break}
}

IF ($InfoSet -eq 'CZ'){
ForEach ($Key in $hash.Keys) {
    $Array = [PSCustomObject]@{
        'Zone' = $Key
        'Name' = $hash[$Key][0]
        'Zone DC' = $hash[$Key][1]
        'Encounter DC' = $hash[$Key][2]
        'Page' = $hash[$Key][3]
        }
$Info_List += $Array
    }
$Info_List | ft
}
IF ($InfoSet -eq 'SLZ'){
ForEach ($Key in $hash.Keys) {
    $Array = [PSCustomObject]@{
        'Level' = $Key
        'Name' = $hash[$Key][0]
        'Code' = $hash[$Key][1]
        'Page' = $hash[$Key][2]
        'Description' = $hash[$Key][3]
        }
$Info_List += $Array
    }
$Info_List | ft
}
IF ($InfoSet -eq 'T'){
ForEach ($Key in $hash.Keys) {
    $Array = [PSCustomObject]@{
        'Terrain' = $Key
        'Note' = $hash[$Key][0]
        'Resources' = $hash[$Key][1]
        'Secrets' = $hash[$Key][2]
        }
$Info_List += $Array
    }
$Info_List | fl
}
}

Function Camp-Event {
#WIP
<#
 # Camping: Expanded rules for camping can be found
on pages 106–119 of the Kingmaker Companion
Guide, including rules on how to fortify campsites,
the effects that different meals might have, and how
to integrate roleplaying elements between the PCs and
their NPC companions.

#>

}

Function Weather-Event {
#WIP Weather: Pages 120–125 of
}

Function Random-Encounter-Type {
$Roll_RET = roll -NumberDice 1 -DiceValue 10 -Title "Random Encounter Type"
switch ($Roll_RET)
{
    { 1, 2, 3, 4, 5  -contains $_ } {Write-Host -ForegroundColor Green "Encounter Type: Harmless"}
    { 6, 7  -contains $_ }          {Write-Host -ForegroundColor Red "Encounter Chance: Hazard"}
    { 8, 9, 10 -contains $_ }       {Write-Host -ForegroundColor Yellow "Encounter Chance: Creature"; Enc-Roll}
}
}

Function Random-Encounter-Chance {

[CmdletBinding()]
Param(
[ValidateSet("Aquatic", "Arctic", "Desert","Forest","Mountain","Plains","Swamp")][string]$Terrain,

[ValidateSet("Road","River","Flying")][string]$Modifier
)

IF($Terrain -eq "$null"){
$Terrain = Show-Menu -Title "Select Terrain Type" -options "Aquatic", "Arctic", "Desert","Forest","Mountain","Plains","Swamp"
}
switch ($Terrain)
{
    Aquatic  {$Zone_DC = 17;}
    Arctic   {$Zone_DC = 17;}
    Desert   {$Zone_DC = 17;}
    Forest   {$Zone_DC = 14;}
    Mountain {$Zone_DC = 16;}
    Plains   {$Zone_DC = 12;}
    Swamp    {$Zone_DC = 14;}
}


IF($Modifier -eq ''){
$Modifier = Show-Menu -Title "On Road/River/Flying - (Changes DC)" -options "Road","River","Flying"
}

Write-Host ""
switch ($Modifier)
{
'Road'   {Write-Host -ForegroundColor Cyan "Road will decrease DC by 2";$ChangeDC = -2}
'River'  {Write-Host -ForegroundColor Cyan "River will decrease DC by 2";$ChangeDC = -2}
'Flying' {Write-Host -ForegroundColor Cyan "Flying will increase DC by 3";$ChangeDC =  3}
}

$EncDC = $Zone_DC+$ChangeDC
IF ($ChangeDC -ne $null){
Write-Host "Rolling: Random Encounter Chance for"$Terrain "(DC $Zone_DC) is Adjusted to $EncDC Total"}
ELSE {Write-Host "Rolling: Random Encounter Chance for"$Terrain "(DC $Zone_DC)"}
$EncRoll = roll -NumberDice 1 -DiceValue 20 -Title "Random Encounter Chance" -Verbose
$CheckDiff = $EncRoll - $EncDC
IF ($EncRoll -ge $EncDC) {Write-Host -ForegroundColor Green "Success: PCs have a random encounter"; Random-Encounter-Type }
ELSE {Write-Host -ForegroundColor Magenta "Failed: PCs no random encounter"}
IF ($CheckDiff -ge 10) {Write-Host -ForegroundColor Green "Critical Success: PCs have a second random encounter"; Random-Encounter-Type }
}

Function Random-Terrain-Feature {
[CmdletBinding()]
Param(
[ValidateSet("Aquatic", "Arctic", "Desert","Forest","Mountain","Plains","Swamp")][string]$Terrain
)

IF ($Terrain.Length -eq 0){
$Terrain = Show-Menu -Title "Select Terrain Type" -options "Aquatic", "Arctic", "Desert","Forest","Mountain","Plains","Swamp"
}

$Roll_RET = roll -NumberDice 1 -DiceValue 20 -Title "Random Terrian Feature - $Terrain"
    switch ($Roll_RET)

    {
        { 1, 2, 3  -contains $_  }                                   {$Feature = 'Landmark' ;Write-Host -ForegroundColor Yellow "Terrain Feature: $Feature"}
        { 4, 5, 6  -contains $_  }                                   {$Feature = 'Secret'   ;Write-Host -ForegroundColor Yellow "Terrain Feature: $Feature"}
        { 7, 8, 9  -contains $_  }                                   {$Feature = 'Resource' ;Write-Host -ForegroundColor Yellow "Terrain Feature: $Feature"}
        { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 -contains $_ }  {$Feature = 'Standard' ;Write-Host -ForegroundColor Yellow "Terrain Feature: $Feature"}

    }

$Info_List = @()
$Hash = $YAML.Information.Topic.TERRAIN

ForEach ($Key in $hash.Keys) {
    $Array = [PSCustomObject]@{
        'Terrain' = $Key
        'Note' = $hash[$Key][0]
        'Resources' = $hash[$Key][1]
        'Secrets' = $hash[$Key][2]
        }
    $Info_List += $Array
    }

IF($Feature -eq "Landmark"){$Info_List | where Terrain -eq $Terrain}
IF($Feature -eq "Secret")  {$Info_List | where Terrain -eq $Terrain | FL Secrets}
IF($Feature -eq "Resource"){$Info_List | where Terrain -eq $Terrain | FL Resources}
IF($Feature -eq "Standard"){$Info_List | where Terrain -eq $Terrain}
}
<#
Function Hexploration-Activities-Per-Day {
[CmdletBinding()]
Param(
[int]$Speed,
[string]$Title
)

IF ($Speed -eq ''){
$Speed = Read-Host "Enter Speed"
}

switch ($Speed)
    {
        10                        {$APD = .5}
        { 15, 25 -contains $_  }  {$APD = 1 }
        { 30, 40 -contains $_  }  {$APD = 2 }
        { 45, 55 -contains $_  }  {$APD = 3 }
        60                        {$APD = 4 }

    }
Write-Host $Title ": has $APD Activities" -ForegroundColor Yellow 
}

Function Hexploration-Days-to-Cross-Tile {

Travel
Move 
Source Gamemastery Guide pg. 172
You progress toward moving into an adjacent hex. In open terrain, like a plain,
using 1 Travel activity allows you to move from one hex to an adjacent hex.
Traversing a hex with difficult terrain (such as a typical forest or desert)
requires 2 Travel activities, and hexes of greater difficult terrain
(such as a steep mountain or typical swamp) require 3 Travel activities to traverse.
Traveling along a road uses a terrain type one step better than the surrounding terrain.
For example, if you are traveling on a road over a mountain pass, the terrain is difficult
terrain instead of greater difficult terrain.

The Travel activity assumes you are walking overland. If you are flying or traveling on water,
most hexes are open terrain, though there are exceptions. Flying into storms or high winds count
as difficult or greater difficult terrain. Traveling down a river is open terrain, but traveling
upriver is difficult or greater difficult terrain.


[CmdletBinding()]
Param(
[ValidateSet("Open Terrain","Difficult Terrain","Greater Difficult Terrain")][string]$DifficultTerrain,
[string]$Title,
[switch]$Easy_Travel
)

IF ($DifficultTerrain.Length -eq 0){
$DifficultTerrain = Show-Menu -Title "Select Terrain Difficulty" -options "Open Terrain","Difficult Terrain","Greater Difficult Terrain"
}

switch ($DifficultTerrain)
{
'Open Terrain'              {$NTA = 1}
'Difficult Terrain'         {$NTA = 2}
'Greater Difficult Terrain' {$NTA = 3}
}

IF ($Easy_Travel.IsPresent){$NTA = $NTA-1}
IF ($NTA -eq '0'){$NTA = $NTA+0.5}

Write-Host $Title ": Requies $NTA Travel Activites" -ForegroundColor Yellow
$NTA
}
#>
Function Speed-Based-Difficult-Terrian {
[CmdletBinding()]
Param(
[ValidateSet("Open Terrain","Difficult Terrain","Greater Difficult Terrain")][string]$DifficultTerrain,
[string]$Title,
[int]$Speed,
[switch]$Easy_Travel,
[switch]$Harder_Travel,
[switch]$Show_Speed
)

Switch ($DifficultTerrain)
{
'Open Terrain'              {$Change = 0 }
'Difficult Terrain'         {$Change = .5 }
'Greater Difficult Terrain' {$Change = (1/3)}
}

IF($Easy_Travel.IsPresent){
Switch ($DifficultTerrain)
{
'Difficult Terrain'         {$Change = 0  ;$DifficultTerrain = "Open Terrain";Write-Host "You Find an Easier Path: Adjusted Difficult Terrain to Open Terrain" -ForegroundColor Yellow }
'Greater Difficult Terrain' {$Change = .5 ;$DifficultTerrain = "Difficult Terrain";Write-Host "You Find an Easier Path: Adjusted Greater Difficult Terrain to Difficult Terrain" -ForegroundColor Yellow }
}
}

IF($Harder_Travel.IsPresent){
Switch ($DifficultTerrain)
{
'Open Terrain'      {$Change = .5    ;$DifficultTerrain = "Difficult Terrain";Write-Host "Path is more Difficult: Adjusted Open Terrain to Difficult Terrain." -ForegroundColor Yellow }
'Difficult Terrain' {$Change = (1/3) ;$DifficultTerrain = "Greater Difficult Terrain";Write-Host "Path is more Difficult: Adjusted Difficult Terrain to Greater Difficult Terrain" -ForegroundColor Yellow }
}
}
$ChangedSpeed = $Speed*$Change
IF ($Change -eq '0'){
$ChangedSpeed = $Speed
}
$ChangedSpeed = [math]::Ceiling($ChangedSpeed)
IF ($Show_Speed.IsPresent){
Write-Host "Your Speed is: "$ChangedSpeed -ForegroundColor Yellow
}
$ChangedSpeed
}

Function Speed-Calculator {
#Based on 6000 ft = Mile
Param(
[int]$Speed
)
$SpeedChart = @()

$Array = [PSCustomObject]@{
    '1 min'  = $Speed*10 
    '10 min' = $Speed*100
    '1 hr'   = (($Speed*100)*6)/6000
    'Daily'  = ((($Speed*100)*6)/6000)*8
    }
$SpeedChart = $Array
$SpeedChart
}

Function Travel-Calculator-Single-Hex {
[CmdletBinding()]
Param(
[int]$Speed
)
IF($Speed -eq ""){
$Speed = Read-Host "Please Enter Party Speed"
}
$Total_Distance = 12

$Day = 1
$Journey = @()
for ($Miles = 0; $Miles -lt $Total_Distance ; $Day++){
        Write-Host ""
        Write-Host "Day: "$Day -ForegroundColor DarkCyan
        $TDDiff = Show-Menu -Title "is Terrain Difficult or Open?" -options "Difficult","Open"
            IF ($TDDiff -eq "Difficult"){
                $TDDiff = Show-Menu -Title "Please Select Terrain Difficulty" -options "Difficult Terrain","Greater Difficult Terrain"
                }
            IF ($TDDiff -eq "Open"){
                $TDDiff =  'Open Terrain'
                }
        $TDAdjust = Show-Menu -Title "Easier or Harder Travel?" -options "Easy","Harder","None"
            Switch ($TDAdjust)
            {
                'Easy'  {$TDAdjust = '-Easy_Travel'}
                'Harder'{$TDAdjust = '-Harder_Travel'}
                'None'  {$TDAdjust = ''}
            }

            IF ($Day -ne '1' ){
                $SpeedCQ = Show-Menu -Title "Change Party Base Speed?" -options "Yes","No"
            }
            IF($SpeedCQ -eq "Yes"){
                $Speed = Read-Host "Please Enter Party Speed"
                }
        $DaySpeed = Invoke-Expression "Speed-Based-Difficult-Terrian -DifficultTerrain '$TDDiff' -Speed $Speed $TDAdjust"
        Write-Host "Current Day Speed:"$DaySpeed -ForegroundColor Cyan
        $Miles_Day = (Speed-Calculator -Speed $DaySpeed).Daily
        Write-Host "Miles Possible:"$Miles_Day -ForegroundColor Yellow
            $Miles += $Miles_Day
                IF($Miles -gt $Total_Distance){
                    $Miles = $Total_Distance
                    Write-Host "You Arrive to Destination Early" -ForegroundColor Red
                        $Miles_Left = $Total_Distance-($Journey[[int]$Day+(-2)].'Total Miles')
                        $Miles_Hour = (Speed-Calculator -Speed $DaySpeed).'1 hr'
                    $HTC = $Miles_Left/$Miles_Hour
                    Write-Host "You Arrive in $HTC Hours" -ForegroundColor Red
                    $Miles_Day = $Miles_Left
                    }
                $Array = [PSCustomObject]@{
                    'Day'            = $Day
                    'Miles Traveled' = $Miles_Day
                    'Total Miles'    = $Miles
                    }
                 $Journey += $Array   
                 }
$Journey
}

Function Travel-Calculator-Builder-Mile {
[CmdletBinding()]
Param(
[int]$Tiles,
[string]$TerrainList,
[int]$Speed,
[string]$DifficultTerrianList
)
$Journey=@()
Write-Host -ForegroundColor Yellow "Kingmaker Hex to Hex is considered 12 Miles, That is normally calculated from Center to Center or Edge to Edge of into same direction"
Write-Host ""
Write-Host -ForegroundColor Cyan "PC's can travel 8 hours before requiring rest/camping"

IF($Tiles -eq ""){
$Tiles = Read-Host "Please Enter Desired Number of Tiles to Travel"
}
IF($Speed -eq ""){
$Speed = Read-Host "Please Enter Party Speed"
}
$Total_Distance = $Tiles * 12
Write-Host -ForegroundColor Gray "Tiles: $Tiles is a total of $Total_Distance miles"

#############################
$Day = 1
$Journey = @()
for ($Miles = 0; $Miles -lt $Total_Distance ; $Day++){
        Write-Host ""
        Write-Host "Day: "$Day -ForegroundColor DarkCyan
        $TDDiff = Show-Menu -Title "is Terrain Difficult or Open?" -options "Difficult","Open"
            IF ($TDDiff -eq "Difficult"){
                $TDDiff = Show-Menu -Title "Please Select Terrain Difficulty" -options "Difficult Terrain","Greater Difficult Terrain"
                }
            IF ($TDDiff -eq "Open"){
                $TDDiff =  'Open Terrain'
                }
        $TDAdjust = Show-Menu -Title "Easier or Harder Travel?" -options "Easy","Harder","None"
            Switch ($TDAdjust)
            {
                'Easy'  {$TDAdjust = '-Easy_Travel'}
                'Harder'{$TDAdjust = '-Harder_Travel'}
                'None'  {$TDAdjust = ''}
            }

            IF ($Day -ne '1' ){
                $SpeedCQ = Show-Menu -Title "Change Party Base Speed?" -options "Yes","No"
            }
            IF($SpeedCQ -eq "Yes"){
                $Speed = Read-Host "Please Enter Party Speed"
                }
        $DaySpeed = Invoke-Expression "Speed-Based-Difficult-Terrian -DifficultTerrain '$TDDiff' -Speed $Speed $TDAdjust"
        Write-Host "Current Day Speed:"$DaySpeed -ForegroundColor Cyan
        $Miles_Day = (Speed-Calculator -Speed $DaySpeed).Daily
        Write-Host "Miles Possible:"$Miles_Day -ForegroundColor Yellow
            $Miles += $Miles_Day
                IF($Miles -gt $Total_Distance){
                    $Miles = $Total_Distance
                    Write-Host "You Arrive to Destination Early" -ForegroundColor Red
                        $Miles_Left = $Total_Distance-($Journey[[int]$Day+(-2)].'Total Miles')
                        $Miles_Hour = (Speed-Calculator -Speed $DaySpeed).'1 hr'
                    $HTC = $Miles_Left/$Miles_Hour
                    Write-Host "You Arrive in $HTC Hours" -ForegroundColor Red
                    $Miles_Day = $Miles_Left
                    }
                $Array = [PSCustomObject]@{
                    'Day'            = $Day
                    'Miles Traveled' = $Miles_Day
                    'Total Miles'    = $Miles
                    }
                 $Journey += $Array   
                 }
Write-Host ""
Write-Host Travel Summary: -ForegroundColor Magenta
$Journey | ft
}

Function List-Exploration-Activities {
$Hash = $YAML.Exploration.Activities

$ExpAct = Show-Menu -Title "Pick" -options 'PREPARE A CAMPSITE','HUSTLE','INVESTIGATE','REPEAT A SPELL','SCOUT','SEARCH','BURROW AN ARCANE SPELL','COERCE','COVER TRACKS','DECIPHER WRITING','GATHER INFORMATION','IDENTIFY ALCHEMY','IDENTIFY MAGIC','IMPERSONATE','LEARN A SPELL','MAKE AN IMPRESSION','REPAIR','SENSE DIRECTION','SQUEEZE','TRACK','TREAT WOUNDS','TRAVEL','RECONNOITER','FORTIFY CAMPING','MAP THE AREA'

$ExActInfo = New-Object -Type PSObject
$Hash.$ExpAct.Keys | ForEach-Object {IF($_ -eq 'Check Result'){return};$ExActInfo | Add-Member -Name $_ -Value ($Hash.$ExpAct.$_ -join " ") -MemberType NoteProperty }
$ExActInfo | fl

$CR_ExActInfo = New-Object -Type PSObject
$Hash.$ExpAct.'Check Result'.Keys | ForEach-Object {$CR_ExActInfo | Add-Member -Name $_ -Value ($Hash.$ExpAct.'Check Result'.$_ -join " ") -MemberType NoteProperty }
$CR_ExActInfo | fl

}

Function List-Camping-Activities {
$Hash = $YAML.Camping.Activities

$CampActivity = Show-Menu -Title "Pick" -options "CAMOUFLAGE CAMPSITE","COOK BASIC MEAL","COOK SPECIAL MEAL","DISCOVER SPECIAL MEAL","HUNT AND GATHER","LEARN FROM A COMPANION","ORGANIZE WATCH","PROVIDE AID","RELAX","TELL CAMPFIRE STORY"

$Camp_Activity_Info = New-Object -Type PSObject
$Hash.$CampActivity.Keys | ForEach-Object {IF($_ -eq 'Check Result'){return};$Camp_Activity_Info | Add-Member -Name $_ -Value ($Hash.$CampActivity.$_ -join " ") -MemberType NoteProperty }
$Camp_Activity_Info | fl

$CR_Camp_Activity_Info = New-Object -Type PSObject
$Hash.$CampActivity.'Check Result'.Keys | ForEach-Object {$CR_Camp_Activity_Info | Add-Member -Name $_ -Value ($Hash.$CampActivity.'Check Result'.$_ -join " ") -MemberType NoteProperty }
$CR_Camp_Activity_Info | fl

}

Function List-Companion-Activities {
[CmdletBinding()]
Param(
[ValidateSet('Amiri','Ekundayo','Harrim','Jaethal','Jubilost','Kalikke','Kanerah','Linzi','Nok-Nok','Octavia','Regongar','Tristian','Valerie')][string]$Companion
)

$Hash = $YAML.Companions

IF($Companion -eq ""){
$Companion = Show-Menu -Title "Select Compainion" -options 'Amiri','Ekundayo','Harrim','Jaethal','Jubilost','Kalikke','Kanerah','Linzi','Nok-Nok','Octavia','Regongar','Tristian','Valerie'
}
$Companion_Activity = @()



ForEach ($Key in $Hash.$Companion.Activity) {
    $Array = [PSCustomObject]@{
        'Activity' = $Key.Name
        'Traits' = $Key.Traits -join " "
        'Requirements' = $Key.Requirements
        'Description' = $Key.Description
        }
    $Companion_Activity += $Array
    }
$Companion_Activity | fl
}

Function Set-WallPaper {
 
<#
 
    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
    
    .PARAMETER Image
    Provide the exact path to the image
 
    .PARAMETER Style
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
    .EXAMPLE
    Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
    Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
  
#>
 
param (
    [parameter(Mandatory=$True)]
    # Provide path to image
    [string]$Image,
    # Provide wallpaper style that you would like applied
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$Style
)
 
$WallpaperStyle = Switch ($Style) {
  
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
  
}
 
If($Style -eq "Tile") {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
 
}
Else {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
 
}
 
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

Function David-Hasselhoff {
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
Read-Host "Please save your WallPaper before Running this, Hit Enter"

do
{
$confirm = Read-Host "Please Type 'David Hasselhoff' to confirm -case sensitive, hit ctrl-c to close"
}
while ($confirm -ne 'David Hasselhoff')

do
{
 $David_Hasselhoff = $true

 $Test_David = [System.IO.File]::Exists("C:\David_Hasselhoff\the_glory.png")

IF ($Test_David -eq $False){
$David_Hasselhoff_Base64 = @"
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
"@
 cd C:\
 mkdir David_Hasselhoff
$filename = 'C:\David_Hasselhoff\the_glory.png'
$bytes = [Convert]::FromBase64String($David_Hasselhoff_Base64)
[IO.File]::WriteAllBytes($filename, $bytes)
}

Set-WallPaper -Image 'C:\David_Hasselhoff\the_glory.png' -Style Fit

$image = [System.Drawing.image]::FromFile('C:\David_Hasselhoff\the_glory.png')
$image.rotateflip("Rotate90FlipNone")
$image.save('C:\David_Hasselhoff\the_glory.png','png')

sleep -Seconds .6
     
}
 while ($David_Hasselhoff = $true)
}


Function Flip-Table {
Write-Host ""
Write-Host "You were so angry you grabbed the Table and Flipped it!!!" -ForegroundColor Red
Write-Host "Then Realize it's Virtual..." -ForegroundColor Cyan
Write-Host '┬─┬ /( º _ º/)'
Write-Host ""
}

Function Main-Run{
do
{
$MENU = Show-Menu -Title "PF2 Kingmaker Generator" -options 'Info','Search Monster','Random Encounter Chance','Encounter Roll','Roll Rumor','Travel Calculator','Companion Activities','Camping Activities','Exploration Activities','David Hasselhoff','Quit','(╯°□°)╯_ ┻━┻'

switch ($MENU)
{
'Info'                     {Topic-Info}
'Search Monster'           {Search-Monster}
'Random Encounter Chance'  {Random-Encounter-Chance}
'Encounter Roll'           {Enc-Roll}
'Roll Rumor'               {Roll-Rumor}
'Travel Calculator'        {Travel-Calculator-Builder-Mile}
'Companion Activities'     {List-Companion-Activities}
'Camping Activities'       {List-Camping-Activities}
'Exploration Activities'   {List-Exploration-Activities}
'David Hasselhoff'         {David-Hasselhoff}
'(╯°□°)╯_ ┻━┻'              {Flip-Table}
}

}
while ($MENU -ne "Quit")
}

Write-Host ""
Write-Host -ForegroundColor Yellow "Running Main-Menu..."

Main-Run

<#
 #SCRATCH PAD BELOW
#>


<#
$YAML = ConvertFrom-Yaml (Get-Content "C:\Monsters\PF2 Kingmaker\Tables.yml" -Raw)

$Menu = Show-Menu -Title "PF2 Kingmaker Generator" -options 'Info','Generators','Hex Map Event','Kingdom Event','Campfire Event','Quit'

IF ($Menu -eq 'Info'){
$Info_List = @()
Write-Host -ForegroundColor Yellow "***Stolen Lands Zones***"
$hash = $YAML.Information.Topic.'Stolen Lands Zones'
ForEach ($Key in $YAML.Information.Topic.'Stolen Lands Zones'.Keys) {
    $Array = [PSCustomObject]@{
        'Level' = $Key
        'Name' = $hash[$Key][0]
        'Code' = $hash[$Key][1]
        'Page' = $hash[$Key][2]
        'Description' = $hash[$Key][3]
        }
$Info_List += $Array
    }
$Info_List | ft
}

IF ($Menu -eq 'Hex Map Event'){
$HME = Show-Menu -Title 'Hex Map Event' -options ($YAML.'Hex-Encounter'.Keys)
}

IF($HME -eq 'Hex-Crawl'){
$Enc_List = @()
$Enc = Show-Menu -Title 'Hex Map Event' -options ($YAML.'Hex-Encounter'.'Hex-Crawl'.Keys)
$hash = $YAML.'Hex-Encounter'.'Hex-Crawl'.$Enc

Write-Host -ForegroundColor Yellow $Enc
ForEach ($Key in $YAML.'Hex-Encounter'.'Hex-Crawl'.$Enc.Keys) {
    $Array = [PSCustomObject]@{
        'Dice' = $Hash[$Key].Dice
        'Encounter' = $hash[$Key].Encounter
        'Notes' = $hash[$Key].Notes
        'Challenge' = $hash[$Key].Challenge
        }
$Enc_List += $Array
    }
$Enc_List | ft

$this_roll = roll -NumberDice 1 -DiceValue 20 -Verbose
$Enc_List | where Dice -Contains $this_roll | Select Encounter, Notes, Challenge | fl
}

IF ($Menu -eq 'Generator'){
$Gen_List = @()
Write-Host -ForegroundColor Yellow "***Generators***"
$hash = $YAML.Generators


}


<#
#List All Tables
$Table_List = @()
foreach ($Table in $YAML.'Hex-Encounter'.'Hex-Crawl'.Keys){
    foreach($Key in $YAML.'Hex-Encounter'.'Hex-Crawl'.$Table.Keys ){
        $Hash = $YAML.'Hex-Encounter'.'Hex-Crawl'.$Table
        $Array = [PSCustomObject]@{
            'Zone' = $Table
            'Dice' = $Hash[$Key].Dice
            'Encounter' = $hash[$Key].Encounter
            'Notes' = $hash[$Key].Notes
            'Challenge' = $hash[$Key].Challenge
            }
            $Table_List += $Array
        }
}
foreach ($Zone in ($Table_List.Zone | sort -Unique)){
    Write-Host -ForegroundColor Yellow $Zone
    $Table_List | Where Zone -EQ $Zone | Select Dice, Encounter, Notes, Challenge | FT
    Write-Host ''
    }

#>

<#
Write-Host "Test Encounter Rolll" -ForegroundColor Yellow
Write-Host ""
Write-Host "Party has to cross 5 tiles, to get to destination, party is just traveling (not hustle or exploring)"
Write-Host "Party is traveling on Open-Terrian to Open-Terrian this is means 1 Activity per Day with Camping Each Hex to Rest"
Write-Host "Party is in Zone 1 Rostland Hinterlands, which has a Zone DC of 15"
Write-Host "Party has picked Dell Raiser to set Camp because he has the highest Survival Skill 8 (Just an example)"
Write-Host ""
Write-Host ""
Write-Host "Tile 1 - Travel"
$Roll_enc_c = roll -NumberDice 1 -DiceValue 20
IF ($Roll_enc_c -lt 12){Write-Host -ForegroundColor Magenta "Encounter Chance: Somthing Will Happen!"
$Roll_enc_t = roll -NumberDice 1 -DiceValue 10
switch ($Roll_enc_t)
{
    { 1, 2, 3, 4, 5  -contains $_ } {Write-Host -ForegroundColor Green "Encounter Type: Harmless"}
    { 6, 7  -contains $_ }          {Write-Host -ForegroundColor Red "Encounter Chance: Hazard"}
    { 8, 9, 10 -contains $_ }       {Write-Host -ForegroundColor Yellow "Encounter Chance: Creature"; Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
} ELSE {Write-Host -ForegroundColor Green "Encounter Chance: Travel is Uneventful!"}

Write-Host "Tile 1 - Camping"
$Roll_enc = roll -NumberDice 1 -DiceValue 20 -Bonus 8
switch ($Roll_enc)
{
    { 25, 26, 27, 28 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Critical Success! :D"}
    { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Success! :)"}
    { 6, 7, 8, 9, 10, 11, 12, 13, 14 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Failure! :("}
    { 5 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Critical Failure! :'("; Write-Host -ForegroundColor Cyan "Flat Roll on Zone ENcounter DC(12):";Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
Write-Host ""
Write-Host "Tile 2 - Travel"
$Roll_enc_c = roll -NumberDice 1 -DiceValue 20
IF ($Roll_enc_c -lt 12){Write-Host -ForegroundColor Magenta "Encounter Chance: Somthing Will Happen!"
$Roll_enc_t = roll -NumberDice 1 -DiceValue 10
switch ($Roll_enc_t)
{
    { 1, 2, 3, 4, 5  -contains $_ } {Write-Host -ForegroundColor Green "Encounter Type: Harmless"}
    { 6, 7  -contains $_ }          {Write-Host -ForegroundColor Red "Encounter Chance: Hazard"}
    { 8, 9, 10 -contains $_ }       {Write-Host -ForegroundColor Yellow "Encounter Chance: Creature"; Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
} ELSE {Write-Host -ForegroundColor Green "Encounter Chance: Travel is Uneventful!"}

Write-Host "Tile 2 - Camping"
$Roll_enc = roll -NumberDice 1 -DiceValue 20 -Bonus 8
switch ($Roll_enc)
{
    { 25, 26, 27, 28 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Critical Success! :D"}
    { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 -contains $_ } {Write-Host -ForegroundColor DarkGreen "Exploration Activity: Prepare a Campsite - Success! :)"}
    { 6, 7, 8, 9, 10, 11, 12, 13, 14 -contains $_ } {Write-Host -ForegroundColor DarkRed "Exploration Activity: Prepare a Campsite - Failure! :("}
    { 5 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Critical Failure! :'("; Write-Host -ForegroundColor Cyan "Flat Roll on Zone ENcounter DC(12):";Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
Write-Host ""
Write-Host "Tile 3 - Travel"
$Roll_enc_c = roll -NumberDice 1 -DiceValue 20
IF ($Roll_enc_c -lt 12){Write-Host -ForegroundColor Magenta "Encounter Chance: Somthing Will Happen!"
$Roll_enc_t = roll -NumberDice 1 -DiceValue 10
switch ($Roll_enc_t)
{
    { 1, 2, 3, 4, 5  -contains $_ } {Write-Host -ForegroundColor Green "Encounter Type: Harmless"}
    { 6, 7  -contains $_ }          {Write-Host -ForegroundColor Red "Encounter Chance: Hazard"}
    { 8, 9, 10 -contains $_ }       {Write-Host -ForegroundColor Yellow "Encounter Chance: Creature"; Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
} ELSE {Write-Host -ForegroundColor Green "Encounter Chance: Travel is Uneventful!"}
Write-Host "Tile 3 - Camping"
$Roll_enc = roll -NumberDice 1 -DiceValue 20 -Bonus 8
switch ($Roll_enc)
{
    { 25, 26, 27, 28 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Critical Success! :D"}
    { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Success! :)"}
    { 6, 7, 8, 9, 10, 11, 12, 13, 14 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Failure! :("}
    { 5 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Critical Failure! :'("; Write-Host -ForegroundColor Cyan "Flat Roll on Zone ENcounter DC(12):";Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
Write-Host ""
Write-Host "Tile 4 - Travel"
$Roll_enc_c = roll -NumberDice 1 -DiceValue 20
IF ($Roll_enc_c -lt 12){Write-Host -ForegroundColor Magenta "Encounter Chance: Somthing Will Happen!"
$Roll_enc_t = roll -NumberDice 1 -DiceValue 10
switch ($Roll_enc_t)
{
    { 1, 2, 3, 4, 5  -contains $_ } {Write-Host -ForegroundColor Green "Encounter Type: Harmless"}
    { 6, 7  -contains $_ }          {Write-Host -ForegroundColor Red "Encounter Chance: Hazard"}
    { 8, 9, 10 -contains $_ }       {Write-Host -ForegroundColor Yellow "Encounter Chance: Creature"; Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
} ELSE {Write-Host -ForegroundColor Green "Encounter Chance: Travel is Uneventful!"}


Write-Host "Tile 4 - Camping"
$Roll_enc = roll -NumberDice 1 -DiceValue 20 -Bonus 8
switch ($Roll_enc)
{
    { 25, 26, 27, 28 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Critical Success! :D"}
    { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Success! :)"}
    { 6, 7, 8, 9, 10, 11, 12, 13, 14 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Failure! :("}
    { 5 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Critical Failure! :'("; Write-Host -ForegroundColor Cyan "Flat Roll on Zone ENcounter DC(12):";Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
Write-Host ""
Write-Host "Tile 5 - Travel"
$Roll_enc_c = roll -NumberDice 1 -DiceValue 20
IF ($Roll_enc_c -lt 12){Write-Host -ForegroundColor Magenta "Encounter Chance: Somthing Will Happen!"
$Roll_enc_t = roll -NumberDice 1 -DiceValue 10
switch ($Roll_enc_t)
{
    { 1, 2, 3, 4, 5  -contains $_ } {Write-Host -ForegroundColor Green "Encounter Type: Harmless"}
    { 6, 7  -contains $_ }          {Write-Host -ForegroundColor Red "Encounter Chance: Hazard"}
    { 8, 9, 10 -contains $_ }       {Write-Host -ForegroundColor Yellow "Encounter Chance: Creature"; Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}
} ELSE {Write-Host -ForegroundColor Green "Encounter Chance: Travel is Uneventful!"}

Write-Host "Tile 5 - Camping"
$Roll_enc = roll -NumberDice 1 -DiceValue 20 -Bonus 8
switch ($Roll_enc)
{
    { 25, 26, 27, 28 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Critical Success! :D"}
    { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 -contains $_ } {Write-Host -ForegroundColor Green "Exploration Activity: Prepare a Campsite - Success! :)"}
    { 6, 7, 8, 9, 10, 11, 12, 13, 14 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Failure! :("}
    { 5 -contains $_ } {Write-Host -ForegroundColor Red "Exploration Activity: Prepare a Campsite - Critical Failure! :'("; Write-Host -ForegroundColor Cyan "Flat Roll on Zone Encounter DC(12):";Enc-Roll -Zone 'Zone 1 - ROSTLAND HINTERLANDS (RL)' }
}


#>
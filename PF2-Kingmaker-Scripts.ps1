#KingMaker + Helpful PF2e Tools +Tables:
<#
Version Log:
WIP
- Weather Event Tables
- Hazard Generator
- Add Compainion Stats (Leveling Options?)
- To Finish - Camping Steps Step 2-5
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
$Module_check = Get-Module "PSYaml"
IF (($Module_check | measure).Count -eq 0){Write-Host -ForegroundColor Magenta "PowerShell Module - PSYaml not installed...";Write-Host -ForegroundColor Cyan "PowerShell Module - PSYaml Installing..."; Install-Module -Name PSYaml -RequiredVersion 1.0.2 -Force -ErrorAction SilentlyContinue }

$ThisScriptPath = $MyInvocation.MyCommand.Path
$FolderScriptPath = (Get-ChildItem "$ThisScriptPath").Directory.FullName

Write-Host ""
Write-Host -ForegroundColor Cyan "Path where Script is: "$ThisScriptPath
Write-Host -ForegroundColor Cyan "Using Parent Folder "$FolderScriptPath

Write-Host ""
Write-Host -ForegroundColor Yellow "Loading Functions..."

Write-Host ""
Write-Host -ForegroundColor Yellow "Downloading Monsters..." 
$MonstersFile = Test-Path -Path "$FolderScriptPath\PF2_Monsters.txt"

IF ($MonstersFile -eq $True){Write-Host -ForegroundColor Green "Monsters...Detected...Skipping Download..." }
IF ($MonstersFile -eq $False){invoke-webrequest -Uri "https://docs.google.com/spreadsheets/d/1SpzEGKgmPNI3fxab4wQtPZm8weqXDgAJeIubIiU-B4U/export?format=csv" -OutFile "$FolderScriptPath\PF2_Monsters.txt"}


$YAML = ConvertFrom-Yaml (Get-Content "$FolderScriptPath\Tables.yml" -Raw)
#$YAML = ConvertFrom-Yaml (Get-Content "C:\Monsters\PF2 Kingmaker\Tables.yml" -Raw)

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
'Stolen Lands Zones' {$InfoSet = 'SLZ';break} 
'CAMPING ZONES'      {$InfoSet = 'CZ';break}
'TERRAIN'      {$InfoSet = 'T';break}
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
$MENU = Show-Menu -Title "PF2 Kingmaker Generator" -options 'Info','Search Monster','Random Encounter Chance','Encounter Roll','Roll Rumor','Travel Calculator','Companion Activities','Camping Activities','Exploration Activities','Quit','(╯°□°)╯_ ┻━┻'

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
'(╯°□°)╯_ ┻━┻'              {Flip-Table}
}

}
while ($MENU -ne "Quit")
}

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
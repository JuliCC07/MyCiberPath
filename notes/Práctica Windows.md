# Windows Server Administration Practice

This document contains a series of exercises and scripts for Windows Server administration, covering disk management, storage spaces, Active Directory automation, and file sharing permissions.

## Part 1: Disk Management (Diskpart)

### Exercise 6: Partition Creation
This script uses `diskpart` to initialize a disk, convert it to GPT, and create two primary partitions (one formatted as NTFS and assigned a drive letter, another formatted as ReFS and mounted to a specific folder).

```powershell
diskpart
select disk x
online disk
attributes disk clear readonly
convert gpt
create partition primary size=5120
format fs=ntfs quick
assign letter=X
create partition primary
format fs=refs quick
assign mount="C:\Usuarios\Grupos"
exit
```

### Exercise 7: Dynamic Disks and Volume Extension
This script initializes two disks as GPT, converts them to dynamic disks, and extends a volume across them.

```powershell
diskpart
select disk x
online disk
attributes disk clear readonly
convert gpt
create partition primary
format fs=ntfs quick
assign letter=X
convert dynamic
select disk y
online disk
attributes disk clear readonly
convert gpt
convert dynamic
select volume X
add disk=y
```

### Exercise 8: RAID 5 Failure Simulation and Recovery
To simulate a failure, one of the virtual disks is disconnected. In the Disk Management tool or via `diskpart`, the affected disk will show a *Missing* or *Offline* status. The RAID 5 volume changes its status from *Healthy* to *Failed Redundancy*, indicating that it is degraded but the information is still accessible.

To add the new replacement disk, connect a drive with a capacity equal to or greater than the damaged one. Open the command console as administrator, launch `diskpart`, identify the drive with `list disk`, and select it with `select disk X`. Prepare the drive by removing protections with `online disk`, `attributes disk clear readonly`, and `clean`. Since fault-tolerant volumes require dynamic disks to share database metadata in their private reserve area, execute `convert dynamic` to integrate it into the disk group.

For volume reconstruction from `diskpart`, identify the degraded RAID using `list volume`, select it with `select volume Y`, and launch the reconstruction to the new disk using `repair disk=X`. As a graphical alternative in Disk Management, right-click on any block of the volume with *Failed Redundancy*, select *Repair Volume*, and choose the newly initialized dynamic disk. The operating system will begin recalculating the lost data based on parity, changing the status to *Resynching*.

Once synchronization reaches 100% and the volume returns to the *Healthy* state, proceed to remove the defective disk. In Disk Management, locate the inactive disk marked as *Missing*, right-click on it, and select *Remove Disk*. This purges its record from the dynamic disk database, leaving the RAID 5 fully restored without experiencing any data loss.

## Part 2: Storage Spaces (PowerShell)

### Exercise 9: Storage Pools and Virtual Disks
These commands create a Storage Pool from available physical disks and provision virtual disks with Mirror and Parity resiliency settings.

```powershell
# Create a new Storage Pool
PS C:\Users\Administrador> $DiscosFisicos = Get-PhysicalDisk -CanPool $True | Where-Object Size -eq 21474836480
PS C:\Users\Administrador> New-StoragePool -StoragePoolFriendlyName "VirtualMachines" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $DiscosFisicos

# Create a 20GB Mirrored Virtual Disk, format as NTFS, and assign drive letter D:
PS C:\Users\Administrador> New-VirtualDisk -StoragePoolFriendlyName "VirtualMachines" -FriendlyName "Disk01" -Size 20GB -ResiliencySettingName Mirror -NumberOfDataCopies 3 -ProvisioningType Fixed
PS C:\Users\Administrador> New-Partition -DiskNumber (Get-VirtualDisk -FriendlyName "Disk01" | Get-Disk).Number -UseMaximumSize -DriveLetter D | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Disk01_NTFS" -Confirm:$false

# Create a 20GB Parity Virtual Disk, initialize it as GPT, format as ReFS, and assign drive letter E:
PS C:\Users\Administrador> New-VirtualDisk -StoragePoolFriendlyName "VirtualMachines" -FriendlyName "Disk02" -Size 20GB -ResiliencySettingName Parity -ProvisioningType Fixed
PS C:\Users\Administrador> Get-VirtualDisk -FriendlyName "Disk02" | Get-Disk | Initialize-Disk -PartitionStyle GPT
PS C:\Users\Administrador> New-Partition -DiskNumber (Get-VirtualDisk -FriendlyName "Disk02" | Get-Disk).Number -UseMaximumSize -DriveLetter E | Format-Volume -FileSystem ReFS -NewFileSystemLabel "Disk02_ReFS" -Confirm:$false
```

## Part 3: Active Directory Administration

### Organizational Units (OUs) Creation
Script to build the OU hierarchy for the domain.

```powershell
$dominio = "DC=julicc,DC=alt"

New-ADOrganizationalUnit -Name "Administración" -Path $dominio
New-ADOrganizationalUnit -Name "Informática" -Path $dominio
New-ADOrganizationalUnit -Name "Producción" -Path $dominio

$ouAdmin = "OU=Administración,$dominio"
New-ADOrganizationalUnit -Name "Contabilidad" -Path $ouAdmin
New-ADOrganizationalUnit -Name "Recursos Humanos" -Path $ouAdmin
New-ADOrganizationalUnit -Name "Ventas" -Path $ouAdmin
New-ADOrganizationalUnit -Name "Marketing" -Path $ouAdmin
New-ADOrganizationalUnit -Name "Dirección" -Path $ouAdmin

$ouInfo = "OU=Informática,$dominio"
New-ADOrganizationalUnit -Name "Sistemas" -Path $ouInfo
New-ADOrganizationalUnit -Name "Desarrollo" -Path $ouInfo

$ouProd = "OU=Producción,$dominio"
New-ADOrganizationalUnit -Name "Animación" -Path $ouProd
```

### Bulk User Creation
Script to generate 200 users for each department OU.

```powershell
$domain = "DC=julicc,DC=alt"
$password = ConvertTo-SecureString "1234" -AsPlainText -Force
$ouList = @(
    @{ Path = "OU=Contabilidad,OU=Administración,OU=Usuarios,$domain"; Prefix = "contabilidad" },
    @{ Path = "OU=Recursos Humanos,OU=Administración,OU=Usuarios,$domain"; Prefix = "recursoshumanos" },
    @{ Path = "OU=Ventas, OU=Administración,OU=Usuarios,$domain"; Prefix = "ventas" },
    @{ Path = "OU=Marketing, OU=Administración,OU=Usuarios,$domain"; Prefix = "marketing" },
    @{ Path = "OU=Dirección, OU=Administración,OU=Usuarios,$domain"; Prefix = "direccion" },
    @{ Path = "OU=Animación, OU=Producción,OU=Usuarios,$domain"; Prefix = "animacion" }
)

foreach ($ou in $ouList) {
	for ($i = 1; $i -le 200; $i++) {
	    $username = "{0}{1:D3}" -f $ou.Prefix, $i
	    $userParams = @{ 
	    	Name = $username 
	    	SamAccountName = $username 
	    	UserPrincipalName = "$username@julicc.alt" 
	    	Path = $ou.Path 
	    	AccountPassword = $password 
	    	Enabled = $true 
	    } 
	    New-ADUser @userParams
	}
}
```

### Group Creation and ADLP Policy
Script to implement the AGDLP/ADLP role-based access control policy by creating Global and Domain Local groups and nesting them properly.

```powershell
$domain = (Get-ADDomain).DistinguishedName
$groupsOU = "OU=Groups,$domain"

# 1. Informática
New-ADGroup -Name "desarrollo" -GroupScope Global -Path $groupsOU
New-ADGroup -Name "sistemas" -GroupScope Global -Path $groupsOU
New-ADGroup -Name "informatica" -GroupScope DomainLocal -Path $groupsOU

Add-ADGroupMember -Identity "informatica" -Members "desarrollo", "sistemas"

$usersDesarrollo = Get-ADUser -SearchBase "OU=desarrollo,OU=informatica,OU=Usuarios,$domain" -Filter *
if ($usersDesarrollo) { Add-ADGroupMember -Identity "desarrollo" -Members $usersDesarrollo }

$usersSistemas = Get-ADUser -SearchBase "OU=sistemas,OU=informatica,OU=Usuarios,$domain" -Filter *
if ($usersSistemas) { Add-ADGroupMember -Identity "sistemas" -Members $usersSistemas }

# 2. Administración
New-ADGroup -Name "Administracion" -GroupScope DomainLocal -Path $groupsOU

$ouAdmin = @("Contabilidad", "Recursos Humanos", "Ventas", "Marketing", "Dirección")
foreach ($ou in $ouAdmin) {
    $groupName = $ou -replace "\s",""
    New-ADGroup -Name $groupName -GroupScope Global -Path $groupsOU
    Add-ADGroupMember -Identity "Administracion" -Members $groupName
    
    $users = Get-ADUser -SearchBase "OU=$ou,OU=Administración,OU=Usuarios,$domain" -Filter *
    if ($users) { Add-ADGroupMember -Identity $groupName -Members $users }
}

# 3. Producción
New-ADGroup -Name "Animacion" -GroupScope Global -Path $groupsOU
New-ADGroup -Name "Produccion" -GroupScope DomainLocal -Path $groupsOU

Add-ADGroupMember -Identity "Produccion" -Members "Animacion"

$usersAnimacion = Get-ADUser -SearchBase "OU=Animación,OU=Producción,OU=Usuarios,$domain" -Filter *
if ($usersAnimacion) { Add-ADGroupMember -Identity "Animacion" -Members $usersAnimacion }
```

## Part 4: File System and Share Permissions

### Directory Creation and ACL Assignment
Script to build local directory structures and apply strict NTFS permissions (icacls) for Active Directory groups.

```powershell
$domain = (Get-ADDomain).DistinguishedName

# 1. Main directory creation and strict ACL assignment for groups
$groupDirectories = @(
    [PSCustomObject]@{ Path = "C:\Users\informatica"; Permission = "informatica" },
    [PSCustomObject]@{ Path = "C:\Users\desarrollo"; Permission = "desarrollo" },
    [PSCustomObject]@{ Path = "C:\Users\sistemas"; Permission = "sistemas" }
) 
foreach ($dir in $groupDirectories) { 
	New-Item -Path $dir.Path -ItemType Directory -Force 
	icacls $dir.Path /inheritance:r /grant "SYSTEM:(OI)(CI)F" "Administradores:(OI)(CI)F" "$($dir.Permission):(OI)(CI)F" 
}

# 2. Dynamic user folder creation for "desarrollo" and strict ACL assignment
$devUsers = Get-ADUser -SearchBase "OU=desarrollo,OU=informatica,OU=Usuarios,$domain" -Filter *
foreach ($user in $devUsers) {
    $devUser = $user.SamAccountName
    $devPath = "C:\Users\$devUser"
    
    New-Item -Path $devPath -ItemType Directory -Force
    icacls $devPath /inheritance:r /grant "SYSTEM:(OI)(CI)F" "Administradores:(OI)(CI)F" "${devUser}:(OI)(CI)F"
}

# 3. Dynamic user folder creation for "sistemas" and strict ACL assignment
$sysUsers = Get-ADUser -SearchBase "OU=sistemas,OU=informatica,OU=Usuarios,$domain" -Filter *
foreach ($user in $sysUsers) {
    $sysUser = $user.SamAccountName
    $sysPath = "C:\Users\$sysUser"
    
    New-Item -Path $sysPath -ItemType Directory -Force
    icacls $sysPath /inheritance:r /grant "SYSTEM:(OI)(CI)F" "Administradores:(OI)(CI)F" "${sysUser}:(OI)(CI)F"
}
```

### Network Shares and Logon Scripts
Comprehensive script to map SMB network shares for users, establishing a `Z:` drive for personal files, a `Y:` drive for group files, and an `X:` drive for department files using logon scripts.

```powershell
# ============================================================
# SMB Shared Resources + Network Drives Mapping
# ============================================================
$domain      = Get-ADDomain
$dn          = $domain.DistinguishedName
$serverName  = $env:COMPUTERNAME
$netlogon    = "\\$env:USERDNSDOMAIN\NETLOGON"

# ------------------------------------------------------------
# 1. Z: Drive (Personal Folder — "Users")
# ------------------------------------------------------------
New-SmbShare -Name "Users" -Path "C:\Users" -FullAccess "Todos" -ErrorAction SilentlyContinue

# Function to assign Z: drive to all users in a given OU
function Set-HomeDrive {
    param([string]$SearchBase)
    $users = Get-ADUser -SearchBase $SearchBase -Filter *
    foreach ($user in $users) {
        $uncPath = "\\$serverName\Users\$($user.SamAccountName)"
        Set-ADUser -Identity $user.SamAccountName -HomeDrive "Z:" -HomeDirectory $uncPath
    }
}

# Informática
Set-HomeDrive "OU=desarrollo,OU=informatica,OU=Usuarios,$dn"
Set-HomeDrive "OU=sistemas,OU=informatica,OU=Usuarios,$dn"

# Administración
Set-HomeDrive "OU=Contabilidad,OU=Administración,OU=Usuarios,$dn"
Set-HomeDrive "OU=Recursos Humanos,OU=Administración,OU=Usuarios,$dn"
Set-HomeDrive "OU=Ventas,OU=Administración,OU=Usuarios,$dn"
Set-HomeDrive "OU=Marketing,OU=Administración,OU=Usuarios,$dn"
Set-HomeDrive "OU=Dirección,OU=Administración,OU=Usuarios,$dn"

# Producción
Set-HomeDrive "OU=Animación,OU=Producción,OU=Usuarios,$dn"

# ------------------------------------------------------------
# 2. Y: Drive (Group Resource) and X: Drive (Department Resource)
# ------------------------------------------------------------
$shares = @(
    # Informática
    @{ Name = "desarrollo";      Path = "C:\Users\desarrollo" },
    @{ Name = "sistemas";        Path = "C:\Users\sistemas" },
    @{ Name = "informatica";     Path = "C:\Users\informatica" },
    # Administración
    @{ Name = "contabilidad";    Path = "C:\Users\Contabilidad" },
    @{ Name = "recursoshumanos"; Path = "C:\Users\RecursosHumanos" },
    @{ Name = "ventas";          Path = "C:\Users\Ventas" },
    @{ Name = "marketing";       Path = "C:\Users\Marketing" },
    @{ Name = "direccion";       Path = "C:\Users\Direccion" },
    @{ Name = "administracion";  Path = "C:\Users\Administracion" },
    # Producción
    @{ Name = "animacion";       Path = "C:\Users\Animacion" },
    @{ Name = "produccion";      Path = "C:\Users\Produccion" }
)

foreach ($share in $shares) {
    New-SmbShare -Name $share.Name -Path $share.Path -FullAccess "Todos" -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# 3. Logon Scripts (.bat) per Group
# ------------------------------------------------------------

# Structure: @{ Bat; Search OU; Y Share (Group); X Share (Department) }
$logonMap = @(
    # Informática
    @{ Bat = "map_desarrollo.bat";      OU = "OU=desarrollo,OU=informatica,OU=Usuarios,$dn";              Y = "desarrollo";      X = "informatica" },
    @{ Bat = "map_sistemas.bat";        OU = "OU=sistemas,OU=informatica,OU=Usuarios,$dn";                Y = "sistemas";        X = "informatica" },

    # Administración
    @{ Bat = "map_contabilidad.bat";    OU = "OU=Contabilidad,OU=Administración,OU=Usuarios,$dn";         Y = "Contabilidad";    X = "Administracion" },
    @{ Bat = "map_recursoshumanos.bat"; OU = "OU=Recursos Humanos,OU=Administración,OU=Usuarios,$dn";     Y = "RecursosHumanos"; X = "Administracion" },
    @{ Bat = "map_ventas.bat";          OU = "OU=Ventas,OU=Administración,OU=Usuarios,$dn";               Y = "Ventas";          X = "Administracion" },
    @{ Bat = "map_marketing.bat";       OU = "OU=Marketing,OU=Administración,OU=Usuarios,$dn";            Y = "Marketing";       X = "Administracion" },
    @{ Bat = "map_direccion.bat";       OU = "OU=Dirección,OU=Administración,OU=Usuarios,$dn";            Y = "Direccion";       X = "Administracion" },

    # Producción
    @{ Bat = "map_animacion.bat";       OU = "OU=Animación,OU=Producción,OU=Usuarios,$dn";                Y = "Animacion";       X = "Produccion" }
)

foreach ($entry in $logonMap) {
    # Create the .bat file in NETLOGON
    $batPath = "$netlogon\$($entry.Bat)"
    Set-Content -Path $batPath -Encoding ASCII -Value @"
@echo off
net use Y: \\$serverName\$($entry.Y) /persistent:no
net use X: \\$serverName\$($entry.X) /persistent:no
"@

    # Assign the script to each user in the OU
    $users = Get-ADUser -SearchBase $entry.OU -Filter *
    foreach ($user in $users) {
        Set-ADUser -Identity $user.SamAccountName -ScriptPath $entry.Bat
    }
}
```
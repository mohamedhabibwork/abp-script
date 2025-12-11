################################################################################
# ABP Framework Project & Module Generator v1.0 (PowerShell)
#
# A comprehensive all-in-one toolkit for ABP Framework development:
# - Create new projects with all templates (app, module, microservice, console)
# - Add modules with complete layered structure
# - Generate entities with CRUD operations from JSON or interactively
# - Support for entity relationships (ManyToOne, OneToMany, ManyToMany, OneToOne)
# - Auto-detect multi-tenancy for proper relationship configurations
# - Create DTOs with validation rules
# - Add ETOs with event handlers
# - Generate data seeders
# - All following SOLID principles and clean code practices
#
# Version: 1.0
# Enhanced: JSON entity definitions with relationships
################################################################################

#Requires -Version 5.1

################################################################################
# SECTION 1: Configuration & Constants
################################################################################

$script:ScriptDir = $PSScriptRoot
$script:TemplatesDir = Join-Path $ScriptDir "templates"
$script:ConfigFile = ".abp-generator.json"
$script:EntityDefinitionsDir = Join-Path $ScriptDir "entity-definitions"

# Global variables
$script:ProjectName = ""
$script:ProjectRoot = ""
$script:Namespace = ""
$script:ModuleName = ""
$script:EntityName = ""
$script:TemplateType = ""
$script:IsMultiTenant = $false
$script:EntityBaseClass = "FullAuditedAggregateRoot<Guid>"

################################################################################
# SECTION 2: Utility Functions
################################################################################

################################################################################
# SECTION 2A: Entity Tracking Functions
################################################################################

function Get-TrackingFile {
    if ([string]::IsNullOrWhiteSpace($script:ProjectRoot)) {
        return Join-Path $script:ScriptDir "generated-entities.json"
    }
    return Join-Path $script:ProjectRoot "generated-entities.json"
}

function Get-TrackedEntities {
    $trackingFile = Get-TrackingFile
    if (Test-Path $trackingFile) {
        try {
            $content = Get-Content $trackingFile -Raw | ConvertFrom-Json
            return $content.entities
        } catch {
            Write-Warning-Custom "Failed to read tracking file: $_"
            return @()
        }
    }
    return @()
}

function Save-TrackedEntities {
    param([array]$Entities)
    
    $trackingFile = Get-TrackingFile
    $trackingDir = Split-Path $trackingFile -Parent
    if (-not (Test-Path $trackingDir)) {
        New-Item -ItemType Directory -Path $trackingDir -Force | Out-Null
    }
    
    $trackingData = @{
        entities = $Entities
    }
    
    $trackingData | ConvertTo-Json -Depth 10 | Set-Content $trackingFile -Encoding UTF8
}

function Add-EntityTracking {
    param([array]$GeneratedFiles)
    
    $entities = Get-TrackedEntities
    if ($null -eq $entities) {
        $entities = @()
    }
    
    # Convert to ArrayList for easier manipulation
    $entityList = [System.Collections.ArrayList]::new()
    foreach ($e in $entities) {
        $entityList.Add($e) | Out-Null
    }
    
    # Get relative paths
    $relativeFiles = @()
    foreach ($file in $GeneratedFiles) {
        if ($file -and (Test-Path $file)) {
            if ($script:ProjectRoot) {
                $relativePath = $file.Replace($script:ProjectRoot, "").TrimStart('\', '/')
            } else {
                $relativePath = $file
            }
            $relativeFiles += $relativePath
        }
    }
    
    $entityInfo = @{
        name = $script:EntityName
        module = $script:ModuleName
        generatedAt = (Get-Date -Format "o")
        files = $relativeFiles
    }
    
    $entityList.Add($entityInfo) | Out-Null
    Save-TrackedEntities -Entities $entityList.ToArray()
}

function Remove-EntityTracking {
    param([string]$EntityName, [string]$ModuleName)
    
    $entities = Get-TrackedEntities
    if ($null -eq $entities) {
        return $false
    }
    
    $filtered = $entities | Where-Object { 
        -not ($_.name -eq $EntityName -and $_.module -eq $ModuleName) 
    }
    
    if ($filtered.Count -lt $entities.Count) {
        Save-TrackedEntities -Entities $filtered
        return $true
    }
    return $false
}

function Get-EntityFiles {
    param([string]$EntityName, [string]$ModuleName)
    
    $entities = Get-TrackedEntities
    $entity = $entities | Where-Object { 
        $_.name -eq $EntityName -and $_.module -eq $ModuleName 
    } | Select-Object -First 1
    
    if ($entity) {
        $files = @()
        foreach ($relativeFile in $entity.files) {
            if ($script:ProjectRoot) {
                $fullPath = Join-Path $script:ProjectRoot $relativeFile
            } else {
                $fullPath = $relativeFile
            }
            if (Test-Path $fullPath) {
                $files += $fullPath
            }
        }
        return $files
    }
    return @()
}

function Invoke-RollbackLastEntity {
    Write-Header "Rollback Last Generated Entity"
    
    $entities = Get-TrackedEntities
    if ($null -eq $entities -or $entities.Count -eq 0) {
        Write-Warning-Custom "No tracked entities found."
        Read-Host "Press Enter to continue..."
        return
    }
    
    $lastEntity = $entities[$entities.Count - 1]
    Write-Host "Last generated entity:"
    Write-Host "  Name: $($lastEntity.name)"
    Write-Host "  Module: $($lastEntity.module)"
    Write-Host "  Generated: $($lastEntity.generatedAt)"
    Write-Host ""
    
    $confirm = Read-Host "Delete this entity and all its files? [y/N]"
    if ($confirm -match '^[Yy]$') {
        $files = Get-EntityFiles -EntityName $lastEntity.name -ModuleName $lastEntity.module
        $deletedCount = 0
        foreach ($file in $files) {
            if (Test-Path $file) {
                Remove-Item $file -Force
                Write-Info "Deleted: $file"
                $deletedCount++
            }
        }
        
        Remove-EntityTracking -EntityName $lastEntity.name -ModuleName $lastEntity.module | Out-Null
        Write-Success "Rolled back entity '$($lastEntity.name)'. Deleted $deletedCount files."
    } else {
        Write-Info "Rollback cancelled."
    }
    
    Read-Host "Press Enter to continue..."
}

function Invoke-DeleteEntity {
    Write-Header "Delete Entity by Name"
    
    $entities = Get-TrackedEntities
    if ($null -eq $entities -or $entities.Count -eq 0) {
        Write-Warning-Custom "No tracked entities found."
        Read-Host "Press Enter to continue..."
        return
    }
    
    Write-Host "Available entities:"
    for ($i = 0; $i -lt $entities.Count; $i++) {
        Write-Host "  $($i + 1)) $($entities[$i].name) (Module: $($entities[$i].module))"
    }
    Write-Host ""
    
    $entityName = Read-Host "Enter entity name"
    $moduleName = Read-Host "Enter module name"
    
    $entity = $entities | Where-Object { 
        $_.name -eq $entityName -and $_.module -eq $moduleName 
    } | Select-Object -First 1
    
    if (-not $entity) {
        Write-Error-Custom "Entity '$entityName' in module '$moduleName' not found."
        Read-Host "Press Enter to continue..."
        return
    }
    
    Write-Host ""
    Write-Host "Entity to delete:"
    Write-Host "  Name: $($entity.name)"
    Write-Host "  Module: $($entity.module)"
    Write-Host "  Files: $($entity.files.Count)"
    Write-Host ""
    
    $confirm = Read-Host "Delete this entity and all its files? [y/N]"
    if ($confirm -match '^[Yy]$') {
        $files = Get-EntityFiles -EntityName $entityName -ModuleName $moduleName
        $deletedCount = 0
        foreach ($file in $files) {
            if (Test-Path $file) {
                Remove-Item $file -Force
                Write-Info "Deleted: $file"
                $deletedCount++
            }
        }
        
        Remove-EntityTracking -EntityName $entityName -ModuleName $moduleName | Out-Null
        Write-Success "Deleted entity '$entityName'. Removed $deletedCount files."
    } else {
        Write-Info "Deletion cancelled."
    }
    
    Read-Host "Press Enter to continue..."
}

function Get-GeneratedEntities {
    Write-Header "List Generated Entities"
    
    $entities = Get-TrackedEntities
    if ($null -eq $entities -or $entities.Count -eq 0) {
        Write-Warning-Custom "No tracked entities found."
        Read-Host "Press Enter to continue..."
        return
    }
    
    Write-Host "Generated Entities ($($entities.Count)):"
    Write-Host ""
    for ($i = 0; $i -lt $entities.Count; $i++) {
        $entity = $entities[$i]
        Write-Host "  $($i + 1)) $($entity.name) (Module: $($entity.module))"
        Write-Host "      Generated: $($entity.generatedAt)"
        Write-Host "      Files: $($entity.files.Count)"
        Write-Host ""
    }
    
    Read-Host "Press Enter to continue..."
}

function Invoke-CleanAllGeneratedFiles {
    Write-Header "Clean All Generated Files"
    
    $entities = Get-TrackedEntities
    if ($null -eq $entities -or $entities.Count -eq 0) {
        Write-Warning-Custom "No tracked entities found."
        Read-Host "Press Enter to continue..."
        return
    }
    
    Write-Host "This will delete ALL tracked entities and their files:"
    Write-Host "  Total entities: $($entities.Count)"
    $totalFiles = ($entities | ForEach-Object { $_.files.Count } | Measure-Object -Sum).Sum
    Write-Host "  Total files: $totalFiles"
    Write-Host ""
    
    $confirm = Read-Host "Are you sure? Type 'DELETE ALL' to confirm"
    if ($confirm -eq "DELETE ALL") {
        $deletedCount = 0
        foreach ($entity in $entities) {
            $files = Get-EntityFiles -EntityName $entity.name -ModuleName $entity.module
            foreach ($file in $files) {
                if (Test-Path $file) {
                    Remove-Item $file -Force
                    $deletedCount++
                }
            }
        }
        
        $trackingFile = Get-TrackingFile
        if (Test-Path $trackingFile) {
            Remove-Item $trackingFile -Force
        }
        
        Write-Success "Cleaned all generated files. Deleted $deletedCount files."
    } else {
        Write-Info "Cleanup cancelled."
    }
    
    Read-Host "Press Enter to continue..."
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  " -NoNewline -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ " -NoNewline -ForegroundColor Green
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  " -NoNewline -ForegroundColor Yellow
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ " -NoNewline -ForegroundColor Red
    Write-Host $Message -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host "🔄 " -NoNewline -ForegroundColor Magenta
    Write-Host $Message -ForegroundColor Magenta
}

function Write-Progress-Step {
    param(
        [string]$Message,
        [int]$Current,
        [int]$Total
    )
    $percentage = [math]::Round(($Current / $Total) * 100)
    $progressBar = "[" + ("=" * ([math]::Floor($percentage / 5))) + (" " * (20 - [math]::Floor($percentage / 5))) + "]"
    Write-Host "⏳ " -NoNewline -ForegroundColor Cyan
    Write-Host "$progressBar $percentage% " -NoNewline -ForegroundColor Cyan
    Write-Host "($Current/$Total) " -NoNewline -ForegroundColor Gray
    Write-Host $Message -ForegroundColor White
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 70) -NoNewline -ForegroundColor Cyan
    Write-Host "╗" -ForegroundColor Cyan
    Write-Host "║  " -NoNewline -ForegroundColor Cyan
    Write-Host $Message.PadRight(68) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 70) -NoNewline -ForegroundColor Cyan
    Write-Host "╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Separator {
    Write-Host ("─" * 72) -ForegroundColor DarkCyan
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "▶ " -NoNewline -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor White
    Write-Host ("─" * 72) -ForegroundColor DarkCyan
}

function Test-Dependencies {
    Write-Step "Checking dependencies..."
    
    $missingDeps = @()
    
    if (-not (Get-Command abp -ErrorAction SilentlyContinue)) {
        $missingDeps += "ABP CLI (install: dotnet tool install -g Volo.Abp.Cli)"
    }
    
    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
        $missingDeps += ".NET SDK 8.0+"
    }
    
    if ($missingDeps.Count -gt 0) {
        Write-Error-Custom "Missing dependencies:"
        foreach ($dep in $missingDeps) {
            Write-Host "  - $dep"
        }
        return $false
    }
    
    Write-Success "All required dependencies found"
    return $true
}

function Read-Config {
    if (Test-Path $script:ConfigFile) {
        try {
            $config = Get-Content $script:ConfigFile -Raw | ConvertFrom-Json
            $script:ProjectRoot = $config.projectRoot
            $script:Namespace = $config.namespace
        } catch {
            Write-Warning-Custom "Could not read config file: $_"
        }
    }
}

function Save-Config {
    $config = @{
        projectRoot = $script:ProjectRoot
        namespace = $script:Namespace
        lastModified = (Get-Date).ToString("o")
    }
    
    $config | ConvertTo-Json | Out-File $script:ConfigFile -Encoding UTF8
    Write-Success "Configuration saved to $script:ConfigFile"
}

function Find-ProjectInfo {
    $slnFiles = Get-ChildItem -Filter "*.sln" -File
    
    if ($slnFiles.Count -gt 0) {
        $script:ProjectRoot = Get-Location
        $script:ProjectName = $slnFiles[0].BaseName
        $script:Namespace = $script:ProjectName
        Write-Info "Detected project: $script:ProjectName"
        return $true
    }
    
    return $false
}

function Test-EntityName {
    param([string]$Name)
    
    if ($Name -notmatch '^[A-Z][a-zA-Z0-9]*$') {
        Write-Error-Custom "Entity name must start with uppercase letter and contain only alphanumeric characters"
        return $false
    }
    return $true
}

function Test-ModuleName {
    param([string]$Name)
    
    if ($Name -notmatch '^[A-Z][a-zA-Z0-9]*$') {
        Write-Error-Custom "Module name must start with uppercase letter and contain only alphanumeric characters"
        return $false
    }
    return $true
}

function New-DirectoryIfNotExists {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Info "Created directory: $Path"
    }
}

################################################################################
# SECTION 3: JSON Parsing Functions
################################################################################

function Read-JsonEntity {
    param([string]$JsonFile)
    
    if (-not (Test-Path $JsonFile)) {
        Write-Error-Custom "JSON file not found: $JsonFile"
        return $null
    }
    
    try {
        $json = Get-Content $JsonFile -Raw | ConvertFrom-Json
        
        if (-not $json.entity -or -not $json.module) {
            Write-Error-Custom "JSON must contain 'entity' and 'module' fields"
            return $null
        }
        
        $script:EntityName = $json.entity
        $script:ModuleName = $json.module
        
        # Parse base class if provided
        if ($json.baseClass) {
            $script:EntityBaseClass = $json.baseClass
        } else {
            $script:EntityBaseClass = "FullAuditedAggregateRoot<Guid>"
        }
        
        # Parse ID type if provided
        if ($json.idType) {
            $script:EntityIdType = $json.idType
        } else {
            $script:EntityIdType = "Guid"
        }
        
        # Parse DbContext name if provided
        if ($json.dbContext) {
            $script:DbContextName = $json.dbContext
        } else {
            $script:DbContextName = "$($script:ModuleName)DbContext"
        }
        
        # Update base class with ID type if it contains <Guid>
        if ($script:EntityBaseClass -match "<Guid>") {
            $script:EntityBaseClass = $script:EntityBaseClass -replace "<Guid>", "<$($script:EntityIdType)>"
        }
        
        Write-Success "Parsed entity: $script:EntityName in module: $script:ModuleName (Base: $script:EntityBaseClass, ID: $script:EntityIdType)"
        return $json
    } catch {
        Write-Error-Custom "Failed to parse JSON: $_"
        return $null
    }
}

function Get-PropertiesFromJson {
    param([object]$Json)
    
    if ($Json.properties) {
        return $Json.properties
    }
    return @()
}

function Get-RelationshipsFromJson {
    param([object]$Json)
    
    if ($Json.relationships) {
        return $Json.relationships
    }
    return @()
}

function New-PropertyDeclaration {
    param([object]$Property)
    
    $declaration = ""
    
    # Add validation attributes
    if ($Property.required -eq $true) {
        $declaration += "[Required]`n    "
    }
    
    if ($Property.maxLength) {
        $declaration += "[StringLength($($Property.maxLength))]`n    "
    }
    
    # Determine if property should be nullable
    $isNullable = $false
    if ($Property.nullable -eq $true -or ($Property.required -ne $true)) {
        $isNullable = $true
    }
    
    # Make type nullable if needed
    $finalType = $Property.type
    if ($isNullable) {
        $valueTypes = @("int", "long", "decimal", "double", "float", "bool", "DateTime", "Guid")
        if ($valueTypes -contains $Property.type) {
            $finalType = "$($Property.type)?"
        } elseif ($Property.type -eq "string") {
            $finalType = "string?"
        }
    }
    
    # Add property
    $declaration += "public $finalType $($Property.name) { get; set; }"
    
    return $declaration
}

################################################################################
# SECTION 4: Multi-Tenancy Detection
################################################################################

function Find-MultiTenancy {
    Write-Step "Detecting multi-tenancy configuration..."
    
    # Check for IMultiTenant interface
    $files = Get-ChildItem -Recurse -Filter "*.cs" -File
    foreach ($file in $files) {
        if (Select-String -Path $file.FullName -Pattern "IMultiTenant" -Quiet) {
            $script:IsMultiTenant = $true
            Write-Info "Multi-tenancy detected: true"
            return $true
        }
    }
    
    # Check for TenantId properties
    foreach ($file in $files) {
        if (Select-String -Path $file.FullName -Pattern "TenantId" -Quiet) {
            $script:IsMultiTenant = $true
            Write-Info "Multi-tenancy detected: true (TenantId found)"
            return $true
        }
    }
    
    $script:IsMultiTenant = $false
    Write-Info "Multi-tenancy detected: false"
    return $false
}

################################################################################
# SECTION 5: Project Creation Functions
################################################################################

function New-AppProject {
    param(
        [string]$ProjectName,
        [string]$DbProvider = "ef",
        [bool]$Tiered = $false
    )
    
    Write-Step "Creating ABP Application project: $ProjectName"
    
    $cmd = "abp new $ProjectName -t app -d $DbProvider --no-ui"
    
    if ($Tiered) {
        $cmd += " --tiered"
    }
    
    Write-Info "Executing: $cmd"
    
    try {
        Invoke-Expression $cmd
        Write-Success "ABP Application project created successfully!"
        Write-Info "Project location: $(Get-Location)\$ProjectName"
        return $true
    } catch {
        Write-Error-Custom "Failed to create ABP Application project: $_"
        return $false
    }
}

function New-ModuleProject {
    param(
        [string]$ProjectName,
        [string]$DbProvider = "ef"
    )
    
    Write-Step "Creating ABP Module project: $ProjectName"
    
    $cmd = "abp new $ProjectName -t module -d $DbProvider --no-ui"
    
    Write-Info "Executing: $cmd"
    
    try {
        Invoke-Expression $cmd
        Write-Success "ABP Module project created successfully!"
        return $true
    } catch {
        Write-Error-Custom "Failed to create ABP Module project: $_"
        return $false
    }
}

function New-MicroserviceProject {
    param(
        [string]$ProjectName,
        [string]$DbProvider = "ef"
    )
    
    Write-Step "Creating ABP Microservice project: $ProjectName"
    
    $cmd = "abp new $ProjectName -t microservice -d $DbProvider"
    
    Write-Info "Executing: $cmd"
    
    try {
        Invoke-Expression $cmd
        Write-Success "ABP Microservice project created successfully!"
        return $true
    } catch {
        Write-Error-Custom "Failed to create ABP Microservice project: $_"
        return $false
    }
}

function New-ConsoleProject {
    param(
        [string]$ProjectName,
        [string]$DbProvider = "ef"
    )
    
    Write-Step "Creating ABP Console project: $ProjectName"
    
    $cmd = "abp new $ProjectName -t console -d $DbProvider"
    
    Write-Info "Executing: $cmd"
    
    try {
        Invoke-Expression $cmd
        Write-Success "ABP Console project created successfully!"
        return $true
    } catch {
        Write-Error-Custom "Failed to create ABP Console project: $_"
        return $false
    }
}

################################################################################
# SECTION 6: Template Processing Functions
################################################################################

function Invoke-TemplateProcessing {
    param(
        [string]$TemplateFile,
        [string]$OutputFile,
        [hashtable]$Variables
    )
    
    if (-not (Test-Path $TemplateFile)) {
        Write-Error-Custom "Template not found: $TemplateFile"
        return $false
    }
    
    $content = Get-Content $TemplateFile -Raw
    
    # Replace variables
    foreach ($key in $Variables.Keys) {
        $value = $Variables[$key]
        $content = $content -replace [regex]::Escape("`${$key}"), $value
    }
    
    # Create output directory
    $outputDir = Split-Path $OutputFile -Parent
    New-DirectoryIfNotExists $outputDir
    
    $content | Out-File $OutputFile -Encoding UTF8
    Write-Success "Generated: $OutputFile"
    return $true
}

function Get-BaseClassConstructor {
    param([string]$BaseClass)
    
    # Check if base class is an AggregateRoot (has constructor with id)
    if ($BaseClass -match "AggregateRoot") {
        return " : base(id)"
    }
    # For Entity classes, we need to set Id property
    return ""
}

function Get-IdAssignment {
    param([string]$BaseClass)
    
    # Check if base class is an AggregateRoot (has constructor with id)
    if ($BaseClass -match "AggregateRoot") {
        return ""
    }
    # For Entity classes, we need to set Id property
    return "Id = id;`n            "
}

function Get-IdDefaultValue {
    param([string]$IdType)
    
    switch ($IdType) {
        "Guid" { return "Guid.NewGuid()" }
        "long" { return "0" }
        "int" { return "0" }
        default { return "Guid.NewGuid()" }
    }
}

function Invoke-TemplateWithProperties {
    param(
        [string]$TemplateFile,
        [string]$OutputFile,
        [array]$Properties,
        [hashtable]$Variables
    )
    
    if (-not (Test-Path $TemplateFile)) {
        Write-Error-Custom "Template not found: $TemplateFile"
        return $false
    }
    
    $content = Get-Content $TemplateFile -Raw
    
    # Generate properties
    $propertiesCode = ""
    foreach ($prop in $Properties) {
        $propDecl = New-PropertyDeclaration $prop
        $propertiesCode += "$propDecl`n`n    "
    }
    
    # Replace PROPERTIES placeholder
    $content = $content -replace [regex]::Escape('${PROPERTIES}'), $propertiesCode
    
    # Handle base class specific placeholders
    $baseClass = $Variables["BASE_CLASS"]
    $idType = $Variables["ID_TYPE"]
    if ($baseClass) {
        $baseClassConstructor = Get-BaseClassConstructor $baseClass
        $idAssignment = Get-IdAssignment $baseClass
        $content = $content -replace [regex]::Escape('${BASE_CLASS_CONSTRUCTOR}'), $baseClassConstructor
        $content = $content -replace [regex]::Escape('${ID_ASSIGNMENT}'), $idAssignment
    }
    if ($idType) {
        $content = $content -replace [regex]::Escape('${ID_TYPE}'), $idType
    }
    
    # Replace other variables
    foreach ($key in $Variables.Keys) {
        $value = $Variables[$key]
        $content = $content -replace [regex]::Escape("`${$key}"), $value
    }
    
    # Create output directory
    $outputDir = Split-Path $OutputFile -Parent
    New-DirectoryIfNotExists $outputDir
    
    $content | Out-File $OutputFile -Encoding UTF8
    Write-Success "Generated: $OutputFile"
    return $true
}

################################################################################
# SECTION 7: Entity Generation from JSON
################################################################################

function New-EntityFromJson {
    param([string]$JsonFile)
    
    Write-Step "Generating entity from JSON: $JsonFile"
    
    # Parse JSON
    $json = Read-JsonEntity $JsonFile
    if (-not $json) {
        return $false
    }
    
    # Detect multi-tenancy
    Find-MultiTenancy | Out-Null
    
    # Parse properties and relationships
    $properties = Get-PropertiesFromJson $json
    $relationships = Get-RelationshipsFromJson $json
    
    # Generate all components
    New-EntityFiles $properties $relationships
    New-DtoFiles $properties
    New-RepositoryFiles
    New-ServiceFiles
    New-ControllerFiles
    
    # Check options
    if ($json.options.generateSeeder -eq $true) {
        New-SeederFiles
    }
    
    if ($json.options.generateTests -eq $true) {
        New-TestFiles
    }
    
    if ($json.options.generateValidation -eq $true) {
        New-ValidationFiles
    }
    
    # Collect generated files for tracking (build expected paths)
    $generatedFiles = @()
    
    # Entity files
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Domain\$script:ModuleName\$script:EntityName.cs"
    
    # DTO files
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\Create$($script:EntityName)Dto.cs"
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\Update$($script:EntityName)Dto.cs"
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\$($script:EntityName)Dto.cs"
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\Get$($script:EntityName)ListInput.cs"
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\$($script:EntityName)LookupDto.cs"
    
    # Repository files
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Domain\$script:ModuleName\I$($script:EntityName)Repository.cs"
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.EntityFrameworkCore\$script:ModuleName\Repositories\EfCore$($script:EntityName)Repository.cs"
    
    # Service files
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\I$($script:EntityName)AppService.cs"
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application\$script:ModuleName\$($script:EntityName)AppService.cs"
    
    # Controller files
    $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.HttpApi\$script:ModuleName\Controllers\$($script:EntityName)Controller.cs"
    
    # Optional files
    if ($json.options.generateSeeder -eq $true) {
        $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.EntityFrameworkCore\$script:ModuleName\$($script:EntityName)DataSeeder.cs"
    }
    if ($json.options.generateValidation -eq $true) {
        $generatedFiles += Join-Path $script:ProjectRoot "src\$script:Namespace.Application\$script:ModuleName\Validators\$($script:EntityName)Validator.cs"
    }
    if ($json.options.generateTests -eq $true) {
        $generatedFiles += Join-Path $script:ProjectRoot "test\$script:Namespace.Application.Tests\$script:ModuleName\$($script:EntityName)AppServiceTests.cs"
        $generatedFiles += Join-Path $script:ProjectRoot "test\$script:Namespace.Domain.Tests\$script:ModuleName\$($script:EntityName)DomainTests.cs"
    }
    
    # Track the generated entity
    Add-EntityTracking -GeneratedFiles $generatedFiles
    
    Write-Success "Entity generation complete!"
    return $true
}

################################################################################
# SECTION 8: Code Generation Functions
################################################################################

function New-EntityFiles {
    param(
        [array]$Properties,
        [array]$Relationships
    )
    
    Write-Step "Generating entity file..."
    
    $entityNameLower = $script:EntityName.Substring(0,1).ToLower() + $script:EntityName.Substring(1)
    
    # Check if base class includes ISoftDelete
    $softDeleteUsing = ""
    if ($script:EntityBaseClass -match "ISoftDelete") {
        $softDeleteUsing = "`nusing Volo.Abp;"
    }
    
    # Check if properties have validation attributes (Required, StringLength, etc.)
    $hasValidationAttributes = $false
    foreach ($prop in $Properties) {
        if ($prop.required -eq $true -or $prop.nullable -eq $true -or $prop.maxLength -or $prop.minLength) {
            $hasValidationAttributes = $true
            break
        }
    }
    
    # Add DataAnnotations using only if validation attributes are present
    $dataAnnotationsUsing = ""
    if ($hasValidationAttributes) {
        $dataAnnotationsUsing = "`nusing System.ComponentModel.DataAnnotations;"
    }
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
        BASE_CLASS = $script:EntityBaseClass
        ID_TYPE = $script:EntityIdType
        SOFT_DELETE_USING = $softDeleteUsing
        DATA_ANNOTATIONS_USING = $dataAnnotationsUsing
    }
    
    $templateFile = Join-Path $script:TemplatesDir "domain\entity.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Domain\$script:ModuleName\$script:EntityName.cs"
    
    Invoke-TemplateWithProperties $templateFile $outputFile $Properties $vars
}

function New-DtoFiles {
    param([array]$Properties)
    
    Write-Step "Generating DTO files..."
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
    }
    
    # Create DTO (in Contracts)
    $templateFile = Join-Path $script:TemplatesDir "application\dto-create.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\Create$($script:EntityName)Dto.cs"
    Invoke-TemplateWithProperties $templateFile $outputFile $Properties $vars
    
    # Update DTO (in Contracts)
    $templateFile = Join-Path $script:TemplatesDir "application\dto-update.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\Update$($script:EntityName)Dto.cs"
    Invoke-TemplateWithProperties $templateFile $outputFile $Properties $vars
    
    # Entity DTO (in Contracts)
    $templateFile = Join-Path $script:TemplatesDir "application\dto-entity.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\$($script:EntityName)Dto.cs"
    Invoke-TemplateWithProperties $templateFile $outputFile $Properties $vars
    
    # List Input DTO (in Contracts)
    $templateFile = Join-Path $script:TemplatesDir "application\dto-list-input.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\Get$($script:EntityName)ListInput.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
    
    # Lookup DTO (in Contracts)
    $templateFile = Join-Path $script:TemplatesDir "application\dto-lookup.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\DTOs\$($script:EntityName)LookupDto.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
}

function New-RepositoryFiles {
    Write-Step "Generating repository files..."
    
    $entityNameLower = $script:EntityName.Substring(0,1).ToLower() + $script:EntityName.Substring(1)
    
    # Use selected DbContext or default to module name
    if ([string]::IsNullOrWhiteSpace($script:DbContextName)) {
        $script:DbContextName = "$($script:ModuleName)DbContext"
    }
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
        ID_TYPE = $script:EntityIdType
        DB_CONTEXT_NAME = $script:DbContextName
    }
    
    # Repository interface
    $templateFile = Join-Path $script:TemplatesDir "domain\repository-interface.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Domain\$script:ModuleName\I$($script:EntityName)Repository.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
    
    # EF Repository
    $templateFile = Join-Path $script:TemplatesDir "infrastructure\ef-repository.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.EntityFrameworkCore\$script:ModuleName\Repositories\EfCore$($script:EntityName)Repository.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
}

function New-ServiceFiles {
    Write-Step "Generating service files..."
    
    $entityNameLower = $script:EntityName.Substring(0,1).ToLower() + $script:EntityName.Substring(1)
    $entityNamePlural = "$($script:EntityName)s"
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
        ENTITY_NAME_PLURAL = $entityNamePlural
    }
    
    # Service interface (in Contracts)
    $templateFile = Join-Path $script:TemplatesDir "application\app-service-interface.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application.Contracts\$script:ModuleName\I$($script:EntityName)AppService.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
    
    # Service implementation (in Application)
    $templateFile = Join-Path $script:TemplatesDir "application\app-service-crud.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application\$script:ModuleName\$($script:EntityName)AppService.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
}

function New-ControllerFiles {
    Write-Step "Generating controller files..."
    
    $moduleNameLower = $script:ModuleName.Substring(0,1).ToLower() + $script:ModuleName.Substring(1)
    $entityNameLower = $script:EntityName.Substring(0,1).ToLower() + $script:EntityName.Substring(1)
    $entityNamePlural = "$($script:EntityName)s"
    $entityNameLowerPlural = "$entityNameLower" + "s"
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        MODULE_NAME_LOWER = $moduleNameLower
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
        ENTITY_NAME_PLURAL = $entityNamePlural
        ENTITY_NAME_LOWER_PLURAL = $entityNameLowerPlural
    }
    
    $templateFile = Join-Path $script:TemplatesDir "api\controller-crud.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.HttpApi\$script:ModuleName\Controllers\$($script:EntityName)Controller.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
}

function New-SeederFiles {
    Write-Step "Generating seeder files..."
    
    $entityNameLower = $script:EntityName.Substring(0,1).ToLower() + $script:EntityName.Substring(1)
    $entityNamePlural = "$($script:EntityName)s"
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
        ENTITY_NAME_PLURAL = $entityNamePlural
        ADDITIONAL_SEED_DATA = ""
    }
    
    $templateFile = Join-Path $script:TemplatesDir "infrastructure\seeder.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.EntityFrameworkCore\$script:ModuleName\$($script:EntityName)DataSeeder.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
}

function New-ValidationFiles {
    Write-Step "Generating validation files..."
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        VALIDATION_RULES = ""
    }
    
    $templateFile = Join-Path $script:TemplatesDir "application\validator.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application\$script:ModuleName\Validators\$($script:EntityName)Validator.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
}

function New-TestFiles {
    Write-Step "Generating test files..."
    
    $entityNameLower = $script:EntityName.Substring(0,1).ToLower() + $script:EntityName.Substring(1)
    $entityNamePlural = "$($script:EntityName)s"
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
        ENTITY_NAME_PLURAL = $entityNamePlural
    }
    
    # Service tests
    $templateFile = Join-Path $script:TemplatesDir "tests\unit-test-service.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "test\$script:Namespace.Application.Tests\$script:ModuleName\$($script:EntityName)AppServiceTests.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
    
    # Domain tests
    $templateFile = Join-Path $script:TemplatesDir "tests\unit-test-domain.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "test\$script:Namespace.Domain.Tests\$script:ModuleName\$($script:EntityName)DomainTests.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
}

################################################################################
# SECTION 9: Interactive Entity Generation
################################################################################

function Get-AbpEntityBaseClasses {
    param([string]$IdType = "Guid")
    
    return @(
        @{Name="Entity<$IdType>"; Description="Basic entity"},
        @{Name="AggregateRoot<$IdType>"; Description="Aggregate root"},
        @{Name="BasicAggregateRoot<$IdType>"; Description="Simplified aggregate root"},
        @{Name="CreationAuditedEntity<$IdType>"; Description="Entity with creation audit"},
        @{Name="CreationAuditedAggregateRoot<$IdType>"; Description="Aggregate root with creation audit"},
        @{Name="AuditedEntity<$IdType>"; Description="Entity with creation and modification audit"},
        @{Name="AuditedAggregateRoot<$IdType>"; Description="Aggregate root with creation and modification audit"},
        @{Name="FullAuditedEntity<$IdType>"; Description="Entity with full audit (creation, modification, deletion)"},
        @{Name="FullAuditedAggregateRoot<$IdType>"; Description="Aggregate root with full audit (default)"},
        @{Name="CreationAuditedEntity<$IdType>, ISoftDelete"; Description="Entity with creation audit and soft delete"},
        @{Name="CreationAuditedAggregateRoot<$IdType>, ISoftDelete"; Description="Aggregate root with creation audit and soft delete"},
        @{Name="AuditedEntity<$IdType>, ISoftDelete"; Description="Entity with audit and soft delete"},
        @{Name="AuditedAggregateRoot<$IdType>, ISoftDelete"; Description="Aggregate root with audit and soft delete"},
        @{Name="FullAuditedEntity<$IdType>, ISoftDelete"; Description="Entity with full audit and soft delete"},
        @{Name="FullAuditedAggregateRoot<$IdType>, ISoftDelete"; Description="Aggregate root with full audit and soft delete"}
    )
}

function Select-EntityIdType {
    Write-Host ""
    Write-Host "Select entity ID type:"
    Write-Host ""
    Write-Host "  1) Guid (default) - Globally unique identifier"
    Write-Host "  2) long - 64-bit integer"
    Write-Host "  3) int - 32-bit integer"
    Write-Host ""
    
    $choice = Read-Host "Enter choice [1-3] (default: 1)"
    
    if ([string]::IsNullOrEmpty($choice)) {
        $choice = "1"
    }
    
    switch ($choice) {
        "1" { 
            $script:EntityIdType = "Guid"
            Write-Info "Selected ID type: Guid"
            return $true
        }
        "2" { 
            $script:EntityIdType = "long"
            Write-Info "Selected ID type: long"
            return $true
        }
        "3" { 
            $script:EntityIdType = "int"
            Write-Info "Selected ID type: int"
            return $true
        }
        default {
            Write-Error-Custom "Invalid choice, using default: Guid"
            $script:EntityIdType = "Guid"
            return $false
        }
    }
}

function Select-EntityBaseClass {
    Write-Host ""
    Write-Host "Select entity base class:"
    Write-Host ""
    
    $baseClasses = Get-AbpEntityBaseClasses -IdType $script:EntityIdType
    for ($i = 0; $i -lt $baseClasses.Count; $i++) {
        $bc = $baseClasses[$i]
        $default = if ($bc.Name -eq "FullAuditedAggregateRoot<$($script:EntityIdType)>") { " (default)" } else { "" }
        Write-Host "  $($i + 1)) $($bc.Name)$default"
        Write-Host "     $($bc.Description)"
    }
    Write-Host ""
    
    $choice = Read-Host "Enter choice [1-$($baseClasses.Count)] (default: 9)"
    
    if ([string]::IsNullOrEmpty($choice)) {
        $choice = "9"
    }
    
    $index = [int]$choice - 1
    if ($index -ge 0 -and $index -lt $baseClasses.Count) {
        $script:EntityBaseClass = $baseClasses[$index].Name
        Write-Info "Selected base class: $script:EntityBaseClass"
        return $true
    } else {
        $defaultBase = "FullAuditedAggregateRoot<$($script:EntityIdType)>"
        Write-Error-Custom "Invalid choice, using default: $defaultBase"
        $script:EntityBaseClass = $defaultBase
        return $false
    }
}

function Select-DbContext {
    Write-Host ""
    Write-Host "Select DbContext:"
    Write-Host ""
    
    # Try to auto-detect DbContext files
    $dbContextFiles = @()
    if ($script:ProjectRoot) {
        $dbContextFiles = Get-ChildItem -Path $script:ProjectRoot -Recurse -Filter "*DbContext.cs" -File -ErrorAction SilentlyContinue | 
            Where-Object { $_.FullName -notmatch "\\bin\\|\\obj\\" }
    }
    
    if ($dbContextFiles.Count -gt 0) {
        Write-Host "Found DbContext files:"
        for ($i = 0; $i -lt $dbContextFiles.Count; $i++) {
            $dbContextName = [System.IO.Path]::GetFileNameWithoutExtension($dbContextFiles[$i].Name)
            Write-Host "  $($i + 1)) $dbContextName"
        }
        Write-Host "  $($dbContextFiles.Count + 1)) Use module name: $($script:ModuleName)DbContext (default)"
        Write-Host "  $($dbContextFiles.Count + 2)) Enter custom DbContext name"
        Write-Host ""
        
        $choice = Read-Host "Enter choice [1-$($dbContextFiles.Count + 2)] (default: $($dbContextFiles.Count + 1))"
        
        if ([string]::IsNullOrEmpty($choice)) {
            $choice = ($dbContextFiles.Count + 1).ToString()
        }
        
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $dbContextFiles.Count) {
            $script:DbContextName = [System.IO.Path]::GetFileNameWithoutExtension($dbContextFiles[$index].Name)
            Write-Info "Selected DbContext: $($script:DbContextName)"
            return $true
        } elseif ($index -eq $dbContextFiles.Count) {
            $script:DbContextName = "$($script:ModuleName)DbContext"
            Write-Info "Using module DbContext: $($script:DbContextName)"
            return $true
        } elseif ($index -eq ($dbContextFiles.Count + 1)) {
            $customName = Read-Host "Enter DbContext name"
            if (-not [string]::IsNullOrWhiteSpace($customName)) {
                $script:DbContextName = $customName
                Write-Info "Using custom DbContext: $($script:DbContextName)"
                return $true
            }
        }
    } else {
        Write-Host "No DbContext files found. Using module name: $($script:ModuleName)DbContext"
        $script:DbContextName = "$($script:ModuleName)DbContext"
        return $true
    }
    
    # Default fallback
    $script:DbContextName = "$($script:ModuleName)DbContext"
    Write-Info "Using default DbContext: $($script:DbContextName)"
    return $true
}

function New-EntityInteractive {
    Write-Step "Interactive entity generation"
    
    Write-Host ""
    $useJson = Read-Host "Load from JSON file? [y/N]"
    
    if ($useJson -match '^[Yy]$') {
        Write-Host ""
        Write-Host "Available JSON files in entity-definitions/:"
        Get-ChildItem -Path $script:EntityDefinitionsDir -Filter "*.json" | ForEach-Object { Write-Host "  $($_.Name)" }
        Write-Host ""
        
        $jsonPath = Read-Host "Enter JSON file path"
        
        if (Test-Path $jsonPath) {
            return New-EntityFromJson $jsonPath
        } elseif (Test-Path (Join-Path $script:EntityDefinitionsDir $jsonPath)) {
            return New-EntityFromJson (Join-Path $script:EntityDefinitionsDir $jsonPath)
        } else {
            Write-Error-Custom "JSON file not found: $jsonPath"
            return $false
        }
    }
    
    # Traditional interactive flow
    $script:ModuleName = Read-Host "Enter module name"
    if (-not (Test-ModuleName $script:ModuleName)) {
        return $false
    }
    
    $script:EntityName = Read-Host "Enter entity name"
    if (-not (Test-EntityName $script:EntityName)) {
        return $false
    }
    
    # Select ID type first
    Select-EntityIdType | Out-Null
    
    # Select base class (will use selected ID type)
    Select-EntityBaseClass | Out-Null
    
    # Select DbContext
    Select-DbContext | Out-Null
    
    Write-Warning-Custom "Basic entity generation (no JSON)"
    Write-Info "For advanced features (properties, relationships), use JSON format"
    
    # Generate with empty properties
    New-EntityFiles @() @()
    return $true
}

################################################################################
# SECTION 10: Main Menu
################################################################################

function Show-MainMenu {
    Clear-Host
    Write-Header "ABP Framework Project & Module Generator v1.0"
    
    Write-Host "🎯 " -NoNewline -ForegroundColor Cyan
    Write-Host "Select an operation:" -ForegroundColor White
    Write-Separator
    
    Write-SectionHeader "PROJECT MANAGEMENT"
    Write-Host "  1️⃣  Create New ABP Project" -ForegroundColor White
    Write-Host "  2️⃣  Create New Module" -ForegroundColor White
    Write-Host "  3️⃣  Create New Package" -ForegroundColor White
    Write-Host "  4️⃣  Initialize Solution" -ForegroundColor White
    Write-Host "  5️⃣  Update Solution" -ForegroundColor White
    Write-Host "  6️⃣  Upgrade Solution" -ForegroundColor White
    Write-Host "  7️⃣  Clean Solution" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "MODULE & PACKAGE MANAGEMENT"
    Write-Host "  8️⃣  Add Package" -ForegroundColor White
    Write-Host "  9️⃣  Add Package Reference" -ForegroundColor White
    Write-Host "  🔟 Install Module" -ForegroundColor White
    Write-Host "  1️⃣ 1️⃣ Install Local Module" -ForegroundColor White
    Write-Host "  1️⃣ 2️⃣ List Modules" -ForegroundColor White
    Write-Host "  1️⃣ 3️⃣ List Templates" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "SOURCE CODE MANAGEMENT"
    Write-Host "  1️⃣ 4️⃣ Get Module Source" -ForegroundColor White
    Write-Host "  1️⃣ 5️⃣ Add Source Code" -ForegroundColor White
    Write-Host "  1️⃣ 6️⃣ List Module Sources" -ForegroundColor White
    Write-Host "  1️⃣ 7️⃣ Add Module Source" -ForegroundColor White
    Write-Host "  1️⃣ 8️⃣ Delete Module Source" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "PROXY GENERATION"
    Write-Host "  1️⃣ 9️⃣ Generate Proxy" -ForegroundColor White
    Write-Host "  2️⃣ 0️⃣ Remove Proxy" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "VERSION MANAGEMENT"
    Write-Host "  2️⃣ 1️⃣ Switch to Preview" -ForegroundColor White
    Write-Host "  2️⃣ 2️⃣ Switch to Nightly" -ForegroundColor White
    Write-Host "  2️⃣ 3️⃣ Switch to Stable" -ForegroundColor White
    Write-Host "  2️⃣ 4️⃣ Switch to Local" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "🎨 ENTITY GENERATION (Custom)"
    Write-Host "  2️⃣ 5️⃣ Add Entity with CRUD" -ForegroundColor Green
    Write-Host "  2️⃣ 6️⃣ Generate from JSON" -ForegroundColor Green
    Write-Host ""
    Write-SectionHeader "🗑️  ENTITY CLEANUP"
    Write-Host "  3️⃣ 9️⃣ Rollback Last Generated Entity" -ForegroundColor Yellow
    Write-Host "  4️⃣ 0️⃣ Delete Entity by Name" -ForegroundColor Yellow
    Write-Host "  4️⃣ 1️⃣ List Generated Entities" -ForegroundColor Cyan
    Write-Host "  4️⃣ 2️⃣ Clean All Generated Files" -ForegroundColor Red
    Write-Host ""
    Write-SectionHeader "AUTHENTICATION"
    Write-Host "  2️⃣ 7️⃣ Login" -ForegroundColor White
    Write-Host "  2️⃣ 8️⃣ Login Info" -ForegroundColor White
    Write-Host "  2️⃣ 9️⃣ Logout" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "BUILD & BUNDLE"
    Write-Host "  3️⃣ 0️⃣ Bundle (Blazor/MAUI)" -ForegroundColor White
    Write-Host "  3️⃣ 1️⃣ Install Libs" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "LOCALIZATION"
    Write-Host "  3️⃣ 2️⃣ Translate" -ForegroundColor White
    Write-Host ""
    Write-SectionHeader "UTILITIES"
    Write-Host "  3️⃣ 3️⃣ Check Extensions" -ForegroundColor White
    Write-Host "  3️⃣ 4️⃣ Install Old CLI" -ForegroundColor White
    Write-Host "  3️⃣ 5️⃣ Generate Razor Page" -ForegroundColor White
    Write-Host "  3️⃣ 6️⃣ Check Dependencies" -ForegroundColor White
    Write-Host "  3️⃣ 7️⃣ ABP Help" -ForegroundColor White
    Write-Host "  3️⃣ 8️⃣ ABP CLI Info" -ForegroundColor White
    Write-Host ""
    Write-Host "  9️⃣ 9️⃣ " -NoNewline -ForegroundColor Red
    Write-Host "Exit" -ForegroundColor Red
    Write-Host ""
    Write-Separator
    
    if ($script:ProjectName) {
        Write-Host "Current Project: " -NoNewline
        Write-Host $script:ProjectName -ForegroundColor Green
        Write-Host "Namespace: " -NoNewline
        Write-Host $script:Namespace -ForegroundColor Green
        Write-Host ""
    }
}

################################################################################
# SECTION 11: Operations
################################################################################

function Invoke-CreateNewProject {
    Write-Header "Create New ABP Project"
    
    $script:ProjectName = Read-Host "Enter project name (e.g., MyApp)"
    if ([string]::IsNullOrEmpty($script:ProjectName)) {
        Write-Error-Custom "Project name cannot be empty"
        return
    }
    
    Write-Host ""
    Write-Host "Select ABP template:"
    Write-Host "  1) Application (app)"
    Write-Host "  2) Module (module)"
    Write-Host "  3) Microservice (microservice)"
    Write-Host "  4) Console (console)"
    Write-Host ""
    
    $templateChoice = Read-Host "Enter template choice [1-4]"
    
    switch ($templateChoice) {
        "1" { $script:TemplateType = "app" }
        "2" { $script:TemplateType = "module" }
        "3" { $script:TemplateType = "microservice" }
        "4" { $script:TemplateType = "console" }
        default {
            Write-Error-Custom "Invalid choice"
            Read-Host "Press Enter to continue..."
            return
        }
    }
    
    Write-Host ""
    Write-Host "Select database provider:"
    Write-Host "  1) Entity Framework Core (ef)"
    Write-Host "  2) MongoDB (mongodb)"
    Write-Host ""
    
    $dbChoice = Read-Host "Enter database choice [1-2]"
    
    $dbProvider = switch ($dbChoice) {
        "1" { "ef" }
        "2" { "mongodb" }
        default {
            Write-Error-Custom "Invalid choice"
            Read-Host "Press Enter to continue..."
            return
        }
    }
    
    Write-Host ""
    $multitenancy = Read-Host "Enable multi-tenancy? [y/N]"
    $tiered = $multitenancy -match '^[Yy]$'
    
    $success = switch ($script:TemplateType) {
        "app" { New-AppProject $script:ProjectName $dbProvider $tiered }
        "module" { New-ModuleProject $script:ProjectName $dbProvider }
        "microservice" { New-MicroserviceProject $script:ProjectName $dbProvider }
        "console" { New-ConsoleProject $script:ProjectName $dbProvider }
    }
    
    if ($success) {
        $script:ProjectRoot = Join-Path (Get-Location) $script:ProjectName
        $script:Namespace = $script:ProjectName
        Save-Config
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue..."
}

function Invoke-AddEntityWithCrud {
    Write-Header "Add Entity with CRUD"
    
    if (-not (Find-ProjectInfo) -and [string]::IsNullOrEmpty($script:ProjectName)) {
        Write-Error-Custom "No ABP project detected. Please create or navigate to an ABP project first."
        Read-Host "Press Enter to continue..."
        return
    }
    
    New-EntityInteractive
    
    Read-Host "Press Enter to continue..."
}

function Invoke-GenerateFromJson {
    Write-Header "Generate from JSON"
    
    if (-not (Find-ProjectInfo) -and [string]::IsNullOrEmpty($script:ProjectName)) {
        Write-Error-Custom "No ABP project detected. Please create or navigate to an ABP project first."
        Read-Host "Press Enter to continue..."
        return
    }
    
    Write-Host ""
    Write-Host "Available JSON files:"
    Get-ChildItem -Path $script:EntityDefinitionsDir -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  $($_.Name)" }
    Write-Host ""
    
    $jsonInput = Read-Host "Enter JSON file path or name"
    
    if (Test-Path $jsonInput) {
        New-EntityFromJson $jsonInput
    } elseif (Test-Path (Join-Path $script:EntityDefinitionsDir $jsonInput)) {
        New-EntityFromJson (Join-Path $script:EntityDefinitionsDir $jsonInput)
    } else {
        Write-Error-Custom "JSON file not found: $jsonInput"
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue..."
}

################################################################################
# SECTION 12: CLI Interface
################################################################################

function Invoke-CliMode {
    param([string[]]$Args)
    
    if ($Args.Count -eq 0) {
        Show-Usage
        return
    }
    
    $operation = $Args[0]
    $remainingArgs = $Args[1..($Args.Count - 1)]
    
    # Parse arguments into hashtable for custom commands
    $params = @{}
    for ($i = 0; $i -lt $remainingArgs.Count; $i += 2) {
        if ($i + 1 -lt $remainingArgs.Count) {
            $key = $remainingArgs[$i] -replace '^--?', '' -replace '-', ''
            $params[$key] = $remainingArgs[$i + 1]
        } else {
            $key = $remainingArgs[$i] -replace '^--?', '' -replace '-', ''
            $params[$key] = $true
        }
    }
    
    switch ($operation) {
        # Custom commands
        "create-project" {
            $name = $params["name"]
            $template = if ($params["template"]) { $params["template"] } else { "app" }
            
            if ([string]::IsNullOrEmpty($name)) {
                Write-Error-Custom "Project name is required (--name)"
                return
            }
            
            $script:ProjectName = $name
            $script:TemplateType = $template
            
            switch ($template) {
                "app" { New-AppProject $name "ef" $false }
                "module" { New-ModuleProject $name "ef" }
                "microservice" { New-MicroserviceProject $name "ef" }
                "console" { New-ConsoleProject $name "ef" }
                default { Write-Error-Custom "Invalid template: $template" }
            }
        }
        "add-entity" {
            $jsonFile = $params["fromjson"]
            
            if ($jsonFile) {
                New-EntityFromJson $jsonFile
            } elseif ($params["module"] -and $params["name"]) {
                $script:ModuleName = $params["module"]
                $script:EntityName = $params["name"]
                New-EntityFiles @() @()
            } else {
                Write-Error-Custom "Either --from-json or both --module and --name are required"
            }
        }
        # ABP CLI commands - direct passthrough to abp CLI
        default {
            # Check if it's a valid ABP CLI command by trying to execute it
            if (-not (Get-Command abp -ErrorAction SilentlyContinue)) {
                Write-Error-Custom "ABP CLI not found. Install with: dotnet tool install -g Volo.Abp.Cli"
                return
            }
            
            # Special handling for update command
            if ($operation -eq "update") {
                $hasSolutionName = $false
                $solutionNameIndex = -1
                for ($i = 0; $i -lt $remainingArgs.Count; $i++) {
                    if ($remainingArgs[$i] -match "^--?solution-name$" -or $remainingArgs[$i] -match "^--?sn$") {
                        $hasSolutionName = $true
                        $solutionNameIndex = $i
                        break
                    }
                }
                
                if (-not $hasSolutionName) {
                    $slnFiles = Get-ChildItem -Path . -Filter "*.sln" -File -ErrorAction SilentlyContinue
                    if ($null -eq $slnFiles -or $slnFiles.Count -eq 0) {
                        Write-Error-Custom "No solution name provided and no .sln file found in current directory."
                        Write-Info "Please either:"
                        Write-Info "  1. Provide --solution-name parameter"
                        Write-Info "  2. Run the command from within a solution directory"
                        return
                    }
                    
                    # Auto-detect solution name from .sln file and add to arguments
                    $slnFile = if ($slnFiles.Count -gt 0) { $slnFiles[0] } else { $slnFiles }
                    $detectedSolutionName = [System.IO.Path]::GetFileNameWithoutExtension($slnFile.Name)
                    Write-Info "Auto-detected solution name: $detectedSolutionName"
                    $remainingArgs = @("--solution-name", $detectedSolutionName) + $remainingArgs
                }
            }
            
            # Pass through to ABP CLI directly
            $finalArgs = @($operation) + $remainingArgs
            Write-Info "Executing: abp $($finalArgs -join ' ')"
            try {
                & abp $finalArgs
                if ($LASTEXITCODE -ne 0) {
                    Write-Error-Custom "Command failed with exit code $LASTEXITCODE"
                }
            } catch {
                Write-Error-Custom "Error executing command: $_"
                Write-Host ""
            Show-Usage
            }
        }
    }
}

function Show-Usage {
    Write-Host "ABP Framework Project & Module Generator v1.0"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\abp-generator.ps1                                    # Interactive mode"
    Write-Host ""
    Write-Host "PROJECT MANAGEMENT:"
    Write-Host "  .\abp-generator.ps1 create-project --name <name> --template <type>"
    Write-Host "  .\abp-generator.ps1 new --name <name> [options]"
    Write-Host "  .\abp-generator.ps1 new-module --name <name> [options]"
    Write-Host "  .\abp-generator.ps1 new-package --name <name> [options]"
    Write-Host "  .\abp-generator.ps1 init-solution --name <name> [options]"
    Write-Host "  .\abp-generator.ps1 update [--solution-name <name>]"
    Write-Host "  .\abp-generator.ps1 upgrade [--solution-name <name>]"
    Write-Host "  .\abp-generator.ps1 clean [--solution-name <name>]"
    Write-Host ""
    Write-Host "MODULE & PACKAGE MANAGEMENT:"
    Write-Host "  .\abp-generator.ps1 add-package --project <path> --package <name>"
    Write-Host "  .\abp-generator.ps1 add-package-ref --project <path> --package <name>"
    Write-Host "  .\abp-generator.ps1 install-module --solution-name <name> --module <name>"
    Write-Host "  .\abp-generator.ps1 install-local-module --solution-name <name> --module <path>"
    Write-Host "  .\abp-generator.ps1 list-modules"
    Write-Host "  .\abp-generator.ps1 list-templates"
    Write-Host ""
    Write-Host "SOURCE CODE MANAGEMENT:"
    Write-Host "  .\abp-generator.ps1 get-source --module <name>"
    Write-Host "  .\abp-generator.ps1 add-source-code --solution-name <name> --module <name>"
    Write-Host "  .\abp-generator.ps1 list-module-sources"
    Write-Host "  .\abp-generator.ps1 add-module-source --name <name> --url <url>"
    Write-Host "  .\abp-generator.ps1 delete-module-source --name <name>"
    Write-Host ""
    Write-Host "PROXY GENERATION:"
    Write-Host "  .\abp-generator.ps1 generate-proxy [options]"
    Write-Host "  .\abp-generator.ps1 remove-proxy [options]"
    Write-Host ""
    Write-Host "VERSION MANAGEMENT:"
    Write-Host "  .\abp-generator.ps1 switch-to-preview [--solution-name <name>]"
    Write-Host "  .\abp-generator.ps1 switch-to-nightly [--solution-name <name>]"
    Write-Host "  .\abp-generator.ps1 switch-to-stable [--solution-name <name>]"
    Write-Host "  .\abp-generator.ps1 switch-to-local [--solution-name <name>]"
    Write-Host ""
    Write-Host "ENTITY GENERATION (Custom):"
    Write-Host "  .\abp-generator.ps1 add-entity --from-json <file.json>"
    Write-Host "  .\abp-generator.ps1 add-entity --module <module> --name <name>"
    Write-Host ""
    Write-Host "ENTITY CLEANUP:"
    Write-Host "  .\abp-generator.ps1 rollback"
    Write-Host "  .\abp-generator.ps1 delete-entity --name <entity>"
    Write-Host "  .\abp-generator.ps1 list-entities"
    Write-Host "  .\abp-generator.ps1 clean-all"
    Write-Host ""
    Write-Host "AUTHENTICATION:"
    Write-Host "  .\abp-generator.ps1 login [--username <user>] [--password <pass>]"
    Write-Host "  .\abp-generator.ps1 login-info"
    Write-Host "  .\abp-generator.ps1 logout"
    Write-Host ""
    Write-Host "BUILD & BUNDLE:"
    Write-Host "  .\abp-generator.ps1 bundle [--working-directory <path>]"
    Write-Host "  .\abp-generator.ps1 install-libs [--working-directory <path>]"
    Write-Host ""
    Write-Host "LOCALIZATION:"
    Write-Host "  .\abp-generator.ps1 translate --culture <code> [options]"
    Write-Host ""
    Write-Host "UTILITIES:"
    Write-Host "  .\abp-generator.ps1 check-extensions"
    Write-Host "  .\abp-generator.ps1 install-old-cli [--version <version>]"
    Write-Host "  .\abp-generator.ps1 generate-razor-page [--working-directory <path>]"
    Write-Host "  .\abp-generator.ps1 help [<command>]"
    Write-Host "  .\abp-generator.ps1 cli"
    Write-Host ""
    Write-Host "KUBERNETES:"
    Write-Host "  .\abp-generator.ps1 kube-connect --context <name>"
    Write-Host "  .\abp-generator.ps1 kube-intercept --service <name>"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\abp-generator.ps1                                          # Interactive mode"
    Write-Host "  .\abp-generator.ps1 create-project --name MyApp --template app"
    Write-Host "  .\abp-generator.ps1 add-entity --from-json product.json"
    Write-Host "  .\abp-generator.ps1 list-entities                           # List generated entities"
    Write-Host "  .\abp-generator.ps1 rollback                                # Undo last entity"
    Write-Host "  .\abp-generator.ps1 install-module --solution-name MyApp --module Volo.Blogging"
    Write-Host ""
    Write-Host "For more information, visit: https://abp.io/docs/latest/cli"
}

################################################################################
# SECTION 14: ABP CLI Command Wrappers
################################################################################

function Invoke-AbpCommand {
    param(
        [string]$Command,
        [hashtable]$Parameters = @{}
    )
    
    if (-not (Get-Command abp -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "ABP CLI not found. Install with: dotnet tool install -g Volo.Abp.Cli"
        return $false
    }
    
    $args = @($Command)
    
    foreach ($key in $Parameters.Keys) {
        $value = $Parameters[$key]
        if ($value -is [bool]) {
            if ($value) {
                $args += "--$key"
            }
        } elseif ($value -is [array]) {
            foreach ($item in $value) {
                $args += "--$key"
                $args += $item
            }
        } elseif ($null -ne $value -and $value -ne "") {
            $args += "--$key"
            $args += $value
        }
    }
    
    Write-Info "Executing: abp $($args -join ' ')"
    
    try {
        & abp $args
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Command completed successfully"
            return $true
        } else {
            Write-Error-Custom "Command failed with exit code $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-Error-Custom "Error executing command: $_"
        return $false
    }
}

# Project & Solution Commands
function Invoke-AbpNew {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [string]$Template = "app",
        [string]$DatabaseProvider = "ef",
        [string]$UiFramework = "",
        [string]$Mobile = "",
        [switch]$Tiered,
        [switch]$SeparateIdentityServer,
        [switch]$PublicWebSite,
        [switch]$NoUi,
        [string]$OutputFolder = "",
        [string]$Version = ""
    )
    
    $params = @{
        name = $Name
        template = $Template
        database-provider = $DatabaseProvider
    }
    
    if ($UiFramework) { $params["ui"] = $UiFramework }
    if ($Mobile) { $params["mobile"] = $Mobile }
    if ($Tiered) { $params["tiered"] = $true }
    if ($SeparateIdentityServer) { $params["separate-identity-server"] = $true }
    if ($PublicWebSite) { $params["public-website"] = $true }
    if ($NoUi) { $params["no-ui"] = $true }
    if ($OutputFolder) { $params["output-folder"] = $OutputFolder }
    if ($Version) { $params["version"] = $Version }
    
    Invoke-AbpCommand "new" $params
}

function Invoke-AbpNewModule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [string]$Template = "module",
        [string]$DatabaseProvider = "ef",
        [string]$OutputFolder = "",
        [string]$Version = ""
    )
    
    $params = @{
        name = $Name
        template = $Template
        database-provider = $DatabaseProvider
    }
    
    if ($OutputFolder) { $params["output-folder"] = $OutputFolder }
    if ($Version) { $params["version"] = $Version }
    
    Invoke-AbpCommand "new-module" $params
}

function Invoke-AbpNewPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [string]$Template = "package",
        [string]$OutputFolder = "",
        [string]$Version = ""
    )
    
    $params = @{
        name = $Name
        template = $Template
    }
    
    if ($OutputFolder) { $params["output-folder"] = $OutputFolder }
    if ($Version) { $params["version"] = $Version }
    
    Invoke-AbpCommand "new-package" $params
}

function Invoke-AbpInitSolution {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [string]$Template = "app",
        [string]$DatabaseProvider = "ef",
        [string]$UiFramework = "",
        [switch]$Tiered,
        [string]$OutputFolder = "",
        [string]$Version = ""
    )
    
    $params = @{
        name = $Name
        template = $Template
        database-provider = $DatabaseProvider
    }
    
    if ($UiFramework) { $params["ui"] = $UiFramework }
    if ($Tiered) { $params["tiered"] = $true }
    if ($OutputFolder) { $params["output-folder"] = $OutputFolder }
    if ($Version) { $params["version"] = $Version }
    
    Invoke-AbpCommand "init-solution" $params
}

function Invoke-AbpUpdate {
    param(
        [string]$SolutionName = "",
        [switch]$NoBuild,
        [switch]$SkipCache
    )
    
    # If no solution name provided, auto-detect from .sln file
    if ([string]::IsNullOrWhiteSpace($SolutionName)) {
        $slnFiles = Get-ChildItem -Path . -Filter "*.sln" -File -ErrorAction SilentlyContinue
        if ($null -eq $slnFiles -or $slnFiles.Count -eq 0) {
            Write-Error-Custom "No solution name provided and no .sln file found in current directory."
            Write-Info "Please either:"
            Write-Info "  1. Provide --solution-name parameter"
            Write-Info "  2. Run the command from within a solution directory"
            return $false
        }
        
        # Auto-detect solution name from .sln file (use first one if multiple exist)
        $slnFile = if ($slnFiles.Count -gt 0) { $slnFiles[0] } else { $slnFiles }
        $SolutionName = [System.IO.Path]::GetFileNameWithoutExtension($slnFile.Name)
        Write-Info "Auto-detected solution name: $SolutionName"
    }
    
    $params = @{}
    
    if ($SolutionName) { $params["solution-name"] = $SolutionName }
    if ($NoBuild) { $params["no-build"] = $true }
    if ($SkipCache) { $params["skip-cache"] = $true }
    
    Invoke-AbpCommand "update" $params
}

function Invoke-AbpUpgrade {
    param(
        [string]$SolutionName = "",
        [switch]$Check,
        [switch]$Pre
    )
    
    $params = @{}
    
    if ($SolutionName) { $params["solution-name"] = $SolutionName }
    if ($Check) { $params["check"] = $true }
    if ($Pre) { $params["pre"] = $true }
    
    Invoke-AbpCommand "upgrade" $params
}

function Invoke-AbpClean {
    param(
        [string]$SolutionName = ""
    )
    
    $params = @{}
    
    if ($SolutionName) { $params["solution-name"] = $SolutionName }
    
    Invoke-AbpCommand "clean" $params
}

# Package & Module Management
function Invoke-AbpAddPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Project,
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        [string]$Version = "",
        [switch]$WithSourceCode,
        [string]$WorkingDirectory = ""
    )
    
    $params = @{
        project = $Project
        package = $PackageName
    }
    
    if ($Version) { $params["version"] = $Version }
    if ($WithSourceCode) { $params["with-source-code"] = $true }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "add-package" $params
}

function Invoke-AbpAddPackageRef {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Project,
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        [string]$Version = "",
        [string]$WorkingDirectory = ""
    )
    
    $params = @{
        project = $Project
        package = $PackageName
    }
    
    if ($Version) { $params["version"] = $Version }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "add-package-ref" $params
}

function Invoke-AbpInstallModule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionName,
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [string]$Version = "",
        [switch]$SkipDbMigrations,
        [string]$WorkingDirectory = ""
    )
    
    $params = @{
        solution-name = $SolutionName
        module = $ModuleName
    }
    
    if ($Version) { $params["version"] = $Version }
    if ($SkipDbMigrations) { $params["skip-db-migrations"] = $true }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "install-module" $params
}

function Invoke-AbpInstallLocalModule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionName,
        [Parameter(Mandatory=$true)]
        [string]$ModulePath,
        [switch]$SkipDbMigrations,
        [string]$WorkingDirectory = ""
    )
    
    $params = @{
        solution-name = $SolutionName
        module = $ModulePath
    }
    
    if ($SkipDbMigrations) { $params["skip-db-migrations"] = $true }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "install-local-module" $params
}

function Invoke-AbpListModules {
    param(
        [switch]$IncludePreRelease
    )
    
    $params = @{}
    
    if ($IncludePreRelease) { $params["include-prerelease"] = $true }
    
    Invoke-AbpCommand "list-modules" $params
}

function Invoke-AbpListTemplates {
    Invoke-AbpCommand "list-templates" @{}
}

# Source Code Management
function Invoke-AbpGetSource {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [string]$Version = "",
        [string]$OutputFolder = ""
    )
    
    $params = @{
        module = $ModuleName
    }
    
    if ($Version) { $params["version"] = $Version }
    if ($OutputFolder) { $params["output-folder"] = $OutputFolder }
    
    Invoke-AbpCommand "get-source" $params
}

function Invoke-AbpAddSourceCode {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionName,
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [string]$Version = "",
        [string]$WorkingDirectory = ""
    )
    
    $params = @{
        solution-name = $SolutionName
        module = $ModuleName
    }
    
    if ($Version) { $params["version"] = $Version }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "add-source-code" $params
}

function Invoke-AbpListModuleSources {
    Invoke-AbpCommand "list-module-sources" @{}
}

function Invoke-AbpAddModuleSource {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Url
    )
    
    $params = @{
        name = $Name
        url = $Url
    }
    
    Invoke-AbpCommand "add-module-source" $params
}

function Invoke-AbpDeleteModuleSource {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    $params = @{
        name = $Name
    }
    
    Invoke-AbpCommand "delete-module-source" $params
}

# Proxy Generation
function Invoke-AbpGenerateProxy {
    param(
        [string]$Module = "",
        [string]$Output = "",
        [string]$ApiName = "",
        [string]$Target = "",
        [string]$WorkingDirectory = "",
        [switch]$Angular,
        [switch]$ReactNative
    )
    
    $params = @{}
    
    if ($Module) { $params["module"] = $Module }
    if ($Output) { $params["output"] = $Output }
    if ($ApiName) { $params["api-name"] = $ApiName }
    if ($Target) { $params["target"] = $Target }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    if ($Angular) { $params["angular"] = $true }
    if ($ReactNative) { $params["react-native"] = $true }
    
    Invoke-AbpCommand "generate-proxy" $params
}

function Invoke-AbpRemoveProxy {
    param(
        [string]$Module = "",
        [string]$ApiName = "",
        [string]$WorkingDirectory = ""
    )
    
    $params = @{}
    
    if ($Module) { $params["module"] = $Module }
    if ($ApiName) { $params["api-name"] = $ApiName }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "remove-proxy" $params
}

# Version Management
function Invoke-AbpSwitchToPreview {
    param(
        [string]$SolutionName = ""
    )
    
    $params = @{}
    
    if ($SolutionName) { $params["solution-name"] = $SolutionName }
    
    Invoke-AbpCommand "switch-to-preview" $params
}

function Invoke-AbpSwitchToNightly {
    param(
        [string]$SolutionName = ""
    )
    
    $params = @{}
    
    if ($SolutionName) { $params["solution-name"] = $SolutionName }
    
    Invoke-AbpCommand "switch-to-nightly" $params
}

function Invoke-AbpSwitchToStable {
    param(
        [string]$SolutionName = ""
    )
    
    $params = @{}
    
    if ($SolutionName) { $params["solution-name"] = $SolutionName }
    
    Invoke-AbpCommand "switch-to-stable" $params
}

function Invoke-AbpSwitchToLocal {
    param(
        [string]$SolutionName = ""
    )
    
    $params = @{}
    
    if ($SolutionName) { $params["solution-name"] = $SolutionName }
    
    Invoke-AbpCommand "switch-to-local" $params
}

# Localization
function Invoke-AbpTranslate {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Culture,
        [string]$Output = "",
        [switch]$All,
        [string]$WorkingDirectory = ""
    )
    
    $params = @{
        culture = $Culture
    }
    
    if ($Output) { $params["output"] = $Output }
    if ($All) { $params["all"] = $true }
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "translate" $params
}

# Authentication
function Invoke-AbpLogin {
    param(
        [string]$Username = "",
        [string]$Password = ""
    )
    
    $params = @{}
    
    if ($Username) { $params["username"] = $Username }
    if ($Password) { $params["password"] = $Password }
    
    Invoke-AbpCommand "login" $params
}

function Invoke-AbpLoginInfo {
    Invoke-AbpCommand "login-info" @{}
}

function Invoke-AbpLogout {
    Invoke-AbpCommand "logout" @{}
}

# Build & Bundle
function Invoke-AbpBundle {
    param(
        [string]$WorkingDirectory = "",
        [switch]$Force,
        [string]$ProjectType = "webassembly",
        [string]$Version = ""
    )
    
    $params = @{}
    
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    if ($Force) { $params["force"] = $true }
    if ($ProjectType) { $params["project-type"] = $ProjectType }
    if ($Version) { $params["version"] = $Version }
    
    Invoke-AbpCommand "bundle" $params
}

function Invoke-AbpInstallLibs {
    param(
        [string]$WorkingDirectory = ""
    )
    
    $params = @{}
    
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "install-libs" $params
}

# Utilities
function Invoke-AbpCheckExtensions {
    Invoke-AbpCommand "check-extensions" @{}
}

function Invoke-AbpInstallOldCli {
    param(
        [string]$Version = ""
    )
    
    $params = @{}
    
    if ($Version) { $params["version"] = $Version }
    
    Invoke-AbpCommand "install-old-cli" $params
}

function Invoke-AbpGenerateRazorPage {
    param(
        [string]$WorkingDirectory = ""
    )
    
    $params = @{}
    
    if ($WorkingDirectory) { $params["working-directory"] = $WorkingDirectory }
    
    Invoke-AbpCommand "generate-razor-page" $params
}

# Kubernetes
function Invoke-AbpKubeConnect {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Context,
        [string]$Namespace = ""
    )
    
    $params = @{
        context = $Context
    }
    
    if ($Namespace) { $params["namespace"] = $Namespace }
    
    Invoke-AbpCommand "kube-connect" $params
}

function Invoke-AbpKubeIntercept {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Service,
        [string]$Context = "",
        [string]$Namespace = "",
        [string]$Port = ""
    )
    
    $params = @{
        service = $Service
    }
    
    if ($Context) { $params["context"] = $Context }
    if ($Namespace) { $params["namespace"] = $Namespace }
    if ($Port) { $params["port"] = $Port }
    
    Invoke-AbpCommand "kube-intercept" $params
}

# Help & Info
function Invoke-AbpHelp {
    param(
        [string]$Command = ""
    )
    
    if ($Command) {
        & abp help $Command
    } else {
        & abp help
    }
}

function Invoke-AbpCli {
    param(
        [switch]$Version
    )
    
    if ($Version) {
        & abp cli --version
    } else {
        & abp cli
    }
}

################################################################################
# SECTION 15: Interactive Command Wrappers
################################################################################

function Invoke-NewModuleInteractive {
    Write-Header "Create New Module"
    $name = Read-Host "Enter module name"
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error-Custom "Module name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $template = Read-Host "Enter template [module] (default: module)"
    if ([string]::IsNullOrEmpty($template)) { $template = "module" }
    $dbProvider = Read-Host "Enter database provider [ef/mongodb] (default: ef)"
    if ([string]::IsNullOrEmpty($dbProvider)) { $dbProvider = "ef" }
    Invoke-AbpNewModule -Name $name -Template $template -DatabaseProvider $dbProvider
    Read-Host "Press Enter to continue..."
}

function Invoke-NewPackageInteractive {
    Write-Header "Create New Package"
    $name = Read-Host "Enter package name"
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error-Custom "Package name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $template = Read-Host "Enter template [package] (default: package)"
    if ([string]::IsNullOrEmpty($template)) { $template = "package" }
    Invoke-AbpNewPackage -Name $name -Template $template
    Read-Host "Press Enter to continue..."
}

function Invoke-InitSolutionInteractive {
    Write-Header "Initialize Solution"
    $name = Read-Host "Enter solution name"
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error-Custom "Solution name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $template = Read-Host "Enter template [app] (default: app)"
    if ([string]::IsNullOrEmpty($template)) { $template = "app" }
    $dbProvider = Read-Host "Enter database provider [ef/mongodb] (default: ef)"
    if ([string]::IsNullOrEmpty($dbProvider)) { $dbProvider = "ef" }
    Invoke-AbpInitSolution -Name $name -Template $template -DatabaseProvider $dbProvider
    Read-Host "Press Enter to continue..."
}

function Invoke-UpdateInteractive {
    Write-Header "Update Solution"
    $solutionName = Read-Host "Enter solution name (optional)"
    $noBuild = (Read-Host "Skip build? [y/N]") -match '^[Yy]$'
    Invoke-AbpUpdate -SolutionName $solutionName -NoBuild:$noBuild
    Read-Host "Press Enter to continue..."
}

function Invoke-UpgradeInteractive {
    Write-Header "Upgrade Solution"
    $solutionName = Read-Host "Enter solution name (optional)"
    $check = (Read-Host "Check only? [y/N]") -match '^[Yy]$'
    Invoke-AbpUpgrade -SolutionName $solutionName -Check:$check
    Read-Host "Press Enter to continue..."
}

function Invoke-CleanInteractive {
    Write-Header "Clean Solution"
    $solutionName = Read-Host "Enter solution name (optional)"
    Invoke-AbpClean -SolutionName $solutionName
    Read-Host "Press Enter to continue..."
}

function Invoke-AddPackageInteractive {
    Write-Header "Add Package"
    $project = Read-Host "Enter project path"
    if ([string]::IsNullOrEmpty($project)) {
        Write-Error-Custom "Project path is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $packageName = Read-Host "Enter package name"
    if ([string]::IsNullOrEmpty($packageName)) {
        Write-Error-Custom "Package name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $version = Read-Host "Enter version (optional)"
    $withSourceCode = (Read-Host "Include source code? [y/N]") -match '^[Yy]$'
    Invoke-AbpAddPackage -Project $project -PackageName $packageName -Version $version -WithSourceCode:$withSourceCode
    Read-Host "Press Enter to continue..."
}

function Invoke-AddPackageRefInteractive {
    Write-Header "Add Package Reference"
    $project = Read-Host "Enter project path"
    if ([string]::IsNullOrEmpty($project)) {
        Write-Error-Custom "Project path is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $packageName = Read-Host "Enter package name"
    if ([string]::IsNullOrEmpty($packageName)) {
        Write-Error-Custom "Package name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $version = Read-Host "Enter version (optional)"
    Invoke-AbpAddPackageRef -Project $project -PackageName $packageName -Version $version
    Read-Host "Press Enter to continue..."
}

function Invoke-InstallModuleInteractive {
    Write-Header "Install Module"
    $solutionName = Read-Host "Enter solution name"
    if ([string]::IsNullOrEmpty($solutionName)) {
        Write-Error-Custom "Solution name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $moduleName = Read-Host "Enter module name"
    if ([string]::IsNullOrEmpty($moduleName)) {
        Write-Error-Custom "Module name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $version = Read-Host "Enter version (optional)"
    $skipDbMigrations = (Read-Host "Skip DB migrations? [y/N]") -match '^[Yy]$'
    Invoke-AbpInstallModule -SolutionName $solutionName -ModuleName $moduleName -Version $version -SkipDbMigrations:$skipDbMigrations
    Read-Host "Press Enter to continue..."
}

function Invoke-InstallLocalModuleInteractive {
    Write-Header "Install Local Module"
    $solutionName = Read-Host "Enter solution name"
    if ([string]::IsNullOrEmpty($solutionName)) {
        Write-Error-Custom "Solution name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $modulePath = Read-Host "Enter module path"
    if ([string]::IsNullOrEmpty($modulePath)) {
        Write-Error-Custom "Module path is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $skipDbMigrations = (Read-Host "Skip DB migrations? [y/N]") -match '^[Yy]$'
    Invoke-AbpInstallLocalModule -SolutionName $solutionName -ModulePath $modulePath -SkipDbMigrations:$skipDbMigrations
    Read-Host "Press Enter to continue..."
}

function Invoke-GetSourceInteractive {
    Write-Header "Get Module Source"
    $moduleName = Read-Host "Enter module name"
    if ([string]::IsNullOrEmpty($moduleName)) {
        Write-Error-Custom "Module name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $version = Read-Host "Enter version (optional)"
    $outputFolder = Read-Host "Enter output folder (optional)"
    Invoke-AbpGetSource -ModuleName $moduleName -Version $version -OutputFolder $outputFolder
    Read-Host "Press Enter to continue..."
}

function Invoke-AddSourceCodeInteractive {
    Write-Header "Add Source Code"
    $solutionName = Read-Host "Enter solution name"
    if ([string]::IsNullOrEmpty($solutionName)) {
        Write-Error-Custom "Solution name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $moduleName = Read-Host "Enter module name"
    if ([string]::IsNullOrEmpty($moduleName)) {
        Write-Error-Custom "Module name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $version = Read-Host "Enter version (optional)"
    Invoke-AbpAddSourceCode -SolutionName $solutionName -ModuleName $moduleName -Version $version
    Read-Host "Press Enter to continue..."
}

function Invoke-AddModuleSourceInteractive {
    Write-Header "Add Module Source"
    $name = Read-Host "Enter source name"
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error-Custom "Source name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $url = Read-Host "Enter source URL"
    if ([string]::IsNullOrEmpty($url)) {
        Write-Error-Custom "Source URL is required"
        Read-Host "Press Enter to continue..."
        return
    }
    Invoke-AbpAddModuleSource -Name $name -Url $url
    Read-Host "Press Enter to continue..."
}

function Invoke-DeleteModuleSourceInteractive {
    Write-Header "Delete Module Source"
    $name = Read-Host "Enter source name"
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error-Custom "Source name is required"
        Read-Host "Press Enter to continue..."
        return
    }
    Invoke-AbpDeleteModuleSource -Name $name
    Read-Host "Press Enter to continue..."
}

function Invoke-GenerateProxyInteractive {
    Write-Header "Generate Proxy"
    $module = Read-Host "Enter module name (optional)"
    $output = Read-Host "Enter output path (optional)"
    $apiName = Read-Host "Enter API name (optional)"
    $target = Read-Host "Enter target [angular/react-native] (optional)"
    $angular = (Read-Host "Angular? [y/N]") -match '^[Yy]$'
    $reactNative = (Read-Host "React Native? [y/N]") -match '^[Yy]$'
    Invoke-AbpGenerateProxy -Module $module -Output $output -ApiName $apiName -Target $target -Angular:$angular -ReactNative:$reactNative
    Read-Host "Press Enter to continue..."
}

function Invoke-RemoveProxyInteractive {
    Write-Header "Remove Proxy"
    $module = Read-Host "Enter module name (optional)"
    $apiName = Read-Host "Enter API name (optional)"
    Invoke-AbpRemoveProxy -Module $module -ApiName $apiName
    Read-Host "Press Enter to continue..."
}

function Invoke-SwitchToPreviewInteractive {
    Write-Header "Switch to Preview"
    $solutionName = Read-Host "Enter solution name (optional)"
    Invoke-AbpSwitchToPreview -SolutionName $solutionName
    Read-Host "Press Enter to continue..."
}

function Invoke-SwitchToNightlyInteractive {
    Write-Header "Switch to Nightly"
    $solutionName = Read-Host "Enter solution name (optional)"
    Invoke-AbpSwitchToNightly -SolutionName $solutionName
    Read-Host "Press Enter to continue..."
}

function Invoke-SwitchToStableInteractive {
    Write-Header "Switch to Stable"
    $solutionName = Read-Host "Enter solution name (optional)"
    Invoke-AbpSwitchToStable -SolutionName $solutionName
    Read-Host "Press Enter to continue..."
}

function Invoke-SwitchToLocalInteractive {
    Write-Header "Switch to Local"
    $solutionName = Read-Host "Enter solution name (optional)"
    Invoke-AbpSwitchToLocal -SolutionName $solutionName
    Read-Host "Press Enter to continue..."
}

function Invoke-LoginInteractive {
    Write-Header "Login"
    $username = Read-Host "Enter username (optional, will prompt if not provided)"
    $password = Read-Host "Enter password (optional, will prompt if not provided)" -AsSecureString
    if ($password) {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        Invoke-AbpLogin -Username $username -Password $plainPassword
    } else {
        Invoke-AbpLogin -Username $username
    }
    Read-Host "Press Enter to continue..."
}

function Invoke-BundleInteractive {
    Write-Header "Bundle (Blazor/MAUI)"
    $workingDirectory = Read-Host "Enter working directory (optional)"
    $force = (Read-Host "Force rebuild? [y/N]") -match '^[Yy]$'
    $projectType = Read-Host "Enter project type [webassembly/maui-blazor] (default: webassembly)"
    if ([string]::IsNullOrEmpty($projectType)) { $projectType = "webassembly" }
    Invoke-AbpBundle -WorkingDirectory $workingDirectory -Force:$force -ProjectType $projectType
    Read-Host "Press Enter to continue..."
}

function Invoke-InstallLibsInteractive {
    Write-Header "Install Libs"
    $workingDirectory = Read-Host "Enter working directory (optional)"
    Invoke-AbpInstallLibs -WorkingDirectory $workingDirectory
    Read-Host "Press Enter to continue..."
}

function Invoke-TranslateInteractive {
    Write-Header "Translate"
    $culture = Read-Host "Enter culture code (e.g., en, tr, fr)"
    if ([string]::IsNullOrEmpty($culture)) {
        Write-Error-Custom "Culture code is required"
        Read-Host "Press Enter to continue..."
        return
    }
    $output = Read-Host "Enter output path (optional)"
    $all = (Read-Host "Translate all? [y/N]") -match '^[Yy]$'
    Invoke-AbpTranslate -Culture $culture -Output $output -All:$all
    Read-Host "Press Enter to continue..."
}

function Invoke-InstallOldCliInteractive {
    Write-Header "Install Old CLI"
    $version = Read-Host "Enter version (optional, latest if not specified)"
    Invoke-AbpInstallOldCli -Version $version
    Read-Host "Press Enter to continue..."
}

function Invoke-GenerateRazorPageInteractive {
    Write-Header "Generate Razor Page"
    $workingDirectory = Read-Host "Enter working directory (optional)"
    Invoke-AbpGenerateRazorPage -WorkingDirectory $workingDirectory
    Read-Host "Press Enter to continue..."
}

################################################################################
# SECTION 13: Main Entry Point
################################################################################

function Main {
    param([string[]]$Arguments)
    
    Read-Config
    
    # If command line arguments provided, use CLI mode
    if ($Arguments.Count -gt 0) {
        Invoke-CliMode $Arguments
        return
    }
    
    # Interactive mode
    while ($true) {
        Show-MainMenu
        $choice = Read-Host "Enter your choice"
        
        switch ($choice) {
            "1" { Invoke-CreateNewProject }
            "2" { Invoke-NewModuleInteractive }
            "3" { Invoke-NewPackageInteractive }
            "4" { Invoke-InitSolutionInteractive }
            "5" { Invoke-UpdateInteractive }
            "6" { Invoke-UpgradeInteractive }
            "7" { Invoke-CleanInteractive }
            "8" { Invoke-AddPackageInteractive }
            "9" { Invoke-AddPackageRefInteractive }
            "10" { Invoke-InstallModuleInteractive }
            "11" { Invoke-InstallLocalModuleInteractive }
            "12" { Invoke-AbpListModules; Read-Host "Press Enter to continue..." }
            "13" { Invoke-AbpListTemplates; Read-Host "Press Enter to continue..." }
            "14" { Invoke-GetSourceInteractive }
            "15" { Invoke-AddSourceCodeInteractive }
            "16" { Invoke-AbpListModuleSources; Read-Host "Press Enter to continue..." }
            "17" { Invoke-AddModuleSourceInteractive }
            "18" { Invoke-DeleteModuleSourceInteractive }
            "19" { Invoke-GenerateProxyInteractive }
            "20" { Invoke-RemoveProxyInteractive }
            "21" { Invoke-SwitchToPreviewInteractive }
            "22" { Invoke-SwitchToNightlyInteractive }
            "23" { Invoke-SwitchToStableInteractive }
            "24" { Invoke-SwitchToLocalInteractive }
            "25" { Invoke-AddEntityWithCrud }
            "26" { Invoke-GenerateFromJson }
            "27" { Invoke-LoginInteractive }
            "28" { Invoke-AbpLoginInfo; Read-Host "Press Enter to continue..." }
            "29" { Invoke-AbpLogout; Read-Host "Press Enter to continue..." }
            "30" { Invoke-BundleInteractive }
            "31" { Invoke-InstallLibsInteractive }
            "32" { Invoke-TranslateInteractive }
            "33" { Invoke-AbpCheckExtensions; Read-Host "Press Enter to continue..." }
            "34" { Invoke-InstallOldCliInteractive }
            "35" { Invoke-GenerateRazorPageInteractive }
            "36" { 
                Test-Dependencies | Out-Null
                Read-Host "Press Enter to continue..."
            }
            "37" { Invoke-AbpHelp; Read-Host "Press Enter to continue..." }
            "38" { Invoke-AbpCli; Read-Host "Press Enter to continue..." }
            "39" { Invoke-RollbackLastEntity }
            "40" { Invoke-DeleteEntity }
            "41" { Get-GeneratedEntities }
            "42" { Invoke-CleanAllGeneratedFiles }
            "99" {
                Write-Host ""
                Write-Info "Exiting... Goodbye!"
                return
            }
            default {
                Write-Error-Custom "Invalid choice. Please try again."
                Start-Sleep -Seconds 2
            }
        }
    }
}

# Run main function
Main $args

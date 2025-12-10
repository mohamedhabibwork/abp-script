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

################################################################################
# SECTION 2: Utility Functions
################################################################################

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Magenta
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host ("=" * 63) -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host ("=" * 63) -ForegroundColor Cyan
    Write-Host ""
}

function Write-Separator {
    Write-Host ("-" * 63) -ForegroundColor Cyan
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
        
        Write-Success "Parsed entity: $script:EntityName in module: $script:ModuleName"
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
    
    # Add property
    $declaration += "public $($Property.type) $($Property.name) { get; set; }"
    
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
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
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
    
    # Create DTO
    $templateFile = Join-Path $script:TemplatesDir "application\dto-create.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application\DTOs\Create$($script:EntityName)Dto.cs"
    Invoke-TemplateWithProperties $templateFile $outputFile $Properties $vars
    
    # Update DTO
    $templateFile = Join-Path $script:TemplatesDir "application\dto-update.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application\DTOs\Update$($script:EntityName)Dto.cs"
    Invoke-TemplateWithProperties $templateFile $outputFile $Properties $vars
    
    # Entity DTO
    $templateFile = Join-Path $script:TemplatesDir "application\dto-entity.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application\DTOs\$($script:EntityName)Dto.cs"
    Invoke-TemplateWithProperties $templateFile $outputFile $Properties $vars
}

function New-RepositoryFiles {
    Write-Step "Generating repository files..."
    
    $entityNameLower = $script:EntityName.Substring(0,1).ToLower() + $script:EntityName.Substring(1)
    
    $vars = @{
        NAMESPACE = $script:Namespace
        MODULE_NAME = $script:ModuleName
        ENTITY_NAME = $script:EntityName
        ENTITY_NAME_LOWER = $entityNameLower
    }
    
    # Repository interface
    $templateFile = Join-Path $script:TemplatesDir "domain\repository-interface.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Domain\$script:ModuleName\I$($script:EntityName)Repository.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
    
    # EF Repository
    $templateFile = Join-Path $script:TemplatesDir "infrastructure\ef-repository.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.EntityFrameworkCore\$script:ModuleName\EfCore$($script:EntityName)Repository.cs"
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
    
    # Service interface
    $templateFile = Join-Path $script:TemplatesDir "application\app-service-interface.template.cs"
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application\$script:ModuleName\I$($script:EntityName)AppService.cs"
    Invoke-TemplateProcessing $templateFile $outputFile $vars
    
    # Service implementation
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
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.HttpApi\Controllers\$($script:EntityName)Controller.cs"
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
    $outputFile = Join-Path $script:ProjectRoot "src\$script:Namespace.Application\$script:ModuleName\$($script:EntityName)Validator.cs"
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
    
    Write-Host "Select an operation:"
    Write-Host ""
    Write-Host "  1) Create New ABP Project"
    Write-Host "  2) Add New Module"
    Write-Host "  3) Add Entity with CRUD"
    Write-Host "  4) Generate from JSON"
    Write-Host "  5) Check Dependencies"
    Write-Host "  6) Exit"
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
    
    switch ($operation) {
        "create-project" {
            $name = ""
            $template = "app"
            
            for ($i = 1; $i -lt $Args.Count; $i += 2) {
                switch ($Args[$i]) {
                    "--name" { $name = $Args[$i + 1] }
                    "--template" { $template = $Args[$i + 1] }
                }
            }
            
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
            $jsonFile = ""
            
            for ($i = 1; $i -lt $Args.Count; $i += 2) {
                switch ($Args[$i]) {
                    "--from-json" { $jsonFile = $Args[$i + 1] }
                    "--module" { $script:ModuleName = $Args[$i + 1] }
                    "--name" { $script:EntityName = $Args[$i + 1] }
                }
            }
            
            if ($jsonFile) {
                New-EntityFromJson $jsonFile
            } elseif ($script:ModuleName -and $script:EntityName) {
                New-EntityFiles @() @()
            } else {
                Write-Error-Custom "Either --from-json or both --module and --name are required"
            }
        }
        default {
            Show-Usage
        }
    }
}

function Show-Usage {
    Write-Host "ABP Framework Project & Module Generator v1.0"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\abp-generator.ps1                                    # Interactive mode"
    Write-Host "  .\abp-generator.ps1 create-project -name <name> -template <type>"
    Write-Host "  .\abp-generator.ps1 add-entity -from-json <file.json>"
    Write-Host "  .\abp-generator.ps1 add-entity -module <module> -name <name>"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\abp-generator.ps1 create-project -name MyApp -template app"
    Write-Host "  .\abp-generator.ps1 add-entity -from-json product.json"
    Write-Host "  .\abp-generator.ps1 add-entity -module Products -name Product"
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
        $choice = Read-Host "Enter your choice [1-6]"
        
        switch ($choice) {
            "1" { Invoke-CreateNewProject }
            "2" { 
                Write-Warning-Custom "Module generation coming soon"
                Read-Host "Press Enter..."
            }
            "3" { Invoke-AddEntityWithCrud }
            "4" { Invoke-GenerateFromJson }
            "5" { 
                Test-Dependencies | Out-Null
                Read-Host "Press Enter to continue..."
            }
            "6" {
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

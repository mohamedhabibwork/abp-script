# ABP Framework Project & Module Generator v1.0

A comprehensive all-in-one toolkit for ABP Framework development with complete ABP CLI integration, JSON entity support, relationship generation, and multi-tenancy detection.

## 🚀 Features

### Project Creation & Management
- ✅ **Application** - Full web application with layered architecture
- ✅ **Module** - Reusable module structure (NuGet package ready)
- ✅ **Microservice** - Microservice architecture with API Gateway
- ✅ **Console** - Console application with ABP integration
- ✅ **Package** - NuGet package project creation
- ✅ **Solution Initialization** - Initialize existing solutions with ABP
- ✅ **Update Solutions** - Update all ABP packages in a solution
- ✅ **Upgrade Solutions** - Upgrade to newer ABP versions
- ✅ **Clean Solutions** - Clean build artifacts and temporary files

### Entity Generation
- ✅ **JSON-based** - Define entities in JSON with properties and relationships
- ✅ **Interactive** - Generate entities interactively with prompts
- ✅ **CLI** - Command-line interface for automation
- ✅ **CRUD Operations** - Complete Create, Read, Update, Delete
- ✅ **Relationships** - ManyToOne, OneToMany, ManyToMany, OneToOne
- ✅ **Multi-tenancy** - Auto-detect and apply tenant isolation
- ✅ **Base Class Selection** - Choose from 15+ ABP entity base classes (Entity, AggregateRoot, Audited variants, Soft Delete)
- ✅ **Entity Tracking** - Track all generated files for easy cleanup and rollback
- ✅ **Cleanup Features** - Rollback, delete by name, list entities, clean all
- ✅ **Advanced Validation** - Regex patterns, async uniqueness checks, custom validators
- ✅ **Permission System** - Auto-generate permissions with `[Authorize]` attributes
- ✅ **Localization** - Generate localization keys for UI elements
- ✅ **API Documentation** - Swagger/OpenAPI attributes for comprehensive API docs
- ✅ **Comprehensive Tests** - Unit and integration tests for all layers
- ✅ **Audit Logging** - Configure entity change tracking

### Code Generation
- ✅ **Domain Layer** - Entities, repositories, domain services, events
- ✅ **Application Layer** - DTOs, services, AutoMapper profiles, validators (basic and advanced)
- ✅ **Infrastructure Layer** - EF configurations, repositories, seeders, audit logging
- ✅ **API Layer** - Controllers with RESTful endpoints, Swagger documentation
- ✅ **Events** - ETOs with event handlers
- ✅ **Permissions** - Permission definitions, permission names, permission providers
- ✅ **Localization** - Localization keys (JSON) for entities, properties, validations, messages
- ✅ **Tests** - Unit tests (AppService, Validator, Domain Manager), Integration tests
- ✅ **Proper Namespaces** - ABP standard layered architecture (`Application.Contracts`, `Application`, `Domain`, `EntityFrameworkCore`, `HttpApi`)

### ABP CLI Integration (40+ Commands)
- ✅ **Complete ABP CLI Support** - All ABP CLI commands available via interactive menu and CLI mode
- ✅ **Project Management** - Create, update, upgrade, and clean solutions
  - `new`, `new-module`, `new-package`, `init-solution`, `update`, `upgrade`, `clean`
- ✅ **Module Management** - Install, list, and manage ABP modules
  - `install-module`, `install-local-module`, `list-modules`, `list-templates`
- ✅ **Package Management** - Add packages and package references
  - `add-package`, `add-package-ref`
- ✅ **Source Code Management** - Get and add module source code
  - `get-source`, `add-source-code`, `list-module-sources`, `add-module-source`, `delete-module-source`
- ✅ **Proxy Generation** - Generate Angular and React Native proxies
  - `generate-proxy`, `remove-proxy`
- ✅ **Version Management** - Switch between stable, preview, nightly, and local versions
  - `switch-to-preview`, `switch-to-nightly`, `switch-to-stable`, `switch-to-local`
- ✅ **Authentication** - Login, logout, and manage ABP account
  - `login`, `login-info`, `logout`
- ✅ **Build & Bundle** - Bundle Blazor/MAUI apps and install client libraries
  - `bundle`, `install-libs`
- ✅ **Localization** - Translate ABP resources
  - `translate`
- ✅ **Kubernetes** - Connect and intercept Kubernetes services
  - `kube-connect`, `kube-intercept`
- ✅ **Utilities** - Check extensions, install old CLI, generate Razor pages
  - `check-extensions`, `install-old-cli`, `generate-razor-page`, `help`, `cli`
- ✅ **Direct Passthrough** - Unknown commands automatically pass through to ABP CLI

### Design Principles
- ✅ **SOLID Principles** - Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- ✅ **Clean Code** - Meaningful names, small methods, DRY, proper exception handling
- ✅ **Design Patterns** - Repository, Unit of Work, Domain-Driven Design, CQRS, Event-Driven

---

## 📋 Requirements

### Required
- **.NET SDK 8.0+** - [Download](https://dotnet.microsoft.com/download)
- **ABP CLI** - `dotnet tool install -g Volo.Abp.Cli`

### Recommended
- **jq** - For JSON parsing (bash)
  - macOS: `brew install jq`
  - Linux: `apt-get install jq` or `yum install jq`
  - Windows: Included in PowerShell (native JSON support)

---

## 🎯 Quick Start

### Quick Examples

**Ready-to-use example files are included:**

```bash
# Full-featured example (all advanced features enabled)
./abp-generator.sh add-entity --from-json examples/entity-advanced.json

# Simple example (basic features only)
./abp-generator.sh add-entity --from-json examples/entity-simple.json

# Various scenarios
./abp-generator.sh add-entity --from-json entity-definitions/simple-entity.json
./abp-generator.sh add-entity --from-json entity-definitions/entity-with-relations.json
./abp-generator.sh add-entity --from-json entity-definitions/multi-tenant-entity.json
```

**See [JSON Schema Documentation](JSON_SCHEMA.md) for complete schema reference.**

### Installation

1. **Install .NET SDK 8.0+** - [Download](https://dotnet.microsoft.com/download)
2. **Install ABP CLI:**
   ```bash
   dotnet tool install -g Volo.Abp.Cli
   ```
3. **Make scripts executable (Linux/macOS):**
   ```bash
   chmod +x abp-generator.sh abp-gen
   ```

### Interactive Mode

The easiest way to use the generator is through the interactive menu with **38 organized options**:

**Linux/macOS:**
```bash
./abp-generator.sh
```

**Windows:**
```powershell
.\abp-generator.ps1
```

**Universal Launcher (Unix):**
```bash
./abp-gen
```

#### Interactive Menu Structure

The interactive menu is organized into logical categories:

**PROJECT MANAGEMENT (Options 1-7)**
- 1) Create New ABP Project
- 2) Create New Module
- 3) Create New Package
- 4) Initialize Solution
- 5) Update Solution
- 6) Upgrade Solution
- 7) Clean Solution

**MODULE & PACKAGE MANAGEMENT (Options 8-13)**
- 8) Add Package
- 9) Add Package Reference
- 10) Install Module
- 11) Install Local Module
- 12) List Modules
- 13) List Templates

**SOURCE CODE MANAGEMENT (Options 14-18)**
- 14) Get Module Source
- 15) Add Source Code
- 16) List Module Sources
- 17) Add Module Source
- 18) Delete Module Source

**PROXY GENERATION (Options 19-20)**
- 19) Generate Proxy
- 20) Remove Proxy

**VERSION MANAGEMENT (Options 21-24)**
- 21) Switch to Preview
- 22) Switch to Nightly
- 23) Switch to Stable
- 24) Switch to Local

**ENTITY GENERATION - Custom (Options 25-26)**
- 25) Add Entity with CRUD (Full-featured with permissions, localization, advanced validation)
- 26) Generate from JSON (With support for all advanced options)

**AUTHENTICATION (Options 27-29)**
- 27) Login
- 28) Login Info
- 29) Logout

**BUILD & BUNDLE (Options 30-31)**
- 30) Bundle (Blazor/MAUI)
- 31) Install Libs

**LOCALIZATION (Option 32)**
- 32) Translate

**ENTITY CLEANUP (Options 39-42)**
- 39) Rollback Last Generated Entity
- 40) Delete Entity by Name
- 41) List Generated Entities
- 42) Clean All Generated Files

**UTILITIES (Options 33-38)**
- 33) Check Extensions
- 34) Install Old CLI
- 35) Generate Razor Page
- 36) Check Dependencies
- 37) ABP Help
- 38) ABP CLI Info

**EXIT (Option 99)**
- 99) Exit

### CLI Mode - Common Workflows

#### 1. Create a New ABP Application

**Using Custom Command:**
```bash
# Linux/macOS
./abp-generator.sh create-project --name MyApp --template app

# Windows
.\abp-generator.ps1 create-project -name MyApp -template app
```

**Using ABP CLI Directly:**
```bash
# Linux/macOS
./abp-generator.sh new --name MyApp --template app --database-provider ef --ui mvc

# Windows
.\abp-generator.ps1 new -name MyApp -template app -database-provider ef -ui mvc
```

**With Additional Options:**
```bash
# Create tiered application with MongoDB
./abp-generator.sh new --name MyApp --template app --database-provider mongodb --tiered

# Create Blazor Server application
./abp-generator.sh new --name MyApp --template app --ui blazor-server

# Create with specific ABP version
./abp-generator.sh new --name MyApp --template app --version 8.0.0
```

#### 2. Install ABP Modules

```bash
# Install Blogging module
./abp-generator.sh install-module --solution-name MyApp --module Volo.Blogging

# Install with specific version
./abp-generator.sh install-module --solution-name MyApp --module Volo.Blogging --version 8.0.0

# Install with source code
./abp-generator.sh add-package --project src/MyApp.Application --package Volo.Blogging --with-source-code

# List available modules
./abp-generator.sh list-modules
```

#### 3. Generate Entity from JSON

**Using Example Files:**

The generator includes ready-to-use example files:

```bash
# Use the advanced example (all features enabled)
./abp-generator.sh add-entity --from-json examples/entity-advanced.json

# Use the simple example (basic features only)
./abp-generator.sh add-entity --from-json examples/entity-simple.json

# Use entity definitions (various scenarios)
./abp-generator.sh add-entity --from-json entity-definitions/simple-entity.json
./abp-generator.sh add-entity --from-json entity-definitions/entity-with-relations.json
```

**Create Custom JSON file:** `my-entity.json`
```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Catalog",
  "entityName": "Product",
  "entityNamePlural": "Products",
  "baseClass": "FullAuditedAggregateRoot",
  "idType": "Guid",
  "dbContextName": "CatalogDbContext",
  "properties": [
    {
      "name": "Name",
      "type": "string",
      "required": true,
      "maxLength": 200,
      "validation": {
        "pattern": "alphanumeric",
        "asyncUnique": true
      }
    },
    {
      "name": "Price",
      "type": "decimal",
      "required": true,
      "validation": {
        "min": 0
      }
    }
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": true,
    "apiDocumentation": true,
    "comprehensiveTests": true,
    "auditLogging": true
  }
}
```

**Generate:**
```bash
# Linux/macOS
./abp-generator.sh add-entity --from-json my-entity.json

# Windows
.\abp-generator.ps1 add-entity -from-json my-entity.json
```

#### 4. Update and Upgrade Solutions

```bash
# Update solution packages
./abp-generator.sh update --solution-name MyApp

# Check for upgrades
./abp-generator.sh upgrade --solution-name MyApp --check

# Upgrade to latest version
./abp-generator.sh upgrade --solution-name MyApp

# Clean solution
./abp-generator.sh clean --solution-name MyApp
```

#### 5. Generate Client Proxies

```bash
# Generate Angular proxy
./abp-generator.sh generate-proxy --module app --target angular --output ./angular-proxy

# Generate React Native proxy
./abp-generator.sh generate-proxy --module app --target react-native
```

#### 6. Switch ABP Versions

```bash
# Switch to preview version
./abp-generator.sh switch-to-preview --solution-name MyApp

# Switch to stable version
./abp-generator.sh switch-to-stable --solution-name MyApp

# Switch to nightly build
./abp-generator.sh switch-to-nightly --solution-name MyApp
```

#### 7. Bundle Blazor/MAUI Applications

```bash
# Bundle Blazor WebAssembly app
./abp-generator.sh bundle --working-directory ./src/MyApp.Blazor --project-type webassembly

# Bundle MAUI Blazor app
./abp-generator.sh bundle --working-directory ./src/MyApp.Maui --project-type maui-blazor --force
```

#### 8. Authentication

```bash
# Login to ABP account (interactive)
./abp-generator.sh login

# Login with credentials
./abp-generator.sh login --username myuser --password mypass

# Check login status
./abp-generator.sh login-info

# Logout
./abp-generator.sh logout
```

#### 9. Source Code Management

```bash
# Get module source code
./abp-generator.sh get-source --module Volo.Blogging

# Get specific version
./abp-generator.sh get-source --module Volo.Blogging --version 8.0.0 --output-folder ./modules

# Add source code to solution
./abp-generator.sh add-source-code --solution-name MyApp --module Volo.Blogging

# List module sources
./abp-generator.sh list-module-sources

# Add custom module source
./abp-generator.sh add-module-source --name MySource --url https://github.com/myorg/abp-modules

# Delete module source
./abp-generator.sh delete-module-source --name MySource
```

#### 10. Package Management

```bash
# Add package to project
./abp-generator.sh add-package --project src/MyApp.Application --package Volo.Blogging

# Add package with source code
./abp-generator.sh add-package --project src/MyApp.Application --package Volo.Blogging --with-source-code

# Add package reference (for central package management)
./abp-generator.sh add-package-ref --project src/MyApp.Application --package Volo.Blogging --version 8.0.0
```

#### 11. Entity Cleanup (New in v1.0)

```bash
# Rollback last generated entity (undo)
./abp-generator.sh rollback

# Delete specific entity by name
./abp-generator.sh delete-entity --name Product

# List all generated entities
./abp-generator.sh list-entities

# Clean all generated files (caution: removes all tracked entities)
./abp-generator.sh clean-all
```

#### 12. Utilities

```bash
# Check ABP CLI extensions
./abp-generator.sh check-extensions

# Install old ABP CLI version
./abp-generator.sh install-old-cli --version 7.4.0

# Generate Razor page
./abp-generator.sh generate-razor-page --working-directory ./Views

# Get help for a specific command
./abp-generator.sh help new

# Get ABP CLI version info
./abp-generator.sh cli
```

#### 13. Kubernetes Integration

```bash
# Connect to Kubernetes cluster
./abp-generator.sh kube-connect --context my-cluster

# Connect with namespace
./abp-generator.sh kube-connect --context my-cluster --namespace production

# Intercept service
./abp-generator.sh kube-intercept --service my-service

# Intercept with options
./abp-generator.sh kube-intercept --service my-service --context my-cluster --port 8080
```

---

## 🎨 Advanced Features (NEW in v1.0)

### Cleanup & Entity Management

The generator now tracks all generated files, allowing you to easily manage and cleanup entities.

#### Entity Tracking

All generated entities are tracked in `generated-entities.json`:

```json
{
  "entities": [
    {
      "name": "Product",
      "module": "Catalog",
      "generatedAt": "2024-12-11T10:30:00Z",
      "files": [
        "src/MyApp.Domain/Catalog/Product.cs",
        "src/MyApp.Application.Contracts/Catalog/DTOs/ProductDto.cs",
        "src/MyApp.Application/Catalog/ProductAppService.cs",
        "..."
      ]
    }
  ]
}
```

#### Cleanup Commands

**Rollback Last Entity:**
```bash
./abp-generator.sh rollback
```
Undoes the last generated entity by deleting all its files.

**Delete Specific Entity:**
```bash
./abp-generator.sh delete-entity --name Product
```
Removes all files for a specific entity.

**List All Entities:**
```bash
./abp-generator.sh list-entities
```
Shows all tracked entities with generation timestamps.

**Clean All Generated Files:**
```bash
./abp-generator.sh clean-all
```
⚠️ **Caution:** Removes ALL tracked generated files.

### Advanced Validation

The generator can create advanced FluentValidation validators with:

- **Regex Patterns** - Email, phone, URL, alphanumeric, or custom regex
- **Async Validation** - Check uniqueness against database
- **Custom Validators** - Business rule validation
- **Conditional Validation** - If-then rules
- **Cross-Property Validation** - Multiple property validation

**Example JSON with Advanced Validation:**
```json
{
  "properties": [
    {
      "name": "Email",
      "type": "string",
      "required": true,
      "validation": {
        "pattern": "email",
        "asyncUnique": true
      }
    },
    {
      "name": "SKU",
      "type": "string",
      "required": true,
      "validation": {
        "pattern": "^[A-Z0-9-]+$",
        "asyncUnique": true,
        "customValidator": "SKUValidator"
      }
    },
    {
      "name": "Price",
      "type": "decimal",
      "required": true,
      "validation": {
        "min": 0,
        "max": 999999.99
      }
    }
  ],
  "options": {
    "advancedValidation": true
  }
}
```

**Generated Validator:**
```csharp
public class CreateProductDtoAdvancedValidator : AbstractValidator<CreateProductDto>
{
    private readonly IProductRepository _productRepository;

    public CreateProductDtoAdvancedValidator(IProductRepository productRepository)
    {
        _productRepository = productRepository;

        // Email with async uniqueness check
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MustAsync(BeUniqueEmailAsync)
            .WithMessage("Email already exists");

        // SKU with regex pattern
        RuleFor(x => x.SKU)
            .Matches(@"^[A-Z0-9-]+$")
            .WithMessage("SKU must contain only uppercase letters, numbers, and hyphens");

        // Price with range validation
        RuleFor(x => x.Price)
            .InclusiveBetween(0, 999999.99m);
    }

    private async Task<bool> BeUniqueEmailAsync(string email, CancellationToken cancellationToken)
    {
        var exists = await _productRepository.ExistsByEmailAsync(email, cancellationToken: cancellationToken);
        return !exists;
    }
}
```

### Permission System

Auto-generates permissions and applies `[Authorize]` attributes.

**Generated Permission Names:**
```csharp
public static class CatalogPermissions
{
    public const string GroupName = "Catalog";

    public static class Products
    {
        public const string Default = GroupName + ".Products";
        public const string Create = Default + ".Create";
        public const string Edit = Default + ".Edit";
        public const string Delete = Default + ".Delete";
    }
}
```

**Generated Permission Provider:**
```csharp
public class CatalogPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var catalogGroup = context.AddGroup(CatalogPermissions.GroupName, L("Permission:Catalog"));

        var productPermission = catalogGroup.AddPermission(
            CatalogPermissions.Products.Default, 
            L("Permission:Products"));
        productPermission.AddChild(
            CatalogPermissions.Products.Create, 
            L("Permission:Products.Create"));
        productPermission.AddChild(
            CatalogPermissions.Products.Edit, 
            L("Permission:Products.Edit"));
        productPermission.AddChild(
            CatalogPermissions.Products.Delete, 
            L("Permission:Products.Delete"));
    }
}
```

**Applied to AppService:**
```csharp
[Authorize]
public class ProductAppService : ApplicationService, IProductAppService
{
    [Authorize("Catalog.Products.Create")]
    public virtual async Task<ProductDto> CreateAsync(CreateProductDto input) { }

    [Authorize("Catalog.Products.Edit")]
    public virtual async Task<ProductDto> UpdateAsync(Guid id, UpdateProductDto input) { }

    [Authorize("Catalog.Products.Delete")]
    public virtual async Task DeleteAsync(Guid id) { }
}
```

### Localization

Generates localization keys for all entity elements.

**Generated Localization File (en.json):**
```json
{
  "culture": "en",
  "texts": {
    "Catalog:Product": "Product",
    "Catalog:Product:Name": "Name",
    "Catalog:Product:Price": "Price",
    "Catalog:Product:Create": "Create Product",
    "Catalog:Product:Edit": "Edit Product",
    "Catalog:Product:Delete": "Delete Product",
    "Catalog:Validation:Product:NameRequired": "Product name is required",
    "Catalog:Validation:Product:NameLength": "Product name must be between {0} and {1} characters",
    "Catalog:Validation:Product:PriceRange": "Price must be between {0} and {1}",
    "Catalog:Permission:Products": "Manage Products",
    "Catalog:Permission:Products.Create": "Create Products",
    "Catalog:Permission:Products.Edit": "Edit Products",
    "Catalog:Permission:Products.Delete": "Delete Products",
    "Catalog:Success:Product:Created": "Product created successfully",
    "Catalog:Error:Product:NotFound": "Product not found"
  }
}
```

### API Documentation (Swagger/OpenAPI)

Enhances controllers with comprehensive Swagger attributes.

**Generated Controller with Documentation:**
```csharp
[ApiExplorerSettings(GroupName = "Catalog")]
[SwaggerTag("Manage Products")]
public class ProductController : AbpController
{
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ProductDto), 200)]
    [ProducesResponseType(404)]
    [ProducesResponseType(401)]
    [SwaggerOperation(
        Summary = "Get Product by ID",
        Description = "Returns a single Product entity by its unique identifier.",
        OperationId = "Product.Get"
    )]
    public virtual async Task<ProductDto> GetAsync(Guid id) { }

    [HttpPost]
    [ProducesResponseType(typeof(ProductDto), 201)]
    [ProducesResponseType(400)]
    [ProducesResponseType(401)]
    [ProducesResponseType(403)]
    [SwaggerOperation(
        Summary = "Create a new Product",
        Description = "Creates a new Product entity with the provided data.",
        OperationId = "Product.Create"
    )]
    public virtual async Task<ProductDto> CreateAsync(CreateProductDto input) { }
}
```

### Comprehensive Tests

Generates complete test suites for all layers.

**AppService Unit Tests:**
```csharp
public class ProductAppServiceTests : CatalogApplicationTestBase
{
    [Fact]
    public async Task GetAsync_Should_Return_Entity_When_Exists() { }

    [Fact]
    public async Task GetListAsync_Should_Return_Paginated_Results() { }

    [Fact]
    public async Task CreateAsync_Should_Create_Entity_Successfully() { }

    [Fact]
    public async Task UpdateAsync_Should_Update_Entity_Successfully() { }

    [Fact]
    public async Task DeleteAsync_Should_Delete_Entity_Successfully() { }
}
```

**Validator Tests:**
```csharp
public class ProductValidatorTests : CatalogApplicationTestBase
{
    [Fact]
    public async Task Should_Have_Error_When_Name_Is_Empty() { }

    [Fact]
    public async Task Should_Have_Error_When_Name_Is_Too_Long() { }

    [Fact]
    public async Task Should_Have_Error_When_Name_Already_Exists() { }

    [Fact]
    public async Task Should_Not_Have_Error_When_Valid() { }
}
```

**Domain Manager Tests:**
```csharp
public class ProductManagerTests : CatalogDomainTestBase
{
    [Fact]
    public async Task CreateAsync_Should_Create_Entity_When_Name_Is_Unique() { }

    [Fact]
    public async Task CreateAsync_Should_Throw_When_Name_Already_Exists() { }

    [Fact]
    public async Task UpdateNameAsync_Should_Update_When_New_Name_Is_Unique() { }
}
```

### Audit Logging

Configures entity change tracking for audit purposes.

**Generated Audit Configuration:**
```csharp
public class ProductAuditConfiguration
{
    public static void Configure(EntityTypeBuilder<Product> builder)
    {
        // Enable change tracking for audit logging
        builder.Property(e => e.Name)
            .HasChangeTrackingEnabled(true)
            .HasComment("Entity name - tracked for audit");

        builder.Property(e => e.Price)
            .HasChangeTrackingEnabled(true)
            .HasComment("Product price - tracked for audit");

        // Audit-specific indexing
        builder.HasIndex(e => e.CreationTime)
            .HasDatabaseName("IX_Product_CreationTime");

        builder.HasIndex(e => e.LastModificationTime)
            .HasDatabaseName("IX_Product_LastModificationTime");
    }
}
```

### Enhanced CLI UX

The generator now features a beautiful, modern CLI interface with:

- ✅ **Emoji Icons** - Visual indicators for different operations
- ✅ **Color Coding** - Green for entity generation, yellow for warnings, red for cleanup
- ✅ **Progress Indicators** - Progress bars for long-running operations
- ✅ **Formatted Headers** - Box-drawn headers for sections
- ✅ **Better Error Messages** - Clear, actionable error messages
- ✅ **Input Validation** - Real-time validation with helpful feedback

**Example CLI Output:**
```
╔══════════════════════════════════════════════════════════════════════╗
║  ABP Framework Project & Module Generator v1.0                       ║
╚══════════════════════════════════════════════════════════════════════╝

🎯 Select an operation:
────────────────────────────────────────────────────────────────────────

▶ 🎨 ENTITY GENERATION (Custom)
  ✅ 25 Add Entity with CRUD
  ✅ 26 Generate from JSON

▶ 🗑️  ENTITY CLEANUP
  ⚠️  39 Rollback Last Generated Entity
  ⚠️  40 Delete Entity by Name
  ℹ️  41 List Generated Entities
  ❌ 42 Clean All Generated Files

⏳ [====================] 100% (5/5) Generating entity files...
✅ Entity 'Product' generated successfully!
```

### JSON Schema Extensions

See `JSON_SCHEMA.md` for complete documentation of the extended JSON schema, including:

- Advanced validation options
- Permission generation flags
- Localization settings
- API documentation options
- Test generation control
- Audit logging configuration

**Example Advanced Entity JSON:**
```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Catalog",
  "entityName": "Product",
  "baseClass": "FullAuditedAggregateRoot",
  "idType": "Guid",
  "dbContextName": "CatalogDbContext",
  "properties": [...],
  "relationships": [...],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": true,
    "apiDocumentation": true,
    "comprehensiveTests": true,
    "auditLogging": true
  }
}
```

See `examples/entity-advanced.json` and `examples/entity-simple.json` for complete working examples.

---

## 📦 JSON Entity Definition Format

### Simple Entity

```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Catalog",
  "entityName": "Product",
  "entityNamePlural": "Products",
  "baseClass": "FullAuditedAggregateRoot",
  "idType": "Guid",
  "dbContextName": "CatalogDbContext",
  "properties": [
    {
      "name": "Name",
      "type": "string",
      "required": true,
      "maxLength": 128
    },
    {
      "name": "Price",
      "type": "decimal",
      "required": true
    },
    {
      "name": "Stock",
      "type": "int",
      "required": true
    }
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": false,
    "apiDocumentation": true,
    "comprehensiveTests": false,
    "auditLogging": false
  }
}
```

**Note:**
- The `namespace` field is required - your project's root namespace (e.g., `MyCompany.MyProject`)
- The `moduleName` field is required - the module name (e.g., `Catalog`, `Blog`)
- The `entityName` field is required - the entity name in PascalCase (e.g., `Product`)
- The `entityNamePlural` field is optional - defaults to `entityName + "s"` (e.g., `Products`)
- The `baseClass` field is optional - defaults to `FullAuditedAggregateRoot` (without generic type - ID type is added automatically)
- The `idType` field is optional - defaults to `Guid`. Supported values: `Guid`, `long`, `int`
- The `dbContextName` field is optional - defaults to `moduleName + "DbContext"`
- When `idType` is specified, the generator automatically applies it to the base class (e.g., `FullAuditedAggregateRoot<Guid>`)
- See [Entity Base Classes](#entity-base-classes) section for all available options
- See `examples/entity-simple.json` for a minimal working example

### Entity with Relationships

```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Catalog",
  "entityName": "Product",
  "entityNamePlural": "Products",
  "baseClass": "FullAuditedAggregateRoot",
  "idType": "Guid",
  "dbContextName": "CatalogDbContext",
  "properties": [
    {
      "name": "Name",
      "type": "string",
      "required": true,
      "maxLength": 128,
      "minLength": 2
    },
    {
      "name": "SKU",
      "type": "string",
      "required": true,
      "maxLength": 50,
      "validation": {
        "pattern": "^[A-Z0-9-]+$",
        "asyncUnique": true
      }
    },
    {
      "name": "Price",
      "type": "decimal",
      "required": true,
      "validation": {
        "min": 0,
        "max": 999999
      }
    },
    {
      "name": "CategoryId",
      "type": "Guid",
      "required": true
    }
  ],
  "relationships": [
    {
      "name": "Category",
      "type": "ManyToOne",
      "relatedEntity": "Category",
      "foreignKey": "CategoryId",
      "required": true
    },
    {
      "name": "Tags",
      "type": "ManyToMany",
      "relatedEntity": "Tag",
      "joinTable": "ProductTags"
    },
    {
      "name": "Reviews",
      "type": "OneToMany",
      "relatedEntity": "ProductReview",
      "foreignKey": "ProductId"
    }
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": true,
    "apiDocumentation": true,
    "comprehensiveTests": true,
    "auditLogging": true
  }
}
```

**See `examples/entity-advanced.json` and `entity-definitions/entity-with-relations.json` for complete working examples.**

### Property Types

- `string`, `int`, `long`, `decimal`, `double`, `float`, `bool`
- `DateTime`, `DateTimeOffset`, `TimeSpan`
- `Guid`, `byte[]`
- Custom types (enums, value objects)

### Entity ID Types

The generator supports three ID types for entities:

- **Guid** (default) - Globally unique identifier, best for distributed systems
- **long** - 64-bit integer, efficient for high-performance scenarios
- **int** - 32-bit integer, suitable for smaller applications

You can specify the `idType` field in your JSON definition or select it interactively. The ID type will be applied to the base class (e.g., `FullAuditedAggregateRoot<Guid>` becomes `FullAuditedAggregateRoot<long>` if `idType` is `long`).

**Example:**
```json
{
  "entity": "Product",
  "module": "Catalog",
  "idType": "long",
  "baseClass": "FullAuditedAggregateRoot<long>",
  "properties": [...]
}
```

### Entity Base Classes

The generator supports all ABP Framework entity base classes. You can specify the `baseClass` field in your JSON definition or select it interactively. The base class will use the selected ID type. Available options:

**Basic Entities:**
- `Entity<T>` - Basic entity (T can be Guid, long, or int)
- `AggregateRoot<T>` - Aggregate root (T can be Guid, long, or int)
- `BasicAggregateRoot<T>` - Simplified aggregate root (T can be Guid, long, or int)

**Audited Entities:**
- `CreationAuditedEntity<T>` - Entity with creation audit
- `CreationAuditedAggregateRoot<T>` - Aggregate root with creation audit
- `AuditedEntity<T>` - Entity with creation and modification audit
- `AuditedAggregateRoot<T>` - Aggregate root with creation and modification audit
- `FullAuditedEntity<T>` - Entity with full audit (creation, modification, deletion)
- `FullAuditedAggregateRoot<T>` - Aggregate root with full audit (default)

**Soft Delete Entities:**
- `CreationAuditedEntity<T>, ISoftDelete` - Entity with creation audit and soft delete
- `CreationAuditedAggregateRoot<T>, ISoftDelete` - Aggregate root with creation audit and soft delete
- `AuditedEntity<T>, ISoftDelete` - Entity with audit and soft delete
- `AuditedAggregateRoot<T>, ISoftDelete` - Aggregate root with audit and soft delete
- `FullAuditedEntity<T>, ISoftDelete` - Entity with full audit and soft delete
- `FullAuditedAggregateRoot<T>, ISoftDelete` - Aggregate root with full audit and soft delete

**Examples:**

**Guid ID with Full Auditing (Default):**
```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Catalog",
  "entityName": "Product",
  "entityNamePlural": "Products",
  "baseClass": "FullAuditedAggregateRoot",
  "idType": "Guid",
  "dbContextName": "CatalogDbContext",
  "properties": [
    {"name": "Name", "type": "string", "required": true, "maxLength": 200},
    {"name": "Price", "type": "decimal", "required": true}
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": false,
    "apiDocumentation": true,
    "comprehensiveTests": false,
    "auditLogging": false
  }
}
```

**Long ID for High Performance:**
```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Sales",
  "entityName": "Order",
  "entityNamePlural": "Orders",
  "baseClass": "AuditedAggregateRoot",
  "idType": "long",
  "dbContextName": "SalesDbContext",
  "properties": [
    {"name": "OrderNumber", "type": "string", "required": true, "maxLength": 50},
    {"name": "TotalAmount", "type": "decimal", "required": true}
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": true,
    "apiDocumentation": true,
    "comprehensiveTests": true,
    "auditLogging": false
  }
}
```

**See `entity-definitions/entity-with-long-id.json` for a complete example.**

**Int ID for Simple Entities:**
```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Catalog",
  "entityName": "Category",
  "entityNamePlural": "Categories",
  "baseClass": "Entity",
  "idType": "int",
  "dbContextName": "CatalogDbContext",
  "properties": [
    {"name": "Name", "type": "string", "required": true, "maxLength": 128},
    {"name": "DisplayOrder", "type": "int", "required": true, "defaultValue": "0"}
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": true,
    "apiDocumentation": true,
    "comprehensiveTests": false,
    "auditLogging": false
  }
}
```

**See `entity-definitions/entity-with-int-id.json` for a complete example.**

**Complete Examples:**

See the example files in the `examples/` and `entity-definitions/` folders:

**Examples Folder (Recommended - Full-featured):**
- `examples/entity-advanced.json` - Complete example with all advanced features enabled (permissions, localization, validation, tests, audit logging)
- `examples/entity-simple.json` - Minimal example with basic features only

**Entity Definitions Folder (Various Scenarios):**
- `entity-definitions/simple-entity.json` - Basic entity with Guid ID and default base class
- `entity-definitions/entity-with-relations.json` - Entity with relationships (ManyToOne, OneToMany, ManyToMany)
- `entity-definitions/multi-tenant-entity.json` - Multi-tenant entity with tenant-scoped relationships
- `entity-definitions/entity-with-long-id.json` - Entity using long ID type for high-performance scenarios
- `entity-with-int-id.json` - Entity using int ID type for simple lookup tables

For more information about ABP entity base classes, see the [ABP Framework Entities Documentation](https://abp.io/docs/latest/framework/architecture/domain-driven-design/entities).

### Property Attributes

- **required** - `true/false` - Generates `[Required]` attribute
- **maxLength** - `number` - Generates `[StringLength(n)]` attribute
- **minLength** - `number` - Minimum length validation
- **unique** - `true/false` - Creates unique index
- **range** - `{min, max}` - Value range validation
- **default** - Default value for property

### Relationship Types

#### ManyToOne (N:1)
```json
{
  "name": "Category",
  "type": "ManyToOne",
  "relatedEntity": "Category",
  "foreignKey": "CategoryId",
  "required": true
}
```
- Adds foreign key property to current entity (must be defined in properties)
- Creates navigation property
- Applies tenant filtering automatically if multi-tenant is detected

**Note:** The foreign key property (e.g., `CategoryId`) must be defined in the `properties` array.

#### OneToMany (1:N)
```json
{
  "name": "Reviews",
  "type": "OneToMany",
  "relatedEntity": "ProductReview",
  "foreignKey": "ProductId"
}
```
- Creates collection navigation property (`ICollection<ProductReview> Reviews`)
- Foreign key is in the related entity (ProductReview.ProductId)
- No foreign key property needed in current entity

#### ManyToMany (N:M)
```json
{
  "name": "Tags",
  "type": "ManyToMany",
  "relatedEntity": "Tag",
  "joinTable": "ProductTags"
}
```
- Creates join table (`ProductTags`)
- Both-way navigation properties
- No foreign key properties needed

#### OneToOne (1:1)
```json
{
  "name": "Profile",
  "type": "OneToOne",
  "relatedEntity": "UserProfile",
  "foreignKey": "ProfileId",
  "required": false
}
```
- Foreign key with unique constraint
- Both-way navigation properties
- Foreign key property must be defined in properties

**See `entity-definitions/entity-with-relations.json` for complete examples of all relationship types.**

---

## 🏗️ Multi-Tenancy Support

### Auto-Detection

The generator automatically detects multi-tenancy by checking:
1. `IMultiTenant` interface in project
2. `TenantId` properties in entities
3. Multi-tenant module configuration

### Tenant-Aware Relationships

**When multi-tenancy is detected:**
```csharp
// Composite foreign key includes TenantId
builder.HasOne(x => x.Category)
    .WithMany()
    .HasForeignKey(x => new { x.CategoryId, x.TenantId })
    .IsRequired();
```

**When multi-tenancy is NOT detected:**
```csharp
// Simple foreign key
builder.HasOne(x => x.Category)
    .WithMany()
    .HasForeignKey(x => x.CategoryId)
    .IsRequired();
```

### Manual Override

```json
{
  "options": {
    "multiTenant": true  // Force multi-tenant
  }
}
```

---

## 📂 Project Structure

```
abp/
├── abp-generator.sh          # Bash script (Linux/macOS)
├── abp-generator.ps1         # PowerShell script (Windows)
├── abp-gen                   # Universal launcher (Unix)
├── README.md                 # This file
├── JSON_SCHEMA.md            # Complete JSON schema documentation
├── FEATURES.md               # Complete features list and implementation details
├── examples/                 # Recommended example files (full-featured)
│   ├── entity-advanced.json  # Complete example with all advanced features
│   └── entity-simple.json    # Minimal example with basic features
├── entity-definitions/       # JSON entity definitions (various scenarios)
│   ├── simple-entity.json              # Simple entity with Guid ID (default)
│   ├── entity-with-relations.json      # Entity with relationships (Guid ID)
│   ├── multi-tenant-entity.json        # Multi-tenant entity (Guid ID)
│   ├── entity-with-long-id.json        # Entity with long ID type (performance)
│   └── entity-with-int-id.json         # Entity with int ID type (simple)
└── templates/                # C# code templates
    ├── domain/               # Domain layer templates
    │   ├── entity.template.cs
    │   ├── aggregate-root.template.cs
    │   ├── value-object.template.cs
    │   ├── repository-interface.template.cs
    │   ├── domain-service.template.cs
    │   └── domain-event.template.cs
    ├── application/          # Application layer templates
    │   ├── dto-create.template.cs
    │   ├── dto-update.template.cs
    │   ├── dto-entity.template.cs
    │   ├── dto-list-input.template.cs
    │   ├── app-service-crud.template.cs
    │   ├── validator.template.cs
    │   └── automapper-profile.template.cs
    ├── infrastructure/       # Infrastructure layer templates
    │   ├── ef-repository.template.cs
    │   ├── ef-configuration.template.cs
    │   ├── dbcontext.template.cs
    │   └── seeder.template.cs
    ├── api/                  # API layer templates
    │   ├── controller-crud.template.cs
    │   └── module-class.template.cs
    ├── events/               # Event templates
    │   ├── eto.template.cs
    │   ├── domain-event-handler.template.cs
    │   └── local-event-handler.template.cs
    ├── permissions/          # Permission templates
    │   ├── permissions.template.cs
    │   └── permission-definition.template.cs
    ├── tests/                # Test templates
    │   ├── unit-test-service.template.cs
    │   ├── unit-test-domain.template.cs
    │   └── integration-test-api.template.cs
    └── shared/               # Shared templates
        └── entity-consts.template.cs
```

---

## 🎨 Template Customization

Templates are organized by layer for easy customization. You can modify any template to match your project's coding standards.

### Template Variables

All templates support variable replacement:

- `${NAMESPACE}` - Project namespace
- `${MODULE_NAME}` - Module name
- `${ENTITY_NAME}` - Entity name
- `${ENTITY_NAME_LOWER}` - Entity name (camelCase)
- `${ENTITY_NAME_PLURAL}` - Entity name (plural)
- `${PROPERTIES}` - Property declarations (from JSON)
- `${RELATIONSHIPS}` - Relationship configurations (from JSON)

### Example Template Modification

Edit `templates/domain/entity.template.cs`:
```csharp
// Add your custom base class
public class ${ENTITY_NAME} : YourCustomBaseClass<Guid>
{
    ${PROPERTIES}
    
    // Add your custom methods
    public void YourCustomMethod()
    {
        // Implementation
    }
}
```

---

## 🔧 Configuration

The generator saves configuration in `.abp-generator.json`:

```json
{
  "projectRoot": "/path/to/project",
  "namespace": "MyApp",
  "lastModified": "2024-01-15T10:30:00Z"
}
```

This allows the generator to remember your project settings.

---

## 📖 Examples

### Example 1: E-Commerce Product Catalog

**Use the provided example:**
```bash
# Use the advanced example with all features
./abp-generator.sh add-entity --from-json examples/entity-advanced.json

# Or use the simple example
./abp-generator.sh add-entity --from-json examples/entity-simple.json
```

**Or create custom JSON:** `product.json`
```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Catalog",
  "entityName": "Product",
  "entityNamePlural": "Products",
  "baseClass": "FullAuditedAggregateRoot",
  "idType": "Guid",
  "dbContextName": "CatalogDbContext",
  "properties": [
    {
      "name": "Name",
      "type": "string",
      "required": true,
      "maxLength": 200,
      "validation": {
        "pattern": "alphanumeric",
        "asyncUnique": true
      }
    },
    {
      "name": "SKU",
      "type": "string",
      "required": true,
      "maxLength": 50,
      "validation": {
        "pattern": "^[A-Z0-9-]+$",
        "asyncUnique": true
      }
    },
    {
      "name": "Price",
      "type": "decimal",
      "required": true,
      "validation": {
        "min": 0
      }
    },
    {
      "name": "Stock",
      "type": "int",
      "required": true,
      "defaultValue": "0",
      "validation": {
        "min": 0
      }
    },
    {
      "name": "IsAvailable",
      "type": "bool",
      "required": true,
      "defaultValue": "true"
    },
    {
      "name": "CategoryId",
      "type": "Guid",
      "required": true
    }
  ],
  "relationships": [
    {
      "name": "Category",
      "type": "ManyToOne",
      "relatedEntity": "Category",
      "foreignKey": "CategoryId",
      "required": true
    }
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": true,
    "apiDocumentation": true,
    "comprehensiveTests": true,
    "auditLogging": true
  }
}
```

**Generate:**
```bash
./abp-generator.sh add-entity --from-json product.json
```

### Example 2: Multi-Tenant Order System

**Use the provided example:**
```bash
./abp-generator.sh add-entity --from-json entity-definitions/multi-tenant-entity.json
```

**Or create custom JSON:** `order.json`
```json
{
  "namespace": "MyCompany.MyProject",
  "moduleName": "Sales",
  "entityName": "Order",
  "entityNamePlural": "Orders",
  "baseClass": "FullAuditedAggregateRoot",
  "idType": "Guid",
  "dbContextName": "SalesDbContext",
  "properties": [
    {
      "name": "OrderNumber",
      "type": "string",
      "required": true,
      "maxLength": 50,
      "validation": {
        "pattern": "^ORD-[0-9]{8}$",
        "asyncUnique": true
      }
    },
    {
      "name": "OrderDate",
      "type": "DateTime",
      "required": true
    },
    {
      "name": "TotalAmount",
      "type": "decimal",
      "required": true,
      "validation": {
        "min": 0
      }
    },
    {
      "name": "Status",
      "type": "string",
      "required": true,
      "maxLength": 50
    },
    {
      "name": "CustomerId",
      "type": "Guid",
      "required": true
    }
  ],
  "relationships": [
    {
      "name": "Customer",
      "type": "ManyToOne",
      "relatedEntity": "Customer",
      "foreignKey": "CustomerId",
      "required": true
    },
    {
      "name": "OrderItems",
      "type": "OneToMany",
      "relatedEntity": "OrderItem",
      "foreignKey": "OrderId"
    }
  ],
  "options": {
    "generatePermissions": true,
    "generateLocalization": true,
    "advancedValidation": true,
    "apiDocumentation": true,
    "comprehensiveTests": true,
    "auditLogging": true
  }
}
```

**Generate:**
```bash
./abp-generator.sh add-entity --from-json order.json
```

---

## 🧪 Testing

After generation, run your tests:

```bash
# Navigate to test project
cd test/YourProject.Application.Tests

# Run tests
dotnet test
```

The generator creates:
- **Unit tests** - For services and domain logic
- **Integration tests** - For API endpoints
- **Test fixtures** - For data seeding

---

## 🚨 Troubleshooting

### "jq not found" (Bash)
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# RHEL/CentOS
sudo yum install jq
```

### "ABP CLI not found"
```bash
dotnet tool install -g Volo.Abp.Cli
```

### Permission denied (Bash)
```bash
chmod +x abp-generator.sh abp-gen
```

### Templates not found
Ensure you're running the script from the `abp/` directory or templates are in the correct location.

---

## 🎯 Best Practices

### 1. Use JSON for Complex Entities
JSON definitions are easier to maintain, version control, and share with the team.

### 2. Start Simple, Add Complexity
Begin with basic properties, then add relationships and validations incrementally.

### 3. Follow ABP Conventions
- Use PascalCase for entity names
- Use plural names for collections
- Follow ABP's layered architecture

### 4. Leverage Multi-Tenancy
Let the generator detect and apply tenant isolation automatically.

### 5. Customize Templates
Adjust templates to match your team's coding standards before generating multiple entities.

### 6. Version Control JSON Definitions
Store entity definitions in your repository for documentation and regeneration.

---

## 📝 Complete CLI Reference

### Custom Commands (Generator-Specific)

These commands are specific to the generator and provide enhanced functionality beyond standard ABP CLI.

#### Create Project (Simplified)
```bash
# Bash
./abp-generator.sh create-project --name MyApp --template app

# PowerShell
.\abp-generator.ps1 create-project -name MyApp -template app
```

**Templates:** `app`, `module`, `microservice`, `console`

**Example:**
```bash
# Create a new application
./abp-generator.sh create-project --name ECommerceApp --template app

# Create a new module
./abp-generator.sh create-project --name PaymentModule --template module
```

#### Add Entity (Custom Generation)
```bash
# From JSON file
./abp-generator.sh add-entity --from-json entity-definitions/product.json

# With module and name
./abp-generator.sh add-entity --module Catalog --name Product
```

**Example:**
```bash
# Generate entity from JSON definition
./abp-generator.sh add-entity --from-json product.json

# Generate entity interactively
./abp-generator.sh add-entity --module Products --name Product
```

---

### ABP CLI Commands

All ABP CLI commands are available through the generator. The generator acts as a wrapper that:
- Provides interactive prompts for all commands
- Validates dependencies before execution
- Provides consistent error handling and output formatting
- Supports direct passthrough for any ABP CLI command

**Note:** You can use the same syntax as ABP CLI directly. The generator will pass through any command it doesn't recognize to the ABP CLI.

#### Project & Solution Management

**Create New Project**
```bash
# Create application with Entity Framework
./abp-generator.sh new --name MyApp --template app --database-provider ef

# Create application with MongoDB
./abp-generator.sh new --name MyApp --template app --database-provider mongodb

# Create with UI framework
./abp-generator.sh new --name MyApp --template app --ui mvc
./abp-generator.sh new --name MyApp --template app --ui blazor-server
./abp-generator.sh new --name MyApp --template app --ui blazor
./abp-generator.sh new --name MyApp --template app --ui angular

# Create tiered application
./abp-generator.sh new --name MyApp --template app --tiered

# Create with specific version
./abp-generator.sh new --name MyApp --template app --version 8.0.0

# Create module
./abp-generator.sh new-module --name MyModule --template module --database-provider ef

# Create package
./abp-generator.sh new-package --name MyPackage --template package
```

**Initialize Solution**
```bash
./abp-generator.sh init-solution --name MyApp --template app
```

**Update Solution**
```bash
./abp-generator.sh update
./abp-generator.sh update --solution-name MyApp --no-build
```

**Upgrade Solution**
```bash
./abp-generator.sh upgrade
./abp-generator.sh upgrade --solution-name MyApp --check
```

**Clean Solution**
```bash
./abp-generator.sh clean
./abp-generator.sh clean --solution-name MyApp
```

#### Module & Package Management

**Add Package**
```bash
./abp-generator.sh add-package --project src/MyApp.Application --package Volo.Blogging
./abp-generator.sh add-package --project src/MyApp.Application --package Volo.Blogging --with-source-code
```

**Add Package Reference**
```bash
./abp-generator.sh add-package-ref --project src/MyApp.Application --package Volo.Blogging
```

**Install Module**
```bash
./abp-generator.sh install-module --solution-name MyApp --module Volo.Blogging
./abp-generator.sh install-module --solution-name MyApp --module Volo.Blogging --version 8.0.0
```

**Install Local Module**
```bash
./abp-generator.sh install-local-module --solution-name MyApp --module /path/to/module
```

**List Modules**
```bash
./abp-generator.sh list-modules
./abp-generator.sh list-modules --include-prerelease
```

**List Templates**
```bash
./abp-generator.sh list-templates
```

#### Source Code Management

**Get Module Source**
```bash
./abp-generator.sh get-source --module Volo.Blogging
./abp-generator.sh get-source --module Volo.Blogging --version 8.0.0 --output-folder ./modules
```

**Add Source Code**
```bash
./abp-generator.sh add-source-code --solution-name MyApp --module Volo.Blogging
```

**List Module Sources**
```bash
./abp-generator.sh list-module-sources
```

**Add Module Source**
```bash
./abp-generator.sh add-module-source --name MySource --url https://github.com/myorg/abp-modules
```

**Delete Module Source**
```bash
./abp-generator.sh delete-module-source --name MySource
```

#### Proxy Generation

**Generate Proxy**
```bash
./abp-generator.sh generate-proxy --module app --output ./proxy
./abp-generator.sh generate-proxy --module app --target angular
./abp-generator.sh generate-proxy --module app --target react-native
```

**Remove Proxy**
```bash
./abp-generator.sh remove-proxy --module app
```

#### Version Management

**Switch to Preview**
```bash
./abp-generator.sh switch-to-preview
./abp-generator.sh switch-to-preview --solution-name MyApp
```

**Switch to Nightly**
```bash
./abp-generator.sh switch-to-nightly
./abp-generator.sh switch-to-nightly --solution-name MyApp
```

**Switch to Stable**
```bash
./abp-generator.sh switch-to-stable
./abp-generator.sh switch-to-stable --solution-name MyApp
```

**Switch to Local**
```bash
./abp-generator.sh switch-to-local
./abp-generator.sh switch-to-local --solution-name MyApp
```

#### Authentication

**Login**
```bash
./abp-generator.sh login
./abp-generator.sh login --username myuser --password mypass
```

**Login Info**
```bash
./abp-generator.sh login-info
```

**Logout**
```bash
./abp-generator.sh logout
```

#### Build & Bundle

**Bundle (Blazor/MAUI)**
```bash
./abp-generator.sh bundle
./abp-generator.sh bundle --working-directory ./src/MyApp.Blazor --force
./abp-generator.sh bundle --project-type webassembly
./abp-generator.sh bundle --project-type maui-blazor
```

**Install Libs**
```bash
./abp-generator.sh install-libs
./abp-generator.sh install-libs --working-directory ./src/MyApp.Web
```

#### Localization

**Translate**
```bash
./abp-generator.sh translate --culture en
./abp-generator.sh translate --culture tr --output ./translations
./abp-generator.sh translate --culture fr --all
```

#### Utilities

**Check Extensions**
```bash
./abp-generator.sh check-extensions
```

**Install Old CLI**
```bash
./abp-generator.sh install-old-cli
./abp-generator.sh install-old-cli --version 7.4.0
```

**Generate Razor Page**
```bash
./abp-generator.sh generate-razor-page
./abp-generator.sh generate-razor-page --working-directory ./Views
```

**Help**
```bash
./abp-generator.sh help
./abp-generator.sh help new
```

**CLI Info**
```bash
./abp-generator.sh cli
```

#### Kubernetes

**Kube Connect**
```bash
./abp-generator.sh kube-connect --context my-cluster
./abp-generator.sh kube-connect --context my-cluster --namespace production
```

**Kube Intercept**
```bash
./abp-generator.sh kube-intercept --service my-service
./abp-generator.sh kube-intercept --service my-service --context my-cluster --port 8080
```

---

## 🎓 Common Workflows & Examples

### Workflow 1: Create a New ABP Application from Scratch

```bash
# 1. Create the application
./abp-generator.sh new --name MyECommerceApp --template app --database-provider ef --ui mvc

# 2. Navigate to the project
cd MyECommerceApp

# 3. Install required modules
./abp-generator.sh install-module --solution-name MyECommerceApp --module Volo.Blogging
./abp-generator.sh install-module --solution-name MyECommerceApp --module Volo.FileManagement

# 4. Generate entities from JSON
./abp-generator.sh add-entity --from-json ../entity-definitions/product.json
./abp-generator.sh add-entity --from-json ../entity-definitions/category.json

# 5. Update solution packages
./abp-generator.sh update --solution-name MyECommerceApp

# 6. Run the application
cd src/MyECommerceApp.Web
dotnet run
```

### Workflow 2: Add Features to Existing Solution

```bash
# 1. Navigate to solution directory
cd MyExistingApp

# 2. Check current ABP version
./abp-generator.sh cli

# 3. Upgrade to latest stable
./abp-generator.sh switch-to-stable --solution-name MyExistingApp
./abp-generator.sh upgrade --solution-name MyExistingApp

# 4. Install new module
./abp-generator.sh install-module --solution-name MyExistingApp --module Volo.Chat

# 5. Add package with source code for customization
./abp-generator.sh add-package --project src/MyExistingApp.Application --package Volo.Blogging --with-source-code

# 6. Generate proxy for frontend
./abp-generator.sh generate-proxy --module app --target angular --output ../frontend/src/app/proxy
```

### Workflow 3: Multi-Tenant Application Setup

```bash
# 1. Create tiered application (required for multi-tenancy)
./abp-generator.sh new --name MultiTenantApp --template app --tiered --database-provider ef

# 2. Navigate to project
cd MultiTenantApp

# 3. Generate multi-tenant entities (with FullAuditedAggregateRoot for audit trail)
./abp-generator.sh add-entity --from-json ../entity-definitions/multi-tenant-entity.json

# 4. Update solution
./abp-generator.sh update --solution-name MultiTenantApp
```

### Workflow 4: Blazor Application Development

```bash
# 1. Create Blazor application
./abp-generator.sh new --name MyBlazorApp --template app --ui blazor --database-provider ef

# 2. Navigate to Blazor project
cd MyBlazorApp/src/MyBlazorApp.Blazor

# 3. Bundle scripts and styles
./abp-generator.sh bundle --working-directory . --project-type webassembly --force

# 4. Install client libraries
./abp-generator.sh install-libs --working-directory .
```

### Workflow 5: Module Development

```bash
# 1. Create module project
./abp-generator.sh new-module --name MyCustomModule --template module --database-provider ef

# 2. Navigate to module
cd MyCustomModule

# 3. Generate entities
./abp-generator.sh add-entity --from-json ../entity-definitions/module-entity.json

# 4. Build and pack
dotnet build
dotnet pack

# 5. Install in another solution
cd ../MyApp
./abp-generator.sh install-local-module --solution-name MyApp --module ../MyCustomModule
```

### Workflow 6: Localization & Translation

```bash
# 1. Generate translation files
./abp-generator.sh translate --culture tr --output ./localization/tr

# 2. Translate all resources
./abp-generator.sh translate --culture fr --all --output ./localization/fr

# 3. Update translations
./abp-generator.sh translate --culture es --output ./localization/es
```

---

### Interactive Mode Examples

All commands are also available through the interactive menu. Simply run the script without arguments:

```bash
# Linux/macOS
./abp-generator.sh

# Windows
.\abp-generator.ps1
```

#### Example Interactive Workflow

1. **Start the generator:**
   ```bash
   ./abp-generator.sh
   ```

2. **Create a new project:**
   - Select option `1` (Create New ABP Project)
   - Enter project name: `MyApp`
   - Select template: `app`
   - Select database provider: `ef`
   - Enable multi-tenancy: `y` or `n`

3. **Install a module:**
   - Select option `10` (Install Module)
   - Enter solution name: `MyApp`
   - Enter module name: `Volo.Blogging`
   - Enter version (optional): `8.0.0`
   - Skip DB migrations: `n`

4. **Generate an entity:**
   - Select option `25` (Add Entity with CRUD)
   - Choose to load from JSON or enter interactively
   - If interactive: Select ID type (Guid/long/int), then select base class
   - Follow prompts to define entity properties

5. **Update solution:**
   - Select option `5` (Update Solution)
   - Enter solution name: `MyApp`
   - Skip build: `n`

#### Interactive Menu Benefits

- **No need to remember command syntax** - All options are clearly listed
- **Guided prompts** - Step-by-step prompts for all parameters
- **Error prevention** - Validates inputs before execution
- **Context awareness** - Remembers current project settings
- **Helpful defaults** - Suggests sensible defaults for optional parameters

---

## 🌟 Features in Detail

### Generated Files

For each entity, the generator creates:

**Domain Layer:**
- `{Entity}.cs` - Entity class with properties and relationships
- `I{Entity}Repository.cs` - Repository interface
- `{Entity}DomainService.cs` - Domain service (optional)
- `{Entity}Consts.cs` - Constants for validation

**Application Layer:**
- `Create{Entity}Dto.cs` - Create DTO
- `Update{Entity}Dto.cs` - Update DTO
- `{Entity}Dto.cs` - Output DTO
- `I{Entity}AppService.cs` - Service interface
- `{Entity}AppService.cs` - Service implementation
- `{Entity}Validator.cs` - FluentValidation rules
- `{Entity}AutoMapperProfile.cs` - AutoMapper configuration

**Infrastructure Layer:**
- `EfCore{Entity}Repository.cs` - EF Core repository
- `{Entity}Configuration.cs` - EF Core fluent configuration
- `{Entity}DataSeeder.cs` - Data seeder

**API Layer:**
- `{Entity}Controller.cs` - RESTful API controller

**Tests:**
- `{Entity}AppServiceTests.cs` - Service unit tests
- `{Entity}DomainTests.cs` - Domain unit tests
- `{Entity}ApiTests.cs` - API integration tests

---

## 🔒 Security

The generator follows ABP's security best practices:
- ✅ Permission-based authorization
- ✅ Input validation with DTOs
- ✅ Audit logging (CreationTime, ModificationTime, etc.)
- ✅ Soft delete support
- ✅ Tenant isolation in multi-tenant scenarios

---

## 🤝 Contributing

This is a tool designed for internal use. If you want to customize:

1. Fork or copy the repository
2. Modify templates in `templates/`
3. Adjust scripts for your needs
4. Share improvements with your team

---

## 📄 License

This generator is provided as-is for ABP Framework development. ABP Framework itself is licensed under LGPL-3.0.

---

## 📞 Support

For ABP Framework questions:
- Documentation: https://docs.abp.io
- GitHub: https://github.com/abpframework/abp
- Community: https://community.abp.io

For generator issues:
- Check template files in `templates/`
- Verify JSON format matches examples
- Ensure all dependencies are installed

---

## ✨ Version History

### v1.0 (Current) - Complete ABP CLI Integration

**Major Features:**

#### ABP CLI Integration (40+ Commands)
- ✅ **Complete Command Coverage** - All ABP CLI commands available
  - Project: `new`, `new-module`, `new-package`, `init-solution`, `update`, `upgrade`, `clean`
  - Modules: `install-module`, `install-local-module`, `list-modules`, `list-templates`
  - Packages: `add-package`, `add-package-ref`
  - Source: `get-source`, `add-source-code`, `list-module-sources`, `add-module-source`, `delete-module-source`
  - Proxy: `generate-proxy`, `remove-proxy`
  - Version: `switch-to-preview`, `switch-to-nightly`, `switch-to-stable`, `switch-to-local`
  - Auth: `login`, `login-info`, `logout`
  - Build: `bundle`, `install-libs`
  - Localization: `translate`
  - Kubernetes: `kube-connect`, `kube-intercept`
  - Utils: `check-extensions`, `install-old-cli`, `generate-razor-page`, `help`, `cli`

#### Enhanced User Experience
- ✅ **Interactive Menu** - 38 organized menu options with categories
- ✅ **CLI Mode** - Direct command-line access to all features
- ✅ **Direct Passthrough** - Unknown commands automatically pass to ABP CLI
- ✅ **Error Handling** - Comprehensive validation and error messages
- ✅ **Dependency Checking** - Validates ABP CLI and .NET SDK before execution

#### Cross-Platform Support
- ✅ **PowerShell Script** - Full Windows support with PowerShell 5.1+
- ✅ **Bash Script** - Full Linux/macOS support with bash 4.0+
- ✅ **Universal Launcher** - Auto-detects platform and runs appropriate script
- ✅ **Feature Parity** - Identical functionality across all platforms

#### Entity Generation (Custom Features)
- ✅ **JSON-based Definitions** - Define entities with properties and relationships
- ✅ **Interactive Generation** - Step-by-step entity creation
- ✅ **Relationship Support** - ManyToOne, OneToMany, ManyToMany, OneToOne
- ✅ **Multi-tenancy Detection** - Automatic tenant isolation configuration
- ✅ **CRUD Operations** - Complete Create, Read, Update, Delete generation
- ✅ **Code Templates** - Organized by layer (Domain, Application, Infrastructure, API)
- ✅ **Validation** - FluentValidation rules generation
- ✅ **Testing** - Unit and integration test generation

#### Project Management
- ✅ **Multiple Templates** - Application, Module, Microservice, Console, Package
- ✅ **Database Providers** - Entity Framework Core, MongoDB
- ✅ **UI Frameworks** - MVC, Blazor Server, Blazor WebAssembly, Angular
- ✅ **Solution Management** - Update, upgrade, and clean operations
- ✅ **Version Control** - Switch between stable, preview, nightly, and local versions

#### Developer Experience
- ✅ **Configuration Persistence** - Remembers project settings in `.abp-generator.json`
- ✅ **Template Customization** - Easy-to-modify templates organized by layer
- ✅ **Comprehensive Documentation** - Detailed README with examples
- ✅ **Help System** - Built-in help for all commands

---

**Happy Coding with ABP Framework! 🚀**

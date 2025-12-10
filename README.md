# ABP Framework Project & Module Generator v1.0

A comprehensive all-in-one toolkit for ABP Framework development with JSON entity support, relationship generation, and multi-tenancy detection.

## 🚀 Features

### Project Creation
- ✅ **Application** - Full web application with layered architecture
- ✅ **Module** - Reusable module structure (NuGet package ready)
- ✅ **Microservice** - Microservice architecture with API Gateway
- ✅ **Console** - Console application with ABP integration

### Entity Generation
- ✅ **JSON-based** - Define entities in JSON with properties and relationships
- ✅ **Interactive** - Generate entities interactively with prompts
- ✅ **CLI** - Command-line interface for automation
- ✅ **CRUD Operations** - Complete Create, Read, Update, Delete
- ✅ **Relationships** - ManyToOne, OneToMany, ManyToMany, OneToOne
- ✅ **Multi-tenancy** - Auto-detect and apply tenant isolation

### Code Generation
- ✅ **Domain Layer** - Entities, repositories, domain services, events
- ✅ **Application Layer** - DTOs, services, AutoMapper profiles, validators
- ✅ **Infrastructure Layer** - EF configurations, repositories, seeders
- ✅ **API Layer** - Controllers with RESTful endpoints
- ✅ **Events** - ETOs with event handlers
- ✅ **Permissions** - Permission definitions
- ✅ **Tests** - Unit and integration tests

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

### Interactive Mode

**Linux/macOS:**
```bash
./abp-generator.sh
```

**Windows:**
```powershell
.\abp-generator.ps1
```

### CLI Mode

#### Create a New Project
```bash
# Linux/macOS
./abp-generator.sh create-project --name MyApp --template app

# Windows
.\abp-generator.ps1 create-project -name MyApp -template app
```

#### Generate Entity from JSON
```bash
# Linux/macOS
./abp-generator.sh add-entity --from-json entity-definitions/product.json

# Windows
.\abp-generator.ps1 add-entity -from-json entity-definitions\product.json
```

#### Generate Entity via CLI
```bash
# Linux/macOS
./abp-generator.sh add-entity --module Products --name Product

# Windows
.\abp-generator.ps1 add-entity -module Products -name Product
```

---

## 📦 JSON Entity Definition Format

### Simple Entity

```json
{
  "entity": "Product",
  "module": "Catalog",
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
  ]
}
```

### Entity with Relationships

```json
{
  "entity": "Product",
  "module": "Catalog",
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
      "unique": true,
      "maxLength": 50
    },
    {
      "name": "Price",
      "type": "decimal",
      "required": true,
      "range": {
        "min": 0,
        "max": 999999
      }
    }
  ],
  "relationships": [
    {
      "name": "Category",
      "type": "ManyToOne",
      "entity": "Category",
      "foreignKey": "CategoryId",
      "required": true,
      "tenantScoped": true
    },
    {
      "name": "Tags",
      "type": "ManyToMany",
      "entity": "Tag",
      "joinTable": "ProductTags"
    },
    {
      "name": "Reviews",
      "type": "OneToMany",
      "entity": "ProductReview",
      "foreignKey": "ProductId"
    }
  ],
  "options": {
    "generateSeeder": true,
    "generateTests": true,
    "generateValidation": true,
    "generateEvents": ["Created", "Updated", "Deleted", "PriceChanged"],
    "multiTenant": "auto"
  }
}
```

### Property Types

- `string`, `int`, `long`, `decimal`, `double`, `float`, `bool`
- `DateTime`, `DateTimeOffset`, `TimeSpan`
- `Guid`, `byte[]`
- Custom types (enums, value objects)

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
  "entity": "Category",
  "foreignKey": "CategoryId",
  "required": true,
  "tenantScoped": true
}
```
- Adds foreign key to current entity
- Creates navigation property
- Applies tenant filtering if multi-tenant

#### OneToMany (1:N)
```json
{
  "name": "Reviews",
  "type": "OneToMany",
  "entity": "ProductReview",
  "foreignKey": "ProductId"
}
```
- Creates collection navigation property
- Foreign key in related entity

#### ManyToMany (N:M)
```json
{
  "name": "Tags",
  "type": "ManyToMany",
  "entity": "Tag",
  "joinTable": "ProductTags"
}
```
- Creates join table
- Both-way navigation properties

#### OneToOne (1:1)
```json
{
  "name": "Profile",
  "type": "OneToOne",
  "entity": "UserProfile",
  "foreignKey": "ProfileId",
  "required": false
}
```
- Foreign key with unique constraint
- Both-way navigation properties

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
├── entity-definitions/       # JSON entity definitions
│   ├── simple-entity.json
│   ├── entity-with-relations.json
│   └── multi-tenant-entity.json
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

**Create JSON:** `product.json`
```json
{
  "entity": "Product",
  "module": "Catalog",
  "properties": [
    {"name": "Name", "type": "string", "required": true, "maxLength": 200},
    {"name": "SKU", "type": "string", "required": true, "unique": true, "maxLength": 50},
    {"name": "Price", "type": "decimal", "required": true, "range": {"min": 0}},
    {"name": "Stock", "type": "int", "required": true, "default": 0},
    {"name": "IsAvailable", "type": "bool", "required": true, "default": true}
  ],
  "relationships": [
    {
      "name": "Category",
      "type": "ManyToOne",
      "entity": "Category",
      "foreignKey": "CategoryId",
      "required": true
    }
  ],
  "options": {
    "generateSeeder": true,
    "generateTests": true,
    "generateValidation": true,
    "generateEvents": ["Created", "StockChanged", "PriceChanged"]
  }
}
```

**Generate:**
```bash
./abp-generator.sh add-entity --from-json product.json
```

### Example 2: Multi-Tenant Order System

**Create JSON:** `order.json`
```json
{
  "entity": "Order",
  "module": "Sales",
  "properties": [
    {"name": "OrderNumber", "type": "string", "required": true, "unique": true, "maxLength": 50},
    {"name": "OrderDate", "type": "DateTime", "required": true},
    {"name": "TotalAmount", "type": "decimal", "required": true},
    {"name": "Status", "type": "string", "required": true, "maxLength": 50}
  ],
  "relationships": [
    {
      "name": "Customer",
      "type": "ManyToOne",
      "entity": "Customer",
      "foreignKey": "CustomerId",
      "required": true,
      "tenantScoped": true
    },
    {
      "name": "OrderItems",
      "type": "OneToMany",
      "entity": "OrderItem",
      "foreignKey": "OrderId"
    }
  ],
  "options": {
    "generateSeeder": true,
    "generateTests": true,
    "multiTenant": true
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

## 📝 CLI Reference

### Commands

#### Create Project
```bash
# Bash
./abp-generator.sh create-project --name <name> --template <type>

# PowerShell
.\abp-generator.ps1 create-project -name <name> -template <type>
```

**Templates:** `app`, `module`, `microservice`, `console`

#### Add Entity
```bash
# From JSON
./abp-generator.sh add-entity --from-json <file.json>

# Interactive
./abp-generator.sh add-entity --module <module> --name <name>
```

#### Check Dependencies
```bash
./abp-generator.sh  # Select option 5 in menu
```

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

### v1.0 (Current)
- ✅ Consolidated single-file scripts (bash + PowerShell)
- ✅ JSON entity definitions with properties
- ✅ Relationship support (ManyToOne, OneToMany, ManyToMany, OneToOne)
- ✅ Multi-tenancy auto-detection
- ✅ Organized templates by layer
- ✅ Interactive and CLI modes
- ✅ Cross-platform support (Windows, macOS, Linux)

---

**Happy Coding with ABP Framework! 🚀**

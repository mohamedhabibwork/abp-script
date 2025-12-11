# Example Entity Definitions

This folder contains ready-to-use example JSON files demonstrating the ABP Generator's capabilities.

## 📁 Files

### `entity-advanced.json`
**Complete example with all advanced features enabled.**

This example demonstrates:
- ✅ All property types (string, decimal, int, bool, DateTime, Guid)
- ✅ Advanced validation (regex patterns, async uniqueness checks)
- ✅ Relationships (ManyToOne)
- ✅ All feature options enabled:
  - Permissions generation
  - Localization keys
  - Advanced validation
  - API documentation (Swagger)
  - Comprehensive tests
  - Audit logging

**Use Case:** Production-ready entity with full CRUD system

**Usage:**
```bash
./abp-generator.sh add-entity --from-json examples/entity-advanced.json
```

### `entity-simple.json`
**Minimal example with basic features only.**

This example demonstrates:
- ✅ Basic properties (string, bool)
- ✅ Simple validation (required, maxLength)
- ✅ Minimal feature set:
  - API documentation only
  - No permissions
  - No localization
  - No advanced validation
  - No tests
  - No audit logging

**Use Case:** Quick prototyping or simple entities

**Usage:**
```bash
./abp-generator.sh add-entity --from-json examples/entity-simple.json
```

## 🎯 When to Use Each Example

### Use `entity-advanced.json` when:
- Building production applications
- You need full CRUD with permissions
- You want comprehensive validation
- You need localization support
- You want complete test coverage
- You need audit logging

### Use `entity-simple.json` when:
- Quick prototyping
- Simple lookup tables
- Internal-only entities
- Minimal requirements
- Learning the generator

## 📚 Additional Examples

For more scenarios, see the `entity-definitions/` folder:
- `simple-entity.json` - Basic entity with Guid ID
- `entity-with-relations.json` - Entity with all relationship types
- `multi-tenant-entity.json` - Multi-tenant entity
- `entity-with-long-id.json` - High-performance entity with long ID
- `entity-with-int-id.json` - Simple entity with int ID

## 🔧 Customization

You can copy any example file and modify it for your needs:

```bash
# Copy the advanced example
cp examples/entity-advanced.json my-product.json

# Edit with your favorite editor
nano my-product.json

# Generate
./abp-generator.sh add-entity --from-json my-product.json
```

## 📖 Schema Reference

For complete JSON schema documentation, see:
- [JSON_SCHEMA.md](../JSON_SCHEMA.md) - Complete schema reference
- [README.md](../README.md) - User guide and examples

## 💡 Tips

1. **Start Simple:** Begin with `entity-simple.json` to understand the basics
2. **Add Complexity:** Gradually add features as needed
3. **Use Advanced:** For production, use `entity-advanced.json` as a template
4. **Version Control:** Store your JSON definitions in source control
5. **Documentation:** Use JSON comments (if supported) or separate docs to explain business rules

## 🚀 Next Steps

1. Try generating an entity from an example
2. Review the generated code
3. Customize the templates if needed
4. Create your own entity definitions
5. Share examples with your team

---

**Happy Generating! 🎉**


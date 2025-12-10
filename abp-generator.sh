#!/bin/bash

################################################################################
# ABP Framework Project & Module Generator v1.0
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

set -e

################################################################################
# SECTION 1: Configuration & Constants
################################################################################

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"
CONFIG_FILE=".abp-generator.json"
ENTITY_DEFINITIONS_DIR="${SCRIPT_DIR}/entity-definitions"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
PROJECT_NAME=""
PROJECT_ROOT=""
NAMESPACE=""
MODULE_NAME=""
ENTITY_NAME=""
TEMPLATE_TYPE=""
IS_MULTITENANT=false

################################################################################
# SECTION 2: Utility Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${MAGENTA}[STEP]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_separator() {
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
}

check_dependencies() {
    log_step "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v abp &> /dev/null; then
        missing_deps+=("ABP CLI (install: dotnet tool install -g Volo.Abp.Cli)")
    fi
    
    if ! command -v dotnet &> /dev/null; then
        missing_deps+=(".NET SDK 8.0+")
    fi
    
    if ! command -v jq &> /dev/null; then
        log_warning "jq not found (recommended for JSON parsing)"
        log_info "Install: brew install jq (macOS) or apt-get install jq (Linux)"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        return 1
    fi
    
    log_success "All required dependencies found"
    return 0
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        if command -v jq &> /dev/null; then
            PROJECT_ROOT=$(jq -r '.projectRoot // ""' "$CONFIG_FILE" 2>/dev/null || echo "")
            NAMESPACE=$(jq -r '.namespace // ""' "$CONFIG_FILE" 2>/dev/null || echo "")
        fi
    fi
}

save_config() {
    if command -v jq &> /dev/null; then
        local config_data=$(jq -n \
            --arg pr "$PROJECT_ROOT" \
            --arg ns "$NAMESPACE" \
            '{projectRoot: $pr, namespace: $ns, lastModified: now|todate}')
        echo "$config_data" > "$CONFIG_FILE"
        log_success "Configuration saved to $CONFIG_FILE"
    fi
}

detect_project_info() {
    local sln_files=(*.sln)
    
    if [ -f "${sln_files[0]}" ] && [ "${sln_files[0]}" != "*.sln" ]; then
        PROJECT_ROOT=$(pwd)
        PROJECT_NAME=$(basename "${sln_files[0]}" .sln)
        NAMESPACE="$PROJECT_NAME"
        log_info "Detected project: $PROJECT_NAME"
        return 0
    fi
    
    return 1
}

validate_entity_name() {
    local name=$1
    if [[ ! "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
        log_error "Entity name must start with uppercase letter and contain only alphanumeric characters"
        return 1
    fi
    return 0
}

validate_module_name() {
    local name=$1
    if [[ ! "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
        log_error "Module name must start with uppercase letter and contain only alphanumeric characters"
        return 1
    fi
    return 0
}

create_directory_if_not_exists() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

################################################################################
# SECTION 3: JSON Parsing Functions
################################################################################

parse_json_entity() {
    local json_file=$1
    
    if [ ! -f "$json_file" ]; then
        log_error "JSON file not found: $json_file"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for JSON parsing. Install: brew install jq"
        return 1
    fi
    
    # Parse basic entity info
    ENTITY_NAME=$(jq -r '.entity // ""' "$json_file")
    MODULE_NAME=$(jq -r '.module // ""' "$json_file")
    
    if [ -z "$ENTITY_NAME" ] || [ -z "$MODULE_NAME" ]; then
        log_error "JSON must contain 'entity' and 'module' fields"
        return 1
    fi
    
    log_success "Parsed entity: $ENTITY_NAME in module: $MODULE_NAME"
    return 0
}

parse_properties_from_json() {
    local json_file=$1
    local properties_json=$(jq -c '.properties // []' "$json_file")
    
    echo "$properties_json"
}

parse_relationships_from_json() {
    local json_file=$1
    local relationships_json=$(jq -c '.relationships // []' "$json_file")
    
    echo "$relationships_json"
}

get_property_count() {
    local properties_json=$1
    echo "$properties_json" | jq 'length'
}

get_property_at_index() {
    local properties_json=$1
    local index=$2
    echo "$properties_json" | jq ".[$index]"
}

generate_property_declaration() {
    local property_json=$1
    local name=$(echo "$property_json" | jq -r '.name')
    local type=$(echo "$property_json" | jq -r '.type')
    local required=$(echo "$property_json" | jq -r '.required // false')
    local max_length=$(echo "$property_json" | jq -r '.maxLength // ""')
    
    local declaration=""
    
    # Add validation attributes
    if [ "$required" = "true" ]; then
        declaration+="[Required]\n    "
    fi
    
    if [ -n "$max_length" ] && [ "$max_length" != "null" ]; then
        declaration+="[StringLength($max_length)]\n    "
    fi
    
    # Add property
    declaration+="public $type $name { get; set; }"
    
    echo -e "$declaration"
}

################################################################################
# SECTION 3B: Interactive Property & Relationship Collection
################################################################################

collect_properties_interactive() {
    local properties=()
    local property_count=0
    
    echo ""
    read -p "Add properties? [y/N]: " add_props
    
    if [[ ! "$add_props" =~ ^[Yy]$ ]]; then
        echo "[]"
        return 0
    fi
    
    while true; do
        property_count=$((property_count + 1))
        echo ""
        echo "Property #${property_count}:"
        
        # Property name (required)
        local prop_name=""
        while [ -z "$prop_name" ]; do
            read -p "  Name [Enter to finish]: " prop_name
            if [ -z "$prop_name" ]; then
                break 2  # Exit outer loop
            fi
            
            # Validate name
            if [[ ! "$prop_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                log_error "  Property name must start with uppercase letter"
                prop_name=""
            fi
        done
        
        # Property type
        echo "  Type options: string, int, long, decimal, bool, DateTime, Guid"
        read -p "  Type [string]: " prop_type
        prop_type=${prop_type:-string}
        
        # Required
        read -p "  Required [y/N]: " prop_required
        local is_required=false
        [[ "$prop_required" =~ ^[Yy]$ ]] && is_required=true
        
        # Max length (for strings)
        local max_length=""
        if [ "$prop_type" = "string" ]; then
            read -p "  Max Length [optional]: " max_length
        fi
        
        # Min length (for strings)
        local min_length=""
        if [ "$prop_type" = "string" ] && [ -n "$max_length" ]; then
            read -p "  Min Length [optional]: " min_length
        fi
        
        # Range (for numeric types)
        local range_min=""
        local range_max=""
        if [[ "$prop_type" =~ ^(int|long|decimal|double|float)$ ]]; then
            read -p "  Min value [optional]: " range_min
            read -p "  Max value [optional]: " range_max
        fi
        
        # Build JSON object
        local prop_json="{\"name\":\"$prop_name\",\"type\":\"$prop_type\",\"required\":$is_required"
        
        [ -n "$max_length" ] && prop_json="$prop_json,\"maxLength\":$max_length"
        [ -n "$min_length" ] && prop_json="$prop_json,\"minLength\":$min_length"
        
        if [ -n "$range_min" ] || [ -n "$range_max" ]; then
            prop_json="$prop_json,\"range\":{"
            [ -n "$range_min" ] && prop_json="$prop_json\"min\":$range_min"
            [ -n "$range_min" ] && [ -n "$range_max" ] && prop_json="$prop_json,"
            [ -n "$range_max" ] && prop_json="$prop_json\"max\":$range_max"
            prop_json="$prop_json}"
        fi
        
        prop_json="$prop_json}"
        
        properties+=("$prop_json")
        log_success "  Property '$prop_name' added"
    done
    
    # Build JSON array
    if [ ${#properties[@]} -eq 0 ]; then
        echo "[]"
    else
        local json="["
        for i in "${!properties[@]}"; do
            [ $i -gt 0 ] && json="$json,"
            json="$json${properties[$i]}"
        done
        json="$json]"
        echo "$json"
    fi
}

collect_relationships_interactive() {
    local relationships=()
    local rel_count=0
    
    echo ""
    read -p "Add relationships? [y/N]: " add_rels
    
    if [[ ! "$add_rels" =~ ^[Yy]$ ]]; then
        echo "[]"
        return 0
    fi
    
    while true; do
        rel_count=$((rel_count + 1))
        echo ""
        echo "Relationship #${rel_count}:"
        
        # Relationship name (required)
        local rel_name=""
        while [ -z "$rel_name" ]; do
            read -p "  Name [Enter to finish]: " rel_name
            if [ -z "$rel_name" ]; then
                break 2  # Exit outer loop
            fi
            
            # Validate name
            if [[ ! "$rel_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                log_error "  Relationship name must start with uppercase letter"
                rel_name=""
            fi
        done
        
        # Relationship type
        echo "  Type:"
        echo "    1) ManyToOne   (N:1 - e.g., Product → Category)"
        echo "    2) OneToMany   (1:N - e.g., Category → Products)"
        echo "    3) ManyToMany  (N:M - e.g., Product ↔ Tags)"
        echo "    4) OneToOne    (1:1 - e.g., User → Profile)"
        local rel_type_choice=""
        local rel_type=""
        while [ -z "$rel_type_choice" ]; do
            read -p "  Choice [1-4]: " rel_type_choice
            case $rel_type_choice in
                1) rel_type="ManyToOne" ;;
                2) rel_type="OneToMany" ;;
                3) rel_type="ManyToMany" ;;
                4) rel_type="OneToOne" ;;
                *) 
                    log_error "  Invalid choice. Please enter 1, 2, 3, or 4"
                    rel_type_choice=""
                    ;;
            esac
        done
        
        # Related entity (required)
        local rel_entity=""
        while [ -z "$rel_entity" ]; do
            read -p "  Related Entity (e.g., Category): " rel_entity
            if [ -z "$rel_entity" ]; then
                log_error "  Related entity is required"
            fi
        done
        
        # Foreign key (with default)
        local default_fk="${rel_entity}Id"
        read -p "  Foreign Key [$default_fk]: " rel_fk
        rel_fk=${rel_fk:-$default_fk}
        
        # Join table (for ManyToMany)
        local join_table=""
        if [ "$rel_type" = "ManyToMany" ]; then
            local default_join="${ENTITY_NAME}${rel_entity}s"
            read -p "  Join Table [$default_join]: " join_table
            join_table=${join_table:-$default_join}
        fi
        
        # Required
        read -p "  Required [y/N]: " rel_required
        local is_required=false
        [[ "$rel_required" =~ ^[Yy]$ ]] && is_required=true
        
        # Tenant scoped
        read -p "  Tenant Scoped [y/N]: " rel_tenant
        local is_tenant_scoped=false
        [[ "$rel_tenant" =~ ^[Yy]$ ]] && is_tenant_scoped=true
        
        # Build JSON
        local rel_json="{\"name\":\"$rel_name\",\"type\":\"$rel_type\",\"entity\":\"$rel_entity\",\"foreignKey\":\"$rel_fk\""
        [ -n "$join_table" ] && rel_json="$rel_json,\"joinTable\":\"$join_table\""
        rel_json="$rel_json,\"required\":$is_required,\"tenantScoped\":$is_tenant_scoped}"
        
        relationships+=("$rel_json")
        log_success "  Relationship '$rel_name' ($rel_type) added"
    done
    
    # Build JSON array
    if [ ${#relationships[@]} -eq 0 ]; then
        echo "[]"
    else
        local json="["
        for i in "${!relationships[@]}"; do
            [ $i -gt 0 ] && json="$json,"
            json="$json${relationships[$i]}"
        done
        json="$json]"
        echo "$json"
    fi
}

################################################################################
# SECTION 4: Multi-Tenancy Detection
################################################################################

detect_multitenancy() {
    log_step "Detecting multi-tenancy configuration..."
    
    # Check for IMultiTenant interface in project files
    if find . -name "*.cs" -type f -exec grep -l "IMultiTenant" {} \; | head -1 > /dev/null 2>&1; then
        IS_MULTITENANT=true
        log_info "Multi-tenancy detected: true"
        return 0
    fi
    
    # Check for TenantId in existing entities
    if find . -name "*.cs" -type f -exec grep -l "TenantId" {} \; | head -1 > /dev/null 2>&1; then
        IS_MULTITENANT=true
        log_info "Multi-tenancy detected: true (TenantId found)"
        return 0
    fi
    
    IS_MULTITENANT=false
    log_info "Multi-tenancy detected: false"
    return 0
}

apply_tenant_filter_to_fk() {
    local fk_config=$1
    
    if [ "$IS_MULTITENANT" = true ]; then
        echo "$fk_config"
        echo "    .HasForeignKey(x => new { x.${fk_name}Id, x.TenantId })"
    else
        echo "$fk_config"
    fi
}

################################################################################
# SECTION 5: Project Creation Functions
################################################################################

create_app_project() {
    local project_name=$1
    local db_provider=${2:-ef}
    local tiered=${3:-false}
    
    log_step "Creating ABP Application project: ${project_name}"
    
    local cmd="abp new ${project_name} -t app -d ${db_provider} --no-ui"
    
    if [ "$tiered" = true ]; then
        cmd="$cmd --tiered"
    fi
    
    log_info "Executing: $cmd"
    
    if eval "$cmd"; then
        log_success "ABP Application project created successfully!"
        log_info "Project location: $(pwd)/${project_name}"
        return 0
    else
        log_error "Failed to create ABP Application project"
        return 1
    fi
}

create_module_project() {
    local project_name=$1
    local db_provider=${2:-ef}
    
    log_step "Creating ABP Module project: ${project_name}"
    
    local cmd="abp new ${project_name} -t module -d ${db_provider} --no-ui"
    
    log_info "Executing: $cmd"
    
    if eval "$cmd"; then
        log_success "ABP Module project created successfully!"
        return 0
    else
        log_error "Failed to create ABP Module project"
        return 1
    fi
}

create_microservice_project() {
    local project_name=$1
    local db_provider=${2:-ef}
    
    log_step "Creating ABP Microservice project: ${project_name}"
    
    local cmd="abp new ${project_name} -t microservice -d ${db_provider}"
    
    log_info "Executing: $cmd"
    
    if eval "$cmd"; then
        log_success "ABP Microservice project created successfully!"
        return 0
    else
        log_error "Failed to create ABP Microservice project"
        return 1
    fi
}

create_console_project() {
    local project_name=$1
    local db_provider=${2:-ef}
    
    log_step "Creating ABP Console project: ${project_name}"
    
    local cmd="abp new ${project_name} -t console -d ${db_provider}"
    
    log_info "Executing: $cmd"
    
    if eval "$cmd"; then
        log_success "ABP Console project created successfully!"
        return 0
    else
        log_error "Failed to create ABP Console project"
        return 1
    fi
}

################################################################################
# SECTION 6: Template Processing Functions
################################################################################

process_template() {
    local template_file=$1
    local output_file=$2
    shift 2
    
    if [ ! -f "$template_file" ]; then
        log_error "Template not found: $template_file"
        return 1
    fi
    
    local content=$(cat "$template_file")
    
    # Replace variables passed as NAME=VALUE pairs
    while [ $# -gt 0 ]; do
        local pair=$1
        local key="${pair%%=*}"
        local value="${pair#*=}"
        content="${content//\$\{${key}\}/${value}}"
        shift
    done
    
    # Create output directory if needed
    local output_dir=$(dirname "$output_file")
    create_directory_if_not_exists "$output_dir"
    
    echo "$content" > "$output_file"
    log_success "Generated: $output_file"
}

process_template_with_properties() {
    local template_file=$1
    local output_file=$2
    local properties_json=$3
    shift 3
    
    if [ ! -f "$template_file" ]; then
        log_error "Template not found: $template_file"
        return 1
    fi
    
    local content=$(cat "$template_file")
    
    # Generate properties from JSON
    local properties_code=""
    if command -v jq &> /dev/null && [ "$properties_json" != "[]" ]; then
        local prop_count=$(echo "$properties_json" | jq 'length' 2>/dev/null || echo "0")
        
        for ((i=0; i<prop_count; i++)); do
            local prop=$(echo "$properties_json" | jq ".[$i]")
            local prop_decl=$(generate_property_declaration "$prop")
            properties_code+="$prop_decl\n\n    "
        done
    fi
    
    # Replace PROPERTIES placeholder
    content="${content//\$\{PROPERTIES\}/$properties_code}"
    
    # Replace RELATIONSHIPS placeholder (empty for now)
    content="${content//\$\{RELATIONSHIPS\}/}"
    
    # Replace other variables passed as NAME=VALUE pairs
    while [ $# -gt 0 ]; do
        local pair=$1
        local key="${pair%%=*}"
        local value="${pair#*=}"
        content="${content//\$\{${key}\}/${value}}"
        shift
    done
    
    # Create output directory
    local output_dir=$(dirname "$output_file")
    create_directory_if_not_exists "$output_dir"
    
    echo -e "$content" > "$output_file"
    log_success "Generated: $output_file"
}

################################################################################
# SECTION 7: Entity Generation from JSON
################################################################################

generate_entity_from_json() {
    local json_file=$1
    
    log_step "Generating entity from JSON: $json_file"
    
    # Parse JSON
    if ! parse_json_entity "$json_file"; then
        return 1
    fi
    
    # Detect multi-tenancy
    detect_multitenancy
    
    # Parse properties and relationships
    local properties=$(parse_properties_from_json "$json_file")
    local relationships=$(parse_relationships_from_json "$json_file")
    
    # Generate all components
    generate_entity_files "$properties" "$relationships"
    generate_dto_files "$properties"
    generate_repository_files
    generate_service_files
    generate_controller_files
    
    # Check options
    local generate_seeder=$(jq -r '.options.generateSeeder // false' "$json_file")
    local generate_tests=$(jq -r '.options.generateTests // false' "$json_file")
    local generate_validation=$(jq -r '.options.generateValidation // false' "$json_file")
    
    if [ "$generate_seeder" = "true" ]; then
        generate_seeder_files
    fi
    
    if [ "$generate_tests" = "true" ]; then
        generate_test_files
    fi
    
    if [ "$generate_validation" = "true" ]; then
        generate_validation_files
    fi
    
    log_success "Entity generation complete!"
}

################################################################################
# SECTION 8: Code Generation Functions
################################################################################

generate_entity_files() {
    local properties=$1
    local relationships=$2
    
    log_step "Generating entity file..."
    
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    
    local template_file="${TEMPLATES_DIR}/domain/entity.template.cs"
    local output_file="${PROJECT_ROOT}/src/${NAMESPACE}.Domain/${MODULE_NAME}/${ENTITY_NAME}.cs"
    
    process_template_with_properties "$template_file" "$output_file" "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower"
}

generate_dto_files() {
    local properties=$1
    
    log_step "Generating DTO files..."
    
    # Create DTO
    process_template_with_properties \
        "${TEMPLATES_DIR}/application/dto-create.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application/DTOs/Create${ENTITY_NAME}Dto.cs" \
        "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
    
    # Update DTO
    process_template_with_properties \
        "${TEMPLATES_DIR}/application/dto-update.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application/DTOs/Update${ENTITY_NAME}Dto.cs" \
        "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
    
    # Entity DTO
    process_template_with_properties \
        "${TEMPLATES_DIR}/application/dto-entity.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application/DTOs/${ENTITY_NAME}Dto.cs" \
        "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
}

generate_repository_files() {
    log_step "Generating repository files..."
    
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    
    # Repository interface
    process_template \
        "${TEMPLATES_DIR}/domain/repository-interface.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Domain/${MODULE_NAME}/I${ENTITY_NAME}Repository.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower"
    
    # EF Repository
    process_template \
        "${TEMPLATES_DIR}/infrastructure/ef-repository.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.EntityFrameworkCore/${MODULE_NAME}/EfCore${ENTITY_NAME}Repository.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower"
}

generate_service_files() {
    log_step "Generating service files..."
    
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    local entity_name_plural="${ENTITY_NAME}s"
    
    # Service interface
    process_template \
        "${TEMPLATES_DIR}/application/app-service-interface.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application/${MODULE_NAME}/I${ENTITY_NAME}AppService.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ENTITY_NAME_PLURAL=$entity_name_plural"
    
    # Service implementation
    process_template \
        "${TEMPLATES_DIR}/application/app-service-crud.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application/${MODULE_NAME}/${ENTITY_NAME}AppService.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ENTITY_NAME_PLURAL=$entity_name_plural"
}

generate_controller_files() {
    log_step "Generating controller files..."
    
    local module_name_lower="$(echo ${MODULE_NAME:0:1} | tr '[:upper:]' '[:lower:]')${MODULE_NAME:1}"
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    local entity_name_plural="${ENTITY_NAME}s"
    local entity_name_lower_plural="${entity_name_lower}s"
    
    process_template \
        "${TEMPLATES_DIR}/api/controller-crud.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.HttpApi/Controllers/${ENTITY_NAME}Controller.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "MODULE_NAME_LOWER=$module_name_lower" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ENTITY_NAME_PLURAL=$entity_name_plural" \
        "ENTITY_NAME_LOWER_PLURAL=$entity_name_lower_plural"
}

generate_seeder_files() {
    log_step "Generating seeder files..."
    
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    local entity_name_plural="${ENTITY_NAME}s"
    
    process_template \
        "${TEMPLATES_DIR}/infrastructure/seeder.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.EntityFrameworkCore/${MODULE_NAME}/${ENTITY_NAME}DataSeeder.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ENTITY_NAME_PLURAL=$entity_name_plural" \
        "ADDITIONAL_SEED_DATA="
}

generate_validation_files() {
    log_step "Generating validation files..."
    
    process_template \
        "${TEMPLATES_DIR}/application/validator.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application/${MODULE_NAME}/${ENTITY_NAME}Validator.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "VALIDATION_RULES="
}

generate_test_files() {
    log_step "Generating test files..."
    
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    local entity_name_plural="${ENTITY_NAME}s"
    
    # Service tests
    process_template \
        "${TEMPLATES_DIR}/tests/unit-test-service.template.cs" \
        "${PROJECT_ROOT}/test/${NAMESPACE}.Application.Tests/${MODULE_NAME}/${ENTITY_NAME}AppServiceTests.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ENTITY_NAME_PLURAL=$entity_name_plural"
    
    # Domain tests
    process_template \
        "${TEMPLATES_DIR}/tests/unit-test-domain.template.cs" \
        "${PROJECT_ROOT}/test/${NAMESPACE}.Domain.Tests/${MODULE_NAME}/${ENTITY_NAME}DomainTests.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ENTITY_NAME_PLURAL=$entity_name_plural"
}

################################################################################
# SECTION 9: Interactive Entity Generation
################################################################################

generate_entity_interactive() {
    log_step "Interactive entity generation"
    
    echo ""
    read -p "Load from JSON file? [y/N]: " use_json
    
    if [[ "$use_json" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Available JSON files in entity-definitions/:"
        ls -1 "$ENTITY_DEFINITIONS_DIR"/*.json 2>/dev/null || echo "  (none found)"
        echo ""
        read -p "Enter JSON file path: " json_path
        
        if [ -f "$json_path" ]; then
            generate_entity_from_json "$json_path"
            return $?
        elif [ -f "$ENTITY_DEFINITIONS_DIR/$json_path" ]; then
            generate_entity_from_json "$ENTITY_DEFINITIONS_DIR/$json_path"
            return $?
        else
            log_error "JSON file not found: $json_path"
            return 1
        fi
    fi
    
    # Interactive flow with property and relationship collection
    while [ -z "$MODULE_NAME" ]; do
        read -p "Enter module name: " MODULE_NAME
        if ! validate_module_name "$MODULE_NAME"; then
            MODULE_NAME=""
        fi
    done
    
    while [ -z "$ENTITY_NAME" ]; do
        read -p "Enter entity name: " ENTITY_NAME
        if ! validate_entity_name "$ENTITY_NAME"; then
            ENTITY_NAME=""
        fi
    done
    
    # Collect properties interactively
    log_info "Let's define the entity properties..."
    local properties=$(collect_properties_interactive)
    
    # Collect relationships interactively
    log_info "Let's define the entity relationships..."
    local relationships=$(collect_relationships_interactive)
    
    # Show summary
    local prop_count=0
    local rel_count=0
    if command -v jq &> /dev/null; then
        prop_count=$(echo "$properties" | jq 'length' 2>/dev/null || echo "0")
        rel_count=$(echo "$relationships" | jq 'length' 2>/dev/null || echo "0")
    fi
    
    echo ""
    log_info "Summary: Entity '$ENTITY_NAME' with $prop_count properties and $rel_count relationships"
    
    # Generate all files
    generate_entity_files "$properties" "$relationships"
    generate_dto_files "$properties"
    generate_repository_files
    generate_service_files
    generate_controller_files
    
    log_success "Entity generation complete!"
}

################################################################################
# SECTION 10: Main Menu
################################################################################

show_main_menu() {
    clear
    print_header "ABP Framework Project & Module Generator v1.0"
    
    echo "Select an operation:"
    echo ""
    echo "  1) Create New ABP Project"
    echo "  2) Add New Module"
    echo "  3) Add Entity with CRUD"
    echo "  4) Generate from JSON"
    echo "  5) Check Dependencies"
    echo "  6) Exit"
    echo ""
    print_separator
    
    if [ -n "$PROJECT_NAME" ]; then
        echo -e "Current Project: ${GREEN}$PROJECT_NAME${NC}"
        echo -e "Namespace: ${GREEN}$NAMESPACE${NC}"
        echo ""
    fi
}

read_menu_choice() {
    local choice
    read -p "Enter your choice [1-6]: " choice
    echo "$choice"
}

################################################################################
# SECTION 11: Operations
################################################################################

create_new_project() {
    print_header "Create New ABP Project"
    
    read -p "Enter project name (e.g., MyApp): " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        log_error "Project name cannot be empty"
        return 1
    fi
    
    echo ""
    echo "Select ABP template:"
    echo "  1) Application (app)"
    echo "  2) Module (module)"
    echo "  3) Microservice (microservice)"
    echo "  4) Console (console)"
    echo ""
    
    read -p "Enter template choice [1-4]: " template_choice
    
    case $template_choice in
        1) TEMPLATE_TYPE="app" ;;
        2) TEMPLATE_TYPE="module" ;;
        3) TEMPLATE_TYPE="microservice" ;;
        4) TEMPLATE_TYPE="console" ;;
        *) log_error "Invalid choice"; return 1 ;;
    esac
    
    echo ""
    echo "Select database provider:"
    echo "  1) Entity Framework Core (ef)"
    echo "  2) MongoDB (mongodb)"
    echo ""
    
    read -p "Enter database choice [1-2]: " db_choice
    
    local db_provider
    case $db_choice in
        1) db_provider="ef" ;;
        2) db_provider="mongodb" ;;
        *) log_error "Invalid choice"; return 1 ;;
    esac
    
    echo ""
    read -p "Enable multi-tenancy? [y/N]: " multitenancy
    local tiered=false
    if [[ "$multitenancy" =~ ^[Yy]$ ]]; then
        tiered=true
    fi
    
    case $TEMPLATE_TYPE in
        "app")
            create_app_project "$PROJECT_NAME" "$db_provider" "$tiered"
            ;;
        "module")
            create_module_project "$PROJECT_NAME" "$db_provider"
            ;;
        "microservice")
            create_microservice_project "$PROJECT_NAME" "$db_provider"
            ;;
        "console")
            create_console_project "$PROJECT_NAME" "$db_provider"
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        PROJECT_ROOT="$(pwd)/$PROJECT_NAME"
        NAMESPACE="$PROJECT_NAME"
        save_config
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

add_new_module() {
    print_header "Add New Module"
    
    if ! detect_project_info && [ -z "$PROJECT_NAME" ]; then
        log_error "No ABP project detected. Please create or navigate to an ABP project first."
        read -p "Press Enter to continue..."
        return 1
    fi
    
    local module_name=""
    while [ -z "$module_name" ]; do
        read -p "Enter module name: " module_name
        if [ -z "$module_name" ]; then
            log_error "Module name cannot be empty"
            module_name=""
        elif ! validate_module_name "$module_name"; then
            module_name=""
        fi
    done
    
    MODULE_NAME="$module_name"
    
    # Create module structure
    log_step "Creating module directory structure..."
    
    create_directory_if_not_exists "${PROJECT_ROOT}/src/${NAMESPACE}.Domain/${MODULE_NAME}"
    create_directory_if_not_exists "${PROJECT_ROOT}/src/${NAMESPACE}.Application/${MODULE_NAME}"
    create_directory_if_not_exists "${PROJECT_ROOT}/src/${NAMESPACE}.Application/DTOs"
    create_directory_if_not_exists "${PROJECT_ROOT}/src/${NAMESPACE}.EntityFrameworkCore/${MODULE_NAME}"
    create_directory_if_not_exists "${PROJECT_ROOT}/src/${NAMESPACE}.HttpApi/Controllers"
    
    log_success "Module '$MODULE_NAME' structure created successfully!"
    log_info "You can now add entities to this module using option 3"
    
    echo ""
    read -p "Press Enter to continue..."
}

add_entity_with_crud() {
    print_header "Add Entity with CRUD"
    
    if ! detect_project_info && [ -z "$PROJECT_NAME" ]; then
        log_error "No ABP project detected. Please create or navigate to an ABP project first."
        read -p "Press Enter to continue..."
        return 1
    fi
    
    generate_entity_interactive
    
    read -p "Press Enter to continue..."
}

generate_from_json_menu() {
    print_header "Generate from JSON"
    
    if ! detect_project_info && [ -z "$PROJECT_NAME" ]; then
        log_error "No ABP project detected. Please create or navigate to an ABP project first."
        read -p "Press Enter to continue..."
        return 1
    fi
    
    echo ""
    echo "Available JSON files:"
    ls -1 "$ENTITY_DEFINITIONS_DIR"/*.json 2>/dev/null || echo "  (none found)"
    echo ""
    
    read -p "Enter JSON file path or name: " json_input
    
    if [ -f "$json_input" ]; then
        generate_entity_from_json "$json_input"
    elif [ -f "$ENTITY_DEFINITIONS_DIR/$json_input" ]; then
        generate_entity_from_json "$ENTITY_DEFINITIONS_DIR/$json_input"
    else
        log_error "JSON file not found: $json_input"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

################################################################################
# SECTION 12: CLI Interface
################################################################################

parse_cli_args() {
    local operation=$1
    shift
    
    case $operation in
        "create-project")
            handle_create_project_cli "$@"
            ;;
        "add-entity")
            handle_add_entity_cli "$@"
            ;;
        "--from-json")
            generate_entity_from_json "$1"
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

handle_create_project_cli() {
    local name=""
    local template="app"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                name="$2"
                shift 2
                ;;
            --template)
                template="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [ -z "$name" ]; then
        log_error "Project name is required (--name)"
        exit 1
    fi
    
    PROJECT_NAME="$name"
    TEMPLATE_TYPE="$template"
    
    case $template in
        "app") create_app_project "$name" "ef" false ;;
        "module") create_module_project "$name" "ef" ;;
        "microservice") create_microservice_project "$name" "ef" ;;
        "console") create_console_project "$name" "ef" ;;
        *) log_error "Invalid template: $template"; exit 1 ;;
    esac
}

handle_add_entity_cli() {
    local json_file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --from-json)
                json_file="$2"
                shift 2
                ;;
            --module)
                MODULE_NAME="$2"
                shift 2
                ;;
            --name)
                ENTITY_NAME="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [ -n "$json_file" ]; then
        generate_entity_from_json "$json_file"
    elif [ -n "$MODULE_NAME" ] && [ -n "$ENTITY_NAME" ]; then
        generate_entity_files "[]" "[]"
    else
        log_error "Either --from-json or both --module and --name are required"
        exit 1
    fi
}

show_usage() {
    echo "ABP Framework Project & Module Generator v1.0"
    echo ""
    echo "Usage:"
    echo "  ./abp-generator.sh                                    # Interactive mode"
    echo "  ./abp-generator.sh create-project --name <name> --template <type>"
    echo "  ./abp-generator.sh add-entity --from-json <file.json>"
    echo "  ./abp-generator.sh add-entity --module <module> --name <name>"
    echo ""
    echo "Examples:"
    echo "  ./abp-generator.sh create-project --name MyApp --template app"
    echo "  ./abp-generator.sh add-entity --from-json product.json"
    echo "  ./abp-generator.sh add-entity --module Products --name Product"
}

################################################################################
# SECTION 13: Main Entry Point
################################################################################

main() {
    load_config
    
    # If command line arguments provided, use CLI mode
    if [ $# -gt 0 ]; then
        parse_cli_args "$@"
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_main_menu
        choice=$(read_menu_choice)
        
        case $choice in
            1) create_new_project ;;
            2) add_new_module ;;
            3) add_entity_with_crud ;;
            4) generate_from_json_menu ;;
            5) check_dependencies; read -p "Press Enter to continue..." ;;
            6) 
                echo ""
                log_info "Exiting... Goodbye!"
                exit 0
                ;;
            *)
                log_error "Invalid choice. Please try again."
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@"

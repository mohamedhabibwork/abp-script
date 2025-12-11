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
ENTITY_BASE_CLASS="FullAuditedAggregateRoot<Guid>"
ENTITY_ID_TYPE="Guid"
DB_CONTEXT_NAME=""


################################################################################
# SECTION 2A: Entity Tracking Functions
################################################################################

get_tracking_file() {
    if [ -z "$PROJECT_ROOT" ]; then
        echo "${SCRIPT_DIR}/generated-entities.json"
    else
        echo "${PROJECT_ROOT}/generated-entities.json"
    fi
}

get_tracked_entities() {
    local tracking_file=$(get_tracking_file)
    if [ -f "$tracking_file" ] && command -v jq &> /dev/null; then
        jq -r '.entities // []' "$tracking_file" 2>/dev/null || echo "[]"
    else
        echo "[]"
    fi
}

save_tracked_entities() {
    local entities_json="$1"
    local tracking_file=$(get_tracking_file)
    local tracking_dir=$(dirname "$tracking_file")
    
    if [ ! -d "$tracking_dir" ]; then
        mkdir -p "$tracking_dir"
    fi
    
    if command -v jq &> /dev/null; then
        echo "{\"entities\": $entities_json}" | jq '.' > "$tracking_file"
    else
        echo "{\"entities\": $entities_json}" > "$tracking_file"
    fi
}

add_entity_tracking() {
    local generated_files=("$@")
    
    local entities_json=$(get_tracked_entities)
    if [ "$entities_json" = "[]" ] || [ -z "$entities_json" ]; then
        entities_json="[]"
    fi
    
    # Build relative paths
    local relative_files="["
    local first=true
    for file in "${generated_files[@]}"; do
        if [ -f "$file" ]; then
            local relative_path="$file"
            if [ -n "$PROJECT_ROOT" ]; then
                relative_path=$(echo "$file" | sed "s|^${PROJECT_ROOT}/||")
            fi
            
            if [ "$first" = true ]; then
                first=false
            else
                relative_files+=","
            fi
            relative_files+="\"$relative_path\""
        fi
    done
    relative_files+="]"
    
    # Add new entity
    local new_entity=$(jq -n \
        --arg name "$ENTITY_NAME" \
        --arg module "$MODULE_NAME" \
        --argjson files "$relative_files" \
        '{name: $name, module: $module, generatedAt: now|todate, files: $files}')
    
    if command -v jq &> /dev/null; then
        local updated_entities=$(echo "$entities_json" | jq ". + [$new_entity]")
        save_tracked_entities "$updated_entities"
    fi
}

remove_entity_tracking() {
    local entity_name="$1"
    local module_name="$2"
    
    local entities_json=$(get_tracked_entities)
    if [ "$entities_json" = "[]" ] || [ -z "$entities_json" ]; then
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        local filtered=$(echo "$entities_json" | jq "[.[] | select(.name != \"$entity_name\" or .module != \"$module_name\")]")
        save_tracked_entities "$filtered"
        return 0
    fi
    return 1
}

get_entity_files() {
    local entity_name="$1"
    local module_name="$2"
    
    local entities_json=$(get_tracked_entities)
    if [ "$entities_json" = "[]" ] || [ -z "$entities_json" ]; then
        return
    fi
    
    if command -v jq &> /dev/null; then
        local entity=$(echo "$entities_json" | jq -r ".[] | select(.name == \"$entity_name\" and .module == \"$module_name\")")
        if [ -n "$entity" ]; then
            echo "$entity" | jq -r '.files[]?' | while read -r relative_file; do
                if [ -n "$PROJECT_ROOT" ]; then
                    echo "${PROJECT_ROOT}/${relative_file}"
                else
                    echo "$relative_file"
                fi
            done
        fi
    fi
}

rollback_last_entity() {
    print_header "Rollback Last Generated Entity"
    
    local entities_json=$(get_tracked_entities)
    if [ "$entities_json" = "[]" ] || [ -z "$entities_json" ]; then
        log_warning "No tracked entities found."
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for this operation"
        return 1
    fi
    
    local entity_count=$(echo "$entities_json" | jq 'length')
    local last_entity=$(echo "$entities_json" | jq ".[$((entity_count - 1))]")
    local entity_name=$(echo "$last_entity" | jq -r '.name')
    local module_name=$(echo "$last_entity" | jq -r '.module')
    local generated_at=$(echo "$last_entity" | jq -r '.generatedAt')
    
    echo "Last generated entity:"
    echo "  Name: $entity_name"
    echo "  Module: $module_name"
    echo "  Generated: $generated_at"
    echo ""
    
    read -p "Delete this entity and all its files? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        local files=($(get_entity_files "$entity_name" "$module_name"))
        local deleted_count=0
        for file in "${files[@]}"; do
            if [ -f "$file" ]; then
                rm -f "$file"
                log_info "Deleted: $file"
                deleted_count=$((deleted_count + 1))
            fi
        done
        
        remove_entity_tracking "$entity_name" "$module_name"
        log_success "Rolled back entity '$entity_name'. Deleted $deleted_count files."
    else
        log_info "Rollback cancelled."
    fi
    
    read -p "Press Enter to continue..."
}

delete_entity_by_name() {
    print_header "Delete Entity by Name"
    
    local entities_json=$(get_tracked_entities)
    if [ "$entities_json" = "[]" ] || [ -z "$entities_json" ]; then
        log_warning "No tracked entities found."
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for this operation"
        return 1
    fi
    
    echo "Available entities:"
    echo "$entities_json" | jq -r '.[] | "  \(.name) (Module: \(.module))"'
    echo ""
    
    read -p "Enter entity name: " entity_name
    read -p "Enter module name: " module_name
    
    local entity=$(echo "$entities_json" | jq -r ".[] | select(.name == \"$entity_name\" and .module == \"$module_name\")")
    if [ -z "$entity" ]; then
        log_error "Entity '$entity_name' in module '$module_name' not found."
        read -p "Press Enter to continue..."
        return
    fi
    
    local file_count=$(echo "$entity" | jq '.files | length')
    echo ""
    echo "Entity to delete:"
    echo "  Name: $entity_name"
    echo "  Module: $module_name"
    echo "  Files: $file_count"
    echo ""
    
    read -p "Delete this entity and all its files? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        local files=($(get_entity_files "$entity_name" "$module_name"))
        local deleted_count=0
        for file in "${files[@]}"; do
            if [ -f "$file" ]; then
                rm -f "$file"
                log_info "Deleted: $file"
                deleted_count=$((deleted_count + 1))
            fi
        done
        
        remove_entity_tracking "$entity_name" "$module_name"
        log_success "Deleted entity '$entity_name'. Removed $deleted_count files."
    else
        log_info "Deletion cancelled."
    fi
    
    read -p "Press Enter to continue..."
}

list_generated_entities() {
    print_header "List Generated Entities"
    
    local entities_json=$(get_tracked_entities)
    if [ "$entities_json" = "[]" ] || [ -z "$entities_json" ]; then
        log_warning "No tracked entities found."
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for this operation"
        return 1
    fi
    
    local entity_count=$(echo "$entities_json" | jq 'length')
    echo "Generated Entities ($entity_count):"
    echo ""
    echo "$entities_json" | jq -r '.[] | "  \(.name) (Module: \(.module))\n      Generated: \(.generatedAt)\n      Files: \(.files | length)\n"'
    
    read -p "Press Enter to continue..."
}

clean_all_generated_files() {
    print_header "Clean All Generated Files"
    
    local entities_json=$(get_tracked_entities)
    if [ "$entities_json" = "[]" ] || [ -z "$entities_json" ]; then
        log_warning "No tracked entities found."
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for this operation"
        return 1
    fi
    
    local entity_count=$(echo "$entities_json" | jq 'length')
    local total_files=$(echo "$entities_json" | jq '[.[] | .files | length] | add')
    
    echo "This will delete ALL tracked entities and their files:"
    echo "  Total entities: $entity_count"
    echo "  Total files: $total_files"
    echo ""
    
    read -p "Are you sure? Type 'DELETE ALL' to confirm: " confirm
    if [ "$confirm" = "DELETE ALL" ]; then
        local deleted_count=0
        echo "$entities_json" | jq -r '.[] | "\(.name)|\(.module)"' | while IFS='|' read -r entity_name module_name; do
            local files=($(get_entity_files "$entity_name" "$module_name"))
            for file in "${files[@]}"; do
                if [ -f "$file" ]; then
                    rm -f "$file"
                    deleted_count=$((deleted_count + 1))
                fi
            done
        done
        
        local tracking_file=$(get_tracking_file)
        if [ -f "$tracking_file" ]; then
            rm -f "$tracking_file"
        fi
        
        log_success "Cleaned all generated files. Deleted $deleted_count files."
    else
        log_info "Cleanup cancelled."
    fi
    
    read -p "Press Enter to continue..."
}

log_info() {
    echo -e "${CYAN}ℹ️  ${NC}${BLUE}$1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${MAGENTA}🔄 $1${NC}"
}

log_progress() {
    local message=$1
    local current=$2
    local total=$3
    local percentage=$((current * 100 / total))
    local filled=$((percentage / 5))
    local empty=$((20 - filled))
    local bar=$(printf '=%.0s' $(seq 1 $filled))$(printf ' %.0s' $(seq 1 $empty))
    echo -e "${CYAN}⏳ [${bar}] ${percentage}% ${NC}${YELLOW}(${current}/${total})${NC} $message"
}

print_header() {
    local message="$1"
    local padding=$((68 - ${#message}))
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYAN}║  ${NC}%-68s${CYAN}║${NC}\n" "$message"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_separator() {
    echo -e "${CYAN}────────────────────────────────────────────────────────────────────────${NC}"
}

print_section_header() {
    local title="$1"
    echo ""
    echo -e "${CYAN}▶ ${NC}$title"
    echo -e "${CYAN}────────────────────────────────────────────────────────────────────────${NC}"
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
    
    # Parse base class if provided
    if jq -e '.baseClass' "$json_file" > /dev/null 2>&1; then
        ENTITY_BASE_CLASS=$(jq -r '.baseClass' "$json_file")
    else
        ENTITY_BASE_CLASS="FullAuditedAggregateRoot<Guid>"
    fi
    
    # Parse ID type if provided
    if jq -e '.idType' "$json_file" > /dev/null 2>&1; then
        ENTITY_ID_TYPE=$(jq -r '.idType' "$json_file")
    else
        ENTITY_ID_TYPE="Guid"
    fi
    
    # Parse DbContext name if provided
    if jq -e '.dbContext' "$json_file" > /dev/null 2>&1; then
        DB_CONTEXT_NAME=$(jq -r '.dbContext' "$json_file")
    else
        DB_CONTEXT_NAME="${MODULE_NAME}DbContext"
    fi
    
    # Update base class with ID type if it contains <Guid>
    ENTITY_BASE_CLASS=$(echo "$ENTITY_BASE_CLASS" | sed "s/<Guid>/<$ENTITY_ID_TYPE>/g")
    
    log_success "Parsed entity: $ENTITY_NAME in module: $MODULE_NAME (Base: $ENTITY_BASE_CLASS, ID: $ENTITY_ID_TYPE)"
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
    local nullable=$(echo "$property_json" | jq -r '.nullable // false')
    local max_length=$(echo "$property_json" | jq -r '.maxLength // ""')
    
    local declaration=""
    
    # Add validation attributes
    if [ "$required" = "true" ]; then
        declaration+="[Required]\n    "
    fi
    
    if [ -n "$max_length" ] && [ "$max_length" != "null" ]; then
        declaration+="[StringLength($max_length)]\n    "
    fi
    
    # Make type nullable if required is false or nullable is explicitly true
    # For value types (int, long, decimal, bool, DateTime, Guid), use nullable version
    local final_type="$type"
    if [ "$required" != "true" ] || [ "$nullable" = "true" ]; then
        case "$type" in
            int|long|decimal|double|float|bool|DateTime|Guid)
                final_type="${type}?"
                ;;
            string)
                # string is already nullable, but we can make it explicitly nullable
                final_type="string?"
                ;;
        esac
    fi
    
    # Add property
    declaration+="public $final_type $name { get; set; }"
    
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
        
        # Nullable (only if not required)
        local is_nullable=false
        if [ "$is_required" != "true" ]; then
            read -p "  Nullable [Y/n]: " prop_nullable
            prop_nullable=${prop_nullable:-Y}
            [[ "$prop_nullable" =~ ^[Yy]$ ]] && is_nullable=true
        fi
        
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
        local prop_json="{\"name\":\"$prop_name\",\"type\":\"$prop_type\",\"required\":$is_required,\"nullable\":$is_nullable"
        
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
        echo ""
        echo "  Relationship Type:"
        echo "    1) ManyToOne   (N:1 - e.g., Product → Category)"
        echo "    2) OneToMany   (1:N - e.g., Category → Products)"
        echo "    3) ManyToMany  (N:M - e.g., Product ↔ Tags)"
        echo "    4) OneToOne    (1:1 - e.g., User → Profile)"
        echo ""
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
        # Escape special characters for sed-like replacement
        value=$(echo "$value" | sed 's/[[\.*^$()+?{|]/\\&/g')
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
    
    # Collect generated files for tracking
    local generated_files=()
    
    # Entity files
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Domain/${MODULE_NAME}/${ENTITY_NAME}.cs")
    
    # DTO files
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/Create${ENTITY_NAME}Dto.cs")
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/Update${ENTITY_NAME}Dto.cs")
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/${ENTITY_NAME}Dto.cs")
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/Get${ENTITY_NAME}ListInput.cs")
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/${ENTITY_NAME}LookupDto.cs")
    
    # Repository files
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Domain/${MODULE_NAME}/I${ENTITY_NAME}Repository.cs")
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.EntityFrameworkCore/${MODULE_NAME}/Repositories/EfCore${ENTITY_NAME}Repository.cs")
    
    # Service files
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/I${ENTITY_NAME}AppService.cs")
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application/${MODULE_NAME}/${ENTITY_NAME}AppService.cs")
    
    # Controller files
    generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.HttpApi/${MODULE_NAME}/Controllers/${ENTITY_NAME}Controller.cs")
    
    # Optional files
    if [ "$generate_seeder" = "true" ]; then
        generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.EntityFrameworkCore/${MODULE_NAME}/${ENTITY_NAME}DataSeeder.cs")
    fi
    if [ "$generate_validation" = "true" ]; then
        generated_files+=("${PROJECT_ROOT}/src/${NAMESPACE}.Application/${MODULE_NAME}/Validators/${ENTITY_NAME}Validator.cs")
    fi
    if [ "$generate_tests" = "true" ]; then
        generated_files+=("${PROJECT_ROOT}/test/${NAMESPACE}.Application.Tests/${MODULE_NAME}/${ENTITY_NAME}AppServiceTests.cs")
        generated_files+=("${PROJECT_ROOT}/test/${NAMESPACE}.Domain.Tests/${MODULE_NAME}/${ENTITY_NAME}DomainTests.cs")
    fi
    
    # Track the generated entity
    add_entity_tracking "${generated_files[@]}"
    
    log_success "Entity generation complete!"
}

################################################################################
# SECTION 8: Code Generation Functions
################################################################################

get_base_class_constructor() {
    local base_class="$1"
    if echo "$base_class" | grep -q "AggregateRoot"; then
        echo " : base(id)"
    else
        echo ""
    fi
}

get_id_assignment() {
    local base_class="$1"
    if echo "$base_class" | grep -q "AggregateRoot"; then
        echo ""
    else
        echo "Id = id;
            "
    fi
}

generate_entity_files() {
    local properties=$1
    local relationships=$2
    
    log_step "Generating entity file..."
    
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    local base_class_constructor=$(get_base_class_constructor "$ENTITY_BASE_CLASS")
    local id_assignment=$(get_id_assignment "$ENTITY_BASE_CLASS")
    
    # Check if base class includes ISoftDelete
    local soft_delete_using=""
    if echo "$ENTITY_BASE_CLASS" | grep -q "ISoftDelete"; then
        soft_delete_using="
using Volo.Abp;"
    fi
    
    # Check if properties have validation attributes
    local has_validation_attributes=false
    if command -v jq &> /dev/null && [ "$properties" != "[]" ] && [ -n "$properties" ]; then
        local prop_count=$(echo "$properties" | jq 'length' 2>/dev/null || echo "0")
        for ((i=0; i<prop_count; i++)); do
            local prop=$(echo "$properties" | jq ".[$i]")
            local required=$(echo "$prop" | jq -r '.required // false')
            local nullable=$(echo "$prop" | jq -r '.nullable // false')
            local max_length=$(echo "$prop" | jq -r '.maxLength // ""')
            local min_length=$(echo "$prop" | jq -r '.minLength // ""')
            
            if [ "$required" = "true" ] || [ "$nullable" = "true" ] || ([ -n "$max_length" ] && [ "$max_length" != "null" ]) || ([ -n "$min_length" ] && [ "$min_length" != "null" ]); then
                has_validation_attributes=true
                break
            fi
        done
    fi
    
    # Add DataAnnotations using only if validation attributes are present
    local data_annotations_using=""
    if [ "$has_validation_attributes" = true ]; then
        data_annotations_using="
using System.ComponentModel.DataAnnotations;"
    fi
    
    local template_file="${TEMPLATES_DIR}/domain/entity.template.cs"
    local output_file="${PROJECT_ROOT}/src/${NAMESPACE}.Domain/${MODULE_NAME}/${ENTITY_NAME}.cs"
    
    process_template_with_properties "$template_file" "$output_file" "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "BASE_CLASS=$ENTITY_BASE_CLASS" \
        "ID_TYPE=$ENTITY_ID_TYPE" \
        "BASE_CLASS_CONSTRUCTOR=$base_class_constructor" \
        "ID_ASSIGNMENT=$id_assignment" \
        "DATA_ANNOTATIONS_USING=$data_annotations_using" \
        "SOFT_DELETE_USING=$soft_delete_using"
}

generate_dto_files() {
    local properties=$1
    
    log_step "Generating DTO files..."
    
    # Create DTO (in Contracts)
    process_template_with_properties \
        "${TEMPLATES_DIR}/application/dto-create.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/Create${ENTITY_NAME}Dto.cs" \
        "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
    
    # Update DTO (in Contracts)
    process_template_with_properties \
        "${TEMPLATES_DIR}/application/dto-update.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/Update${ENTITY_NAME}Dto.cs" \
        "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
    
    # Entity DTO (in Contracts)
    process_template_with_properties \
        "${TEMPLATES_DIR}/application/dto-entity.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/${ENTITY_NAME}Dto.cs" \
        "$properties" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
    
    # List Input DTO (in Contracts)
    process_template \
        "${TEMPLATES_DIR}/application/dto-list-input.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/Get${ENTITY_NAME}ListInput.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
    
    # Lookup DTO (in Contracts)
    process_template \
        "${TEMPLATES_DIR}/application/dto-lookup.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application.Contracts/${MODULE_NAME}/DTOs/${ENTITY_NAME}LookupDto.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME"
}

generate_repository_files() {
    log_step "Generating repository files..."
    
    local entity_name_lower="$(echo ${ENTITY_NAME:0:1} | tr '[:upper:]' '[:lower:]')${ENTITY_NAME:1}"
    
    # Use selected DbContext or default to module name
    if [ -z "$DB_CONTEXT_NAME" ]; then
        DB_CONTEXT_NAME="${MODULE_NAME}DbContext"
    fi
    
    # Repository interface
    process_template \
        "${TEMPLATES_DIR}/domain/repository-interface.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.Domain/${MODULE_NAME}/I${ENTITY_NAME}Repository.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ID_TYPE=$ENTITY_ID_TYPE"
    
    # EF Repository
    process_template \
        "${TEMPLATES_DIR}/infrastructure/ef-repository.template.cs" \
        "${PROJECT_ROOT}/src/${NAMESPACE}.EntityFrameworkCore/${MODULE_NAME}/Repositories/EfCore${ENTITY_NAME}Repository.cs" \
        "NAMESPACE=$NAMESPACE" \
        "MODULE_NAME=$MODULE_NAME" \
        "ENTITY_NAME=$ENTITY_NAME" \
        "ENTITY_NAME_LOWER=$entity_name_lower" \
        "ID_TYPE=$ENTITY_ID_TYPE" \
        "DB_CONTEXT_NAME=$DB_CONTEXT_NAME"
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
        "${PROJECT_ROOT}/src/${NAMESPACE}.HttpApi/${MODULE_NAME}/Controllers/${ENTITY_NAME}Controller.cs" \
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
        "${PROJECT_ROOT}/src/${NAMESPACE}.Application/${MODULE_NAME}/Validators/${ENTITY_NAME}Validator.cs" \
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

get_abp_entity_base_classes() {
    local id_type=${1:-Guid}
    
    echo "Entity<$id_type>|Basic entity"
    echo "AggregateRoot<$id_type>|Aggregate root"
    echo "BasicAggregateRoot<$id_type>|Simplified aggregate root"
    echo "CreationAuditedEntity<$id_type>|Entity with creation audit"
    echo "CreationAuditedAggregateRoot<$id_type>|Aggregate root with creation audit"
    echo "AuditedEntity<$id_type>|Entity with creation and modification audit"
    echo "AuditedAggregateRoot<$id_type>|Aggregate root with creation and modification audit"
    echo "FullAuditedEntity<$id_type>|Entity with full audit (creation, modification, deletion)"
    echo "FullAuditedAggregateRoot<$id_type>|Aggregate root with full audit (default)"
    echo "CreationAuditedEntity<$id_type>, ISoftDelete|Entity with creation audit and soft delete"
    echo "CreationAuditedAggregateRoot<$id_type>, ISoftDelete|Aggregate root with creation audit and soft delete"
    echo "AuditedEntity<$id_type>, ISoftDelete|Entity with audit and soft delete"
    echo "AuditedAggregateRoot<$id_type>, ISoftDelete|Aggregate root with audit and soft delete"
    echo "FullAuditedEntity<$id_type>, ISoftDelete|Entity with full audit and soft delete"
    echo "FullAuditedAggregateRoot<$id_type>, ISoftDelete|Aggregate root with full audit and soft delete"
}

select_entity_id_type() {
    echo ""
    echo "Select entity ID type:"
    echo ""
    echo "  1) Guid (default) - Globally unique identifier"
    echo "  2) long - 64-bit integer"
    echo "  3) int - 32-bit integer"
    echo ""
    
    read -p "Enter choice [1-3] (default: 1): " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            ENTITY_ID_TYPE="Guid"
            log_info "Selected ID type: Guid"
            ;;
        2)
            ENTITY_ID_TYPE="long"
            log_info "Selected ID type: long"
            ;;
        3)
            ENTITY_ID_TYPE="int"
            log_info "Selected ID type: int"
            ;;
        *)
            log_error "Invalid choice, using default: Guid"
            ENTITY_ID_TYPE="Guid"
            ;;
    esac
}

select_entity_base_class() {
    echo ""
    echo "Select entity base class:"
    echo ""
    
    local base_classes=$(get_abp_entity_base_classes "$ENTITY_ID_TYPE")
    local index=1
    local default_index=9
    
    while IFS='|' read -r name description; do
        if [ $index -eq $default_index ]; then
            echo "  $index) $name (default)"
        else
            echo "  $index) $name"
        fi
        echo "     $description"
        index=$((index + 1))
    done <<< "$base_classes"
    
    echo ""
    read -p "Enter choice [1-$((index - 1))] (default: $default_index): " choice
    choice=${choice:-$default_index}
    
    local selected_index=1
    while IFS='|' read -r name description; do
        if [ $selected_index -eq $choice ]; then
            ENTITY_BASE_CLASS="$name"
            log_info "Selected base class: $ENTITY_BASE_CLASS"
            return 0
        fi
        selected_index=$((selected_index + 1))
    done <<< "$base_classes"
    
    # Default fallback
    ENTITY_BASE_CLASS="FullAuditedAggregateRoot<$ENTITY_ID_TYPE>"
    log_error "Invalid choice, using default: $ENTITY_BASE_CLASS"
}

select_db_context() {
    echo ""
    echo "Select DbContext:"
    echo ""
    
    # Try to auto-detect DbContext files
    local db_context_files=()
    if [ -n "$PROJECT_ROOT" ] && [ -d "$PROJECT_ROOT" ]; then
        while IFS= read -r file; do
            if [ -n "$file" ] && [[ "$file" != *"/bin/"* ]] && [[ "$file" != *"/obj/"* ]]; then
                db_context_files+=("$file")
            fi
        done < <(find "$PROJECT_ROOT" -name "*DbContext.cs" -type f 2>/dev/null)
    fi
    
    if [ ${#db_context_files[@]} -gt 0 ]; then
        echo "Found DbContext files:"
        local i=1
        for file in "${db_context_files[@]}"; do
            local db_context_name=$(basename "$file" .cs)
            echo "  $i) $db_context_name"
            i=$((i + 1))
        done
        echo "  $i) Use module name: ${MODULE_NAME}DbContext (default)"
        echo "  $((i + 1))) Enter custom DbContext name"
        echo ""
        
        read -p "Enter choice [1-$((i + 1))] (default: $i): " choice
        choice=${choice:-$i}
        
        if [ "$choice" -ge 1 ] && [ "$choice" -le ${#db_context_files[@]} ]; then
            local selected_file="${db_context_files[$((choice - 1))]}"
            DB_CONTEXT_NAME=$(basename "$selected_file" .cs)
            log_info "Selected DbContext: $DB_CONTEXT_NAME"
            return 0
        elif [ "$choice" -eq $i ]; then
            DB_CONTEXT_NAME="${MODULE_NAME}DbContext"
            log_info "Using module DbContext: $DB_CONTEXT_NAME"
            return 0
        elif [ "$choice" -eq $((i + 1)) ]; then
            read -p "Enter DbContext name: " custom_name
            if [ -n "$custom_name" ]; then
                DB_CONTEXT_NAME="$custom_name"
                log_info "Using custom DbContext: $DB_CONTEXT_NAME"
                return 0
            fi
        fi
    else
        echo "No DbContext files found. Using module name: ${MODULE_NAME}DbContext"
        DB_CONTEXT_NAME="${MODULE_NAME}DbContext"
        return 0
    fi
    
    # Default fallback
    DB_CONTEXT_NAME="${MODULE_NAME}DbContext"
    log_info "Using default DbContext: $DB_CONTEXT_NAME"
    return 0
}

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
    
    # Select ID type first
    select_entity_id_type
    
    # Select base class (will use selected ID type)
    select_entity_base_class
    
    # Select DbContext
    select_db_context
    
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
    
    echo -e "${CYAN}🎯 ${NC}Select an operation:"
    print_separator
    
    print_section_header "PROJECT MANAGEMENT"
    echo -e "  1️⃣  Create New ABP Project"
    echo -e "  2️⃣  Create New Module"
    echo -e "  3️⃣  Create New Package"
    echo -e "  4️⃣  Initialize Solution"
    echo -e "  5️⃣  Update Solution"
    echo -e "  6️⃣  Upgrade Solution"
    echo -e "  7️⃣  Clean Solution"
    echo ""
    print_section_header "MODULE & PACKAGE MANAGEMENT"
    echo -e "  8️⃣  Add Package"
    echo -e "  9️⃣  Add Package Reference"
    echo -e "  🔟 Install Module"
    echo -e "  1️⃣  1️⃣ Install Local Module"
    echo -e "  1️⃣  2️⃣ List Modules"
    echo -e "  1️⃣  3️⃣ List Templates"
    echo ""
    print_section_header "SOURCE CODE MANAGEMENT"
    echo -e "  1️⃣  4️⃣ Get Module Source"
    echo -e "  1️⃣  5️⃣ Add Source Code"
    echo -e "  1️⃣  6️⃣ List Module Sources"
    echo -e "  1️⃣  7️⃣ Add Module Source"
    echo -e "  1️⃣  8️⃣ Delete Module Source"
    echo ""
    print_section_header "PROXY GENERATION"
    echo -e "  1️⃣  9️⃣ Generate Proxy"
    echo -e "  2️⃣  0️⃣ Remove Proxy"
    echo ""
    print_section_header "VERSION MANAGEMENT"
    echo -e "  2️⃣  1️⃣ Switch to Preview"
    echo -e "  2️⃣  2️⃣ Switch to Nightly"
    echo -e "  2️⃣  3️⃣ Switch to Stable"
    echo -e "  2️⃣  4️⃣ Switch to Local"
    echo ""
    print_section_header "🎨 ENTITY GENERATION (Custom)"
    echo -e "  ${GREEN}2️⃣  5️⃣ Add Entity with CRUD${NC}"
    echo -e "  ${GREEN}2️⃣  6️⃣ Generate from JSON${NC}"
    echo ""
    print_section_header "🗑️  ENTITY CLEANUP"
    echo -e "  ${YELLOW}3️⃣  9️⃣ Rollback Last Generated Entity${NC}"
    echo -e "  ${YELLOW}4️⃣  0️⃣ Delete Entity by Name${NC}"
    echo -e "  ${CYAN}4️⃣  1️⃣ List Generated Entities${NC}"
    echo -e "  ${RED}4️⃣  2️⃣ Clean All Generated Files${NC}"
    echo ""
    print_section_header "AUTHENTICATION"
    echo -e "  2️⃣  7️⃣ Login"
    echo -e "  2️⃣  8️⃣ Login Info"
    echo -e "  2️⃣  9️⃣ Logout"
    echo ""
    print_section_header "BUILD & BUNDLE"
    echo -e "  3️⃣  0️⃣ Bundle (Blazor/MAUI)"
    echo -e "  3️⃣  1️⃣ Install Libs"
    echo ""
    print_section_header "LOCALIZATION"
    echo -e "  3️⃣  2️⃣ Translate"
    echo ""
    print_section_header "UTILITIES"
    echo -e "  3️⃣  3️⃣ Check Extensions"
    echo -e "  3️⃣  4️⃣ Install Old CLI"
    echo -e "  3️⃣  5️⃣ Generate Razor Page"
    echo -e "  3️⃣  6️⃣ Check Dependencies"
    echo -e "  3️⃣  7️⃣ ABP Help"
    echo -e "  3️⃣  8️⃣ ABP CLI Info"
    echo ""
    echo -e "  ${RED}9️⃣  9️⃣ Exit${NC}"
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
    read -p "Enter your choice: " choice
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
            # Pass through to ABP CLI directly
            if ! command -v abp &> /dev/null; then
                log_error "ABP CLI not found. Install with: dotnet tool install -g Volo.Abp.Cli"
                exit 1
            fi
            
            # Special handling for update command
            if [ "$operation" = "update" ]; then
                local has_solution_name=false
                local args=("$@")
                
                for ((i=0; i<${#args[@]}; i++)); do
                    if [ "${args[i]}" = "--solution-name" ] || [ "${args[i]}" = "-sn" ] || [ "${args[i]}" = "--sn" ]; then
                        has_solution_name=true
                        break
                    fi
                done
                
                if [ "$has_solution_name" = false ]; then
                    local sln_files=$(find . -maxdepth 1 -name "*.sln" -type f 2>/dev/null)
                    if [ -z "$sln_files" ]; then
                        log_error "No solution name provided and no .sln file found in current directory."
                        log_info "Please either:"
                        log_info "  1. Provide --solution-name parameter"
                        log_info "  2. Run the command from within a solution directory"
                        exit 1
                    fi
                    
                    # Auto-detect solution name from .sln file (use first one if multiple exist)
                    local first_sln=$(echo "$sln_files" | head -n1)
                    local detected_solution_name=$(basename "$first_sln" .sln)
                    log_info "Auto-detected solution name: $detected_solution_name"
                    
                    # Add solution name to arguments
                    set -- "$operation" --solution-name "$detected_solution_name" "$@"
                fi
            fi
            
            log_info "Executing: abp $operation $*"
            
            # Execute with proper error handling (temporarily disable set -e)
            set +e  # Don't exit on error
            abp "$operation" "$@" 2>&1
            local exit_code=$?
            set -e  # Re-enable exit on error
            
            case $exit_code in
                0)
                    log_success "Command completed successfully"
                    ;;
                134|6)
                    # Abort trap (SIGABRT) - usually indicates a crash
                    log_error "ABP CLI crashed (Abort trap: 6, exit code: $exit_code)"
                    log_error "This may indicate invalid arguments, missing files, or corrupted installation."
                    log_info "Try running the command directly: abp $operation $*"
                    echo ""
                    show_usage
                    exit 1
                    ;;
                *)
                    log_error "Command failed with exit code $exit_code"
                    echo ""
                    show_usage
                    exit 1
                    ;;
            esac
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
    echo ""
    echo "PROJECT MANAGEMENT:"
    echo "  ./abp-generator.sh create-project --name <name> --template <type>"
    echo "  ./abp-generator.sh new --name <name> [options]"
    echo "  ./abp-generator.sh new-module --name <name> [options]"
    echo "  ./abp-generator.sh new-package --name <name> [options]"
    echo "  ./abp-generator.sh init-solution --name <name> [options]"
    echo "  ./abp-generator.sh update [--solution-name <name>]"
    echo "  ./abp-generator.sh upgrade [--solution-name <name>]"
    echo "  ./abp-generator.sh clean [--solution-name <name>]"
    echo ""
    echo "MODULE & PACKAGE MANAGEMENT:"
    echo "  ./abp-generator.sh add-package --project <path> --package <name>"
    echo "  ./abp-generator.sh add-package-ref --project <path> --package <name>"
    echo "  ./abp-generator.sh install-module --solution-name <name> --module <name>"
    echo "  ./abp-generator.sh install-local-module --solution-name <name> --module <path>"
    echo "  ./abp-generator.sh list-modules"
    echo "  ./abp-generator.sh list-templates"
    echo ""
    echo "SOURCE CODE MANAGEMENT:"
    echo "  ./abp-generator.sh get-source --module <name>"
    echo "  ./abp-generator.sh add-source-code --solution-name <name> --module <name>"
    echo "  ./abp-generator.sh list-module-sources"
    echo "  ./abp-generator.sh add-module-source --name <name> --url <url>"
    echo "  ./abp-generator.sh delete-module-source --name <name>"
    echo ""
    echo "PROXY GENERATION:"
    echo "  ./abp-generator.sh generate-proxy [options]"
    echo "  ./abp-generator.sh remove-proxy [options]"
    echo ""
    echo "VERSION MANAGEMENT:"
    echo "  ./abp-generator.sh switch-to-preview [--solution-name <name>]"
    echo "  ./abp-generator.sh switch-to-nightly [--solution-name <name>]"
    echo "  ./abp-generator.sh switch-to-stable [--solution-name <name>]"
    echo "  ./abp-generator.sh switch-to-local [--solution-name <name>]"
    echo ""
    echo "ENTITY GENERATION (Custom):"
    echo "  ./abp-generator.sh add-entity --from-json <file.json>"
    echo "  ./abp-generator.sh add-entity --module <module> --name <name>"
    echo ""
    echo "ENTITY CLEANUP:"
    echo "  ./abp-generator.sh rollback"
    echo "  ./abp-generator.sh delete-entity --name <entity>"
    echo "  ./abp-generator.sh list-entities"
    echo "  ./abp-generator.sh clean-all"
    echo ""
    echo "AUTHENTICATION:"
    echo "  ./abp-generator.sh login [--username <user>] [--password <pass>]"
    echo "  ./abp-generator.sh login-info"
    echo "  ./abp-generator.sh logout"
    echo ""
    echo "BUILD & BUNDLE:"
    echo "  ./abp-generator.sh bundle [--working-directory <path>]"
    echo "  ./abp-generator.sh install-libs [--working-directory <path>]"
    echo ""
    echo "LOCALIZATION:"
    echo "  ./abp-generator.sh translate --culture <code> [options]"
    echo ""
    echo "UTILITIES:"
    echo "  ./abp-generator.sh check-extensions"
    echo "  ./abp-generator.sh install-old-cli [--version <version>]"
    echo "  ./abp-generator.sh generate-razor-page [--working-directory <path>]"
    echo "  ./abp-generator.sh help [<command>]"
    echo "  ./abp-generator.sh cli"
    echo ""
    echo "KUBERNETES:"
    echo "  ./abp-generator.sh kube-connect --context <name>"
    echo "  ./abp-generator.sh kube-intercept --service <name>"
    echo ""
    echo "Examples:"
    echo "  ./abp-generator.sh                                          # Interactive mode"
    echo "  ./abp-generator.sh create-project --name MyApp --template app"
    echo "  ./abp-generator.sh add-entity --from-json product.json"
    echo "  ./abp-generator.sh list-entities                           # List generated entities"
    echo "  ./abp-generator.sh rollback                                # Undo last entity"
    echo "  ./abp-generator.sh install-module --solution-name MyApp --module Volo.Blogging"
    echo ""
    echo "For more information, visit: https://abp.io/docs/latest/cli"
}

################################################################################
# SECTION 14: ABP CLI Command Wrappers
################################################################################

execute_abp_command() {
    local command=$1
    shift
    local args=("$@")
    
    if ! command -v abp &> /dev/null; then
        log_error "ABP CLI not found. Install with: dotnet tool install -g Volo.Abp.Cli"
        return 1
    fi
    
    # Validate command is not empty
    if [ -z "$command" ]; then
        log_error "Command cannot be empty"
        return 1
    fi
    
    # Filter out empty arguments to prevent issues
    local filtered_args=()
    for arg in "${args[@]}"; do
        # Only add non-empty arguments
        if [ -n "$arg" ] && [ "$arg" != "" ]; then
            filtered_args+=("$arg")
        fi
    done
    
    log_info "Executing: abp $command ${filtered_args[*]}"
    
    # Execute with proper error handling (temporarily disable set -e)
    set +e  # Don't exit on error
    abp "$command" "${filtered_args[@]}" 2>&1
    local exit_code=$?
    set -e  # Re-enable exit on error
    
    # Handle different exit codes
    case $exit_code in
        0)
            log_success "Command completed successfully"
            return 0
            ;;
        134|6)
            # Abort trap (SIGABRT) - usually indicates a crash
            log_error "ABP CLI crashed (Abort trap: 6, exit code: $exit_code)"
            log_error "This may indicate:"
            log_error "  1. Invalid arguments or parameters"
            log_error "  2. Missing required files or directories"
            log_error "  3. Corrupted ABP CLI installation"
            log_error "  4. Missing solution name when required"
            log_info "Try running the command directly to see full error:"
            log_info "  abp $command ${filtered_args[*]}"
            log_info "Or reinstall ABP CLI: dotnet tool update -g Volo.Abp.Cli"
            return 1
            ;;
        *)
            log_error "Command failed with exit code $exit_code"
            return 1
            ;;
    esac
}

# Project & Solution Commands
abp_new() {
    local name=$1
    shift
    local args=("$@")
    
    if [ -z "$name" ]; then
        log_error "Name is required"
        return 1
    fi
    
    execute_abp_command "new" --name "$name" "${args[@]}"
}

abp_new_module() {
    local name=$1
    shift
    local args=("$@")
    
    if [ -z "$name" ]; then
        log_error "Name is required"
        return 1
    fi
    
    execute_abp_command "new-module" --name "$name" "${args[@]}"
}

abp_new_package() {
    local name=$1
    shift
    local args=("$@")
    
    if [ -z "$name" ]; then
        log_error "Name is required"
        return 1
    fi
    
    execute_abp_command "new-package" --name "$name" "${args[@]}"
}

abp_init_solution() {
    local name=$1
    shift
    local args=("$@")
    
    if [ -z "$name" ]; then
        log_error "Name is required"
        return 1
    fi
    
    execute_abp_command "init-solution" --name "$name" "${args[@]}"
}

abp_update() {
    # Check if solution-name is provided in arguments
    local has_solution_name=false
    local args=("$@")
    
    for ((i=0; i<${#args[@]}; i++)); do
        if [ "${args[i]}" = "--solution-name" ] || [ "${args[i]}" = "-sn" ] || [ "${args[i]}" = "--sn" ]; then
            has_solution_name=true
            break
        fi
    done
    
    # If no solution name provided, auto-detect from .sln file
    if [ "$has_solution_name" = false ]; then
        local sln_files=$(find . -maxdepth 1 -name "*.sln" -type f 2>/dev/null)
        if [ -z "$sln_files" ]; then
            log_error "No solution name provided and no .sln file found in current directory."
            log_info "Please either:"
            log_info "  1. Provide --solution-name parameter"
            log_info "  2. Run the command from within a solution directory"
            return 1
        fi
        
        # Auto-detect solution name from .sln file (use first one if multiple exist)
        local first_sln=$(echo "$sln_files" | head -n1)
        local detected_solution_name=$(basename "$first_sln" .sln)
        log_info "Auto-detected solution name: $detected_solution_name"
        
        # Add solution name to arguments
        args=("--solution-name" "$detected_solution_name" "${args[@]}")
    fi
    
    execute_abp_command "update" "${args[@]}"
}

abp_upgrade() {
    execute_abp_command "upgrade" "$@"
}

abp_clean() {
    execute_abp_command "clean" "$@"
}

# Package & Module Management
abp_add_package() {
    local project=$1
    local package=$2
    shift 2
    local args=("$@")
    
    if [ -z "$project" ] || [ -z "$package" ]; then
        log_error "Both --project and --package are required"
        return 1
    fi
    
    execute_abp_command "add-package" --project "$project" --package "$package" "${args[@]}"
}

abp_add_package_ref() {
    local project=$1
    local package=$2
    shift 2
    local args=("$@")
    
    if [ -z "$project" ] || [ -z "$package" ]; then
        log_error "Both --project and --package are required"
        return 1
    fi
    
    execute_abp_command "add-package-ref" --project "$project" --package "$package" "${args[@]}"
}

abp_install_module() {
    local solution_name=$1
    local module=$2
    shift 2
    local args=("$@")
    
    if [ -z "$solution_name" ] || [ -z "$module" ]; then
        log_error "Both --solution-name and --module are required"
        return 1
    fi
    
    execute_abp_command "install-module" --solution-name "$solution_name" --module "$module" "${args[@]}"
}

abp_install_local_module() {
    local solution_name=$1
    local module=$2
    shift 2
    local args=("$@")
    
    if [ -z "$solution_name" ] || [ -z "$module" ]; then
        log_error "Both --solution-name and --module are required"
        return 1
    fi
    
    execute_abp_command "install-local-module" --solution-name "$solution_name" --module "$module" "${args[@]}"
}

abp_list_modules() {
    execute_abp_command "list-modules" "$@"
}

abp_list_templates() {
    execute_abp_command "list-templates" "$@"
}

# Source Code Management
abp_get_source() {
    local module=$1
    shift
    local args=("$@")
    
    if [ -z "$module" ]; then
        log_error "Module is required (--module)"
        return 1
    fi
    
    execute_abp_command "get-source" --module "$module" "${args[@]}"
}

abp_add_source_code() {
    local solution_name=$1
    local module=$2
    shift 2
    local args=("$@")
    
    if [ -z "$solution_name" ] || [ -z "$module" ]; then
        log_error "Both --solution-name and --module are required"
        return 1
    fi
    
    execute_abp_command "add-source-code" --solution-name "$solution_name" --module "$module" "${args[@]}"
}

abp_list_module_sources() {
    execute_abp_command "list-module-sources" "$@"
}

abp_add_module_source() {
    local name=$1
    local url=$2
    
    if [ -z "$name" ] || [ -z "$url" ]; then
        log_error "Both --name and --url are required"
        return 1
    fi
    
    execute_abp_command "add-module-source" --name "$name" --url "$url"
}

abp_delete_module_source() {
    local name=$1
    
    if [ -z "$name" ]; then
        log_error "Name is required (--name)"
        return 1
    fi
    
    execute_abp_command "delete-module-source" --name "$name"
}

# Proxy Generation
abp_generate_proxy() {
    execute_abp_command "generate-proxy" "$@"
}

abp_remove_proxy() {
    execute_abp_command "remove-proxy" "$@"
}

# Version Management
abp_switch_to_preview() {
    execute_abp_command "switch-to-preview" "$@"
}

abp_switch_to_nightly() {
    execute_abp_command "switch-to-nightly" "$@"
}

abp_switch_to_stable() {
    execute_abp_command "switch-to-stable" "$@"
}

abp_switch_to_local() {
    execute_abp_command "switch-to-local" "$@"
}

# Localization
abp_translate() {
    local culture=$1
    shift
    local args=("$@")
    
    if [ -z "$culture" ]; then
        log_error "Culture is required (--culture)"
        return 1
    fi
    
    execute_abp_command "translate" --culture "$culture" "${args[@]}"
}

# Authentication
abp_login() {
    execute_abp_command "login" "$@"
}

abp_login_info() {
    execute_abp_command "login-info" "$@"
}

abp_logout() {
    execute_abp_command "logout" "$@"
}

# Build & Bundle
abp_bundle() {
    execute_abp_command "bundle" "$@"
}

abp_install_libs() {
    execute_abp_command "install-libs" "$@"
}

# Utilities
abp_check_extensions() {
    execute_abp_command "check-extensions" "$@"
}

abp_install_old_cli() {
    execute_abp_command "install-old-cli" "$@"
}

abp_generate_razor_page() {
    execute_abp_command "generate-razor-page" "$@"
}

# Kubernetes
abp_kube_connect() {
    local context=$1
    shift
    local args=("$@")
    
    if [ -z "$context" ]; then
        log_error "Context is required (--context)"
        return 1
    fi
    
    execute_abp_command "kube-connect" --context "$context" "${args[@]}"
}

abp_kube_intercept() {
    local service=$1
    shift
    local args=("$@")
    
    if [ -z "$service" ]; then
        log_error "Service is required (--service)"
        return 1
    fi
    
    execute_abp_command "kube-intercept" --service "$service" "${args[@]}"
}

# Help & Info
abp_help() {
    if [ $# -gt 0 ]; then
        abp help "$@"
    else
        abp help
    fi
}

abp_cli() {
    abp cli "$@"
}

################################################################################
# SECTION 15: Interactive Command Wrappers
################################################################################

interactive_new_module() {
    print_header "Create New Module"
    read -p "Enter module name: " name
    if [ -z "$name" ]; then
        log_error "Module name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter template [module] (default: module): " template
    template=${template:-module}
    read -p "Enter database provider [ef/mongodb] (default: ef): " db_provider
    db_provider=${db_provider:-ef}
    abp_new_module "$name" --template "$template" --database-provider "$db_provider"
    read -p "Press Enter to continue..."
}

interactive_new_package() {
    print_header "Create New Package"
    read -p "Enter package name: " name
    if [ -z "$name" ]; then
        log_error "Package name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter template [package] (default: package): " template
    template=${template:-package}
    abp_new_package "$name" --template "$template"
    read -p "Press Enter to continue..."
}

interactive_init_solution() {
    print_header "Initialize Solution"
    read -p "Enter solution name: " name
    if [ -z "$name" ]; then
        log_error "Solution name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter template [app] (default: app): " template
    template=${template:-app}
    read -p "Enter database provider [ef/mongodb] (default: ef): " db_provider
    db_provider=${db_provider:-ef}
    abp_init_solution "$name" --template "$template" --database-provider "$db_provider"
    read -p "Press Enter to continue..."
}

interactive_update() {
    print_header "Update Solution"
    read -p "Enter solution name (optional): " solution_name
    read -p "Skip build? [y/N]: " skip_build
    local args=()
    [ -n "$solution_name" ] && args+=(--solution-name "$solution_name")
    [ "$skip_build" = "y" ] || [ "$skip_build" = "Y" ] && args+=(--no-build)
    abp_update "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_upgrade() {
    print_header "Upgrade Solution"
    read -p "Enter solution name (optional): " solution_name
    read -p "Check only? [y/N]: " check_only
    local args=()
    [ -n "$solution_name" ] && args+=(--solution-name "$solution_name")
    [ "$check_only" = "y" ] || [ "$check_only" = "Y" ] && args+=(--check)
    abp_upgrade "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_clean() {
    print_header "Clean Solution"
    read -p "Enter solution name (optional): " solution_name
    local args=()
    [ -n "$solution_name" ] && args+=(--solution-name "$solution_name")
    abp_clean "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_add_package() {
    print_header "Add Package"
    read -p "Enter project path: " project
    if [ -z "$project" ]; then
        log_error "Project path is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter package name: " package
    if [ -z "$package" ]; then
        log_error "Package name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter version (optional): " version
    read -p "Include source code? [y/N]: " with_source
    local args=()
    [ -n "$version" ] && args+=(--version "$version")
    [ "$with_source" = "y" ] || [ "$with_source" = "Y" ] && args+=(--with-source-code)
    abp_add_package "$project" "$package" "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_add_package_ref() {
    print_header "Add Package Reference"
    read -p "Enter project path: " project
    if [ -z "$project" ]; then
        log_error "Project path is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter package name: " package
    if [ -z "$package" ]; then
        log_error "Package name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter version (optional): " version
    local args=()
    [ -n "$version" ] && args+=(--version "$version")
    abp_add_package_ref "$project" "$package" "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_install_module() {
    print_header "Install Module"
    read -p "Enter solution name: " solution_name
    if [ -z "$solution_name" ]; then
        log_error "Solution name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter module name: " module
    if [ -z "$module" ]; then
        log_error "Module name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter version (optional): " version
    read -p "Skip DB migrations? [y/N]: " skip_db
    local args=()
    [ -n "$version" ] && args+=(--version "$version")
    [ "$skip_db" = "y" ] || [ "$skip_db" = "Y" ] && args+=(--skip-db-migrations)
    abp_install_module "$solution_name" "$module" "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_install_local_module() {
    print_header "Install Local Module"
    read -p "Enter solution name: " solution_name
    if [ -z "$solution_name" ]; then
        log_error "Solution name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter module path: " module_path
    if [ -z "$module_path" ]; then
        log_error "Module path is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Skip DB migrations? [y/N]: " skip_db
    local args=()
    [ "$skip_db" = "y" ] || [ "$skip_db" = "Y" ] && args+=(--skip-db-migrations)
    abp_install_local_module "$solution_name" "$module_path" "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_get_source() {
    print_header "Get Module Source"
    read -p "Enter module name: " module
    if [ -z "$module" ]; then
        log_error "Module name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter version (optional): " version
    read -p "Enter output folder (optional): " output
    local args=()
    [ -n "$version" ] && args+=(--version "$version")
    [ -n "$output" ] && args+=(--output-folder "$output")
    abp_get_source "$module" "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_add_source_code() {
    print_header "Add Source Code"
    read -p "Enter solution name: " solution_name
    if [ -z "$solution_name" ]; then
        log_error "Solution name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter module name: " module
    if [ -z "$module" ]; then
        log_error "Module name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter version (optional): " version
    local args=()
    [ -n "$version" ] && args+=(--version "$version")
    abp_add_source_code "$solution_name" "$module" "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_add_module_source() {
    print_header "Add Module Source"
    read -p "Enter source name: " name
    if [ -z "$name" ]; then
        log_error "Source name is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter source URL: " url
    if [ -z "$url" ]; then
        log_error "Source URL is required"
        read -p "Press Enter to continue..."
        return
    fi
    abp_add_module_source "$name" "$url"
    read -p "Press Enter to continue..."
}

interactive_delete_module_source() {
    print_header "Delete Module Source"
    read -p "Enter source name: " name
    if [ -z "$name" ]; then
        log_error "Source name is required"
        read -p "Press Enter to continue..."
        return
    fi
    abp_delete_module_source "$name"
    read -p "Press Enter to continue..."
}

interactive_generate_proxy() {
    print_header "Generate Proxy"
    read -p "Enter module name (optional): " module
    read -p "Enter output path (optional): " output
    read -p "Enter API name (optional): " api_name
    read -p "Enter target [angular/react-native] (optional): " target
    read -p "Angular? [y/N]: " angular
    read -p "React Native? [y/N]: " react_native
    local args=()
    [ -n "$module" ] && args+=(--module "$module")
    [ -n "$output" ] && args+=(--output "$output")
    [ -n "$api_name" ] && args+=(--api-name "$api_name")
    [ -n "$target" ] && args+=(--target "$target")
    [ "$angular" = "y" ] || [ "$angular" = "Y" ] && args+=(--angular)
    [ "$react_native" = "y" ] || [ "$react_native" = "Y" ] && args+=(--react-native)
    abp_generate_proxy "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_remove_proxy() {
    print_header "Remove Proxy"
    read -p "Enter module name (optional): " module
    read -p "Enter API name (optional): " api_name
    local args=()
    [ -n "$module" ] && args+=(--module "$module")
    [ -n "$api_name" ] && args+=(--api-name "$api_name")
    abp_remove_proxy "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_switch_to_preview() {
    print_header "Switch to Preview"
    read -p "Enter solution name (optional): " solution_name
    local args=()
    [ -n "$solution_name" ] && args+=(--solution-name "$solution_name")
    abp_switch_to_preview "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_switch_to_nightly() {
    print_header "Switch to Nightly"
    read -p "Enter solution name (optional): " solution_name
    local args=()
    [ -n "$solution_name" ] && args+=(--solution-name "$solution_name")
    abp_switch_to_nightly "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_switch_to_stable() {
    print_header "Switch to Stable"
    read -p "Enter solution name (optional): " solution_name
    local args=()
    [ -n "$solution_name" ] && args+=(--solution-name "$solution_name")
    abp_switch_to_stable "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_switch_to_local() {
    print_header "Switch to Local"
    read -p "Enter solution name (optional): " solution_name
    local args=()
    [ -n "$solution_name" ] && args+=(--solution-name "$solution_name")
    abp_switch_to_local "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_login() {
    print_header "Login"
    read -p "Enter username (optional, will prompt if not provided): " username
    read -sp "Enter password (optional, will prompt if not provided): " password
    echo
    local args=()
    [ -n "$username" ] && args+=(--username "$username")
    [ -n "$password" ] && args+=(--password "$password")
    abp_login "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_bundle() {
    print_header "Bundle (Blazor/MAUI)"
    read -p "Enter working directory (optional): " working_dir
    read -p "Force rebuild? [y/N]: " force
    read -p "Enter project type [webassembly/maui-blazor] (default: webassembly): " project_type
    project_type=${project_type:-webassembly}
    local args=()
    [ -n "$working_dir" ] && args+=(--working-directory "$working_dir")
    [ "$force" = "y" ] || [ "$force" = "Y" ] && args+=(--force)
    [ -n "$project_type" ] && args+=(--project-type "$project_type")
    abp_bundle "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_install_libs() {
    print_header "Install Libs"
    read -p "Enter working directory (optional): " working_dir
    local args=()
    [ -n "$working_dir" ] && args+=(--working-directory "$working_dir")
    abp_install_libs "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_translate() {
    print_header "Translate"
    read -p "Enter culture code (e.g., en, tr, fr): " culture
    if [ -z "$culture" ]; then
        log_error "Culture code is required"
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter output path (optional): " output
    read -p "Translate all? [y/N]: " all
    local args=()
    [ -n "$output" ] && args+=(--output "$output")
    [ "$all" = "y" ] || [ "$all" = "Y" ] && args+=(--all)
    abp_translate "$culture" "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_install_old_cli() {
    print_header "Install Old CLI"
    read -p "Enter version (optional, latest if not specified): " version
    local args=()
    [ -n "$version" ] && args+=(--version "$version")
    abp_install_old_cli "${args[@]}"
    read -p "Press Enter to continue..."
}

interactive_generate_razor_page() {
    print_header "Generate Razor Page"
    read -p "Enter working directory (optional): " working_dir
    local args=()
    [ -n "$working_dir" ] && args+=(--working-directory "$working_dir")
    abp_generate_razor_page "${args[@]}"
    read -p "Press Enter to continue..."
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
            2) interactive_new_module ;;
            3) interactive_new_package ;;
            4) interactive_init_solution ;;
            5) interactive_update ;;
            6) interactive_upgrade ;;
            7) interactive_clean ;;
            8) interactive_add_package ;;
            9) interactive_add_package_ref ;;
            10) interactive_install_module ;;
            11) interactive_install_local_module ;;
            12) abp_list_modules; read -p "Press Enter to continue..." ;;
            13) abp_list_templates; read -p "Press Enter to continue..." ;;
            14) interactive_get_source ;;
            15) interactive_add_source_code ;;
            16) abp_list_module_sources; read -p "Press Enter to continue..." ;;
            17) interactive_add_module_source ;;
            18) interactive_delete_module_source ;;
            19) interactive_generate_proxy ;;
            20) interactive_remove_proxy ;;
            21) interactive_switch_to_preview ;;
            22) interactive_switch_to_nightly ;;
            23) interactive_switch_to_stable ;;
            24) interactive_switch_to_local ;;
            25) add_entity_with_crud ;;
            26) generate_from_json_menu ;;
            27) interactive_login ;;
            28) abp_login_info; read -p "Press Enter to continue..." ;;
            29) abp_logout; read -p "Press Enter to continue..." ;;
            30) interactive_bundle ;;
            31) interactive_install_libs ;;
            32) interactive_translate ;;
            33) abp_check_extensions; read -p "Press Enter to continue..." ;;
            34) interactive_install_old_cli ;;
            35) interactive_generate_razor_page ;;
            36) check_dependencies; read -p "Press Enter to continue..." ;;
            37) abp_help; read -p "Press Enter to continue..." ;;
            38) abp_cli; read -p "Press Enter to continue..." ;;
            39) rollback_last_entity ;;
            40) delete_entity_by_name ;;
            41) list_generated_entities ;;
            42) clean_all_generated_files ;;
            99) 
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

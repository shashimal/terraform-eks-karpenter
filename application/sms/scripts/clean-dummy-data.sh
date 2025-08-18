#!/bin/bash

# Clean Dummy Data Script for SMS Application
# This script removes all students and courses from the SMS application

set -e

# Configuration
STUDENT_SERVICE_URL="http://localhost:3001/api/students"
COURSE_SERVICE_URL="http://localhost:3002/api/courses"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_data() {
    echo -e "${CYAN}[DATA]${NC} $1"
}

# Function to check if services are running
check_services() {
    print_status "Checking if SMS services are running..."
    
    if ! curl -s "$STUDENT_SERVICE_URL" > /dev/null; then
        print_error "Student service is not accessible at $STUDENT_SERVICE_URL"
        print_error "Please start your services with: docker-compose up"
        exit 1
    fi
    
    if ! curl -s "$COURSE_SERVICE_URL" > /dev/null; then
        print_error "Course service is not accessible at $COURSE_SERVICE_URL"
        print_error "Please start your services with: docker-compose up"
        exit 1
    fi
    
    print_success "All services are running"
}

# Function to get current data count
get_data_counts() {
    local student_response=$(curl -s "$STUDENT_SERVICE_URL")
    local course_response=$(curl -s "$COURSE_SERVICE_URL")
    
    local student_count=$(echo "$student_response" | grep -o '"_id"' | wc -l | tr -d ' ')
    local course_count=$(echo "$course_response" | grep -o '"_id"' | wc -l | tr -d ' ')
    
    echo "$student_count $course_count"
}

# Function to display current data summary
display_current_data() {
    print_status "Current data in the system:"
    
    read student_count course_count <<< "$(get_data_counts)"
    
    print_data "Students: $student_count"
    print_data "Courses: $course_count"
    
    if [ "$student_count" -gt 0 ]; then
        echo ""
        print_data "Current students:"
        curl -s "$STUDENT_SERVICE_URL" | grep -o '"firstName":"[^"]*","lastName":"[^"]*","email":"[^"]*"' | \
            sed 's/"firstName":"//g; s/","lastName":"/ /g; s/","email":"/ (/g; s/"$/)/g' | \
            while read -r line; do
                echo "  • $line"
            done
    fi
    
    if [ "$course_count" -gt 0 ]; then
        echo ""
        print_data "Current courses:"
        curl -s "$COURSE_SERVICE_URL" | grep -o '"title":"[^"]*","code":"[^"]*"' | \
            sed 's/"title":"//g; s/","code":"/ (/g; s/"$/)/g' | \
            while read -r line; do
                echo "  • $line"
            done
    fi
}

# Function to delete all students
delete_all_students() {
    print_status "Deleting all students..."
    
    # Get all student IDs
    local students_response=$(curl -s "$STUDENT_SERVICE_URL")
    local student_ids=$(echo "$students_response" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$student_ids" ]; then
        print_warning "No students found to delete"
        return
    fi
    
    local deleted_count=0
    local failed_count=0
    
    while IFS= read -r student_id; do
        if [ -n "$student_id" ]; then
            local response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X DELETE "$STUDENT_SERVICE_URL/$student_id")
            local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            
            if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 204 ]; then
                ((deleted_count++))
                print_success "Deleted student ID: $student_id"
            else
                ((failed_count++))
                print_error "Failed to delete student ID: $student_id (HTTP: $http_code)"
            fi
        fi
    done <<< "$student_ids"
    
    print_data "Students deleted: $deleted_count"
    if [ "$failed_count" -gt 0 ]; then
        print_warning "Failed deletions: $failed_count"
    fi
}

# Function to delete all courses
delete_all_courses() {
    print_status "Deleting all courses..."
    
    # Get all course IDs
    local courses_response=$(curl -s "$COURSE_SERVICE_URL")
    local course_ids=$(echo "$courses_response" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$course_ids" ]; then
        print_warning "No courses found to delete"
        return
    fi
    
    local deleted_count=0
    local failed_count=0
    
    while IFS= read -r course_id; do
        if [ -n "$course_id" ]; then
            local response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X DELETE "$COURSE_SERVICE_URL/$course_id")
            local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            
            if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 204 ]; then
                ((deleted_count++))
                print_success "Deleted course ID: $course_id"
            else
                ((failed_count++))
                print_error "Failed to delete course ID: $course_id (HTTP: $http_code)"
            fi
        fi
    done <<< "$course_ids"
    
    print_data "Courses deleted: $deleted_count"
    if [ "$failed_count" -gt 0 ]; then
        print_warning "Failed deletions: $failed_count"
    fi
}

# Function to confirm deletion
confirm_deletion() {
    local item_type="$1"
    
    echo ""
    print_warning "This will permanently delete all $item_type from the database!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled"
        exit 0
    fi
}

# Function to clean specific data type
clean_students_only() {
    display_current_data
    confirm_deletion "students"
    delete_all_students
}

clean_courses_only() {
    display_current_data
    confirm_deletion "courses"
    delete_all_courses
}

# Function to clean all data
clean_all_data() {
    display_current_data
    
    read student_count course_count <<< "$(get_data_counts)"
    
    if [ "$student_count" -eq 0 ] && [ "$course_count" -eq 0 ]; then
        print_success "Database is already clean - no data to delete"
        exit 0
    fi
    
    confirm_deletion "students and courses"
    
    # Delete students first (they reference courses)
    if [ "$student_count" -gt 0 ]; then
        delete_all_students
    fi
    
    # Then delete courses
    if [ "$course_count" -gt 0 ]; then
        delete_all_courses
    fi
}

# Function to display final summary
display_final_summary() {
    echo ""
    print_status "=== CLEANUP SUMMARY ==="
    
    read student_count course_count <<< "$(get_data_counts)"
    
    print_data "Remaining Students: $student_count"
    print_data "Remaining Courses: $course_count"
    
    if [ "$student_count" -eq 0 ] && [ "$course_count" -eq 0 ]; then
        print_success "Database successfully cleaned!"
    else
        print_warning "Some data may still remain in the database"
    fi
}

# Show help
show_help() {
    echo "SMS Application Data Cleanup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  --students       Delete only students"
    echo "  --courses        Delete only courses"
    echo "  --status         Show current data status"
    echo "  --force          Skip confirmation prompts"
    echo ""
    echo "Prerequisites:"
    echo "  • SMS services must be running (docker-compose up)"
    echo "  • curl must be installed"
    echo ""
    echo "Examples:"
    echo "  $0                    # Delete all students and courses (with confirmation)"
    echo "  $0 --students         # Delete only students"
    echo "  $0 --courses          # Delete only courses"
    echo "  $0 --status           # Show current data status"
    echo "  $0 --force            # Delete all data without confirmation"
    echo ""
    echo "WARNING: This script permanently deletes data from your database!"
}

# Main function
main() {
    local students_only=false
    local courses_only=false
    local status_only=false
    local force_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --students)
                students_only=true
                shift
                ;;
            --courses)
                courses_only=true
                shift
                ;;
            --status)
                status_only=true
                shift
                ;;
            --force)
                force_mode=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_status "Starting SMS Application data cleanup..."
    
    # Check if services are running
    check_services
    
    # Handle status only
    if [ "$status_only" = true ]; then
        display_current_data
        exit 0
    fi
    
    # Override confirmation function if force mode
    if [ "$force_mode" = true ]; then
        confirm_deletion() {
            print_warning "Force mode enabled - skipping confirmation for $1"
        }
    fi
    
    # Execute based on flags
    if [ "$students_only" = true ]; then
        clean_students_only
    elif [ "$courses_only" = true ]; then
        clean_courses_only
    else
        clean_all_data
    fi
    
    # Display final summary
    display_final_summary
    
    print_success "Data cleanup completed!"
}

# Run main function
main "$@"
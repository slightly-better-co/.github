#!/bin/bash

# Scaffold GitHub Issues from Task Files
# Creates GitHub issues from all .md and .yml files in the tasks directory
# 
# Usage: ./scaffold-issues.sh [path-to-tasks-directory]
#
# Configuration via .env file in project root:
#   GITHUB_PROJECT=ProjectName    # GitHub project to add issues to
#   GITHUB_ASSIGNEE=@me          # Who to assign issues to (defaults to @me)
#
# Example .env file:
#   GITHUB_PROJECT="Product Backlog"
#   GITHUB_ASSIGNEE="@username"

# Don't exit on errors in subshells to prevent early termination
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed. Please install it first.${NC}"
    echo "Visit: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI. Please run 'gh auth login' first.${NC}"
    exit 1
fi

# Get repository info using git remote (simpler method, no jq required)
if git remote get-url origin &>/dev/null; then
    REPO_URL=$(git remote get-url origin)
    # Handle both SSH and HTTPS URLs
    if [[ "$REPO_URL" == git@github.com:* ]]; then
        # SSH format: git@github.com:owner/repo.git
        REPO_PATH=$(echo "$REPO_URL" | sed 's/git@github.com://' | sed 's/\.git$//')
    else
        # HTTPS format: https://github.com/owner/repo.git
        REPO_PATH=$(echo "$REPO_URL" | sed 's|https://github.com/||' | sed 's/\.git$//')
    fi
    REPO_OWNER=$(echo "$REPO_PATH" | cut -d'/' -f1)
    REPO_NAME=$(echo "$REPO_PATH" | cut -d'/' -f2)
else
    echo -e "${RED}❌ Could not determine repository info. Make sure you're in a Git repository.${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Creating GitHub issues for repository: ${REPO_OWNER}/${REPO_NAME}${NC}"

# Load configuration from .env file if it exists
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    echo -e "${BLUE}📄 Loading configuration from $ENV_FILE...${NC}"
    # Source the .env file, but only load GITHUB_* variables for security
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ $line =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Only load GITHUB_* variables
        if [[ $line =~ ^GITHUB_[A-Z_]+=.* ]]; then
            export "$line"
            echo -e "${GREEN}  ✓ Loaded: ${line%%=*}${NC}"
        fi
    done < "$ENV_FILE"
else
    echo -e "${YELLOW}📄 No .env file found, using defaults${NC}"
fi

# Set default values if not provided in .env
GITHUB_PROJECT="${GITHUB_PROJECT:-}"
GITHUB_ASSIGNEE="${GITHUB_ASSIGNEE:-@me}"

# Function to extract content between markdown headers
extract_section() {
    local file="$1"
    local header="$2"
    local next_header="$3"
    
    if [ -n "$next_header" ]; then
        sed -n "/^## $header/,/^## $next_header/p" "$file" | sed '$d' | tail -n +2
    else
        sed -n "/^## $header/,\$p" "$file" | tail -n +2
    fi
}

# Function to extract title from markdown
extract_title() {
    local file="$1"
    head -n 10 "$file" | grep "^# " | sed 's/^# //' | head -n 1
}

# Function to create issue from task file
create_issue_from_task() {
    local task_file="$1"
    local sprint_dir="$2"
    
    echo -e "${YELLOW}📋 Processing: $task_file${NC}"
    
    # Extract title
    local title=$(extract_title "$task_file")
    if [ -z "$title" ]; then
        echo -e "${RED}⚠️  No title found in $task_file, skipping...${NC}"
        return
    fi
    
    # Extract sections
    local context=$(extract_section "$task_file" "🧠 Context" "✅ Acceptance Criteria")
    local acceptance_criteria=$(extract_section "$task_file" "✅ Acceptance Criteria" "📁 Files Involved")
    local files_involved=$(extract_section "$task_file" "📁 Files Involved" "🎭 Role Prompt File")
    local role_prompt=$(extract_section "$task_file" "🎭 Role Prompt File" "⏱️ Estimated Hours")
    local estimated_hours=$(extract_section "$task_file" "⏱️ Estimated Hours" "🧩 Complexity")
    local complexity=$(extract_section "$task_file" "🧩 Complexity" "🔗 Dependencies")
    local dependencies=$(extract_section "$task_file" "🔗 Dependencies" "🔧 Technical Notes")
    local technical_notes=$(extract_section "$task_file" "🔧 Technical Notes" "🧪 Testing")
    local testing=$(extract_section "$task_file" "🧪 Testing" "")
    
    # Build issue body
    local body="## 🧠 Context
$context

## ✅ Acceptance Criteria
$acceptance_criteria

## 📁 Files Involved
$files_involved

## 🎭 Role Prompt File
$role_prompt

## ⏱️ Estimated Hours
$estimated_hours

## 🧩 Complexity
$complexity"

    # Add optional sections if they exist
    if [ -n "$dependencies" ] && [ "$dependencies" != "" ]; then
        body="$body

## 🔗 Dependencies
$dependencies"
    fi
    
    if [ -n "$technical_notes" ] && [ "$technical_notes" != "" ]; then
        body="$body

## 🔧 Technical Notes
$technical_notes"
    fi
    
    if [ -n "$testing" ] && [ "$testing" != "" ]; then
        body="$body

## 🧪 Testing
$testing"
    fi
    
    # Determine labels based on sprint and content using existing org labels
    local labels=""
    
    # Add sprint-specific labels using existing org labels
    case "$sprint_dir" in
        "1-planning") labels="planning" ;;
        "2-system") labels="infra" ;;
        "3-build") labels="feature" ;;
        "4-onboarding") labels="documentation" ;;
        "5-launch") labels="marketing" ;;
    esac
    
    # Add enhancement label for new features
    if [ -n "$labels" ]; then
        labels="$labels,enhancement"
    else
        labels="enhancement"
    fi
    
    # Create the GitHub issue
    echo -e "${BLUE}Creating issue: $title${NC}"
    
    # Use a temporary file for the body to handle multiline content properly
    local temp_body_file=$(mktemp)
    echo "$body" > "$temp_body_file"
    
    # Build the gh issue create command with optional parameters
    local gh_cmd="gh issue create --title \"$title\" --body-file \"$temp_body_file\""
    
    # Add assignee (defaults to @me)
    if [ -n "$GITHUB_ASSIGNEE" ]; then
        gh_cmd="$gh_cmd --assignee \"$GITHUB_ASSIGNEE\""
    fi
    
    # Add project if specified
    if [ -n "$GITHUB_PROJECT" ]; then
        gh_cmd="$gh_cmd --project \"$GITHUB_PROJECT\""
    fi
    
    # Add labels if available
    if [ -n "$labels" ]; then
        gh_cmd="$gh_cmd --label \"$labels\""
    fi
    
    # Execute the command and capture output
    local issue_url=""
    echo -e "${BLUE}  Command: $gh_cmd${NC}"
    
    if [ -n "$labels" ]; then
        # Try to create with labels first
        issue_url=$(eval "$gh_cmd" 2>&1)
        
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ Created issue with labels: $title${NC}"
            echo -e "${BLUE}   URL: $issue_url${NC}"
        else
            # If labels fail, try without them
            echo -e "${YELLOW}⚠️  Labels failed, trying without labels...${NC}"
            gh_cmd_no_labels="gh issue create --title \"$title\" --body-file \"$temp_body_file\""
            
            if [ -n "$GITHUB_ASSIGNEE" ]; then
                gh_cmd_no_labels="$gh_cmd_no_labels --assignee \"$GITHUB_ASSIGNEE\""
            fi
            
            if [ -n "$GITHUB_PROJECT" ]; then
                gh_cmd_no_labels="$gh_cmd_no_labels --project \"$GITHUB_PROJECT\""
            fi
            
            issue_url=$(eval "$gh_cmd_no_labels" 2>&1)
            
            if [[ $? -eq 0 ]]; then
                echo -e "${YELLOW}⚠️  Created issue without labels: $title${NC}"
                echo -e "${BLUE}   URL: $issue_url${NC}"
            else
                echo -e "${RED}❌ Failed to create issue: $title${NC}"
                echo -e "${RED}   Error: $issue_url${NC}"
            fi
        fi
    else
        # Create without labels
        issue_url=$(eval "$gh_cmd" 2>&1)
        
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ Created issue: $title${NC}"
            echo -e "${BLUE}   URL: $issue_url${NC}"
        else
            echo -e "${RED}❌ Failed to create issue: $title${NC}"
            echo -e "${RED}   Error: $issue_url${NC}"
        fi
    fi
    
    # Clean up temp file
    rm "$temp_body_file"
    
    # Small delay to avoid rate limiting
    sleep 1
}

# Main execution
# Allow custom tasks directory path as first argument
TASKS_DIR="${1:-.github/tasks}"

if [ ! -d "$TASKS_DIR" ]; then
    echo -e "${RED}❌ Tasks directory not found: $TASKS_DIR${NC}"
    echo -e "${YELLOW}💡 Usage: $0 [path-to-tasks-directory]${NC}"
    echo -e "${YELLOW}   Example: $0 /path/to/.github/tasks${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Scanning for task files in $TASKS_DIR...${NC}"

# Counter for issues created
issues_created=0

# Create a temporary file to store the list of task files
temp_file_list=$(mktemp)
find "$TASKS_DIR" -type f \( -name "*.md" -o -name "*.yml" \) > "$temp_file_list"

# Process each file from the list
while IFS= read -r task_file; do
    # Skip if file doesn't exist or is empty
    if [ ! -s "$task_file" ]; then
        echo -e "${YELLOW}⏭️  Skipping empty file: $task_file${NC}"
        continue
    fi
    
    # Skip README.md files as they're not task files
    if [[ "$(basename "$task_file")" == "README.md" ]]; then
        echo -e "${YELLOW}⏭️  Skipping README file: $task_file${NC}"
        continue
    fi
    
    # Extract sprint directory name
    sprint_dir=$(basename "$(dirname "$task_file")")
    
    # Skip the root tasks directory files
    if [ "$sprint_dir" = "tasks" ] || [ "$sprint_dir" = "$(basename "$TASKS_DIR")" ]; then
        echo -e "${YELLOW}⏭️  Skipping root task file: $task_file${NC}"
        continue
    fi
    
    echo -e "${BLUE}🔍 Found task file: $task_file (sprint: $sprint_dir)${NC}"
    create_issue_from_task "$task_file" "$sprint_dir"
    ((issues_created++))
done < "$temp_file_list"

# Clean up temp file
rm "$temp_file_list"

echo -e "${GREEN}🎉 Completed! Created $issues_created GitHub issues.${NC}"
echo -e "${BLUE}💡 You can view all issues at: https://github.com/${REPO_OWNER}/${REPO_NAME}/issues${NC}"

#!/bin/bash

# Scaffold Tasks Directory Structure
# Based on the GitHub issue template: tasks/scaffold-tasks-issue.yml

set -e

echo "📋 Scaffolding .github/tasks directory structure..."

# Create sprint directories
mkdir -p .github/tasks/1-planning
mkdir -p .github/tasks/2-system
mkdir -p .github/tasks/3-build
mkdir -p .github/tasks/4-onboarding
mkdir -p .github/tasks/5-launch

# Create scaffold-docs-issue.yml in tasks root
cat > .github/tasks/scaffold-docs-issue.md << 'EOF'
# 📁 Scaffold Docs Issue Task

## 🧠 Context
Generate the foundational documentation structure under /docs/ for a new product repository.

## ✅ Acceptance Criteria
- [ ] Create all required /docs/ directories and README files
- [ ] Generate stub .md files for all planning documentation
- [ ] Ensure consistent structure across blueprint, planning, marketing, and design folders

## 📁 Files Involved
- /docs/README.md and all subdirectory structure
- All planning, blueprint, marketing, and design stub files

## 🎭 Role Prompt File
project-manager-prompt.md

## ⏱️ Estimated Hours
1 hour

## 🧩 Complexity
Low - Basic file system scaffolding

## 🔧 Technical Notes
Run the scaffold-docs.sh script to automate directory and file creation.

## 🔗 Dependencies
None - foundational task

## 🧪 Testing
Verify all directories and files exist with proper H1 headings
EOF

# Sprint 1 - Planning tasks
cat > .github/tasks/1-planning/audience-insights.md << 'EOF'
# 📊 Audience Insights Research

## 🧠 Context
Research and document target audience demographics, motivators, and language patterns for marketing positioning.

## ✅ Acceptance Criteria
- [ ] Complete demographic analysis of target users
- [ ] Identify key motivators and pain points
- [ ] Document language patterns and communication preferences
- [ ] Create audience insights summary in docs/marketing/audience-insights.md

## 📁 Files Involved
- docs/marketing/audience-insights.md

## 🎭 Role Prompt File
marketer-prompt.md

## ⏱️ Estimated Hours
3 hours

## 🧩 Complexity
Medium - Requires market research and analysis

## 🔗 Dependencies
- persona-builder.yml
EOF

cat > .github/tasks/1-planning/competitive-gap-analysis.md << 'EOF'
# 🔍 Competitive Gap Analysis

## 🧠 Context
Analyze existing solutions in the market to identify gaps and opportunities for differentiation.

## ✅ Acceptance Criteria
- [ ] Research 5-10 direct and indirect competitors
- [ ] Document feature comparison matrix
- [ ] Identify market gaps and opportunities
- [ ] Complete competitive analysis in docs/planning/competitive-analysis.md

## 📁 Files Involved
- docs/planning/competitive-analysis.md

## 🎭 Role Prompt File
research-analyst-prompt.md

## ⏱️ Estimated Hours
4 hours

## 🧩 Complexity
High - Requires thorough market research

## 🔗 Dependencies
- pain-point.yml
EOF

cat > .github/tasks/1-planning/customer-validation-survey.md << 'EOF'
# 📋 Customer Validation Survey

## 🧠 Context
Create and deploy a validation survey to test product-market fit assumptions with potential users.

## ✅ Acceptance Criteria
- [ ] Design survey questions based on pain points and personas
- [ ] Set up survey platform (Google Forms, Typeform, etc.)
- [ ] Deploy survey to target audience
- [ ] Document survey results in docs/planning/validation-survey.md

## 📁 Files Involved
- docs/planning/validation-survey.md

## 🎭 Role Prompt File
research-analyst-prompt.md

## ⏱️ Estimated Hours
3 hours

## 🧩 Complexity
Medium - Survey design and deployment

## 🔗 Dependencies
- persona-builder.yml
- pain-point.yml
EOF

cat > .github/tasks/1-planning/mvp-landing-page-copy.md << 'EOF'
# 📝 MVP Landing Page Copy

## 🧠 Context
Create compelling copy for the MVP landing page including headlines, features, and call-to-action text.

## ✅ Acceptance Criteria
- [ ] Write main headline and subheadline
- [ ] Create feature descriptions and benefits
- [ ] Develop call-to-action copy
- [ ] Complete landing page copy in docs/marketing/landing-page-copy.md

## 📁 Files Involved
- docs/marketing/landing-page-copy.md

## 🎭 Role Prompt File
marketer-prompt.md

## ⏱️ Estimated Hours
4 hours

## 🧩 Complexity
High - Requires copywriting expertise

## 🔗 Dependencies
- audience-insights.yml
- persona-builder.yml
EOF

cat > .github/tasks/1-planning/pain-point.md << 'EOF'
# 🎯 Pain Point Analysis

## 🧠 Context
Research and document real user problems that the product should solve.

## ✅ Acceptance Criteria
- [ ] Identify 3-5 core pain points through user research
- [ ] Validate pain points with target audience
- [ ] Prioritize pain points by severity and frequency
- [ ] Document findings in docs/planning/pain-points.md

## 📁 Files Involved
- docs/planning/pain-points.md

## 🎭 Role Prompt File
research-analyst-prompt.md

## ⏱️ Estimated Hours
3 hours

## 🧩 Complexity
Medium - User research and analysis

## 🔗 Dependencies
None - foundational research task
EOF

cat > .github/tasks/1-planning/persona-builder.md << 'EOF'
# 👥 User Persona Development

## 🧠 Context
Create detailed user personas based on research to guide product development and marketing decisions.

## ✅ Acceptance Criteria
- [ ] Develop 2-3 primary user personas
- [ ] Include demographics, goals, frustrations, and behaviors
- [ ] Validate personas with user interviews or surveys
- [ ] Document personas in docs/planning/user-personas.md

## 📁 Files Involved
- docs/planning/user-personas.md

## 🎭 Role Prompt File
research-analyst-prompt.md

## ⏱️ Estimated Hours
4 hours

## 🧩 Complexity
High - Requires user research and synthesis

## 🔗 Dependencies
- pain-point.yml
EOF

cat > .github/tasks/1-planning/trend-scanner-reddit.md << 'EOF'
# 📡 Reddit Trend Scanning

## 🧠 Context
Monitor relevant Reddit communities to identify trends, discussions, and insights related to the target market.

## ✅ Acceptance Criteria
- [ ] Identify 5-10 relevant subreddits
- [ ] Monitor discussions for 1-2 weeks
- [ ] Extract key trends and insights
- [ ] Document findings and implications for product direction

## 📁 Files Involved
- docs/planning/reddit-trends.md

## 🎭 Role Prompt File
research-analyst-prompt.md

## ⏱️ Estimated Hours
2 hours

## 🧩 Complexity
Low - Social media monitoring

## 🔗 Dependencies
- pain-point.yml
EOF

echo "✅ Tasks directory structure scaffolded successfully!"
echo "📝 Created:"
echo "  - .github/tasks/scaffold-docs-issue.yml"
echo "  - Sprint 1 Planning: 9 task files"
echo "  - Sprint 2 System: 1 task file"
echo "  - Sprint 3-5: Empty directories prepared"
echo "🚀 Ready for project management workflows!"
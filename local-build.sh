#!/bin/bash


set -e  # Exit on any error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Proton Prediction Market - Local Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FRONTEND_DIR="${SCRIPT_DIR}/frontend"

if [ ! -d "$FRONTEND_DIR" ]; then
    echo -e "${RED}Error: Frontend directory not found at $FRONTEND_DIR${NC}"
    exit 1
fi

cd "$FRONTEND_DIR"

if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install Node.js 16 or higher.${NC}"
    exit 1
fi

echo -e "${GREEN}Node.js version: $(node --version)${NC}"
echo -e "${GREEN}npm version: $(npm --version)${NC}"
echo ""

if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Warning: .env file not found!${NC}"
    echo -e "${YELLOW}Using default environment variables.${NC}"
    echo -e "${YELLOW}Create a .env file with your configuration for production.${NC}"
    echo ""
fi

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
    echo ""
else
    echo -e "${GREEN}Dependencies already installed.${NC}"
    echo ""
fi

echo -e "${YELLOW}Building React application...${NC}"
npm run build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo ""
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

DEPLOY_DIR="${SCRIPT_DIR}/deploy-package"
echo -e "${YELLOW}Creating deployment package...${NC}"

rm -rf "$DEPLOY_DIR"

mkdir -p "$DEPLOY_DIR"

cp -r build/* "$DEPLOY_DIR/"

if [ -f "${SCRIPT_DIR}/.htaccess.template" ]; then
    cp "${SCRIPT_DIR}/.htaccess.template" "${DEPLOY_DIR}/.htaccess"
    echo -e "${GREEN}.htaccess file added to deployment package${NC}"
fi

cat > "${DEPLOY_DIR}/DEPLOY_INSTRUCTIONS.txt" << 'EOF'
DEPLOYMENT INSTRUCTIONS FOR CPANEL
===================================

1. Upload all files in this directory to your cPanel server at:
   /home/pawnline/public_html/

2. Make sure the following files are in /home/pawnline/public_html/:
   - index.html (main entry point)
   - .htaccess (for React Router support)
   - All static files (js, css, images, etc.)

3. Verify the .htaccess file is present and contains the React Router configuration.

4. Set proper file permissions:
   - Files: 644
   - Directories: 755

5. Test your deployment by visiting: https://pawnline.io

IMPORTANT NOTES:
- Do NOT upload node_modules or source files to public_html
- Only upload the contents of this deploy-package directory
- The .htaccess file is critical for React Router to work properly
- If you have SSL enabled, uncomment the HTTPS redirect in .htaccess

TROUBLESHOOTING:
- If pages return 404 errors, check that .htaccess is present and mod_rewrite is enabled
- If assets don't load, check the PUBLIC_URL in your .env file
- If the app doesn't connect to Proton, verify your REACT_APP_* environment variables

For more information, see the main README.md file.
EOF

echo -e "${GREEN}Deployment package created successfully!${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Build Directory: ${YELLOW}${FRONTEND_DIR}/build${NC}"
echo -e "Deployment Package: ${YELLOW}${DEPLOY_DIR}${NC}"
echo -e "Package Size: ${YELLOW}$(du -sh $DEPLOY_DIR | cut -f1)${NC}"
echo -e "Files to Deploy: ${YELLOW}$(find $DEPLOY_DIR -type f | wc -l)${NC}"
echo ""
echo -e "${GREEN}✓ Build completed successfully!${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. Upload the contents of ${YELLOW}deploy-package/${NC} to ${YELLOW}/home/pawnline/public_html/${NC}"
echo -e "2. You can use cPanel File Manager, FTP, or rsync to upload"
echo -e "3. Example rsync command:"
echo -e "   ${YELLOW}rsync -avz deploy-package/ user@server:/home/pawnline/public_html/${NC}"
echo ""

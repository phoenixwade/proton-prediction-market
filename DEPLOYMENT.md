# Deployment Guide - Proton Prediction Market

This guide covers deploying the Proton Prediction Market platform to a cPanel server.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Configuration](#environment-configuration)
3. [Deployment Methods](#deployment-methods)
4. [Post-Deployment](#post-deployment)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

### Server Requirements

- **cPanel hosting account** with:
  - SSH access (recommended) or FTP access
  - Node.js 16+ support (available via cPanel's "Setup Node.js App")
  - Apache with mod_rewrite enabled
  - Sufficient disk space (~50MB for the app)

### Local Requirements (for local build method)

- Node.js 16 or higher
- npm or yarn
- Git (to clone the repository)

## Environment Configuration

Before deploying, you need to configure environment variables for the React frontend.

### 1. Create Environment File

Create a `.env` file in the `frontend/` directory:

```bash
cd frontend
cp .env.example .env  # If .env.example exists, or create new file
```

### 2. Configure Environment Variables

Edit `frontend/.env` with your production settings:

```env
# Proton Network Configuration
REACT_APP_PROTON_ENDPOINT=https://proton.greymass.com
REACT_APP_CHAIN_ID=384da888112027f0321850a169f737c33e53b388aad48b5adace4bab97f437e0

# Contract Configuration
REACT_APP_CONTRACT_NAME=prediction

# Optional: Analytics, etc.
# REACT_APP_GA_TRACKING_ID=UA-XXXXXXXXX-X
```

**Important Notes:**
- For **testnet**, use: `https://testnet.protonchain.com` and testnet chain ID
- For **mainnet**, use: `https://proton.greymass.com` and mainnet chain ID
- The `REACT_APP_CONTRACT_NAME` should match your deployed smart contract account name
- These values are **baked into the build** - you must rebuild if you change them

### 3. Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `REACT_APP_PROTON_ENDPOINT` | Proton RPC endpoint | `https://proton.greymass.com` |
| `REACT_APP_CHAIN_ID` | Proton chain ID | `384da888112027f0321850a169f737c33e53b388aad48b5adace4bab97f437e0` |
| `REACT_APP_CONTRACT_NAME` | Smart contract account name | `prediction` |

## Deployment Methods

Choose one of the following deployment methods:

### Method 1: Build on cPanel Server (Recommended)

This method builds the app directly on your cPanel server.

#### Step 1: Upload Project Files

Upload the entire project to your cPanel server:

```bash
# Using rsync (recommended)
rsync -avz --exclude 'node_modules' --exclude '.git' \
  ./ user@pawnline.io:/home/pawnline/proton-prediction-market/

# Or using scp
scp -r . user@pawnline.io:/home/pawnline/proton-prediction-market/

# Or use cPanel File Manager to upload a zip file
```

**Important:** Upload to `/home/pawnline/proton-prediction-market/`, NOT to `public_html/`

#### Step 2: Enable Node.js in cPanel

1. Log into cPanel
2. Go to "Setup Node.js App"
3. Create a new application:
   - **Node.js version:** 16.x or higher
   - **Application root:** `/home/pawnline/proton-prediction-market/frontend`
   - **Application startup file:** Not needed (we're just building, not running a server)
4. Click "Create"

#### Step 3: Run Deployment Script

SSH into your server and run:

```bash
cd /home/pawnline/proton-prediction-market
chmod +x deploy-to-cpanel.sh
./deploy-to-cpanel.sh
```

The script will:
- Install dependencies
- Build the React app
- Deploy to `/home/pawnline/public_html/`
- Create `.htaccess` for React Router
- Set proper file permissions

### Method 2: Build Locally and Upload

This method builds the app on your local machine and uploads the build files.

#### Step 1: Build Locally

```bash
# Navigate to project directory
cd proton-prediction-market

# Make script executable
chmod +x local-build.sh

# Run build script
./local-build.sh
```

This creates a `deploy-package/` directory with all files ready to upload.

#### Step 2: Upload Build Files

Upload the contents of `deploy-package/` to `/home/pawnline/public_html/`:

**Option A: Using rsync (recommended)**
```bash
rsync -avz --delete deploy-package/ user@pawnline.io:/home/pawnline/public_html/
```

**Option B: Using FTP/SFTP**
1. Connect to your server via FTP/SFTP
2. Navigate to `/home/pawnline/public_html/`
3. Upload all files from `deploy-package/`
4. Ensure `.htaccess` is uploaded (it may be hidden)

**Option C: Using cPanel File Manager**
1. Zip the `deploy-package/` directory
2. Upload the zip file to `/home/pawnline/public_html/`
3. Extract the zip file in cPanel File Manager
4. Move all files from the extracted folder to `public_html/` root
5. Delete the zip file and empty folder

#### Step 3: Verify .htaccess

Ensure `.htaccess` is present in `/home/pawnline/public_html/.htaccess`

## Post-Deployment

### 1. Verify Deployment

Visit your website: `https://pawnline.io`

Check that:
- ✅ The app loads correctly
- ✅ You can navigate between pages (Markets, Portfolio, Admin)
- ✅ Deep links work (e.g., `https://pawnline.io/markets/1`)
- ✅ Wallet connection works (Proton WebAuth)

### 2. Test Functionality

1. **Connect Wallet:** Click "Connect Wallet" and test Proton WebAuth
2. **Browse Markets:** Navigate to the Markets page
3. **View Market Details:** Click on a market to view details
4. **Test Routing:** Refresh the page on a market detail page - it should not 404

### 3. Set File Permissions

If you uploaded manually, set proper permissions:

```bash
# SSH into server
ssh user@pawnline.io

# Set permissions
cd /home/pawnline/public_html
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```

### 4. Enable SSL (Recommended)

1. In cPanel, go to "SSL/TLS Status"
2. Enable AutoSSL or install a Let's Encrypt certificate
3. Once SSL is active, uncomment the HTTPS redirect in `.htaccess`:

```apache
# Uncomment these lines:
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

## Troubleshooting

### Issue: Pages Return 404 Errors

**Cause:** `.htaccess` is missing or mod_rewrite is not enabled

**Solution:**
1. Verify `.htaccess` exists in `/home/pawnline/public_html/.htaccess`
2. Check that mod_rewrite is enabled in Apache (contact hosting support if needed)
3. Verify `.htaccess` contains the React Router rewrite rules

### Issue: Assets Don't Load (404 for JS/CSS files)

**Cause:** Incorrect `PUBLIC_URL` or `homepage` setting

**Solution:**
1. If serving from root domain (`pawnline.io`), ensure `PUBLIC_URL` is not set or is set to `/`
2. If serving from subdirectory (`pawnline.io/app`), set in `frontend/.env`:
   ```env
   PUBLIC_URL=/app
   ```
3. Rebuild the app after changing `PUBLIC_URL`

### Issue: App Doesn't Connect to Proton

**Cause:** Incorrect environment variables

**Solution:**
1. Check `REACT_APP_PROTON_ENDPOINT` in your `.env` file
2. Verify `REACT_APP_CHAIN_ID` matches your target network (testnet vs mainnet)
3. Ensure `REACT_APP_CONTRACT_NAME` matches your deployed contract
4. Rebuild the app after changing environment variables

### Issue: "Module not found" Errors During Build

**Cause:** Dependencies not installed or outdated

**Solution:**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Issue: Build Runs Out of Memory

**Cause:** Insufficient memory on cPanel server

**Solution:**
1. Use Method 2 (build locally) instead
2. Or contact hosting support to increase memory limits
3. Or add swap space (if you have SSH root access)

### Issue: Deployment Script Permission Denied

**Cause:** Script not executable

**Solution:**
```bash
chmod +x deploy-to-cpanel.sh
chmod +x local-build.sh
```

### Issue: Old Version Still Showing After Deployment

**Cause:** Browser cache or CDN cache

**Solution:**
1. Hard refresh in browser: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
2. Clear browser cache
3. If using Cloudflare or CDN, purge the cache
4. Check that files were actually updated on the server

## Updating the Deployment

To update your deployment after making changes:

### If Using Method 1 (Build on Server):
```bash
ssh user@pawnline.io
cd /home/pawnline/proton-prediction-market
git pull origin main  # Pull latest changes
./deploy-to-cpanel.sh  # Rebuild and deploy
```

### If Using Method 2 (Build Locally):
```bash
git pull origin main  # Pull latest changes
./local-build.sh  # Build locally
# Upload deploy-package/ to server
```

## Directory Structure on cPanel

After deployment, your cPanel server should have this structure:

```
/home/pawnline/
├── proton-prediction-market/     # Source code (not public)
│   ├── contracts/                # Smart contract source
│   ├── frontend/                 # React source code
│   │   ├── src/
│   │   ├── public/
│   │   ├── build/               # Build output (created by npm run build)
│   │   ├── package.json
│   │   └── .env                 # Environment config
│   ├── deploy-to-cpanel.sh      # Deployment script
│   └── README.md
│
└── public_html/                  # Public web root (accessible via pawnline.io)
    ├── index.html               # Main entry point
    ├── .htaccess                # Apache config for React Router
    ├── static/                  # JS, CSS, and other assets
    │   ├── css/
    │   ├── js/
    │   └── media/
    ├── manifest.json
    ├── favicon.ico
    └── robots.txt
```

## Security Considerations

1. **Never upload `.env` files to public_html** - environment variables are baked into the build
2. **Never upload `node_modules`** to public_html - only upload the build output
3. **Keep source code outside public_html** - only built static files should be public
4. **Use HTTPS** - Enable SSL certificate for secure connections
5. **Review `.htaccess`** - Ensure security headers are enabled
6. **Regular updates** - Keep dependencies updated for security patches

## Performance Optimization

1. **Enable compression** - The `.htaccess` includes gzip compression
2. **Enable caching** - The `.htaccess` includes browser caching rules
3. **Use CDN** - Consider using Cloudflare for additional caching and DDoS protection
4. **Optimize images** - Compress images before including in the app
5. **Code splitting** - React automatically code-splits, but verify chunks are loading efficiently

## Support

For issues specific to:
- **Proton blockchain:** See [Proton Documentation](https://docs.xprnetwork.org/)
- **React deployment:** See [Create React App Deployment](https://create-react-app.dev/docs/deployment/)
- **cPanel:** Contact your hosting provider's support

For project-specific issues, see the main [README.md](README.md) or open an issue on GitHub.

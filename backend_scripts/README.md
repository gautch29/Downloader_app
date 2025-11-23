# Database Setup Instructions

## Quick Fix

Run these commands on your server to set up the database:

```bash
# 1. Copy the scripts to your backend
cd /home/Downloader
mkdir -p scripts

# Copy these files to /home/Downloader/scripts/:
# - schema.sql
# - init-db.ts
# - create-user.ts

# 2. Add scripts to package.json
# Add these to the "scripts" section:
#   "db:init": "tsx scripts/init-db.ts",
#   "create-user": "tsx scripts/create-user.ts"

# 3. Initialize the database
npm run db:init

# 4. Create your first user
npm run create-user
```

## What These Scripts Do

### `schema.sql`
- Defines all database tables (users, sessions, downloads, paths, settings)
- Creates indexes for better performance
- Uses SQLite syntax

### `init-db.ts`
- Reads the schema.sql file
- Creates all tables in your database
- Verifies tables were created successfully

### `create-user.ts`
- Interactive script to create a new user
- Prompts for username and password
- Hashes the password with bcrypt
- Inserts user into the database

## Manual Setup (Alternative)

If you prefer to do it manually:

```bash
# 1. Open SQLite
sqlite3 /home/downloader-data/downloader.db

# 2. Paste the contents of schema.sql

# 3. Exit SQLite
.exit

# 4. Create a user manually
npm run create-user
```

## Verification

After running the scripts, verify everything works:

```bash
# List users
npm run list-users

# Should show your created user
```

## Troubleshooting

**Error: "no such table: users"**
- Run `npm run db:init` first

**Error: "User already exists"**
- Use a different username or delete the existing user

**Error: "Cannot find module 'better-sqlite3'"**
- Run `npm install` to install dependencies

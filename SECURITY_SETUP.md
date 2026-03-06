# 🔐 IMPORTANT: Securing Your Supabase Credentials

Your Supabase credentials have been moved to a secure configuration.

## ⚠️ IMMEDIATE ACTION REQUIRED

Since you've already pushed credentials to GitHub, follow these steps:

### 1. Rotate Your Supabase Keys (CRITICAL)
```bash
# Go to your Supabase Dashboard:
# https://app.supabase.com/project/_/settings/api
# 
# Click "Reset" on your anon key to generate a new one
# This invalidates the exposed key immediately
```

### 2. Set Up Local Secrets File
```bash
# In your project directory:
cd ToDoList/Shared/Constants/

# Copy the example file
cp SupabaseSecrets.swift.example SupabaseSecrets.swift

# Edit the new file and add your NEW credentials
# (Use your code editor to open SupabaseSecrets.swift)
```

### 3. Update Git History (Remove Exposed Credentials)

**Option A: Use BFG Repo-Cleaner (Recommended)**
```bash
# Install BFG
brew install bfg

# Clone a fresh copy of your repo
git clone --mirror https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Remove the exposed file from all commits
bfg --delete-files SupabaseConfig.swift YOUR_REPO.git

# Clean up and push
cd YOUR_REPO.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

**Option B: Use git filter-branch**
```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch ToDoList/Shared/Constants/SupabaseConfig.swift" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
```

### 4. Verify .gitignore is Working
```bash
# From your project root
git status

# You should NOT see SupabaseSecrets.swift listed
# Only SupabaseSecrets.swift.example should be tracked
```

## 📁 File Structure

```
ToDoList/
├── .gitignore                                          ✅ Created (ignores secrets)
└── ToDoList/
    └── Shared/
        └── Constants/
            ├── SupabaseConfig.swift                    ✅ Updated (references secrets)
            ├── SupabaseSecrets.swift.example           ✅ Template (committed to Git)
            └── SupabaseSecrets.swift                   🔒 Your actual secrets (NEVER committed)
```

## 🚀 How It Works

1. **SupabaseSecrets.swift** - Contains your REAL credentials (gitignored, never committed)
2. **SupabaseSecrets.swift.example** - Template file (committed to Git for team members)
3. **SupabaseConfig.swift** - References the secrets (safe to commit)

## 👥 For Team Members

When cloning this repo, they need to:
```bash
cd ToDoList/Shared/Constants/
cp SupabaseSecrets.swift.example SupabaseSecrets.swift
# Then edit SupabaseSecrets.swift with their own credentials
```

## ✅ Security Checklist

- [ ] Rotated Supabase keys in dashboard
- [ ] Created `SupabaseSecrets.swift` with NEW credentials
- [ ] Verified app builds and runs
- [ ] Removed old credentials from Git history
- [ ] Force pushed to GitHub
- [ ] Confirmed SupabaseSecrets.swift is in .gitignore
- [ ] Verified `git status` doesn't show SupabaseSecrets.swift

## 🔍 Verify It's Working

```bash
# These files should appear in git status:
git status

# Should show (if modified):
# ✅ .gitignore
# ✅ SupabaseConfig.swift
# ✅ SupabaseSecrets.swift.example

# Should NOT show:
# ❌ SupabaseSecrets.swift
```

## 📚 Additional Security Tips

1. **Never** log credentials in console
2. **Never** put credentials in comments or strings
3. **Always** use environment-specific configs
4. Consider using **GitHub Secrets** for CI/CD
5. Enable **Row Level Security (RLS)** in Supabase

---

Need help? Check the Supabase docs: https://supabase.com/docs/guides/api/securing-your-api-keys

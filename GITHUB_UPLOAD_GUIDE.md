# 🚀 GitHub Upload Guide - Mosques App

Follow these step-by-step instructions to upload your Flutter project to GitHub.

---

## 📋 Prerequisites

1. **GitHub Account**: Create one at [github.com](https://github.com) if you don't have it
2. **Git Installed**: Download from [git-scm.com](https://git-scm.com)
3. **Git Configured**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

---

## ✅ Step 1: Initialize Local Git Repository

Open PowerShell and navigate to your project:

```powershell
cd I:\flutter_projects\lerning\work\mosques_app
```

Initialize Git:

```bash
git init
```

Check status (should show many untracked files):

```bash
git status
```

---

## ✅ Step 2: Verify .gitignore is Correct

The `.gitignore` file is already configured. Verify it's excluding the right files:

```bash
git status
```

**You should NOT see**:
- `build/` folder
- `.dart_tool/` folder
- `.idea/` folder
- `pubspec.lock` file
- Android build files

---

## ✅ Step 3: Add All Files to Git

Add all tracked files (respecting .gitignore rules):

```bash
git add .
```

View what will be committed:

```bash
git status
```

---

## ✅ Step 4: Create Initial Commit

```bash
git commit -m "Initial commit - Mosque App with prayer times, Azan, and location features"
```

Or with a more detailed message:

```bash
git commit -m "Initial commit - Mosque App with prayer times, Azan, and location features

Features:
- Prayer times calculation with Adhan Dart
- GPS-based location services
- Push notifications with WorkManager
- Bilingual support (AR/EN)
- Dark/Light theme
- Favorite mosques
- Offline functionality"
```

---

## ✅ Step 5: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. **Repository name**: `mosques_app`
3. **Description**: `A Flutter app for prayer times, Azan notifications, and mosque discovery with bilingual support`
4. **Visibility**: Public (or Private if you prefer)
5. **Initialize with**: 
   - ❌ Do NOT add README
   - ❌ Do NOT add .gitignore
   - ❌ Do NOT add License
   (We already have these locally)
6. Click **Create repository**

---

## ✅ Step 6: Add Remote Repository

After creating the GitHub repo, you'll see instructions. Copy the repository URL (looks like `https://github.com/yourusername/mosques_app.git`).

Add the remote:

```bash
git remote add origin https://github.com/yourusername/mosques_app.git
```

Verify it's added:

```bash
git remote -v
```

You should see:
```
origin  https://github.com/yourusername/mosques_app.git (fetch)
origin  https://github.com/yourusername/mosques_app.git (push)
```

---

## ✅ Step 7: Rename Branch (if needed)

If your local branch is `master`, rename it to `main` (GitHub's default):

```bash
git branch -M main
```

Check current branch:

```bash
git branch -a
```

---

## ✅ Step 8: Push to GitHub

Push your commits to GitHub:

```bash
git push -u origin main
```

**Explanation of flags**:
- `-u` (--set-upstream): Set this branch to track remote
- `origin`: Remote repository name
- `main`: Branch name

**You may be prompted for authentication**:
- Use your GitHub username
- Use a **Personal Access Token** (not password):
  1. Go to GitHub Settings → Developer settings → Personal access tokens
  2. Click "Generate new token"
  3. Give it repo access
  4. Use the token as password

---

## ✅ Step 9: Verify Upload

1. Go to `https://github.com/yourusername/mosques_app`
2. You should see:
   - ✅ All your Flutter code
   - ✅ `README.md` displayed beautifully
   - ✅ `LICENSE` file listed
   - ✅ `.gitignore` excluding build artifacts
   - ✅ All features in the feature branches (if you had any)

3. Check specific files:
   - README.md should display all features
   - LICENSE should show your name
   - No build/ or .dart_tool/ folders

---

## 🔄 Quick Reference - All Commands at Once

```bash
# 1. Navigate to project
cd I:\flutter_projects\lerning\work\mosques_app

# 2. Initialize
git init

# 3. Add all files
git add .

# 4. Commit
git commit -m "Initial commit - Mosque App with prayer times, Azan, and location features"

# 5. Rename branch
git branch -M main

# 6. Add remote (replace yourusername)
git remote add origin https://github.com/yourusername/mosques_app.git

# 7. Push to GitHub
git push -u origin main
```

---

## 🆘 Troubleshooting

### Problem: "fatal: not a git repository"
**Solution**: Run `git init` first

### Problem: "Permission denied" when pushing
**Solution**: 
- Use Personal Access Token instead of password
- Or use SSH key: `git remote set-url origin git@github.com:yourusername/mosques_app.git`

### Problem: "Everything up to date" but files not showing
**Solution**: 
1. Check `git status` - make sure files are committed
2. Check GitHub - refresh the page
3. Check `.gitignore` - maybe files are ignored

### Problem: Want to change repo URL
**Solution**:
```bash
git remote set-url origin https://github.com/yourusername/mosques_app.git
```

### Problem: Want to delete last commit (before pushing)
**Solution**:
```bash
git reset --soft HEAD~1
```

---

## 📚 Future Commits

After initial upload, new changes are simple:

```bash
# 1. Stage changes
git add .

# 2. Commit
git commit -m "Fix: Prayer time calculation for timezone"

# 3. Push
git push origin main
```

---

## 🏷️ Create Release Tags (Optional)

After uploading, you can create releases:

```bash
# Create tag
git tag -a v1.0.0 -m "Version 1.0.0 - Initial Release"

# Push tags
git push origin --tags
```

Then go to GitHub → Releases → Create Release from tag, and add release notes!

---

## ✨ Pro Tips

1. **Branch Protection**: Go to GitHub repo settings → Branches → Add rule for `main` to require reviews before merging
2. **Issue Templates**: Create `.github/ISSUE_TEMPLATE/bug_report.md` for bug reporting
3. **CI/CD**: Add GitHub Actions for automated testing
4. **README Badge**: Update the GitHub link in README badges
5. **Social**: Share your repo with the Flutter community!

---

Made with ❤️ for the Muslim community  
Good luck with your mosque app! 🕌

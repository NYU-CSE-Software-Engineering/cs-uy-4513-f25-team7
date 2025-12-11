# Installing Ruby 3.3.8 on Windows

## Quick Steps

1. **Download RubyInstaller:**
   - Visit: https://rubyinstaller.org/downloads/
   - Download: **Ruby+Devkit 3.3.8 (x64)** - the version matching your `.ruby-version` file

2. **Run the Installer:**
   - Check "Add Ruby executables to your PATH"
   - Check "Associate .rb and .rbw files with this Ruby installation"
   - Click Install

3. **Install Development Tools:**
   - After installation, a terminal will open
   - Press Enter to install MSYS2 and development toolchain
   - Wait for completion, then press Enter again

4. **Verify Installation:**
   Open a **new** PowerShell window and run:
   ```powershell
   ruby --version
   # Should show: ruby 3.3.8...
   
   gem --version
   # Should show a gem version number
   ```

5. **Install Bundler:**
   ```powershell
   gem install bundler
   ```

6. **Install Project Dependencies:**
   ```powershell
   cd c:\Users\willi\pairup-frontend\cs-uy-4513-f25-team7
   bundle install
   ```

7. **Run Cucumber Tests:**
   ```powershell
   # Run all tests
   bundle exec cucumber
   
   # Run a specific feature file
   bundle exec cucumber features/social_graph_notifications.feature
   
   # Run with pretty output
   bundle exec cucumber --format pretty
   
   # Run only scenarios with specific tags
   bundle exec cucumber --tags @happy
   ```

## Alternative: Using WSL (Windows Subsystem for Linux)

If you prefer a Linux-like environment:

1. Install WSL2: `wsl --install` in PowerShell (as Administrator)
2. Install Ruby in WSL using rbenv or rvm
3. Run tests from WSL terminal

## Troubleshooting

- **"bundle is not recognized"**: Close and reopen PowerShell after installing Ruby
- **"ruby is not recognized"**: Make sure "Add Ruby executables to your PATH" was checked during installation
- **Gem compilation errors**: Make sure you installed the Devkit version and ran `ridk install`




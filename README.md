# Claude Code Marketplace

Custom plugins for Claude Code by [@rarebek](https://github.com/rarebek).

## Plugins

### notify-on-done
Windows toast notification when Claude Code finishes responding. Shows the project name so you can distinguish between multiple sessions.

**Requires:** [BurntToast](https://github.com/Windos/BurntToast) PowerShell module

```powershell
Install-Module -Name BurntToast -Scope CurrentUser -Force
```

## Usage

Add this marketplace to your `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "rarebek-marketplace": {
      "source": {
        "source": "github",
        "repo": "rarebek/claude-marketplace"
      }
    }
  }
}
```

Then enable plugins:

```json
{
  "enabledPlugins": {
    "notify-on-done@rarebek-marketplace": true
  }
}
```

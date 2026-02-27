# Development Setup

This guide covers setting up the development environment for the Wormhole Chess project, including GitHub MCP integration.

## Prerequisites

- macOS (development environment)
- Git
- Terminal access
- Flutter SDK
- Dart SDK
- Melos (for monorepo management)

## Flutter Installation

### 1. Install Flutter SDK

Follow the official [Flutter installation guide](https://docs.flutter.dev/get-started/install) for your platform.

### 2. Verify Installation

```bash
flutter doctor
```

### 3. Install Melos

```bash
dart pub global activate melos
```

### 4. Install Project Dependencies

```bash
melos get
```

## Node.js Installation (using NVM)

### 1. Install NVM (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
```

### 2. Reload Shell Configuration

```bash
source ~/.zshrc
```

### 3. Install Node.js LTS

```bash
nvm install --lts
```

### 4. Verify Installation

```bash
node --version
npm --version
```

## GitHub MCP Setup

### 1. Create GitHub Personal Access Token

1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Wormhole Chess MCP")
4. Set an appropriate expiration
5. Select the following permissions:
   - **repo** - Full control of private repositories
   - **workflows** - Update GitHub Action workflows
6. Click "Generate token"
7. **Important**: Copy the token immediately as you won't see it again

### 2. Configure Global MCP

Add the GitHub MCP server to your global MCP configuration file (usually located at `~/.codeium/windsurf/mcp_config.json` or similar):

```json
{
  "mcpServers": {
    "github-mcp-server": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<GITHUB_PAT_HERE>"
      }
    }
  }
}
```

Replace `<GITHUB_PAT_HERE>` with your actual GitHub Personal Access Token.

### 3. Restart Your IDE

After updating the MCP configuration, restart Windsurf/VS Code to load the new MCP server.

### 4. Verify GitHub MCP Connection

Test the connection using curl:

```bash
curl -H "Authorization: token <YOUR_TOKEN>" https://api.github.com/repos/jaybjird/wormhole_chess/milestones
```

Replace `<YOUR_TOKEN>` with your actual GitHub token. You should see a JSON response with the project milestones.

## IDE Setup

### Install Recommended Extensions

The project includes a `.vscode/extensions.json` file with recommended extensions for Windsurf/VS Code:

1. Open Windsurf or VS Code
2. Go to the Extensions view (Ctrl+Shift+X or Cmd+Shift+X)
3. Use the "Extensions: Install Extensions" command and the IDE will prompt you to install the recommended extensions automatically

Alternatively, you can manually search for and install the extensions listed in the `.vscode/extensions.json` file.

## Security Notes

- **Never commit** your MCP configuration file with actual tokens to version control
- Use environment variables for all sensitive configuration
- Keep your GitHub Personal Access Token secure and rotate it regularly

## Troubleshooting

### Common Issues

1. **Command not found: npm**
   - Ensure NVM is properly installed and loaded
   - Run `source ~/.zshrc` to reload shell configuration
   - Verify with `which npm` and `which node`

2. **GitHub API returns 401 Bad credentials**
   - Check that your GitHub token is set correctly in the MCP configuration
   - Ensure the token has the required permissions
   - Verify the token hasn't expired

3. **MCP server not found**
   - Ensure the MCP configuration file is properly formatted JSON
   - Check that your IDE supports MCP and can read the global configuration
   - Restart your IDE after updating the MCP configuration

### Getting Help

- Check the [GitHub MCP documentation](https://github.com/modelcontextprotocol/servers)
- Review the [NVM documentation](https://github.com/nvm-sh/nvm)
- Consult the project's issue tracker for platform-specific issues

## Development Commands

### Running the Applications

```bash
# Run Flutter app
melos dev:app

# Run terminal chess engine
melos dev:engine
```

### Code Quality

```bash
# Format all Dart code
melos format

# Analyze all Dart code
melos analyze

# Clean Flutter packages
melos clean

# Upgrade dependencies
melos upgrade
```

## How to Play

1. **Standard Chess Rules**: All traditional chess rules apply
2. **Wormholes**: Special squares on the board allow pieces to teleport
3. **Teleportation**: When a piece lands on a wormhole, it can instantly move to any other wormhole
4. **Custom Placement**: Set up your pieces in unique starting positions
5. **Asynchronous Play**: Take turns at your own pace with cloud sync

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

- Follow Flutter/Dart coding standards
- Write clear, commented code
- Test your changes thoroughly
- Update documentation as needed

## Next Steps

After completing setup:

1. Explore the project milestones using the GitHub MCP
2. Set up your preferred development environment (VS Code, Android Studio, etc.)
3. Review the Flutter/Dart codebase in `packages/app/lib/`
4. Check the chess engine structure in `packages/engine/lib/`
5. Examine shared models in `packages/models/lib/`

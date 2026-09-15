# Action: Collect Context

Collect context information for the review target.

## Purpose

Before starting the review, collect basic information about the target code:
- Determine the review scope, files, or directories
- Identify the programming language and framework
- Measure the codebase size

## Preconditions

- [ ] state.status === 'pending' || state.context === null

## Execution

```javascript
async function execute(state, workDir) {
  // 1. Ask the user for the review target.
  const input = await AskUserQuestion({
    questions: [{
      question: "Please specify the code path to review:",
      header: "Review Target",
      multiSelect: false,
      options: [
        { label: "Current directory", description: "Review all code under the current working directory" },
        { label: "src/", description: "Review the src/ directory" },
        { label: "Custom path", description: "Enter a custom path" }
      ]
    }]
  });
  
  function validatePath(p) {
    if (!p || p.startsWith('/') || p.includes('..')) return null;
    const resolved = p.replace(/\/+$/, '');
    return resolved || '.';
  }

  let targetPath;
  if (input["Review Target"] === "Custom path") {
    targetPath = validatePath(input["Other"]);
    let retries = 0;
    while (!targetPath && retries < 3) {
      retries++;
      const retry = await AskUserQuestion({
        questions: [{
          question: "Invalid path. Provide a relative path within the project (no '..' or absolute paths):",
          header: "Review Target",
          multiSelect: false,
          options: [
            { label: "src/", description: "Review the src/ directory" },
            { label: "Custom path", description: "Enter a custom relative path" }
          ]
        }]
      });
      targetPath = retry["Review Target"] === "Custom path"
        ? validatePath(retry["Other"])
        : retry["Review Target"] === "Current directory" ? "." : "src/";
    }
    if (!targetPath) targetPath = ".";
  } else {
    targetPath = input["Review Target"] === "Current directory" ? "." : "src/";
  }

  // 2. Collect the file list.
  const files = Glob(`${targetPath}/**/*.{ts,tsx,js,jsx,py,java,go,rs,cpp,c,cs}`);
  
  // 3. Detect the primary language.
  const languageCounts = {};
  files.forEach(file => {
    const ext = file.split('.').pop();
    const langMap = {
      'ts': 'TypeScript', 'tsx': 'TypeScript',
      'js': 'JavaScript', 'jsx': 'JavaScript',
      'py': 'Python',
      'java': 'Java',
      'go': 'Go',
      'rs': 'Rust',
      'cpp': 'C++', 'c': 'C',
      'cs': 'C#'
    };
    const lang = langMap[ext] || 'Unknown';
    languageCounts[lang] = (languageCounts[lang] || 0) + 1;
  });
  
  const primaryLanguage = Object.entries(languageCounts)
    .sort((a, b) => b[1] - a[1])[0]?.[0] || 'Unknown';
  
  // 4. Count lines of code.
  const sensitivePatterns = ['.env', '.pem', '.key', '.p12', '.pfx', 'credentials', 'secret', 'id_rsa'];
  function isSensitive(file) {
    return sensitivePatterns.some(p => file.toLowerCase().includes(p));
  }

  let totalLines = 0;
  for (const file of files.filter(f => !isSensitive(f)).slice(0, 30)) {
    try {
      const content = Read(file);
      totalLines += content.split('\n').length;
    } catch (e) {}
  }
  
  // 5. Detect the framework.
  let framework = null;
  if (files.some(f => f.includes('package.json'))) {
    const pkg = JSON.parse(Read('package.json'));
    if (pkg.dependencies?.react) framework = 'React';
    else if (pkg.dependencies?.vue) framework = 'Vue';
    else if (pkg.dependencies?.angular) framework = 'Angular';
    else if (pkg.dependencies?.express) framework = 'Express';
    else if (pkg.dependencies?.next) framework = 'Next.js';
  }
  
  // 6. Build the context.
  const context = {
    target_path: targetPath,
    files: files.slice(0, 200),  // Limit to at most 200 files.
    language: primaryLanguage,
    framework: framework,
    total_lines: totalLines,
    file_count: files.length
  };
  
  // 7. Save the context.
  Write(`${workDir}/context.json`, JSON.stringify(context, null, 2));
  
  return {
    stateUpdates: {
      status: 'running',
      context: context
    }
  };
}
```

## State Updates

```javascript
return {
  stateUpdates: {
    status: 'running',
    context: {
      target_path: targetPath,
      files: fileList,
      language: primaryLanguage,
      framework: detectedFramework,
      total_lines: totalLines,
      file_count: fileCount
    }
  }
};
```

## Output

- **File**: `context.json`
- **Location**: `${workDir}/context.json`
- **Format**: JSON

## Error Handling

| Error Type | Recovery |
|------------|----------|
| Path does not exist | Ask the user to enter the path again |
| No code files found | Return an error and terminate the review |
| Read permission issue | Skip the file and record a warning |

## Next Actions

- Success: action-quick-scan
- Failure: action-abort

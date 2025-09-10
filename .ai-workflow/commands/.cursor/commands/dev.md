You are managing autonomous development for the current project. Follow this protocol exactly.

**Arguments:**
- No args or "start": Initialize/resume development cycle
- "status": Show current development state only

**AUTONOMOUS DEVELOPMENT PROTOCOL:**

1. **READ STATE** (always check current state first):
   - Read `.ai-workflow/state/tasks.md` - Find next incomplete task `[ ]`
   - Read `.ai-workflow/state/requirements.md` - Understand project goals
   - Read `.ai-workflow/state/progress.log` - Check recent progress

2. **ANALYZE** (determine what to do):
   - Identify the next incomplete task from tasks.md
   - Understand what this task requires
   - Check if any previous work needs to be continued

3. **ACT** (execute development work):
   - Work on ONLY the current incomplete task
   - Follow Shell Starter conventions and patterns
   - Create/modify files as needed for this specific task
   - Use proper logging, error handling, and Shell Starter functions

4. **VERIFY** (quality assurance):
   - Run `shellcheck` on any shell scripts created/modified
   - Run `shfmt -d` to check formatting
   - Test the functionality manually if applicable
   - Ensure the task is actually complete

5. **UPDATE STATE** (record progress):
   - Mark completed tasks with `[x]` in tasks.md
   - Add detailed progress entry to progress.log with timestamp
   - Identify next task or mark project complete

**CONTEXT MANAGEMENT:**
- When approaching context limits, save all progress to state files
- End with: "Continue development with: /dev"
- Never leave work in incomplete state

**OUTPUT FORMAT:**
```
🔄 AUTONOMOUS DEVELOPMENT CYCLE
Current Task: [task code and description]
Action: [what you're implementing]
Progress: [current progress status]
Next: [next task or completion status]
```

Begin autonomous development now.

# PowerShell Profiles Presentation

This repository contains the slides, demos, and reusable profile snippets for my **PowerShell Profiles** presentation.

---

## Folder Structure

- **assets/**  
  Images, diagrams, and supporting media used in slides.

- **demos/**  
  Live demo scripts organized by topic and presentation order.  
  These are safe, pre-written examples used during the talk.

- **powershell-profiles/**  
  Core working files specific to this presentation.

- **profile-snippets/**  
  Modular PowerShell profile examples.  
  Includes structured snippets (environment setup, aliases, functions, completions, etc.) that demonstrate a clean, scalable profile design.

- **slides/**  
  Slide deck and speaker notes.

---

## Presentation Goals

- Explain what PowerShell profiles are and how they load
- Demonstrate profile scopes and paths
- Show how to build a modular, maintainable profile
- Improve shell productivity safely
- Cover performance and troubleshooting techniques

---

## Running the Demos

Open PowerShell 7+ and navigate to the `demos` directory:

```powershell
cd .\demos
```

Run scripts in numerical order for a smooth presentation flow.

If needed, start PowerShell without loading a profile:

```powershell
pwsh -NoProfile
```

---

## Recommended Setup

- PowerShell 7+
- VS Code (optional)
- Oh My Posh (optional for prompt demonstrations)

---
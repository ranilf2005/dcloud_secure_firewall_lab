# dcloud_secure_firewall_lab

dCloud Secure Cisco Firewall lab using 7.7.0 and 10.0.

The workshop guide is published as a static website built with [MkDocs](https://www.mkdocs.org/)
and the [Material](https://squidfunk.github.io/mkdocs-material/) theme.

**Live site:** <https://ranilf2005.github.io/dcloud_secure_firewall_lab/>

Every page is a plain Markdown file in [docs](docs). Edit a file, commit, push - GitHub Actions
rebuilds the HTML and republishes the site automatically.

## Repository layout

| Path | Purpose |
| --- | --- |
| `docs/*.md` | One Markdown file per page - edit these |
| `docs/assets/` | Screenshots and diagrams |
| `docs/assets/<page-name>/` | Images pasted into a specific page |
| `docs/stylesheets/extra.css` | Colour palette and table/grid tweaks |
| `docs/javascripts/collapsible.js` | Makes every section heading expand/collapse |
| `docs/template_assets/` | Logos used by the theme and home page |
| `overrides/home.html` | Home page hero layout |
| `mkdocs.yml` | Site settings and navigation |
| `.github/workflows/publish.yml` | Build + deploy to GitHub Pages |
| `scripts/Paste-Image.ps1` | Save a clipboard screenshot into the right folder |

## Editing a page

1. Open any file under `docs/` and change the Markdown.
2. Commit and push to `main`.
3. The **Publish docs** workflow rebuilds and deploys the site.

## Adding a page

1. Create `docs/my-new-page.md`.
2. Add one line to the `nav:` section of `mkdocs.yml`, for example:

   ```yaml
   - My New Page: my-new-page.md
   ```

## Collapsible sections

Every `##` and `###` heading on the site is clickable and expands or collapses its own content, so
readers can skip past parts they do not need. Sections are open by default.

To make a section start **closed**, add `{ .collapsed }` to the end of the heading:

```markdown
### 2a. Troubleshoot from the FTD CLI (optional) { .collapsed }
```

Links, search hits and table-of-contents entries that point inside a closed section open it
automatically, and everything is expanded when the page is printed.

## Adding screenshots

### In VS Code (recommended - no path typing)

Take a screenshot (<kbd>Win</kbd>+<kbd>Shift</kbd>+<kbd>S</kbd>) or copy an image file, place the
cursor where the image belongs in a `docs/*.md` file and press <kbd>Ctrl</kbd>+<kbd>V</kbd>.
Dragging an image file into the editor works the same way.

VS Code writes the file to `docs/assets/<page-name>/` and inserts the correct relative link:

```markdown
![Alt text](./assets/lab-tasks/image.png)
```

This is configured in [.vscode/settings.json](.vscode/settings.json) via
`markdown.copyFiles.destination`, so the destination folder and the link are always derived from
the page you are editing.

### From PowerShell

```powershell
# Append the image to the end of a page
.\scripts\Paste-Image.ps1 -Page lab-tasks -Append

# Save the image and copy the Markdown snippet to the clipboard instead
.\scripts\Paste-Image.ps1 -Page theory -Name nat-order -Alt "NAT order" -Width 700

# Import an existing file rather than the clipboard
.\scripts\Paste-Image.ps1 -Page topologies -From C:\temp\diagram.png -Append
```

Omit `-Page` to target the most recently edited page. The script creates
`docs/assets/<page-name>/` if needed, never overwrites an existing image, and works out the
relative path itself.

If PowerShell blocks the script with *"running scripts is disabled on this system"*, allow it for
the current session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Sizing and captions

```markdown
![Packet tracer output](./assets/lab-tasks/packet-tracer.png){ width="700" }

<figure markdown>
  ![Lab topology](./assets/topology-lab.png){ width="900" }
  <figcaption>Lab topology</figcaption>
</figure>
```

Images open in a lightbox when clicked. Add `{ .no-lightbox }` to opt a single image out.

## Local preview

```powershell
python -m pip install -r requirements.txt
python -m mkdocs serve
```

Then browse to <http://127.0.0.1:8000>. The preview reloads on every save.

VS Code tasks are also provided (**Terminal > Run Task**): *Docs: install dependencies*,
*Docs: live preview*, *Docs: build*, *Docs: paste screenshot into current page*.

## One-time GitHub Pages setup

In the repository, open **Settings > Pages** and set **Source** to **GitHub Actions**.
After that, every push to `main` publishes automatically.


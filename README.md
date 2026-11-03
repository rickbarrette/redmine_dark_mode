# Redmine Dark Mode

A dark mode for Redmine 7, in the colours of [Gitea](https://gitea.com)'s dark theme.

## Features

* **Follows the device** by default: dark when the phone or computer is in dark mode, light otherwise, switching as the device does.
* **Per-user choice** in My account › Preferences › Dark mode: Automatic, Off (light) or On (dark).
* **Toggle in the top bar** (sun/moon) switches right away and saves the choice; people not logged in keep theirs in the browser.
* **No flash**: the mode is set before the page paints.
* **Pictures keep their colours**: nothing is inverted. Attachments, thumbnails, images in issues and wiki pages, and the lightbox show the files as they are (transparent pictures get a white backing so dark lines stay visible).
* Works on top of Redmine's own look: Redmine 7 colours almost everything with Open Color variables, which the plugin gives dark values. Code blocks get a dark highlighting style.
* Dark styles for these plugins' hard-coded colours: redmine_qbo (estimate and invoice editor, status badges, reports), redmine_qbo_calendar, redmine_qbo_lineitems, redmine_qbo_reminders, redmine_qbo_vehicles, stopwatch, redmine_easy_notes, redmine_issue_templates and redmine_lightbox.

## Requirements

* Redmine 7.0+

## Installation

1. Clone into `plugins/redmine_dark_mode`.
2. Restart Redmine. There are no migrations.

## Styling another plugin

Dark mode sets `html.dark-mode`. A plugin that colours with Redmine's `--oc-*` variables gets dark mode for free; for hard-coded colours, add rules under `html.dark-mode` to `assets/stylesheets/dark_mode.css` (Plugins section).

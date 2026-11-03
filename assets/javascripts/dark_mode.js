// The top menu's dark mode toggle: switches between light and dark right away and saves the choice (with the
// user's preferences when logged in, else in this browser). "Automatic" is chosen in My account.
(function () {
  var MOON = '<svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true"><path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  var SUN = '<svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true"><g fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></g></svg>';

  function isDark() {
    return document.documentElement.classList.contains('dark-mode');
  }

  function save(mode) {
    var dm = window.RedmineDarkMode;
    if (!dm.loggedIn) {
      try { localStorage.setItem('redmine_dark_mode', mode); } catch (e) {}
      return;
    }
    var token = document.querySelector('meta[name="csrf-token"]');
    var body = new URLSearchParams({ mode: mode });
    fetch((window.relativeUrlRoot || '') + '/dark_mode', {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'X-CSRF-Token': token ? token.content : '', 'X-Requested-With': 'XMLHttpRequest' },
      body: body
    });
  }

  function render(button) {
    var dm = window.RedmineDarkMode;
    var label = isDark() ? dm.labels.light : dm.labels.dark;
    button.innerHTML = isDark() ? SUN : MOON;
    button.title = label;
    button.setAttribute('aria-label', label);
  }

  document.addEventListener('DOMContentLoaded', function () {
    var menu = document.querySelector('#top-menu .profile-menu');
    if (!menu || !window.RedmineDarkMode) return;

    var button = document.createElement('button');
    button.type = 'button';
    button.className = 'dark-mode-toggle';
    render(button);
    button.addEventListener('click', function () {
      var mode = isDark() ? 'light' : 'dark';
      window.RedmineDarkMode.set(mode);
      render(button);
      save(mode);
    });
    menu.insertBefore(button, menu.firstChild);

    // The device switching light/dark (Automatic) changes the icon too
    var media = window.matchMedia('(prefers-color-scheme: dark)');
    if (media.addEventListener) media.addEventListener('change', function () { render(button); });
  });
})();

// "Are you sure?" confirmations (data-confirm, through rails-ujs). The browser draws its own box in the device's
// colours, so on a dark page it can flash up bright; while the page is dark, a dark dialog asks instead, and OK
// carries on with the link, button or form. Light pages keep the browser's box.
(function () {
  if (!window.RedmineDarkMode || !window.HTMLDialogElement) return;

  var nativeConfirm = window.Rails && Rails.confirm;
  var approved = null;

  function ask(message, onOk) {
    var labels = window.RedmineDarkMode.labels;
    var dialog = document.createElement('dialog');
    dialog.className = 'dark-mode-confirm';
    var text = document.createElement('p');
    text.textContent = message;
    var buttons = document.createElement('div');
    buttons.className = 'dark-mode-confirm-buttons';
    var cancel = document.createElement('button');
    cancel.type = 'button';
    cancel.textContent = labels.cancel;
    var ok = document.createElement('button');
    ok.type = 'button';
    ok.className = 'dark-mode-confirm-ok';
    ok.textContent = labels.ok;
    buttons.append(cancel, ok);
    dialog.append(text, buttons);
    document.body.appendChild(dialog);

    var confirmed = false;
    cancel.addEventListener('click', function () { dialog.close(); });
    ok.addEventListener('click', function () { confirmed = true; dialog.close(); });
    // Clicking the dimmed page outside the dialog cancels, like Escape
    dialog.addEventListener('click', function (e) { if (e.target === dialog) dialog.close(); });
    dialog.addEventListener('close', function () {
      dialog.remove();
      if (confirmed) onOk();
    });
    dialog.showModal();
    ok.focus();
  }

  // For other scripts: asks in the dark dialog on dark pages, or the browser's box on light ones, then runs onOk
  window.RedmineDarkMode.confirm = function (message, onOk) {
    if (document.documentElement.classList.contains('dark-mode')) {
      ask(message, onOk);
    } else if (window.confirm(message)) {
      onOk();
    }
  };

  if (!window.Rails) return;

  Rails.confirm = function (message, element) {
    if (!document.documentElement.classList.contains('dark-mode')) {
      return nativeConfirm ? nativeConfirm(message, element) : window.confirm(message);
    }
    // The second pass, after OK: let it through
    if (approved === element) {
      approved = null;
      return true;
    }
    ask(message, function () {
      approved = element;
      if (element.tagName === 'FORM') {
        element.requestSubmit ? element.requestSubmit() : element.submit();
      } else {
        element.click();
      }
    });
    return false;
  };
})();

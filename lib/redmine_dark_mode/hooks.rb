#The MIT License (MIT)
#
#Copyright (c) 2026 rick barrette
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module RedmineDarkMode
  class Hooks < Redmine::Hook::ViewListener
    # Before the page paints: the stylesheet, and a small script that sets html.dark-mode from the user's
    # choice (or the device's setting), so pages never flash white
    def view_layouts_base_html_head(context = {})
      mode = RedmineDarkMode.mode_for(User.current)
      script = <<~JS
        (function () {
          var mode = #{mode.to_json}, saved = #{User.current.logged? ? 'false' : 'true'};
          try { if (saved) mode = localStorage.getItem('redmine_dark_mode') || mode; } catch (e) {}
          var media = window.matchMedia('(prefers-color-scheme: dark)');
          // Pages drawn by scripts (e.g. charts) can listen for 'redmine:color-scheme' to recolour themselves
          function apply() {
            var dark = mode === 'dark' || (mode === 'auto' && media.matches);
            if (document.documentElement.classList.contains('dark-mode') === dark) return;
            document.documentElement.classList.toggle('dark-mode', dark);
            document.dispatchEvent(new CustomEvent('redmine:color-scheme', { detail: { dark: dark } }));
          }
          window.RedmineDarkMode = {
            get mode() { return mode; },
            set: function (value) { mode = value; apply(); },
            loggedIn: #{User.current.logged?.to_json},
            labels: #{{ dark: l(:label_dark_mode_switch_dark), light: l(:label_dark_mode_switch_light) }.to_json}
          };
          apply();
          if (media.addEventListener) media.addEventListener('change', apply);
        })();
      JS
      safe_join([
        tag.meta(name: 'color-scheme', content: 'light dark'),
        javascript_tag(script),
        stylesheet_link_tag('dark_mode', plugin: :redmine_dark_mode),
        javascript_include_tag('dark_mode', plugin: :redmine_dark_mode)
      ])
    end

    # My account › Preferences: Automatic (the device's setting), Light or Dark
    def view_my_account_preferences(context = {})
      pref = context[:user].pref
      options = RedmineDarkMode::MODES.map { |m| [l(:"label_dark_mode_#{m}"), m] }
      content_tag(:p) do
        label_tag('pref_dark_mode', l(:label_dark_mode)) +
          select_tag('pref[dark_mode]', options_for_select(options, pref.dark_mode), id: 'pref_dark_mode')
      end
    end
  end
end

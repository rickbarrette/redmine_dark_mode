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
  # A user's choice: follow the device, or always light or dark
  MODES = %w[auto light dark].freeze

  # Until someone chooses, Redmine follows their device
  DEFAULT_MODE = 'auto'

  def self.setup
    UserPreference.prepend(RedmineDarkMode::UserPreferencePatch)
    UserPreference.safe_attributes 'dark_mode'

    # Hooks
    RedmineDarkMode::Hooks
  end

  # The mode for this user: their choice, else the default (anonymous users: their browser's saved choice, else the default)
  def self.mode_for(user)
    mode = user&.logged? ? user.pref.dark_mode : nil
    MODES.include?(mode) ? mode : DEFAULT_MODE
  end
end

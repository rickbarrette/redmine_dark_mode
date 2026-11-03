RedmineApp::Application.routes.draw do
  # The top menu's toggle saves the user's choice
  post 'dark_mode', to: 'dark_mode#update', as: 'dark_mode'
end

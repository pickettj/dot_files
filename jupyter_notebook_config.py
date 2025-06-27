# Each Python environment (base conda, virtual envs, system Python) has its own Jupyter installation
# But they all look for config files in the same user-level locations


# Basic settings
c.ServerApp.open_browser = True
c.ServerApp.browser = ''  # Use default browser

# Optional: Set default directory (customize as needed)
# c.ServerApp.notebook_dir = '~/Documents/notebooks'

# Optional: Disable token for local use (less secure but convenient)
# c.ServerApp.token = ''
# c.ServerApp.password = ''
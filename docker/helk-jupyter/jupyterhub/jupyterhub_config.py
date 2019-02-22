# HELK script: HELK JupyterHub Config
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

c.JupyterHub.log_level = 10

c.Authenticator.admin_users = {'helk'}
c.Spawner.cmd = ['jupyter-labhub']
c.Spawner.notebook_dir = '~/'
c.NotebookApp.notebook_dir = '~/'
c.JupyterHub.hub_ip = 'helk-jupyter'
c.JupyterHub.port = 8000
c.JupyterHub.base_url = '/jupyter'
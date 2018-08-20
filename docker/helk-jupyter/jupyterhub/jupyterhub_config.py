# HELK script: HELK JupyterHub Config
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

#c = get_config()

c.JupyterHub.log_level = 10

c.Authenticator.whitelist = {'hunter1','hunter2','hunter3'}
c.Authenticator.admin_users = {'hunter1'}
c.Spawner.cmd = ['jupyter-labhub']
c.Spawner.notebook_dir = '/opt/helk/jupyterhub'

c.JupyterHub.hub_ip = 'helk-jupyter'
c.JupyterHub.port = 8000
c.JupyterHub.base_url = '/jupyter'
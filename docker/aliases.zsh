com_addons_opt="--addons-path=odoo/addons"
ent_addons_opt="--addons-path=enterprise,odoo/addons"
db_opt="--db_host=db --db_user=odoo --db_password=odoo"
limits_opt="--limit-time-cpu=99999999 --limit-time-real=99999999"

debug_cmd="python3 -m debugpy --wait-for-client --listen 0.0.0.0:5678"

# Odoo
alias o-bin="odoo/odoo-bin $db_opt $limits_opt"
alias o-bin-c="odoo/odoo-bin $db_opt $com_addons_opt $limits_opt"
alias o-bin-e="odoo/odoo-bin $db_opt $ent_addons_opt $limits_opt"

# Odoo Debug
alias o-bin-deb="$debug_cmd odoo/odoo-bin $db_opt $limits_opt"
alias o-bin-deb-c="$debug_cmd odoo/odoo-bin $db_opt $com_addons_opt $limits_opt"
alias o-bin-deb-e="$debug_cmd odoo/odoo-bin $db_opt $ent_addons_opt $limits_opt"

# Override PostgreSQL commands to use the external database
alias createdb="PGPASSWORD=odoo createdb --host=db --username=odoo"
alias dropdb="PGPASSWORD=odoo dropdb --host=db --username=odoo"
alias pgbench="PGPASSWORD=odoo pgbench --host=db --username=odoo"
alias pg_dump="PGPASSWORD=odoo pg_dump --host=db --username=odoo"
alias psql="PGPASSWORD=odoo psql --host=db --username=odoo"

# Override odoo-dev helpers to use the external database
alias o-export-pot="o-export-pot --db_host=db --db_user=odoo --db_password=odoo"

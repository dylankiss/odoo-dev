# Odoo Development Tools

This repository contains a few tools you can use to perform various tasks related to Odoo development. The tools are primarily aimed at Odoo employees, but they can also be useful for community contributors.

The quickest way to make the tools available is to clone this repository to your computer and add it to your `PATH` in your shell's rc-file, like `.bashrc` or `.zshrc`.

```bash
export PATH="$HOME/code/odoo-dev:$PATH"
```

You can run any command with the `-h` or `--help` option to see all possible options.


## Table of Contents

| Tool                                                               | Purpose |
| ------------------------------------------------------------------ | ---- |
| [`o-dev-start` and `o-dev-stop`](#o-dev-start-and-o-dev-stop-bash) |  |
| [`o-multiverse`](#o-multiverse-bash)                               |  |
| [`o-export-pot`](#o-export-pot-python)                             |  |
| [`o-update-po`](#o-update-po-python)                               |  |


## [`o-dev-start`](o-dev-start) and [`o-dev-stop`](o-dev-stop) <sup>(Bash)</sup>

Using these tools you can automatically start and stop a fully configured Docker container to run your Odoo server(s) during development.

> [!IMPORTANT]
> These tools require [Docker Desktop](https://www.docker.com/products/docker-desktop/) to be installed on your system.

The Docker container is carefully configured to resemble the latest [Runbot](https://runbot.odoo.com/) container and thus tries to eliminate discrepancies between your local system and the CI server.

You can start a development container easily like this:

```console
$ o-dev-start -b master -w ~/code/odoo
```

This will build a Docker image using the `master` branch dependencies, start a container and mount the `~/code/odoo` directory inside your container at `/code` to allow live code updates while developing. It will then open an interactive shell to the container to allow you to run any `odoo-bin` command.

The container exposes ports `8069`, `8071`, `8072` and `8073`, so you could run up to 4 Odoo instances simultaneously (each on one of the ports) and access them from your host machine at `http://localhost:<port>`.

The command will also start a separate PostgreSQL container that you can access from your host machine at `localhost:5432` with `odoo` as username and password. Inside your other Docker container, the hostname of the PostgreSQL server is `db`. You might need this information if you manually start an Odoo server in your container by providing these additional arguments:

```console
$ ./odoo-bin --db_host=db --db_user=odoo --db_password=odoo ...
```

When you're done with the container, you can exit the session by running the `exit` command. At this point, the container will still be running and you can access it again using the same `o-dev-start` command.

If you want to stop the containers and clean them up, you simply run:

```console
$ o-dev-stop
```


## [`o-multiverse`](o-multiverse) <sup>(Bash)</sup>

This tool allows to set up an Odoo "Multiverse" environment in order to have all relevant versions of Odoo checked out at the same time. That way you can easily work on tasks in different versions without having to switch branches, or compare behaviors in different versions easily.

The setup makes use of the `git worktree` feature to prevent having multiple full clones of the repositories for each version. The `git` history is only checked out once, and the only extra data you have per branch are the actual source files.

The easiest way to set this up is by creating a directory for your multiverse setup and then run the command in that directory. *(Make sure you set up your GitHub SSH key beforehand!)*

```console
$ mkdir ~/code/odoo
$ cd ~/code/odoo
$ o-multiverse
```

> [!NOTE]
> The branches checked out by default are: `15.0`, `16.0`, `17.0`, `saas-17.1`, `saas-17.2`, `saas-17.4` and `master`. You can override this using the `-b` or `--branches` option with a comma-separated list of branches (e.g. `13.0,14.0`).

> [!NOTE]
> The repositories checked out by default are: `odoo`, `enterprise`, `design-themes`, `documentation`, `internal`, `upgrade` and `upgrade-util`. If you want to exclude any of these (because you don't need them or don't have access to them), you can use the `-e` or `--exclude` option with a comma-separated list of repositories to exclude (from the list defined above).

**You can run the command as many times as you want. It will skip repositories and branches that already exist and only set up the ones that don't exist yet.**

The `o-multiverse` command will do the following:

1. Clone all bare repositories that have multiple branches (`odoo`, `enterprise`, `design-themes` and `documentation`) to a `.multiverse-source/<repository>` folder (we don't need the source files themselves here). We set them up in a way that we can correctly create worktrees for each branch. We add the remote `origin` (`git@github.com:odoo/<repository>.git`) for all repositories and the remote `dev` (`git@github.com:odoo-dev/<repository>.git`) for the `odoo`, `enterprise` and `design-themes` repositories only.

2. Clone the single-branch repositories (`internal`, `upgrade` and `upgrade-util`) to the root of your multiverse directory.

3. Create a directory per branch in your multiverse directory, and a directory per multi-branch repository inside each branch directory. We use `git worktree add` to add a worktree for the correct branch for each repository.

4. Create a symlink to each single-branch repository in each branch directory, since they all use the same `master` branch of these repositories.

After that is done, your directory structure should look a bit like this:

```
<multiverse-folder>
├── .worktree-source
│   ├── odoo (bare)
│   ├── enterprise (bare)
│   ├── design-themes (bare)
│   └── documentation (bare)
├── 15.0
│   └── ...
├── 16.0
│   └── ...
├── 17.0
│   ├── odoo (17.0)
│   ├── enterprise (17.0)
│   ├── design-themes (17.0)
│   ├── documentation (17.0)
│   ├── internal (symlink to ../internal)
│   ├── upgrade (symlink to ../upgrade)
│   └── upgrade-util (symlink to ../upgrade-util)
├── saas-17.1
│   └── ...
├── saas-17.2
│   └── ...
├── saas-17.4
│   └── ...
├── master
│   └── ...
├── internal (master)
├── upgrade (master)
└── upgrade-util (master)
```

The script will log every step to the console and provide the paths of the generated or existing folders to easily open any of them.


## [`o-export-pot`](o-export-pot) <sup>(Python)</sup>

This tool allows to export clean `.pot` files for one or more modules using just one command.

The most common use would be to run this (from the workspace folder containing both your `odoo` and `enterprise` repositories):

```console
$ o-export-pot -s -i -m account,account_payment
```

With these options, the script will:

1. Start a local Odoo Community or Enterprise server (`-s`) , depending on the modules you provided;

> [!IMPORTANT]
> Always try to export Community and Enterprise modules separately, so there can't be any pollution from Enterprise overrides in Community `.pot` files!

2. Install (`-i`) the modules you provided after the argument `-m` (comma-separated list without spaces);

3. Export the `.pot` file of each of these modules and save them in their respective `i18n` directories;

4. Stop the Odoo server and remove the temporary database.

The script will log every step to the console and provide the paths of the generated files to easily open any of them.

> [!TIP]
> If you want to use the script against a PostgreSQL server that is not on your local machine (e.g. using a Docker container), you can provide these options: `--db_host db --db_port 5432 --db_user odoo --db_password odoo` (e.g.).


## [`o-update-po`](o-update-po) <sup>(Python)</sup>

This tool allows to update all `.po` files for one or more modules according to its `.pot` file using just one command.

The most common use would be to run this (from the workspace folder containing both your `odoo` and `enterprise` repositories):

```console
$ o-update-po -m account,account_payment
```

> [!IMPORTANT]
> You need to have the `gettext` tools installed on your system via your favorite package manager.
> ```console
> $ sudo apt-get install gettext  # Ubuntu, Linux Mint ...
> $ brew install gettext  # macOS
> ```

The script will locate all `.po` files per module and use the `msgmerge` and `msgattrib` commands to update them according to the `.pot` file in the module's `i18n` directory. Make sure it is up to date by first running [`o-export-pot`](#o-export-pot-python).

The script will log every step to the console and provide the paths of the updated files to easily open any of them.

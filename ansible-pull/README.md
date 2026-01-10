# ansible-pull
Ansible pull repository for Ubuntu-based Servers and Desktops.

# Usage

```
sudo apt update && sudo apt install -y curl
bash <(curl -s https://raw.githubusercontent.com/rtdevx/cicd-ansible-pull/main/scripts/bootstrap.sh)
```

# Host Name Patterns

**Server base:**

_Regex:_ `^srv-.*[s|p][0-9]?[0-9]?`

**Desktop base:**

_Regex:_ `^ws-.*[s|p][0-9]?[0-9]?`

**Region:**

`p` = Prod
`s` = Staging

## 🖥️ Servers - Hostname Patterns

| Category             | Pattern               | Meaning                      |
| -------------------- | --------------------- | ---------------------------- |
| server_iac           | **srv-iacp1**         | IAC server, prod, instance 1 |
| server_swarm_manager | **srv-docker-mgrp1**  | Docker swarm manager, prod   |
| server_swarm_host    | **srv-docker-hostp1** | Docker swarm worker, prod    |
| server_utility       | **srv-utlp1**         | Utility server, prod         |

## 🖥️ Desktops - Hostname Patterns

| Category            | Pattern      | Meaning                     |
| ------------------- | ------------ | --------------------------- |
| desktop_general     | **ws-genp1** | General workstation, prod   |
| desktop_development | **ws-devp1** | Developer workstation, prod |

## 🧠 Example Hostnames

`srv-iacp1` → prod, server
`srv-iacs1` → staging, server
`ws-devs3` → staging, workstation
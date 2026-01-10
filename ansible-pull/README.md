# ansible-pull
Ansible pull repository for Ubuntu-based Servers and Desktops.

# Usage

```
sudo apt update && sudo apt install -y curl
bash <(curl -s https://github.com/rtdevx/homelab/tree/main/ansible-pull/scripts/bootstrap.sh)
```

# Host Name Patterns

**Server base:**

_Regex:_ `^srv-.*[0-9]?[0-9]?`

**Desktop base:**

_Regex:_ `^ws-.[0-9]?[0-9]?`


## 🖥️ Servers - Hostname Patterns

| Category             | Pattern              | Meaning                      |
| -------------------- | -------------------- | ---------------------------- |
| server_iac           | **srv-iac1**         | IAC server, prod, instance 1 |
| server_swarm_manager | **srv-docker-mgr1**  | Docker swarm manager, prod   |
| server_swarm_host    | **srv-docker-host1** | Docker swarm worker, prod    |
| server_utility       | **srv-utl1**         | Utility server, prod         |

## 🖥️ Desktops - Hostname Patterns

| Category            | Pattern     | Meaning                     |
| ------------------- | ----------- | --------------------------- |
| desktop_general     | **ws-gen1** | General workstation, prod   |
| desktop_development | **ws-dev1** | Developer workstation, prod |
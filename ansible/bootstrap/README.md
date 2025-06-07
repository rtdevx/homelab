## Bootstrapping ansible nodes

#### 1. Add new nodes to ./inventory/bootstrap.yml

#### 2. Run ansible playbook with --ask-become-pass

```bash
ansible-playbook --ask-become-pass ./bootstrap/bootstrap.yml -i ./inventory/site/bootstrap.yml
```

#### 3. Update appropriate inventory file to include new hosts.

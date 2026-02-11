#!/usr/bin/env bash

SSH_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn55Ck/aZ/UdRTpw1DN9iGNBIksbvwjBGWWkdQ2QzRl robk"

reload_sshd() {

    ssh_daemon="ssh"

    # Reload ssh / sshd daemon
    if systemctl status "$ssh_daemon" >/dev/null 2>&1; then
        echo "Reloading ssh"
        sudo systemctl reload $ssh_daemon
        systemctl status "$ssh_daemon"
    else
        echo "Reloading sshd"
        ssh_daemon=sshd
        sudo systemctl reload $ssh_daemon
        systemctl status "$ssh_daemon"
    fi

}

ssh_configure() {
    local sshd_config="/etc/ssh/sshd_config"
    
echo "------------------------------------------------"
echo "Configuring SSH: Disable Password Authentication"
echo "------------------------------------------------"

    # Only if $sshd_config file exist
    if [ -f "$sshd_config" ]; then

        echo "Disabling Password Authentication"
        sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' "$sshd_config"
        sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$sshd_config"
    
        sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' "$sshd_config"
        sudo sed -i 's/^ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' "$sshd_config" 

        echo "Disabling root login"
        sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
        sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config   


        # Reload ssh / sshd daemon
        reload_sshd

        else

        echo "Password Authentication already disabled OR sshd is not installed."
        
    fi
}

ssh_provision_keys() {

echo "-----------------------------------"
echo "Configuring SSH: Provision SSH keys"
echo "-----------------------------------"

    for user in "${USERS[@]}"; do # $USERS defined in functions/users.sh

        # Skip is user doesn't exist
        if ! id "$user" >/dev/null 2>&1; then
            echo ">> Skipping SSH config for '$user' (user doestn't exist)"
            continue
        fi

        local home_dir=$(eval echo "~$user")
        local ssh_dir="$home_dir/.ssh"
        local auth_keys="$ssh_dir/authorized_keys"

        echo ">> Configuring user: $user"

        # Create .ssh folder if it's missing
        if [[ ! -d "$ssh_dir" ]]; then

            sudo mkdir -p "$ssh_dir"
            sudo chown "$user:$user" "$ssh_dir"
            sudo chmod 700 "$ssh_dir"

        else

        echo -e "$ssh_dir for user: $user already exists, skipping..."

        fi

        echo "Creating '$auth_keys'"

        # Create auth_keys if missing
        if [[ ! -f "$auth_keys" ]]; then

            sudo touch "$auth_keys"
            sudo chown "$user:$user" "$auth_keys"
            sudo chmod 600 "$auth_keys"

       else

       echo "$auth_keys for user: $user already exist, skipping..."              

       fi

       # Add key if not already present
       if ! sudo grep -qxF "$SSH_PUBLIC_KEY" "$auth_keys"; then # q=quiet, x=match whole line, F=literal match

       echo "Adding $auth_keys for user: $user"
       echo "$SSH_PUBLIC_KEY" | sudo tee -a "$auth_keys" >/dev/null
       sudo chown "$user:$user" "$auth_keys"

       else

       echo "SSH key already present for user: $user"
       
       fi

    done

}

ssh_disable_root() {

echo "-------------------------------------"
echo "Configuring SSH: Disable SSH for root"
echo "-------------------------------------"

    if [[ -f "$sshd_config" ]]; then

        sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' "$sshd_config"
        sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' "$sshd_config"
    
        # Reload ssh / sshd daemon
        reload_sshd

    else

        echo "root access already disabled OR sshd is not installed."

    fi

}
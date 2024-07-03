#!/bin/bash

mkdir -p /var/log /var/secure

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Function to create a user and the associated groups
create_user() {
  local username=$1
  local groups=$2

  # Create personal group if it doesn't exist
  if ! getent group "$username" &>/dev/null; then
    groupadd "$username"
    echo "Created group $username." | tee -a "$LOG_FILE"
  fi

  # Check if user already exists
  if id "$username" &>/dev/null; then
    echo "User '$username' exists" | tee -a "$LOG_FILE"
  else
    # Create user with personal group
    useradd -m -g "$username" "$username"
    echo "Created user $username with group $username." | tee -a "$LOG_FILE"

    # Generate random password and store securely
    password=$(openssl rand -base64 12)
    echo "$username:$password" >> "$PASSWORD_FILE"
    echo "Generated password for $username and stored in $PASSWORD_FILE." | tee -a "$LOG_FILE"

    # Set permissions for home directory
    chmod 700 "/home/$username"
    chown "$username:$username" "/home/$username"

    echo "Successfully configured user $username." | tee -a "$LOG_FILE"
  fi

  # Add additional groups if provided
  IFS=',' read -ra user_groups <<< "$groups"
  for group in "${user_groups[@]}"; do
    group=$(echo "$group" | xargs) # Trim whitespace
    if ! getent group "$group" &>/dev/null; then
      groupadd "$group"
      echo "Created group $group." | tee -a "$LOG_FILE"
    fi
    if id -nG "$username" | grep -qw "$group"; then
      echo "  - Belongs to group: $group" | tee -a "$LOG_FILE"
    else
      usermod -aG "$group" "$username"
      echo "Added user $username to group $group." | tee -a "$LOG_FILE"
      echo "  - Does NOT belong to group: $group" | tee -a "$LOG_FILE"
    fi
  done
}

# Main script starts here
input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Error: Input file $input_file not found." >&2
    exit 1
fi

while IFS=';' read -r username groups; do
  # Trim any leading/trailing whitespace from username and groups
  username=$(echo "$username" | xargs)
  groups=$(echo "$groups" | xargs)

  if [ -n "$username" ]; then
    create_user "$username" "$groups"
  else
    echo "User '$username' does not exist" | tee -a "$LOG_FILE"
  fi
done < "$input_file"

exit 0

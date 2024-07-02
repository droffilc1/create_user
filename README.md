# Automating User and Group Management

## **Set Up a Test Environment**

Create a test environment to avoid making changes to your production system. You can use a virtual machine, a Docker container, or a dedicated test server.

### Using Docker:

Create a Docker container with a suitable Linux image.

```bash
docker run -it --name user-management-test ubuntu:latest /bin/bash
```

Inside the container, install necessary tools:

```bash
sudo apt-get update
sudo apt-get install -y sudo openssl
```

## **Prepare the Input File**

Create a sample `employees.txt` file with test data.

```bash
cat <<EOF > employees.txt
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
EOF
```

## **Run the Script**

Make the script executable and run it.

```bash
chmod +x create_users.sh
sudo bash create_user.sh <name-of-text-file>
```

## **Verify the Output**

- **Check the Log File**: Review `/var/log/user_management.log` for logged actions and any errors.
  ```bash
  cat /var/log/user_management.log
  ```
- **Check Password Storage**: Verify that passwords are stored in `/var/secure/user_passwords.txt`.
  ```bash
  cat /var/secure/user_passwords.txt
  ```
- **Check User and Group Creation**: Verify that users and groups have been created as expected.
  ```bash
  getent passwd | grep -E "light|idimma|mayowa"
  getent group | grep -E "light|idimma|mayowa|sudo|dev|www-data"
  ```
- **Check Home Directories**: Ensure home directories exist with correct permissions and ownership.
  ```bash
  ls -ld /home/light /home/idimma /home/mayowa
  ```

## **Test Error Handling**

- **Existing Users/Groups**: Run the script again to see how it handles existing users/groups.
  ```bash
  sudo bash create_user.sh <name-of-text-file>
  ```
  Check the log file for appropriate error messages.

## **Clean Up**

After testing, you may want to clean up the test environment:

```bash
userdel -r light
userdel -r idimma
userdel -r mayowa
groupdel www-data
groupdel light
groupdel idimma
groupdel mayowa
rm /var/log/user_management.log
rm /var/secure/user_passwords.txt
```

More details on how the script works can be found on this [article](https://cliffordmapesa.hashnode.dev/automating-user-and-group-management-with-bash-script)

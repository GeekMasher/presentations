import hashlib


def hashData(data: str) -> str:
    hashobj = hashlib.sha1(data.encode())
    digest = hashobj.hexdigest()
    return digest


d = hashData("This is my testing string")
print(d)


# hashlib.sha256(data.encode())

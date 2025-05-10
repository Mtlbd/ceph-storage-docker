# 🐳 Deploying Ceph Cluster using Docker Containers

> This guide demonstrates deploying a **Ceph cluster using Docker containers** on Ubuntu. Ideal for testing and educational purposes.

---

## ⚙️ Prerequisites
Install Docker and necessary tools on all nodes:

```bash
sudo apt update
sudo apt install -y docker.io lvm2
sudo systemctl enable --now docker
```

> 💡 Ensure each node has 2 disks: one for OS and one (e.g., `/dev/sdb`) for Ceph OSD.

---

## 📍 IP and Hostname Planning
Update `/etc/hosts` on all nodes:

```
192.168.1.31    ceph-admin
192.168.1.32    ceph-n1
192.168.1.33    ceph-n2
192.168.1.34    ceph-n3
```

---

## 1️⃣ Run MON & MGR in a Container on Admin Node

### Create a Docker volume:
```bash
docker volume create ceph-data
```

### Start MON and MGR:
```bash
docker run -d \
  --name=ceph-mon \
  --net=host \
  --restart=always \
  -v ceph-data:/var/lib/ceph \
  -e MON_IP=192.168.1.31 \
  -e CEPH_PUBLIC_NETWORK=192.168.1.0/24 \
  ceph/ceph:v17.2 mon

# Create manager

docker run -d \
  --name=ceph-mgr \
  --net=host \
  --restart=always \
  -v ceph-data:/var/lib/ceph \
  ceph/ceph:v17.2 mgr
```

---

## 2️⃣ Add OSD Containers on Worker Nodes
Repeat this on each node (`ceph-n1`, `ceph-n2`, ...):

```bash
docker volume create ceph-osd

docker run -d \
  --name=ceph-osd \
  --net=host \
  --privileged \
  --restart=always \
  -v ceph-osd:/var/lib/ceph \
  -v /dev:/dev \
  ceph/ceph:v17.2 osd
```

> Replace `/dev/sdb` as needed depending on your actual block device.

---

## 3️⃣ Enable Dashboard (Optional)
On the admin node:
```bash
docker exec ceph-mgr ceph mgr module enable dashboard

docker exec ceph-mgr ceph dashboard create-self-signed-cert

docker exec ceph-mgr ceph dashboard set-login-credentials admin admin123
```

Access dashboard via: `http://192.168.1.31:8443`

---

## 4️⃣ RGW (Optional Object Gateway)
Start RGW in a container:
```bash
docker run -d \
  --name=ceph-rgw \
  --net=host \
  --restart=always \
  -v ceph-data:/var/lib/ceph \
  ceph/ceph:v17.2 rgw

# Create S3 user:
docker exec ceph-rgw radosgw-admin user create --uid=admin --display-name="Admin" --system
```

---

## 🔍 Check Cluster Health
```bash
docker exec ceph-mon ceph -s
```

---

## 📌 Notes
- This setup is good for lab/test environments.
- For production, use `cephadm` or bare-metal orchestration.

---

> Created by [Mohammad Talebi](https://linkedin.com/in/mtlbd) – DevOps Engineer 👨‍💻

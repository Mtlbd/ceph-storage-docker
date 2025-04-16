# Base image
FROM ceph/ceph:v17.2

# Set environment variables (override when running)
ENV MON_IP=127.0.0.1
ENV CEPH_PUBLIC_NETWORK=192.168.1.0/24
ENV NODE_TYPE=mon

# Default command
CMD ["/usr/bin/bash"]

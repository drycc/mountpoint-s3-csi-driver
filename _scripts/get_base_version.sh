echo $(curl -Ls https://github.com/awslabs/mountpoint-s3-csi-driver/releases | grep /awslabs/mountpoint-s3-csi-driver/releases/tag/ \
    | grep -o 'href="/awslabs/mountpoint-s3-csi-driver/releases/tag/[^"]*"' \
    | sed 's|href="/awslabs/mountpoint-s3-csi-driver/releases/tag/||; s/"$//' \
    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -Vr \
    | head -1)

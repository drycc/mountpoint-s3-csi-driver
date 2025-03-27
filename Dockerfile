FROM public.ecr.aws/mountpoint-s3-csi-driver/aws-mountpoint-s3-csi-driver:v1.13.0

RUN mv /mountpoint-s3/bin/mount-s3 /mountpoint-s3/bin/mount-s3-raw

ADD rootfs /



# AWS S3 Mount Helper

This is a simple helper script that allows you to mount an AWS S3 bucket using the `mount-s3` program. It handles the AWS access key and secret key separately, and passes all other arguments directly to the `mount-s3` program.

## Usage

Use custom images packaged here:

```
helm repo add aws-mountpoint-s3-csi-driver https://awslabs.github.io/mountpoint-s3-csi-driver
helm repo update
helm upgrade --install aws-mountpoint-s3-csi-driver \
    --namespace kube-system \
    --set experimental.podMounter=true \
    --set image.repository=registry.drycc.cc/drycc/mountpoint-s3-csi-driver \
    --set image.tag=1.13.0 \
    aws-mountpoint-s3-csi-driver/aws-mountpoint-s3-csi-driver
```

Create PVC that supports custom endpoints and keys, for example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: s3-pv
spec:
  capacity:
    storage: 1200Gi # ignored, required
  accessModes:
    - ReadWriteMany # supported options: ReadWriteMany / ReadOnlyMany
  storageClassName: "" # Required for static provisioning
  claimRef: # To ensure no other PVCs can claim this PV
    namespace: default # Namespace is required even though it's in "default" namespace.
    name: s3-pvc # Name of your PVC
  mountOptions:
    - allow-delete
    - force-path-style
    - aws-access-key-id Q3AM3UQ867SPQQA43P2F
    - aws-secret-access-key zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG
    - endpoint-url https://play.min.io
  csi:
    driver: s3.csi.aws.com # required
    volumeHandle: s3-csi-driver-volume # Must be unique
    volumeAttributes:
      bucketName: builds
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: s3-pvc
spec:
  accessModes:
    - ReadWriteMany # Supported options: ReadWriteMany / ReadOnlyMany
  storageClassName: "" # Required for static provisioning
  resources:
    requests:
      storage: 1200Gi # Ignored, required
  volumeName: s3-pv # Name of your PV
```

The original `aws-mountpoint-s3-csi-driver` image did not support passing `aws-access-key-id` and `aws-secret-access-key` through mountOptions; the wrapped image now supports these two parameters.

## Example

```
mount-s3 --aws-access-key-id AKIAIOSFODNN7EXAMPLE --aws-secret-access-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY -o loop --debug
```

This will mount an S3 bucket using the specified AWS credentials, with the additional options `-o loop --debug` passed to the `mount-s3` program.

## How it works

The `mount-s3` script defines a function `parse_args` that parses the command line arguments. It separates the `--aws-access-key-id` and `--aws-secret-access-key` arguments and stores their values in environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, respectively. All other arguments are stored in an array `OTHER_ARGS`.

After setting the environment variables, the script uses the `exec` command to run the `mount-s3` program, passing the arguments stored in the `OTHER_ARGS` array. The `exec` command replaces the current process with the `mount-s3` process, ensuring a clean process tree and proper signal handling.

## Requirements

- The `mount-s3` program must be installed and available in the system's `PATH`.
- The script assumes that the AWS access key ID and secret access key are provided as command line arguments.

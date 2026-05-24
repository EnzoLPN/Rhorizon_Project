serviceAccount:
  create: true
  name: fluent-bit
  annotations:
    eks.amazonaws.com/role-arn: "${FLUENT_BIT_ROLE_ARN}"

config:
  inputs: |
    [INPUT]
        Name            tail
        Tag             kube.*
        Path            /var/log/containers/*.log
        Parser          docker
        DB              /var/log/flb_kube.db
        Mem_Buf_Limit   5MB
        Skip_Long_Lines On

  filters: |
    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Kube_Tag_Prefix     kube.var.log.containers.
        Merge_Log           On
        Keep_Log            Off
        K8S-Logging.Parser  On
        K8S-Logging.Exclude On

  outputs: |
    [OUTPUT]
        Name            cloudwatch_logs
        Match           kube.*
        region          ${AWS_REGION}
        log_group_name  /eks/rhzorion/${ENVIRONMENT}/applications
        log_stream_prefix fluent-bit-
        auto_create_group true

    [OUTPUT]
        Name            s3
        Match           kube.*
        bucket          ${LOGS_BUCKET_NAME}
        region          ${AWS_REGION}
        s3_key_format   /eks/${ENVIRONMENT}/%Y/%m/%d/%H-%M-%S-$UUID.gz
        store_dir       /tmp/fluent-bit/s3
        upload_timeout  1m
